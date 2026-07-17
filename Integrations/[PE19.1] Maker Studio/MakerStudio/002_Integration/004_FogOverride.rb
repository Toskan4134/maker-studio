#===============================================================================
# MakerStudio - Graphic Layer Groups (Fog / Panorama / Custom) Override
# Renders the Maker Studio graphic layer groups as Plane sprites:
#   - fogLayers          at viewport z = 3000  (above all tiles/events)
#   - panoramaLayers     at viewport z = -1000 (beneath all tiles)
#   - customLayerGroups  at viewport z = group "priority" (mod-defined)
# Every layer shares the same config: graphic, hue, opacity, blend_type, zoom,
# sx/sy scroll, follow_player, parallax. Groups are clipped to each map's
# boundaries using a per-map per-group Viewport so connected maps don't overlap.
#
# Scroll convention: positive sx = layer moves right, positive sy = down.
# Camera follow: follow_player = screen-locked. Otherwise the "parallax"
# factor scales camera tracking: 1 = world-anchored (moves 1:1 with the map,
# classic fog), 0.5 = RMXP native panorama half-speed, 0 = screen-locked.
#
# Sprites are created for ALL maps in the map factory and remain visible for
# all connected maps (not just the current game map). Each map's Viewports clip
# its layers to that map's bounds. Scroll offsets persist across
# map-connection transitions.
#
# Written to stay Ruby 1.8-compatible so the SAME file works in every
# framework build (BES5 / LBDS / PE21).
#===============================================================================
module MakerStudio
  FOG_DIR = File.join("Graphics", "Fogs")
  PANORAMA_DIR = File.join("Graphics", "Panoramas")
  FOG_GROUP_Z = 3000
  PANORAMA_GROUP_Z = -1000

  # Module-level sprite cache — { map_id => [plane_sprite, ...] } (all groups)
  @fog_sprites_cache = {}
  # Per-map per-group viewports for clipping — { map_id => { group_key => Viewport } }
  @fog_viewports_cache = {}
  # Per-layer scroll offsets — { "group_key:layer_id" => { :ox => 0, :oy => 0 } }
  @fog_scroll_offsets = {}

  module_function

  # The engine's map factory ($map_factory in Essentials v19+/LBDS,
  # $MapFactory in BES/v16). Nil when no factory is alive.
  def ms_map_factory
    return $map_factory if defined?($map_factory) && $map_factory
    return $MapFactory if defined?($MapFactory) && $MapFactory
    nil
  end

  #---------------------------------------------------------------------------
  # Resolve a map's renderable graphic layer groups from its extended data.
  # Returns an array of [group_key, viewport_z, graphics_dir, layers].
  #---------------------------------------------------------------------------
  def plane_groups_for(ext_data)
    groups = []
    fogs = ext_data["fogLayers"]
    if fogs && !fogs.empty?
      groups.push(["fog", FOG_GROUP_Z, FOG_DIR, fogs])
    end
    panos = ext_data["panoramaLayers"]
    if panos && !panos.empty?
      groups.push(["panorama", PANORAMA_GROUP_Z, PANORAMA_DIR, panos])
    end
    customs = ext_data["customLayerGroups"]
    if customs
      customs.each do |g|
        next unless g
        layers = g["layers"]
        next unless layers && !layers.empty?
        key = g["key"]
        next if key.nil? || key.empty? || key == "fog" || key == "panorama"
        folder = g["folder"]
        # Single path component only — never honour traversal from map data.
        next if folder.nil? || folder.empty?
        next if folder.include?("/") || folder.include?("\\") || folder.include?("..") || folder.include?(":")
        groups.push([key, (g["priority"] || 0).to_i, File.join("Graphics", folder), layers])
      end
    end
    groups
  end

  #---------------------------------------------------------------------------
  # Create the graphic-group sprites for a map from extended data.
  # Skips creation if sprites already exist (preserves scroll offsets across
  # map-connection transitions). Layers are visible for all factory maps.
  #---------------------------------------------------------------------------
  def create_fog_sprites_for_map(map_id, map)
    # Skip if sprites already exist — preserves scroll offsets and avoids
    # expensive bitmap reload on map-connection transitions.
    existing = @fog_sprites_cache[map_id]
    return if existing && !existing.empty?

    ext_data = @extended_data_cache[map_id]
    return unless ext_data
    groups = plane_groups_for(ext_data)
    return if groups.empty?

    sprites = []
    viewports = {}
    groups.each do |group|
      group_key = group[0]
      group_z   = group[1]
      dir       = group[2]
      layers    = group[3]

      # Clipping viewport, one per group so each group sits at its own z.
      # Sized to the SCREEN, not to the map: a Plane fills its whole viewport
      # rect, so a map-sized viewport made every fog/panorama layer draw a
      # map-sized surface (a 500x500 map = 16000x16000 px) every frame, most of
      # it off-camera. update_fog_sprites re-clips it to the visible part of the
      # map each frame and shifts the plane to compensate.
      vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
      vp.z = group_z
      vp.visible = true
      viewports[group_key] = vp

      layers.each do |layer|
        next unless layer["visible"] != false
        config = layer["config"] || {}
        graphic_name = config["graphicName"]
        next if graphic_name.nil? || graphic_name.empty?

        # Load layer bitmap
        path = find_group_graphic(dir, graphic_name)
        next unless path

        begin
          bmp = Bitmap.new(path)
        rescue
          next
        end

        # Apply hue rotation if needed
        hue = (config["hue"] || 0).to_i
        bmp.hue_change(hue) if hue != 0

        # Create Plane sprite clipped to the group viewport
        sprite = Plane.new(vp)
        sprite.bitmap = bmp
        sprite.z = 0
        sprite.opacity = (layer["opacity"] || 255).to_i
        sprite.blend_type = (config["blendType"] || 0).to_i

        zoom = (config["zoom"] || 1.0).to_f
        zoom = 0.1 if zoom < 0.1
        sprite.zoom_x = zoom
        sprite.zoom_y = zoom

        # Store metadata on the sprite for update loop
        layer_id = layer["id"]
        sprite.instance_variable_set(:@fog_id, layer_id)
        sprite.instance_variable_set(:@ms_group, group_key)
        sprite.instance_variable_set(:@fog_sx, (config["sx"] || 0).to_f)
        sprite.instance_variable_set(:@fog_sy, (config["sy"] || 0).to_f)
        sprite.instance_variable_set(:@fog_follow, config["followPlayer"] == true)
        par = config["parallax"]
        sprite.instance_variable_set(:@ms_parallax, par.nil? ? 1.0 : par.to_f)
        sprite.instance_variable_set(:@map_id, map_id)

        # Initialize scroll offset (preserve if already exists for transitions)
        scroll_key = "#{group_key}:#{layer_id}"
        @fog_scroll_offsets[scroll_key] ||= { :ox => 0, :oy => 0 }

        sprite.visible = true

        sprites.push(sprite)
      end
    end

    @fog_sprites_cache[map_id] = sprites
    @fog_viewports_cache[map_id] = viewports
  end

  #---------------------------------------------------------------------------
  # Update group sprites (scroll animation + viewport tracking)
  # Shows layers for ALL maps in the factory (not just current).
  # Each map's viewports clip its layers to that map's bounds.
  #---------------------------------------------------------------------------
  def update_fog_sprites
    return if @fog_sprites_cache.empty?
    factory = ms_map_factory
    return unless factory

    # Build set of factory map IDs for visibility toggling
    factory_maps = {}
    factory.maps.each do |map|
      next unless map
      factory_maps[map.map_id] = map
    end

    @fog_sprites_cache.each do |map_id, sprites|
      next if sprites.nil? || sprites.empty?
      map = factory_maps[map_id]
      in_factory = !!map

      # Where this map sits on screen, and how much of it the camera actually
      # sees. The viewport is clipped to that intersection, so each layer paints
      # at most one screenful — never the whole map.
      clip_dx = 0
      clip_dy = 0
      on_screen = false
      if in_factory
        vx = -(map.display_x / 4.0).round
        vy = -(map.display_y / 4.0).round
        cx = [vx, 0].max
        cy = [vy, 0].max
        cw = [vx + (map.width * 32), Graphics.width].min - cx
        ch = [vy + (map.height * 32), Graphics.height].min - cy
        on_screen = cw > 0 && ch > 0
        # Pixels of the map clipped off the left/top edge: the plane's pattern
        # has to shift by the same amount to stay anchored to the map.
        clip_dx = cx - vx
        clip_dy = cy - vy
      end

      vps = @fog_viewports_cache[map_id]
      if vps
        vps.each do |group_key, vp|
          next if vp.nil? || vp.disposed?
          if on_screen
            vp.rect.set(cx, cy, cw, ch)
            # Apply screen shake so layers wobble with the map. viewport1
            # receives `+= $game_screen.shake` in Spriteset_Map; these
            # viewports are separate so we must re-apply it here ourselves.
            vp.ox = $game_screen ? $game_screen.shake : 0
            vp.visible = true
          else
            vp.visible = false
          end
        end
      end

      sprites.each do |sprite|
        next if sprite.nil? || sprite.disposed?

        # Hide layers for maps that left the factory or are fully off-camera.
        sprite.visible = on_screen
        next unless in_factory

        layer_id = sprite.instance_variable_get(:@fog_id)
        next unless layer_id
        group_key = sprite.instance_variable_get(:@ms_group) || "fog"
        sx = sprite.instance_variable_get(:@fog_sx) || 0
        sy = sprite.instance_variable_get(:@fog_sy) || 0
        follow = sprite.instance_variable_get(:@fog_follow)
        par = sprite.instance_variable_get(:@ms_parallax)

        # Accumulate scroll.
        # Plane.ox positive shifts pattern LEFT, so negate sx/sy so that
        # positive values move the layer RIGHT / DOWN (matching editor).
        # Accumulated for every factory map, on-camera or not, so a layer's scroll
        # phase doesn't depend on which maps happen to be visible.
        scroll = @fog_scroll_offsets["#{group_key}:#{layer_id}"]
        if scroll
          scroll[:ox] -= sx * 0.1667 if sx != 0
          scroll[:oy] -= sy * 0.1667 if sy != 0
        end
        next unless on_screen

        # Camera-follow with a camera-tracking viewport. The viewport moves
        # with the camera (vx = -display_x/4); Plane.ox is relative to it.
        # Generalised over the parallax factor p (0 = screen-locked, 1 =
        # world-anchored, 0.5 = native RMXP panorama):
        #   Plane.ox = -(display_x/4) * (1 - p) + scroll
        #   p=1 -> ox = scroll                (viewport handles positioning)
        #   p=0 -> ox = -(display_x/4)+scroll (fixed on screen)
        p = follow ? 0.0 : (par.nil? ? 1.0 : par.to_f)
        comp = 1.0 - p
        # clip_dx/clip_dy re-anchor the pattern after the viewport was clipped to
        # the visible part of the map (its origin moved right/down by that much).
        sprite.ox = -(map.display_x / 4.0) * comp + clip_dx + (scroll ? scroll[:ox] : 0)
        sprite.oy = -(map.display_y / 4.0) * comp + clip_dy + (scroll ? scroll[:oy] : 0)
      end
    end
  end

  #---------------------------------------------------------------------------
  # Dispose group sprites and viewports for a map
  #---------------------------------------------------------------------------
  def dispose_fog_sprites(map_id)
    sprites = @fog_sprites_cache.delete(map_id)
    if sprites
      sprites.each do |sprite|
        next if sprite.nil? || sprite.disposed?
        sprite.bitmap.dispose if sprite.bitmap
        sprite.dispose
      end
    end
    vps = @fog_viewports_cache.delete(map_id)
    if vps
      vps.each do |group_key, vp|
        vp.dispose if vp && !vp.disposed?
      end
    end
  end

  #---------------------------------------------------------------------------
  # Dispose all group sprites and viewports
  #---------------------------------------------------------------------------
  def dispose_all_fog_sprites
    @fog_sprites_cache.keys.each do |map_id|
      dispose_fog_sprites(map_id)
    end
    @fog_scroll_offsets.clear
  end

  #---------------------------------------------------------------------------
  # Find a group graphic file in `dir` (case-insensitive, multiple extensions)
  #---------------------------------------------------------------------------
  def find_group_graphic(dir, name)
    extensions = [".png", ".bmp", ".gif", ".jpg", ".jpeg"]

    # Try exact name with extensions
    extensions.each do |ext|
      path = File.join(dir, name + ext)
      return path if File.exist?(path)
    end

    # Case-insensitive search
    if File.directory?(dir)
      Dir.entries(dir).each do |entry|
        next if entry[0, 1] == "."   # 1.8-safe (no String#start_with?)
        ext = File.extname(entry)
        base = File.basename(entry, ".*")
        if base.downcase == name.downcase && extensions.include?(ext.downcase)
          return File.join(dir, entry)
        end
      end
    end

    return nil
  end

  # Back-compat helper (008_FogCommands and older code look fogs up here).
  def find_fog_graphic(name)
    find_group_graphic(FOG_DIR, name)
  end
end
