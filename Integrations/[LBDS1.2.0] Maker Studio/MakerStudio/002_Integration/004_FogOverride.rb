#===============================================================================
# MakerStudio - Fog Override
# Extends TilemapRenderer to render multiple fog layers per map.
# Each fog has: graphic, hue, opacity, blend_type, zoom, sx/sy scroll, follow_player.
# Fogs render at z=3000 (above all tiles/events), clipped to each map's
# boundaries using a Viewport so connected maps don't show fog overflow.
#
# Scroll convention: positive sx = fog moves right, positive sy = fog moves down.
# Follow camera: checked = screen-locked (fog stays on screen as camera moves).
#   unchecked = world-anchored (fog is fixed in the world, scrolls off screen).
#
# Fog sprites are created for ALL maps in $map_factory and remain visible for
# all connected maps (not just the current game map). Each map's Viewport clips
# its fog to that map's bounds so fogs don't overlap between connected maps.
# Scroll offsets persist across map-connection transitions.
#===============================================================================
module MakerStudio
  FOG_DIR = File.join("Graphics", "Fogs")

  # Module-level fog sprite cache — { map_id => [fog_sprite, ...] }
  @fog_sprites_cache = {}
  # Per-map viewports for fog clipping — { map_id => Viewport }
  @fog_viewports_cache = {}
  # Per-fog scroll offsets — { fog_id => { ox: 0, oy: 0 } }
  @fog_scroll_offsets = {}

  module_function

  #---------------------------------------------------------------------------
  # Create fog sprites for a map from extended data.
  # Skips creation if sprites already exist (preserves scroll offsets across
  # map-connection transitions). Fog is visible for all factory maps.
  #---------------------------------------------------------------------------
  def create_fog_sprites_for_map(map_id, map)
    # Skip if sprites already exist — preserves scroll offsets and avoids
    # expensive bitmap reload on map-connection transitions.
    existing = @fog_sprites_cache[map_id]
    return if existing && !existing.empty?

    ext_data = @extended_data_cache[map_id]
    return unless ext_data
    fog_layers = ext_data["fogLayers"]
    return unless fog_layers && !fog_layers.empty?

    # Create clipping viewport sized to the map.
    # Position set to (0,0) initially — update_fog_sprites corrects it each frame.
    fog_vp = Viewport.new(0, 0, map.width * 32, map.height * 32)
    fog_vp.z = 3000
    fog_vp.visible = true

    sprites = []
    fog_layers.each do |fog|
      next unless fog["visible"] != false
      config = fog["config"] || {}
      graphic_name = config["graphicName"]
      next if graphic_name.nil? || graphic_name.empty?

      # Load fog bitmap
      fog_path = find_fog_graphic(graphic_name)
      next unless fog_path

      begin
        bmp = Bitmap.new(fog_path)
      rescue
        next
      end

      # Apply hue rotation if needed
      hue = (config["hue"] || 0).to_i
      bmp.hue_change(hue) if hue != 0

      # Create Plane sprite clipped to the map viewport
      sprite = Plane.new(fog_vp)
      sprite.bitmap = bmp
      sprite.z = 0
      sprite.opacity = (fog["opacity"] || 255).to_i
      sprite.blend_type = (config["blendType"] || 0).to_i

      zoom = (config["zoom"] || 1.0).to_f
      zoom = 0.1 if zoom < 0.1
      sprite.zoom_x = zoom
      sprite.zoom_y = zoom

      # Store metadata on the sprite for update loop
      fog_id = fog["id"]
      sprite.instance_variable_set(:@fog_id, fog_id)
      sprite.instance_variable_set(:@fog_sx, (config["sx"] || 0).to_f)
      sprite.instance_variable_set(:@fog_sy, (config["sy"] || 0).to_f)
      sprite.instance_variable_set(:@fog_follow, config["followPlayer"] == true)
      sprite.instance_variable_set(:@map_id, map_id)

      # Initialize scroll offset (preserve if already exists for transitions)
      @fog_scroll_offsets[fog_id] ||= { ox: 0, oy: 0 }

      sprite.visible = true

      sprites.push(sprite)
    end

    @fog_sprites_cache[map_id] = sprites
    @fog_viewports_cache[map_id] = fog_vp
  end

  #---------------------------------------------------------------------------
  # Update fog sprites (scroll animation + viewport tracking)
  # Shows fog for ALL maps in $map_factory (not just current).
  # Each map's viewport clips its fog to that map's bounds.
  #---------------------------------------------------------------------------
  def update_fog_sprites
    return if @fog_sprites_cache.empty?
    return unless $map_factory

    # Build set of factory map IDs for visibility toggling
    factory_maps = {}
    $map_factory.maps.each do |map|
      next unless map
      factory_maps[map.map_id] = map
    end

    @fog_sprites_cache.each do |map_id, sprites|
      next if sprites.nil? || sprites.empty?
      map = factory_maps[map_id]
      in_factory = !!map

      # Update the clipping viewport to track the map's screen position
      vp = @fog_viewports_cache[map_id]
      if vp && !vp.disposed?
        if in_factory
          vx = -(map.display_x / 4.0).round
          vy = -(map.display_y / 4.0).round
          vp.rect.set(vx, vy, map.width * 32, map.height * 32)
          # Apply screen shake so fogs wobble with the map. viewport1 receives
          # `+= $game_screen.shake` in Spriteset_Map; the fog viewport is
          # separate so we must re-apply it here ourselves.
          vp.ox = $game_screen ? $game_screen.shake : 0
          vp.visible = true
        else
          vp.visible = false
        end
      end

      sprites.each do |sprite|
        next if sprite.nil? || sprite.disposed?

        # Hide fog for maps that left the factory
        sprite.visible = in_factory
        next unless in_factory

        fog_id = sprite.instance_variable_get(:@fog_id)
        next unless fog_id
        fog_sx = sprite.instance_variable_get(:@fog_sx) || 0
        fog_sy = sprite.instance_variable_get(:@fog_sy) || 0
        fog_follow = sprite.instance_variable_get(:@fog_follow)

        # Accumulate scroll.
        # Plane.ox positive shifts pattern LEFT, so negate sx/sy so that
        # positive values move the fog RIGHT / DOWN (matching editor).
        scroll = @fog_scroll_offsets[fog_id]
        if scroll
          scroll[:ox] -= fog_sx * 0.1667 if fog_sx != 0
          scroll[:oy] -= fog_sy * 0.1667 if fog_sy != 0
        end

        # Follow-camera logic with camera-tracking viewport:
        # The viewport moves with the camera (vx = -display_x/4).
        # Plane.ox is relative to the viewport's content area.
        #
        # Screen-locked (fog_follow=true): viewport moves with camera, pattern
        #   at fixed viewport-relative position → stays fixed on screen.
        #   Plane.ox = scroll
        #
        # World-anchored (fog_follow=false): compensate for viewport movement
        #   so pattern stays at the same world position.
        #   Plane.ox = display_x/4 + scroll
        if fog_follow
          # Screen-locked: compensate viewport movement so fog stays on screen
          sprite.ox = -(map.display_x / 4.0) + (scroll ? scroll[:ox] : 0)
          sprite.oy = -(map.display_y / 4.0) + (scroll ? scroll[:oy] : 0)
        else
          # World-anchored: viewport handles positioning, pattern stays in viewport
          sprite.ox = scroll ? scroll[:ox] : 0
          sprite.oy = scroll ? scroll[:oy] : 0
        end
      end
    end
  end

  #---------------------------------------------------------------------------
  # Dispose fog sprites and viewport for a map
  #---------------------------------------------------------------------------
  def dispose_fog_sprites(map_id)
    sprites = @fog_sprites_cache.delete(map_id)
    if sprites
      sprites.each do |sprite|
        next if sprite.nil? || sprite.disposed?
        sprite.bitmap&.dispose
        sprite.dispose
      end
    end
    vp = @fog_viewports_cache.delete(map_id)
    vp&.dispose
  end

  #---------------------------------------------------------------------------
  # Dispose all fog sprites and viewports
  #---------------------------------------------------------------------------
  def dispose_all_fog_sprites
    @fog_sprites_cache.keys.each do |map_id|
      dispose_fog_sprites(map_id)
    end
    @fog_scroll_offsets.clear
  end

  #---------------------------------------------------------------------------
  # Find fog graphic file (case-insensitive, multiple extensions)
  #---------------------------------------------------------------------------
  def find_fog_graphic(name)
    extensions = [".png", ".bmp", ".gif", ".jpg", ".jpeg"]
    dir = File.join(FOG_DIR)

    # Try exact name with extensions
    extensions.each do |ext|
      path = File.join(dir, name + ext)
      return path if File.exist?(path)
    end

    # Case-insensitive search
    if File.directory?(dir)
      Dir.entries(dir).each do |entry|
        next if entry.start_with?(".")
        ext = File.extname(entry)
        base = File.basename(entry, ".*")
        if base.downcase == name.downcase && extensions.include?(ext.downcase)
          return File.join(dir, entry)
        end
      end
    end

    return nil
  end
end
