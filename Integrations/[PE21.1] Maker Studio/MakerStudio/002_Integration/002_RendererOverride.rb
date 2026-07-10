#===============================================================================
# MakerStudio - Renderer Override
# Extends TilemapRenderer to render extended layers (3, 4, 5...) as separate
# layers per map. Also applies per-tile properties to native layers.
# Supports map connections, tone/color filters, and z-ordering that follows
# the native priority system.
#===============================================================================
module MakerStudio
  #---------------------------------------------------------------------------
  # Module-level state — hash of { map_id => extended_data }
  #---------------------------------------------------------------------------
  @extended_data_cache = {}
  # Cache for extra autotile bitmaps (by name)
  @extra_autotile_cache = {}
  # Cache for extra tileset bitmaps (by tileset name)
  @extra_tileset_cache = {}
  # Cache for shadow layer bitmaps (by shadow layer id + map_id) — value is
  # [bitmap, frame_count, frame_w] when the shadow contains animated autotiles.
  @shadow_bitmap_cache = {}
  # Shared timer for shadow frame animation
  @shadow_timer_start = nil
  # Cache for shadow source tile positions per map (avoids rebuilding every frame)
  # Value is { map_w: Integer, source_keys: { (y*map_w+x) => tile_id } } —
  # integer keys avoid per-frame string allocation in adjust_ground_z_for_shadows.
  @shadow_source_tiles_cache = {}
  # Cache for pre-tinted 32×32 tile silhouettes used by shadow generation.
  # Keyed by tile identity + frame + tint hex; survives across all shadows on
  # all maps in the session so the costly per-pixel tint loop runs at most once
  # per (tile, tint, frame) combination instead of per shadow.
  @tinted_tile_cache = {}
  # Per-map row index of native layer properties:
  #   { map_id => [ layer_idx => { row_y => [[col_x, key_str, props_hash], ...] } ] }
  # Lets apply_native_tile_properties iterate only rows overlapping the viewport
  # instead of scanning every property entry on the map every frame.
  @native_props_by_row_cache = {}
  # Per-map "ground cap" index: { map_id => { (y*map_w + x) => cap_layer } }.
  # cap_layer = the highest UNIFIED layer (native 0-2, then NATIVE_LAYERS+ext_id
  # for extended) holding a non-empty PRIORITY-0 (ground) tile at the cell;
  # absent = -1. A tile renders OVERHEAD (above the player) iff its OWN priority
  # >= 1 AND its layer is ABOVE the cap — so a ground tile on a higher layer
  # pushes everything beneath it under the player (a high-priority tile on a low
  # layer can't draw above a higher layer), while each tile keeps its own
  # priority. Built once per map (memoized); dropped when extended data reloads.
  @cell_band_cache = {}

  module_function

  # Returns a tw×th Bitmap of one source tile rendered + tinted to
  # `tint_color`. The caller passes a block that knows how to blit the
  # untinted source tile into the bitmap (typically the renderer's
  # `blit_tile_to_bitmap`). The per-pixel tint loop only runs on cache miss.
  # Subsequent shadows using the same source-tile signature + tint colour
  # reuse the cached bitmap, so the tint loop is a one-shot cost per unique
  # (tile, tint, frame) combination across the whole session.
  def cached_tinted_tile(sig, tw, th, tint_color)
    cached = @tinted_tile_cache[sig]
    return cached if cached && !cached.disposed?
    bmp = Bitmap.new(tw, th)
    yield bmp
    (0...th).each do |y|
      (0...tw).each do |x|
        c = bmp.get_pixel(x, y)
        bmp.set_pixel(x, y, tint_color) if c.alpha > 0
      end
    end
    @tinted_tile_cache[sig] = bmp
    bmp
  end

  def shadow_current_frame(frame_count)
    return 0 if frame_count <= 1
    # $PokemonSystem.autotile_animations is an LBDS/older-Essentials option that
    # does NOT exist in vanilla v21.1 — guard with respond_to? so this never
    # NoMethodErrors on vanilla (where autotile animation is always on).
    return 0 if defined?($PokemonSystem) && $PokemonSystem &&
                $PokemonSystem.respond_to?(:autotile_animations) &&
                $PokemonSystem.autotile_animations == 1
    @shadow_timer_start ||= System.uptime
    duration = TilemapRenderer::AUTOTILE_FRAME_DURATION.to_f / 20
    return 0 if duration <= 0
    return ((System.uptime - @shadow_timer_start) / duration).floor % frame_count
  end

  def current_extended_data
    return @extended_data_cache[$game_map&.map_id] if $game_map
    return nil
  end

  def get_extended_data_for(map_id)
    return @extended_data_cache[map_id]
  end

  def load_extended_layers_for_map(map_id, map)
    @extended_data_cache[map_id] = DataStore.get_extended_data(map_id, map.width, map.height, map)
    # Invalidate the row-index cache for this map; rebuilt lazily by
    # native_props_by_row_for on next access.
    @native_props_by_row_cache.delete(map_id) if @native_props_by_row_cache
    @cell_band_cache.delete(map_id) if @cell_band_cache
  end

  #---------------------------------------------------------------------------
  # Ground-cap resolution (see @cell_band_cache).
  #---------------------------------------------------------------------------

  # Priority of a single tile, self-contained (mirrors resolve_tile_priority /
  # resolve_autotile_priority but callable at module level for cap building).
  def resolve_band_priority(map, tid, td)
    return td["priority"].to_i if td && td["priority"]
    if td && td["autotile_name"]
      entry = DataStore.get_expanded_autotile(td["autotile_name"])
      return entry["priority"].to_i if entry
      idx = map.autotile_names.index(td["autotile_name"])
      return (map.priorities[(idx + 1) * MakerStudio::TILES_PER_AUTOTILE] || 0) if idx
      return 0
    end
    if td && td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return (ts && ts.priorities[tid]) ? ts.priorities[tid] : 0
    end
    map.priorities[tid] || 0
  end

  # Unified layer index ordering: native 0-2, then extended layers above.
  def unified_layer(ext_id)
    MakerStudio::NATIVE_LAYERS + ext_id.to_i
  end

  # Scan every cell once, recording the highest UNIFIED layer that holds a
  # priority-0 (ground) tile (native 0-2, then NATIVE_LAYERS+ext_id). A tile is
  # overhead only if its priority >= 1 AND its layer is ABOVE this cap, so a
  # ground tile on a higher layer covers everything beneath it. Absent = -1.
  def compute_cell_caps(map, ext_data)
    rpg = map.instance_variable_get(:@map)
    return {} unless rpg
    w = map.width
    h = map.height
    native_props = ext_data ? ext_data["nativeProperties"] : nil
    caps = {}
    MakerStudio::NATIVE_LAYERS.times do |layer|
      lp = native_props ? native_props[layer] : nil
      y = 0
      while y < h
        x = 0
        while x < w
          tid = rpg.data[x, y, layer]
          if tid && tid != 0
            entry = lp ? lp["#{x},#{y}"] : nil
            if resolve_band_priority(map, tid, entry) == 0
              idx = y * w + x
              caps[idx] = layer if (caps[idx] || -1) < layer
            end
          end
          x += 1
        end
        y += 1
      end
    end
    if ext_data
      (ext_data["layers"] || []).each do |layer|
        next unless layer["visible"]
        ul = unified_layer(layer["id"])
        (layer["tiles"] || {}).each do |key, td|
          next unless td
          tid = td["tile_id"].to_i
          next unless tid > 0 || td["autotile_name"]
          next unless resolve_band_priority(map, tid, td) == 0
          comma = key.index(",")
          next unless comma
          idx = key[comma + 1..].to_i * w + key[0, comma].to_i
          caps[idx] = ul if (caps[idx] || -1) < ul
        end
      end
    end
    caps
  end

  # Memoized per-map ground-cap index. Rebuilt when extended data reloads.
  def cell_caps_for(map)
    @cell_band_cache[map.map_id] ||= compute_cell_caps(map, @extended_data_cache[map.map_id])
  end

  # Highest unified layer with a ground (priority-0) tile at (x,y); -1 if none.
  def cell_ground_cap(map, x, y)
    cell_caps_for(map)[y * map.width + x] || -1
  end

  def clear_extended_layers
    # Light-touch cleanup fired on :on_leave_map. Only refreshes the extended
    # data cache for maps currently in $map_factory — does NOT dispose shadow
    # bitmaps or extra autotile/tileset caches (those are keyed by map_id /
    # name and safe to persist across connected-map transitions, saving the
    # per-hop regeneration cost). Use clear_all_caches for the full nuke
    # needed on explicit editor-driven reloads.
    @extended_data_cache = {}
    @shadow_source_tiles_cache = {}
    @native_props_by_row_cache = {}
    @cell_band_cache = {}
    if $map_factory
      $map_factory.maps.each do |map|
        next unless map&.instance_variable_get(:@map)
        @extended_data_cache[map.map_id] = DataStore.get_extended_data(
          map.map_id, map.width, map.height, map
        )
      end
    end
  end

  # Full cache flush — dispose all cached shadow bitmaps and drop extra
  # autotile/tileset bitmaps. Call only when map data has actually changed
  # (e.g. editor hot-reload), since regenerating shadow bitmaps is costly.
  def clear_all_caches
    if @shadow_bitmap_cache
      @shadow_bitmap_cache.each_value do |v|
        bmp = v.is_a?(Array) ? v[0] : v
        bmp.dispose if bmp && !bmp.disposed?
      end
    end
    @shadow_bitmap_cache = {}
    @extra_autotile_cache = {}
    @extra_tileset_cache = {}
    @native_props_by_row_cache = {}
    @cell_band_cache = {}
    if @tinted_tile_cache
      @tinted_tile_cache.each_value { |bmp| bmp.dispose if bmp && !bmp.disposed? }
    end
    @tinted_tile_cache = {}
    RPG::Cache.clear if defined?(RPG::Cache)
    MakerStudio::TileEffects.clear_cache if defined?(MakerStudio::TileEffects)
    dispose_all_fog_sprites
    clear_extended_layers
  end

  #---------------------------------------------------------------------------
  # Row-indexed view of nativeProperties for one map, built lazily and
  # invalidated whenever the extended-data cache for the map is rewritten
  # (load_extended_layers_for_map / clear_extended_layers / clear_all_caches).
  # Returns: [ layer_idx => { row_y => sorted [[col_x, props_hash, has_effects?], ...] } ]
  #
  # Per-row entries are sorted by col so the hot loop can `break` as soon as
  # col > viewport max — avoids scanning whole rows on wide maps with native
  # properties spanning many columns.
  #
  # has_effects? is precomputed once per props: when false, the per-frame
  # apply_to_sprite call is replaced with cheap direct setters to sprite
  # defaults. The bulk of native extra-autotile / per-tile-property tiles
  # carry only collision/terrain overrides, so most entries are trivial.
  #---------------------------------------------------------------------------
  def native_props_by_row_for(map_id)
    cached = @native_props_by_row_cache[map_id]
    return cached if cached
    ext_data = @extended_data_cache[map_id]
    return nil unless ext_data
    native_props = ext_data["nativeProperties"]
    return nil unless native_props
    by_layer = []
    MakerStudio::NATIVE_LAYERS.times do |layer|
      layer_props = native_props[layer]
      next unless layer_props && !layer_props.empty?
      rows = {}
      layer_props.each do |key, props|
        comma = key.index(",")
        next unless comma
        col = key[0, comma].to_i
        row = key[comma + 1..].to_i
        (rows[row] ||= []) << [col, props, props_has_visual_effects?(props)]
      end
      rows.each_value { |entries| entries.sort_by! { |e| e[0] } }
      by_layer[layer] = rows
    end
    @native_props_by_row_cache[map_id] = by_layer
    by_layer
  end

  #---------------------------------------------------------------------------
  # Cheap once-per-load classifier: does this props hash trigger any branch
  # inside TileEffects.apply_to_sprite that diverges from sprite defaults?
  # Tiles with only passage / priority / terrain_tag / autotile_name /
  # tileset_id / autotile_pattern / autotile_detail return false (trivial).
  #---------------------------------------------------------------------------
  def props_has_visual_effects?(props)
    return true if props["flipH"]
    return true if props["flipV"]
    v = props["opacity"];    return true if v && v.to_i != 255
    v = props["rotation"];   return true if v && v.to_i != 0
    v = props["hue"];        return true if v && v.to_i != 0
    v = props["saturation"]; return true if v && v.to_i != 100
    v = props["lighting"];   return true if v && v.to_i != 0
    false
  end

  #---------------------------------------------------------------------------
  # Yield tile_data for each native layer tile at (x, y) that has extra
  # properties (autotile_name or cross-tileset tileset_id) on the CURRENT
  # game map.  Iterates layers top-to-bottom (2 → 0) so collision callers
  # can early-return on the highest blocker first.
  #
  # Autotiles are yielded with tile_id=0 (Table stores 0 for autotiles).
  # Cross-tileset tiles are yielded with their Table tile_id.
  #
  # IMPORTANT: collision callers must NOT "return true" for cross-tileset
  # tiles in this loop — only "return false" (block) or "next".  Yielding
  # "return true" for a passable cross-tileset ground tile on a low layer
  # would bypass the native_layer_* fallback that checks regular tiles on
  # higher layers.  Autotiles are exempt because their tile_id=0 never
  # conflicts with regular Table entries.
  #---------------------------------------------------------------------------
  def each_native_extra_tile_at(x, y)
    ext_data = @extended_data_cache[$game_map&.map_id]
    return unless ext_data
    native_props = ext_data["nativeProperties"]
    return unless native_props
    key = "#{x},#{y}"
    map = $game_map
    return unless map
    layers = MakerStudio::NATIVE_LAYERS - 1
    layers.downto(0) do |layer|
      props = native_props[layer]
      next unless props
      td = props[key]
      next unless td
      if td["autotile_name"]
        yield 0, td
      elsif td["tileset_id"]
        yield map.data[x, y, layer], td
      end
    end
  end

  #---------------------------------------------------------------------------
  # Yield tile_id for each visible extended layer tile at (x, y) on the
  # CURRENT game map only.  Collision methods (passable?, terrain_tag, etc.)
  # are always called on $game_map, so checking other factory maps at the same
  # local (x,y) would bleed collisions from unrelated map positions.
  #---------------------------------------------------------------------------
  def each_extended_tile_at(x, y)
    ext_data = @extended_data_cache[$game_map&.map_id]
    return unless ext_data
    layers = (ext_data["layers"] || [])
      .select { |l| l["visible"] }
      .sort_by { |l| -l["id"] }
    layers.each do |layer|
      td = (layer["tiles"] || {})["#{x},#{y}"]
      next unless td
      tid = td["tile_id"].to_i
      # Include tiles with tile_id > 0, or tile_id=0 with autotile_name (extra autotiles)
      next unless tid > 0 || td["autotile_name"]
      yield tid, td
    end
  end

  #---------------------------------------------------------------------------
  # Get tile data for an extended layer at a specific position
  #---------------------------------------------------------------------------
  def get_extended_tile(layer_id, x, y)
    data = current_extended_data
    return nil unless data
    layers = data["layers"]
    return nil unless layers
    layer = layers.find { |l| l["id"] == layer_id }
    return nil unless layer && layer["visible"]
    key = "#{x},#{y}"
    return layer["tiles"][key]
  end

  #---------------------------------------------------------------------------
  # Get all visible extended layers for a specific map
  #---------------------------------------------------------------------------
  def get_visible_extended_layers(map_id = nil)
    map_id ||= $game_map&.map_id
    data = @extended_data_cache[map_id]
    return [] unless data
    return (data["layers"] || []).select { |l| l["visible"] }
  end

  #---------------------------------------------------------------------------
  # Get or load an extra autotile bitmap by name
  #---------------------------------------------------------------------------
  def get_extra_autotile(name)
    return nil unless name
    bmp = @extra_autotile_cache[name]
    return bmp if bmp && !bmp.disposed?
    begin
      # Load PNG directly via Bitmap.new — bypasses both pbGetAutotile
      # (which deanimates and strips multi-frame info) and RPG::Cache
      # (which shares refcounted entries with PngAnimatedBitmap that may
      # already have been dispose'd into a partial state).  Direct load
      # gives us the full on-disk strip every time.
      bmp = Bitmap.new("Graphics/Autotiles/" + name)
      if MakerStudio::DEBUG_LOG && defined?(Console)
        Console.echoln("MakerStudio: loaded extra autotile '#{name}' #{bmp.width}x#{bmp.height}")
      end
      @extra_autotile_cache[name] = bmp if bmp
    rescue => e
      Console.echo_error("MakerStudio: Failed to load extra autotile '#{name}': #{e.message}") if defined?(Console)
    end
    return bmp
  end

  #---------------------------------------------------------------------------
  # Get or load an extra tileset bitmap by name
  #---------------------------------------------------------------------------
  def get_extra_tileset(name)
    return nil unless name
    bmp = @extra_tileset_cache[name]
    return bmp if bmp && !bmp.disposed?
    begin
      bmp = RPG::Cache.tileset(name)
      @extra_tileset_cache[name] = bmp if bmp
    rescue => e
      Console.echo_error("MakerStudio: Failed to load extra tileset '#{name}': #{e.message}") if defined?(Console)
    end
    return bmp
  end
end

#===============================================================================
# Add map coordinate tracking to TileSprite for extended layers
#===============================================================================
class TilemapRenderer::TileSprite
  attr_accessor :map_x, :map_y
  attr_accessor :map_id   # which map this sprite belongs to (for connections)
  # Shadow animation: width of one frame within a sprite-sheet shadow bitmap
  # and total frame count.  When frame_count > 1, sprite.src_rect.x is updated
  # each Graphics frame to cycle through frames.
  attr_accessor :shadow_frame_w, :shadow_frame_count
  # Name of the source autotile whose animation drives this shadow's frame
  # index — looked up in @autotiles.current_frames each tick so shadow stays
  # in lockstep with the source tile (instead of drifting on its own timer).
  attr_accessor :shadow_anim_source_name
  # Per-extended-layer fractional z bias applied on top of the priority-based
  # z formula. Recorded at creation so the per-frame z recompute (which uses
  # screen-y instead of map-y) can preserve layer stacking order.
  attr_accessor :ext_z_offset
  # Effective render priority: 0 = ground (below player), else this tile's own
  # priority when it sits OVERHEAD (above the player) — i.e. above the cell's
  # highest ground tile. Drives the per-frame z recompute in Pass 2.
  attr_accessor :cell_band
end

#===============================================================================
# Monkey-patch TilemapRenderer to support extended layers + native properties
#===============================================================================
class TilemapRenderer
  # Small z-offset per extended layer to guarantee layer stacking order
  EXT_LAYER_Z_OFFSET = 0.001

  alias __mkst__initialize initialize unless method_defined?(:__mkst__initialize)
  def initialize(viewport)
    __mkst__initialize(viewport)
    @extended_tile_sprites = []
    @tile_sprites_by_map_row = {}   # { map_id => { row => [sprites] } }
    @shadow_sprites = []            # flat list of shadow sprites only
    @last_visible_extended_sprites = []  # sprites we set visible last frame
    @extended_data_loaded  = false
    @last_extended_cache_sig = nil
  end

  alias __mkst__dispose dispose unless method_defined?(:__mkst__dispose)
  def dispose
    dispose_extended_sprites
    __mkst__dispose
  end

  alias __mkst__refresh refresh unless method_defined?(:__mkst__refresh)
  def refresh
    __mkst__refresh
    @extended_data_loaded = false
    # Hide extended/shadow sprites immediately so stale sprites from the
    # previous map don't appear at wrong screen positions during the
    # transition frame (before ensure_extended_sprites disposes them).
    @extended_tile_sprites.each { |spr| spr.visible = false rescue nil }
  end

  #---------------------------------------------------------------------------
  # Create extended layer sprites for ALL connected maps (called per refresh)
  #---------------------------------------------------------------------------
  def ensure_extended_sprites
    # Detect when the cache was cleared/rebuilt (size + map_id signature changes)
    cache = MakerStudio.instance_variable_get(:@extended_data_cache)
    cache_sig = cache.object_id ^ cache.size
    return if @extended_data_loaded && cache_sig == @last_extended_cache_sig
    return unless $map_factory
    # Always dispose old sprites before recreating — refresh() can reset
    # @extended_data_loaded without changing cache_sig, and failing to
    # dispose would stack duplicate shadow sprites (causing progressive
    # darkening on non-connected maps).
    dispose_extended_sprites
    # Per-map lazy loading: ensure each loaded map has its extended data cached.
    $map_factory.maps.each do |map|
      next unless map&.instance_variable_get(:@map)
      unless MakerStudio.get_extended_data_for(map.map_id)
        MakerStudio.load_extended_layers_for_map(map.map_id, map)
      end
    end
    $map_factory.maps.each do |map|
      ext_data = MakerStudio.get_extended_data_for(map.map_id)
      next unless ext_data
      create_extended_sprites_for_map(map, ext_data)
      create_shadow_sprites_for_map(map, ext_data)
      MakerStudio.create_fog_sprites_for_map(map.map_id, map)
    end
    # Dispose fog sprites and extended sprites only for maps that left the
    # factory entirely. Fog sprites persist for all factory maps (hidden via
    # visible=false when not current) so scroll offsets survive transitions.
    factory_map_ids = $map_factory.maps.map { |m| m.map_id }
    fog_cache = MakerStudio.instance_variable_get(:@fog_sprites_cache)
    fog_cache.keys.each do |cached_map_id|
      unless factory_map_ids.include?(cached_map_id)
        MakerStudio.dispose_fog_sprites(cached_map_id)
      end
    end
    # Dispose orphaned extended/shadow sprites whose map left the factory.
    @extended_tile_sprites.reject! do |spr|
      next false if factory_map_ids.include?(spr.map_id)
      spr.dispose rescue nil
      true
    end
    @tile_sprites_by_map_row.reject! { |mid, _| !factory_map_ids.include?(mid) }
    # Drop already-disposed shadow sprite refs (sprite.disposed? was set above).
    @shadow_sprites.reject!(&:disposed?) if @shadow_sprites
    @extended_data_loaded = true
    @last_extended_cache_sig = cache_sig
  end

  #---------------------------------------------------------------------------
  # Create sprites for one map's extended layers
  #---------------------------------------------------------------------------
  def create_extended_sprites_for_map(map, ext_data)
    visible_layers = (ext_data["layers"] || [])
      .select { |l| l["visible"] }
      .sort_by { |l| l["id"] }
    return if visible_layers.empty?
    # Create sprites for each extended layer
    visible_layers.each_with_index do |layer, layer_order|
      z_offset = (layer_order + 1) * EXT_LAYER_Z_OFFSET
      (layer["tiles"] || {}).each do |key, tile_data|
        next unless tile_data
        tile_id = tile_data["tile_id"].to_i
        # Skip completely empty tiles (no tile_id and no extra data)
        next unless tile_id > 0 || tile_data["autotile_name"]
        mx, my = key.split(",").map(&:to_i)
        # Create sprite
        sprite = TileSprite.new(@viewport)
        sprite.zoom_x = ZOOM_X
        sprite.zoom_y = ZOOM_Y
        sprite.map_x = mx
        sprite.map_y = my
        sprite.map_id = map.map_id
        setup_extended_sprite_bitmap(sprite, tile_id, map, tile_data)
        # Apply per-tile visual effects (opacity, rotation, hue, etc.)
        MakerStudio::TileEffects.apply_to_sprite(
          sprite, tile_data, @tilesets, @autotiles
        )
        # Apply layer-level opacity (multiplicative with per-tile opacity)
        layer_opacity = (layer["opacity"] || 255).to_i
        if layer_opacity < 255
          sprite.opacity = (sprite.opacity * layer_opacity / 255.0).round.clamp(0, 255)
        end
        # Apply current renderer tone/color so day/night filters work
        sprite.tone = @tone.clone if @tone
        sprite.color = @color.clone if @color
        # Z-ordering keeps this tile's OWN priority, but it only goes OVERHEAD
        # (above the player) when its layer is above the cell's highest ground
        # tile — a ground tile on a higher layer covers everything beneath it.
        # The effective priority (0 = ground, else own priority) is stored on the
        # sprite so Pass 2's per-frame z recompute uses it.
        own_pri = MakerStudio.resolve_band_priority(map, tile_id, tile_data)
        ul = MakerStudio.unified_layer(layer["id"])
        eff = (own_pri >= 1 && ul > MakerStudio.cell_ground_cap(map, mx, my)) ? own_pri : 0
        sprite.ext_z_offset = z_offset
        sprite.cell_band = eff
        if eff == 0
          sprite.z = 2 + z_offset  # Ground band (above shadow z=1), layer order
        else
          # Overhead: refreshed each frame in Pass 2 using current screen-y so it
          # tracks the player's z (whether the player passes above/below).
          sprite.z = (my * SOURCE_TILE_HEIGHT) +
                     (eff * SOURCE_TILE_HEIGHT) +
                     SOURCE_TILE_HEIGHT + 1 + z_offset
        end
        # MUST be last — set_bitmap (called by setup_extended_sprite_bitmap)
        # resets visible=true internally.  The update loop re-enables visibility
        # only after computing the correct screen position.
        sprite.visible = false
        @extended_tile_sprites << sprite
        (@tile_sprites_by_map_row[map.map_id] ||= {})[my] ||= []
        @tile_sprites_by_map_row[map.map_id][my] << sprite
      end
    end
  end

  #---------------------------------------------------------------------------
  # Set up bitmap for an extended tile sprite (mirrors refresh_tile_bitmap)
  #---------------------------------------------------------------------------
  def setup_extended_sprite_bitmap(sprite, tile_id, map, tile_data = nil)
    # Case 1: Extra autotile by name
    if tile_data && tile_data["autotile_name"]
      autotile_name = tile_data["autotile_name"]
      # Register the extra autotile bitmap with @autotiles for chunk composition
      unless @autotiles[autotile_name]
        raw_bmp = MakerStudio.get_extra_autotile(autotile_name)
        if raw_bmp && !raw_bmp.disposed?
          # Set frame_duration before registration to prevent nil division
          # in AutotileBitmaps#set_current_frame
          durations = @autotiles.instance_variable_get(:@frame_durations)
          unless durations.key?(autotile_name)
            durations[autotile_name] = TilemapRenderer::AUTOTILE_FRAME_DURATION.to_f / 20
          end
          # Expand compact autotile into the 48-row format expected by
          # AutotileBitmaps#set_src_rect.  RPG::Cache.autotile returns the
          # raw compact bitmap; AutotileExpander.expand converts it.
          expanded_bmp = AutotileExpander.expand(raw_bmp)
          @autotiles[autotile_name] = expanded_bmp
          # Seed @load_counts so a subsequent add_autotile(name) from Essentials
          # (which finds @bitmaps populated and does `@load_counts[name] += 1`)
          # doesn't crash on nil.  [] = path skips add's load_count init.
          load_counts = @autotiles.instance_variable_get(:@load_counts)
          load_counts[autotile_name] ||= 1 if load_counts
          # AutotileBitmaps#[]= hardcodes @bitmap_wraps[name]=false, which
          # breaks set_src_rect for wrap-layout autotiles (height < 1536).
          # Detect + fix, then recompute frame_count with correct wraps flag.
          if expanded_bmp.height > MakerStudio::TILE_HEIGHT &&
             expanded_bmp.height < MakerStudio::TILES_PER_AUTOTILE * MakerStudio::TILE_HEIGHT
            wraps_hash = @autotiles.instance_variable_get(:@bitmap_wraps)
            wraps_hash[autotile_name] = true if wraps_hash
            @autotiles.frame_count(autotile_name, true)
          end
        end
      end
      if @autotiles[autotile_name] && !@autotiles[autotile_name].disposed?
        # Use a virtual tile_id: slot 8+ * 48 + pattern
        # The slot number doesn't matter — set_src_rect uses sprite.filename
        pattern = (tile_data["autotile_pattern"] || 0).to_i
        virtual_tile_id = 8 * MakerStudio::TILES_PER_AUTOTILE + pattern
        priority = resolve_tile_priority(tile_id, tile_data, map)
        sprite.set_bitmap(autotile_name, virtual_tile_id, true, true, priority, @autotiles[autotile_name])
        @autotiles.set_src_rect(sprite, virtual_tile_id)
      else
        sprite.visible = false
      end
      return
    end

    # Case 2: Cross-tileset reference (tileset tiles + autotiles from foreign ts)
    if tile_data && tile_data["tileset_id"]
      ts_id = tile_data["tileset_id"].to_i
      ts = $data_tilesets[ts_id]
      if ts && setup_cross_tileset_sprite_bitmap(sprite, tile_id, ts, tile_data, map)
        return
      end
      sprite.visible = false
      return
    end

    # Case 3: Default behavior (map's own tileset)
    if tile_id >= MakerStudio::TILESET_START_ID
      filename = map.tileset_name
      bitmap = @tilesets[filename]
      if bitmap && !bitmap.disposed?
        priority = resolve_tile_priority(tile_id, tile_data, map)
        sprite.set_bitmap(filename, tile_id, false, false, priority, bitmap)
        @tilesets.set_src_rect(sprite, tile_id)
      end
    elsif tile_id > 0
      autotile_index = (tile_id / MakerStudio::TILES_PER_AUTOTILE) - 1
      if autotile_index >= 0 && autotile_index < map.autotile_names.length
        filename = map.autotile_names[autotile_index]
        bitmap = @autotiles[filename]
        if bitmap && !bitmap.disposed?
          animated = @autotiles.animated?(filename)
          priority = resolve_tile_priority(tile_id, tile_data, map)
          sprite.set_bitmap(filename, tile_id, true, animated, priority, bitmap)
          @autotiles.set_src_rect(sprite, tile_id)
        end
      end
    else
      sprite.visible = false
    end
  end

  #---------------------------------------------------------------------------
  # Bind a sprite to a tile from a foreign tileset (regular tile or autotile).
  # Returns true when the bitmap was set successfully.
  #---------------------------------------------------------------------------
  def setup_cross_tileset_sprite_bitmap(sprite, tile_id, ts, tile_data, map)
    ts_bitmap = MakerStudio.get_extra_tileset(ts.tileset_name)
    return false unless ts_bitmap && !ts_bitmap.disposed?
    priority = resolve_tile_priority(tile_id, tile_data, map)
    if tile_id >= MakerStudio::TILESET_START_ID
      sprite.set_bitmap(ts.tileset_name, tile_id, false, false, priority, ts_bitmap)
      i = tile_id - MakerStudio::TILESET_START_ID
      src_col = i % MakerStudio::TILESET_TILES_PER_ROW
      src_row = i / MakerStudio::TILESET_TILES_PER_ROW
      sprite.src_rect.set(
        src_col * MakerStudio::TILE_WIDTH,
        src_row * MakerStudio::TILE_HEIGHT,
        MakerStudio::TILE_WIDTH,
        MakerStudio::TILE_HEIGHT
      )
    elsif tile_id > 0
      autotile_index = (tile_id / MakerStudio::TILES_PER_AUTOTILE) - 1
      return false if autotile_index < 0 || autotile_index >= ts.autotile_names.length
      at_name = ts.autotile_names[autotile_index]
      unless @autotiles[at_name] && !@autotiles[at_name].disposed?
        register_extra_autotile_in_engine(at_name)
      end
      return false unless @autotiles[at_name] && !@autotiles[at_name].disposed?
      animated = @autotiles.animated?(at_name)
      sprite.set_bitmap(at_name, tile_id, true, animated, priority, @autotiles[at_name])
      @autotiles.set_src_rect(sprite, tile_id)
    else
      return false
    end
    true
  end

  #---------------------------------------------------------------------------
  # Resolve passage for shadow z-splitting, honouring nativeProperties overrides.
  #---------------------------------------------------------------------------
  def resolve_shadow_tile_passage(tid, entry, default_passages)
    return entry["passage"].to_i if entry && entry["passage"]
    if entry && entry["autotile_name"]
      auto_entry = MakerStudio::DataStore.get_expanded_autotile(entry["autotile_name"])
      return auto_entry["passage"].to_i if auto_entry && auto_entry["passage"]
    end
    if entry && entry["tileset_id"]
      ts = $data_tilesets[entry["tileset_id"].to_i]
      return ts ? (ts.passages[tid] || 0) : 0
    end
    return default_passages[tid] || 0
  end

  #---------------------------------------------------------------------------
  # Finalize a native-layer sprite after per-tile property overrides: visual
  # state, screen coords, and z from the resolved priority (set_bitmap alone
  # does not refresh z for cross-tileset / extra-autotile tiles).
  #---------------------------------------------------------------------------
  def finalize_native_prop_sprite(sprite, props, has_effects, map, screen_i, screen_j, tile_id, tone, color)
    apply_native_visual_state(sprite, props, has_effects, tile_id, tone, color)
    refresh_tile_coordinates(sprite, screen_i, screen_j)
    refresh_tile_z(sprite, map, screen_j, 0, tile_id) if sprite.visible
    if sprite.ox != 0 || sprite.oy != 0
      sprite.x += (sprite.ox * sprite.zoom_x.abs).round
      sprite.y += (sprite.oy * sprite.zoom_y.abs).round
    end
  end

  #---------------------------------------------------------------------------
  # Resolve priority for a tile, checking per-tile data first
  #---------------------------------------------------------------------------
  def resolve_tile_priority(tile_id, tile_data, map)
    # Per-tile priority takes precedence
    if tile_data && tile_data["priority"]
      return tile_data["priority"].to_i
    end
    # Extra autotile: search tilesets for matching autotile name
    if tile_data && tile_data["autotile_name"]
      return resolve_autotile_priority(tile_data["autotile_name"], map)
    end
    # Cross-tileset: use referenced tileset
    if tile_data && tile_data["tileset_id"]
      ts = $data_tilesets[tile_data["tileset_id"].to_i]
      return (ts && ts.priorities[tile_id]) ? ts.priorities[tile_id] : 0
    end
    # Default: map tileset
    return map.priorities[tile_id] || 0
  end

  #---------------------------------------------------------------------------
  # Look up priority for an extra autotile by searching all tilesets
  #---------------------------------------------------------------------------
  def resolve_autotile_priority(autotile_name, map)
    # Check expanded_autotiles config first (named autotile priority override)
    entry = MakerStudio::DataStore.get_expanded_autotile(autotile_name)
    return entry["priority"].to_i if entry
    # Check map's own tileset native autotile slots
    idx = map.autotile_names.index(autotile_name)
    if idx
      base = (idx + 1) * MakerStudio::TILES_PER_AUTOTILE
      return map.priorities[base] || 0
    end
    # Check all tilesets
    $data_tilesets.each do |ts|
      next unless ts
      idx = ts.autotile_names.index(autotile_name)
      if idx
        base = (idx + 1) * MakerStudio::TILES_PER_AUTOTILE
        return ts.priorities[base] || 0
      end
    end
    return 0
  end

  # Try to load a pre-baked shadow bitmap that the editor wrote to
  # Graphics/Shadows/<mapId>_<shadowId>.png on save. Returns the loaded Bitmap
  # on success, or nil if the file is missing / unreadable.
  def load_baked_shadow_bitmap(map_id, shadow_id)
    base = sprintf("Graphics/Shadows/%03d_%d", map_id, shadow_id)
    begin
      Bitmap.new(base)
    rescue
      nil
    end
  end

  #---------------------------------------------------------------------------
  # Create sprites for shadow layers — fast path loads baked PNG, falls back
  # to runtime generation from sourceTiles + config.
  #---------------------------------------------------------------------------
  def create_shadow_sprites_for_map(map, ext_data)
    shadows = ext_data["shadowLayers"]
    if !shadows || shadows.empty?
      single = ext_data["shadowLayer"]
      shadows = single ? [single] : []
    end
    return if shadows.empty?
    tw = MakerStudio::TILE_WIDTH
    th = MakerStudio::TILE_HEIGHT
    shadows.each_with_index do |shadow, idx|
      next unless shadow["visible"]
      config = shadow["config"]
      source_tiles = shadow["sourceTiles"]
      next unless config && source_tiles && !source_tiles.empty?
      # Legacy stretch-based configs are unsupported — editor must re-apply
      # to migrate. Skip rendering until then so we never silently mis-cast.
      next if config["height"].nil? || config["direction"].nil?
      shadow_id = shadow["id"] || idx
      # Embed frame_count signature so logic changes to frame-count detection
      # invalidate stale cached bitmaps automatically.
      fc_sig = source_tiles.map { |st| source_tile_frame_count(st, map) }.max || 1
      cache_key = "shadow_#{map.map_id}_#{shadow_id}_fc#{fc_sig}"
      cached = MakerStudio.instance_variable_get(:@shadow_bitmap_cache)[cache_key]
      bmp = cached.is_a?(Array) ? cached[0] : cached
      frame_count = cached.is_a?(Array) ? cached[1] : 1
      frame_w = cached.is_a?(Array) ? cached[2] : (bmp ? bmp.width : 0)
      unless bmp && !bmp.disposed?
        # Fast path: load the editor-baked PNG from Graphics/Shadows/. Avoids
        # the full silhouette + tint + slab + connect-fill pipeline.
        baked = load_baked_shadow_bitmap(map.map_id, shadow_id)
        if baked
          bmp = baked
          # frameCount/frameWidth are persisted in the shadow's config so the
          # sprite-sheet src_rect math matches the baked layout.
          frame_count = (shadow["frameCount"] || 1).to_i
          frame_count = 1 if frame_count < 1
          frame_w = (shadow["frameWidth"] || bmp.width).to_i
          frame_w = bmp.width if frame_w <= 0 || frame_w > bmp.width
          MakerStudio.instance_variable_get(:@shadow_bitmap_cache)[cache_key] = [bmp, frame_count, frame_w]
          if MakerStudio::DEBUG_LOG && defined?(Console)
            Console.echoln("MakerStudio Shadow: map=#{map.map_id} id=#{shadow_id} loaded baked PNG (#{bmp.width}x#{bmp.height})")
          end
        else
          # Fallback: build the bitmap at runtime when no baked PNG is present
          # (e.g. mod-created shadows, or projects that haven't re-saved with
          # the bake-enabled editor yet).
          begin
            result = generate_shadow_bitmap(map, config, source_tiles, tw, th)
          rescue => e
            Console.echo_error("MakerStudio: Shadow generation failed: #{e.message}") if defined?(Console)
            next
          end
          next unless result
          bmp, frame_count, frame_w = result
          MakerStudio.instance_variable_get(:@shadow_bitmap_cache)[cache_key] = [bmp, frame_count, frame_w]
          if MakerStudio::DEBUG_LOG && defined?(Console)
            Console.echoln("MakerStudio Shadow: map=#{map.map_id} id=#{shadow_id} runtime-gen #{bmp.width}x#{bmp.height}")
          end
        end
      end

      # Compute position: the bitmap is padded so that the shadow drawing
      # sits at an offset from the source tiles' base.
      # We position the sprite so the source base aligns correctly on the map.
      min_x = source_tiles.map { |t| t["x"].to_i }.min
      min_y = source_tiles.map { |t| t["y"].to_i }.min
      max_x = source_tiles.map { |t| t["x"].to_i }.max
      max_y = source_tiles.map { |t| t["y"].to_i }.max
      bw = max_x - min_x + 1
      bh = max_y - min_y + 1
      src_h = bh * th
      src_w = bw * tw

      layout = compute_shadow_layout(config, src_w, src_h, tw, th)
      next unless layout
      anchor_px_x = layout[:anchor_x]
      anchor_px_y = layout[:anchor_y]
      map_origin_px_x = min_x * tw - anchor_px_x
      map_origin_px_y = (min_y + bh) * th - anchor_px_y

      # Convert to tile coords (integer) + pixel remainder
      sprite_map_x = (map_origin_px_x / tw.to_f).floor
      sprite_map_y = (map_origin_px_y / th.to_f).floor
      # ox/oy handle sub-tile offset (bitmap pixel that maps to sprite_map_x/y)
      sprite_ox = sprite_map_x * tw - map_origin_px_x
      sprite_oy = sprite_map_y * th - map_origin_px_y

      sprite = TileSprite.new(@viewport)
      sprite.zoom_x = ZOOM_X
      sprite.zoom_y = ZOOM_Y
      sprite.map_x = sprite_map_x
      sprite.map_y = sprite_map_y
      sprite.map_id = map.map_id
      sprite.bitmap = bmp
      # Sprite-sheet shadow: src_rect covers one frame's column
      sprite.src_rect.set(0, 0, frame_w, bmp.height)
      sprite.shadow_frame_w = frame_w
      sprite.shadow_frame_count = frame_count
      # Pick the first animated source autotile name as the timing reference
      # so the shadow stays in lockstep with that tile's frame index every
      # tick (instead of free-running on its own timer).
      if frame_count > 1
        anim_st = source_tiles.find { |st| source_tile_frame_count(st, map) == frame_count }
        if anim_st
          name = anim_st["autotile_name"]
          if !name && anim_st["tileset_id"]
            ts = $data_tilesets[anim_st["tileset_id"].to_i]
            tid = anim_st["tileId"].to_i
            if ts && tid > 0 && tid < MakerStudio::TILESET_START_ID
              ai = (tid / MakerStudio::TILES_PER_AUTOTILE) - 1
              name = ts.autotile_names[ai] if ai >= 0 && ai < ts.autotile_names.length
            end
          end
          if !name
            tid = anim_st["tileId"].to_i
            if tid > 0 && tid < MakerStudio::TILESET_START_ID
              ai = (tid / MakerStudio::TILES_PER_AUTOTILE) - 1
              name = map.autotile_names[ai] if ai >= 0 && ai < map.autotile_names.length
            end
          end
          sprite.shadow_anim_source_name = name
        end
      end
      sprite.ox = sprite_ox
      sprite.oy = sprite_oy

      # Shadow opacity = config shadowOpacity * layer opacity
      shadow_opacity = (config["shadowOpacity"] || 51).to_i
      layer_opacity = (shadow["opacity"] || 255).to_i
      sprite.opacity = (shadow_opacity * layer_opacity / 255.0).round.clamp(0, 255)

      # Shadow sits ON ground (above priority-0 z=0) but BEHIND objects (priority 1+)
      sprite.z = 1
      sprite.tone = @tone.clone if @tone
      sprite.color = @color.clone if @color
      # MUST be last — sprite.bitmap= above may reset visible=true internally.
      # The update loop re-enables visibility only after positioning.
      sprite.visible = false
      @extended_tile_sprites << sprite
      @shadow_sprites << sprite   # dedicated list so Pass 3 doesn't filter
    end
  end

  #---------------------------------------------------------------------------
  # Generate shadow bitmap at runtime from source tiles + config.
  # Uses only fast bitmap ops (blt, stretch_blt, fill_rect) — no get_pixel.
  #
  # Simplified approach for RGSS:
  # 1. Render source tiles → silhouette (black fill via fill_rect per tile)
  # 2. stretch_blt for Y-compression (0.5x)
  # 3. Position offset via direction + distance + user offset
  # 4. Opacity handled by sprite.opacity (not bitmap alpha)
  #
  # Shadow is a flat compressed silhouette offset in the configured direction.
  # Shadow is a flat compressed silhouette offset in the configured direction.
  #---------------------------------------------------------------------------
  def generate_shadow_bitmap(map, config, source_tiles, tw, th)
    min_x = source_tiles.map { |t| t["x"].to_i }.min
    min_y = source_tiles.map { |t| t["y"].to_i }.min
    max_x = source_tiles.map { |t| t["x"].to_i }.max
    max_y = source_tiles.map { |t| t["y"].to_i }.max
    bw = max_x - min_x + 1
    bh = max_y - min_y + 1
    src_w = bw * tw
    src_h = bh * th

    # Determine frame count = max across all source tiles' source bitmaps
    frame_count = 1
    source_tiles.each do |st|
      fc = source_tile_frame_count(st, map)
      frame_count = fc if fc > frame_count
    end

    # Parse tint colour once.
    tint_hex = (config["tintColor"] || "#000000").to_s
    tint_r = tint_g = tint_b = 0
    if tint_hex =~ /^#?([0-9a-fA-F]{6})$/
      n = $1.to_i(16)
      tint_r = (n >> 16) & 0xff
      tint_g = (n >> 8) & 0xff
      tint_b = n & 0xff
    end
    tint_color = Color.new(tint_r, tint_g, tint_b, 255)

    # Step 1+2 combined: blit pre-tinted per-tile silhouettes into src_bmp.
    # The tinting (per-pixel get/set) only runs on cache misses — repeated tiles
    # across shadows and frames hit the cached tinted bitmap.
    src_bmp = Bitmap.new(src_w * frame_count, src_h)
    source_tiles.each do |st|
      tile_id = st["tileId"].to_i
      next if tile_id <= 0 && !st["autotile_name"]
      # Pre-warm extra autotile (RPG::Cache may not have it registered yet).
      if st["autotile_name"]
        raw = MakerStudio.get_extra_autotile(st["autotile_name"])
        if !raw || raw.disposed?
          Console.echo_error("MakerStudio: Shadow could not load extra autotile '#{st["autotile_name"]}'") if defined?(Console)
          next
        end
      end
      px = (st["x"].to_i - min_x) * tw
      py = (st["y"].to_i - min_y) * th
      frame_count.times do |frame|
        # Identity of one source-tile render: same map, tile_id, autotile/
        # tileset overrides, transforms, frame, and tint produces the same
        # tinted 32×32 bitmap.
        sig = "m#{map.map_id}_t#{tile_id}_a#{st['autotile_name']}_ts#{st['tileset_id']}_p#{st['autotile_pattern']}_h#{st['flipH'] ? 1 : 0}_v#{st['flipV'] ? 1 : 0}_r#{st['rotation'].to_i}_f#{frame}_c#{tint_hex.downcase}"
        tinted = MakerStudio.cached_tinted_tile(sig, tw, th, tint_color) do |bmp|
          blit_tile_to_bitmap(bmp, tile_id, 0, 0, map, st, frame)
        end
        src_bmp.blt(frame * src_w + px, py, tinted, Rect.new(0, 0, tw, th))
      end
    end

    # Build drop slab once; both placements (base + optional sprite-top) reuse it.
    layout = compute_shadow_layout(config, src_w, src_h, tw, th)
    unless layout
      src_bmp.dispose
      return nil
    end
    drop = layout[:drop]
    placements = layout[:placements]
    drop_slab = build_drop_slab(src_bmp, src_w, src_h, frame_count, drop)
    src_bmp.dispose

    out_w = layout[:out_w]
    out_h = layout[:out_h]
    anchor_x = layout[:anchor_x]
    anchor_y = layout[:anchor_y]

    shadow_bmp = Bitmap.new(out_w * frame_count, out_h)
    frame_count.times do |frame|
      col_x = frame * out_w
      placements.each do |p|
        blt_slab_placement(shadow_bmp, col_x, drop_slab, drop, frame, anchor_x, anchor_y, p)
      end
      # Connect the two placements via per-column vertical fill.
      if placements.size > 1
        connect_shadow_columns(shadow_bmp, col_x, 0, out_w, out_h, tint_color)
      end
    end
    drop_slab.dispose

    return [shadow_bmp, frame_count, out_w]
  end

  # Per-column vertical fill within a (col_x, 0, w, h) frame slice — between the
  # topmost and bottommost shadow pixel of each column, paint the gap with
  # tint. Uses fill_rect for the inner span (single op vs per-pixel set_pixel)
  # which is the practical bottleneck of 3D-mode shadow generation. Shadow
  # pixels in the span are already tint+alpha255, so overwriting them with the
  # same colour is a no-op visually.
  def connect_shadow_columns(bitmap, col_x, col_y, w, h, tint_color)
    w.times do |x|
      bx = col_x + x
      min_y = -1
      max_y = -1
      h.times do |y|
        if bitmap.get_pixel(bx, col_y + y).alpha > 0
          min_y = y if min_y < 0
          max_y = y
        end
      end
      next if min_y < 0 || min_y == max_y
      gap_height = max_y - min_y - 1
      next if gap_height <= 0
      bitmap.fill_rect(bx, col_y + min_y + 1, 1, gap_height, tint_color)
    end
  end

  #---------------------------------------------------------------------------
  # Shadow layout — drop slab plus an optional second drop slab anchored at
  # the group's TOP edge (3D mode). Bitmap anchor = group's bottom-left in
  # map coords; each slab placement contributes its own extents.
  #---------------------------------------------------------------------------
  def compute_shadow_layout(config, src_w, src_h, tw, th)
    height_val = (config["height"] || 0.6).to_f.abs
    direction = (config["direction"] || 180).to_f
    drop = drop_geometry(direction, height_val, src_w, src_h)
    return nil unless drop

    user_off_x = ((config["offsetX"] || 0).to_f * tw).round
    user_off_y = ((config["offsetY"] || 0).to_f * th).round
    user_off_x2 = ((config["secondOffsetX"] || 0).to_f * tw).round
    user_off_y2 = ((config["secondOffsetY"] || 0).to_f * th).round

    placements = []
    placements << { group_x: 0, group_y: 0, off_x: user_off_x, off_y: user_off_y }
    if config["threeDShadow"]
      placements << { group_x: 0, group_y: -src_h, off_x: user_off_x2, off_y: user_off_y2 }
    end

    left_max = right_max = above_max = below_max = 0
    placements.each do |p|
      ext = placed_extents(drop, p[:group_x], p[:group_y], p[:off_x], p[:off_y])
      left_max = ext[:left]  if ext[:left]  > left_max
      right_max = ext[:right] if ext[:right] > right_max
      above_max = ext[:above] if ext[:above] > above_max
      below_max = ext[:below] if ext[:below] > below_max
    end

    pad = 4 * tw
    left_pad_aligned = ((left_max + tw - 1) / tw) * tw
    above_pad_aligned = ((above_max + th - 1) / th) * th
    anchor_x = pad + left_pad_aligned
    anchor_y = pad + above_pad_aligned
    out_w = anchor_x + right_max + pad
    out_h = anchor_y + below_max + pad

    {
      anchor_x: anchor_x, anchor_y: anchor_y,
      out_w: out_w, out_h: out_h,
      drop: drop, placements: placements,
    }
  end

  def drop_geometry(direction, height_val, src_w, src_h)
    rad = direction * Math::PI / 180.0
    dir_x = Math.sin(rad)
    dir_y = -Math.cos(rad)
    l = height_val * src_h
    skew_x = (l * dir_x).round
    abs_skew = skew_x.abs
    # Floor flat_h to min(skew_min_cap, abs_skew) so near-EW directions still
    # have enough rows for the skew to spread the silhouette across; otherwise
    # the line would collapse to a single row that can't extend in any
    # direction. Cap keeps diagonals untouched.
    skew_min_cap = 4
    skew_floor = [skew_min_cap, abs_skew].min
    flat_h = [1, skew_floor, (l * dir_y.abs).round].max
    downward = dir_y > 0
    {
      flat_h: flat_h,
      skew_x: skew_x,
      abs_skew: abs_skew,
      inner_w: src_w + abs_skew,
      downward: downward,
      slab_anchor_x: skew_x < 0 ? abs_skew : 0,
      slab_anchor_y: downward ? 0 : [0, flat_h - 1].max,
    }
  end

  def placed_extents(g, group_x, group_y, off_x, off_y)
    tl_x = group_x - g[:slab_anchor_x] + off_x
    tl_y = group_y - g[:slab_anchor_y] + off_y
    br_x = tl_x + g[:inner_w]
    br_y = tl_y + g[:flat_h]
    {
      left:  [0, -tl_x].max,
      right: [0,  br_x].max,
      above: [0, -tl_y].max,
      below: [0,  br_y].max,
    }
  end

  # Build drop slab bitmap (inner_w*frameCount wide, flat_h tall).
  def build_drop_slab(src_bmp, src_w, src_h, frame_count, g)
    flat_h = g[:flat_h]
    inner_w = g[:inner_w]
    skew_x = g[:skew_x]
    abs_skew = g[:abs_skew]
    downward = g[:downward]

    wide_flat = Bitmap.new(src_w * frame_count, flat_h)
    temp_bmp = Bitmap.new(src_w * frame_count, flat_h)
    temp_bmp.stretch_blt(
      Rect.new(0, 0, src_w * frame_count, flat_h),
      src_bmp,
      Rect.new(0, 0, src_w * frame_count, src_h)
    )
    if downward
      (0...flat_h).each do |y|
        wide_flat.blt(0, flat_h - 1 - y, temp_bmp, Rect.new(0, y, src_w * frame_count, 1))
      end
    else
      wide_flat.blt(0, 0, temp_bmp, Rect.new(0, 0, src_w * frame_count, flat_h))
    end
    temp_bmp.dispose

    slab_bmp = Bitmap.new(inner_w * frame_count, flat_h)
    denom = [flat_h - 1, 1].max
    slab_anchor_x_local = skew_x < 0 ? abs_skew : 0
    frame_count.times do |frame|
      src_col_x = frame * src_w
      dst_col_x = frame * inner_w
      (0...flat_h).each do |r|
        dist = downward ? r : (flat_h - 1 - r)
        off = (dist.to_f * skew_x / denom).round
        slab_x = slab_anchor_x_local + off
        slab_bmp.blt(dst_col_x + slab_x, r, wide_flat, Rect.new(src_col_x, r, src_w, 1))
      end
    end
    wide_flat.dispose
    slab_bmp
  end

  # Compose one frame of one slab placement into shadow_bmp.
  def blt_slab_placement(shadow_bmp, col_x, slab_bmp, g, frame, anchor_x, anchor_y, p)
    draw_x = col_x + anchor_x + p[:group_x] - g[:slab_anchor_x] + p[:off_x]
    draw_y = anchor_y + p[:group_y] - g[:slab_anchor_y] + p[:off_y]
    shadow_bmp.blt(
      draw_x, draw_y,
      slab_bmp,
      Rect.new(frame * g[:inner_w], 0, g[:inner_w], g[:flat_h]),
    )
  end

  #---------------------------------------------------------------------------
  # Frame count for one source tile (max defines the shadow's animation length).
  #---------------------------------------------------------------------------
  def source_tile_frame_count(st, map)
    # Always resolve frame count from the RAW autotile PNG width.
    # @autotiles.frame_count is unreliable for extras: AutotileBitmaps#[]=
    # hardcodes @bitmap_wraps[name]=false, so wrap-layout extras report
    # 2x the true count. Raw width / 96 is layout-independent.
    resolve = lambda do |name|
      autotile_frame_count_by_name(name)
    end

    if st["autotile_name"]
      return resolve.call(st["autotile_name"])
    end
    tile_id = st["tileId"].to_i
    if st["tileset_id"]
      ts = $data_tilesets[st["tileset_id"].to_i]
      return 1 unless ts
      if tile_id < MakerStudio::TILESET_START_ID && tile_id > 0
        idx = (tile_id / MakerStudio::TILES_PER_AUTOTILE) - 1
        return 1 if idx < 0 || idx >= ts.autotile_names.length
        return resolve.call(ts.autotile_names[idx])
      end
      return 1
    end
    if tile_id < MakerStudio::TILESET_START_ID && tile_id > 0
      idx = (tile_id / MakerStudio::TILES_PER_AUTOTILE) - 1
      return 1 if idx < 0 || idx >= map.autotile_names.length
      name = map.autotile_names[idx]
      # Map's own autotiles: try @autotiles.frame_count (wraps tracked correctly
      # via AutotileBitmaps#add), else fall back to raw.
      if @autotiles && @autotiles[name]
        fc = @autotiles.frame_count(name)
        return fc if fc && fc > 0
      end
      return resolve.call(name)
    end
    return 1
  end

  def autotile_raw_frame_count(raw)
    return 1 unless raw && !raw.disposed?
    tw = MakerStudio::TILE_WIDTH
    th = MakerStudio::TILE_HEIGHT
    # Mini autotile (single row, 32px tall) = N frames × 32px horizontally.
    if raw.height <= th
      return [raw.width / tw, 1].max
    end
    # Standard RMXP autotile = N frames × 96px horizontally (3-tile wide block).
    [raw.width / (3 * tw), 1].max
  end

  # Frame count for a named autotile — parses Essentials' [N] prefix first
  # (since AnimatedBitmap.deanimate strips animation info from the bitmap),
  # then falls back to raw width.  `MyAuto.png` → width-based; `[3]MyAuto.png`
  # → 3 regardless of bitmap.width.
  def autotile_frame_count_by_name(name)
    return 1 unless name
    if name =~ /^\[(\d+)(?:,\d+)?\]/
      return [$1.to_i, 1].max
    end
    raw = MakerStudio.get_extra_autotile(name)
    autotile_raw_frame_count(raw)
  end

  #---------------------------------------------------------------------------
  # Source rect for an autotile pattern at a given animation frame.
  # Mirrors AutotileBitmaps#set_src_rect (handles wrap layout).
  #---------------------------------------------------------------------------
  def autotile_src_rect(expanded, pattern, frame, tw, th)
    tpa = MakerStudio::TILES_PER_AUTOTILE
    # Single-tile autotile (raw 32px tall returned unchanged by expander).
    # Only one row exists, so patterns all map to sy=0.
    if expanded.height <= th
      return Rect.new(frame * tw, 0, tw, th)
    end
    wraps = expanded.height < (tpa * th)
    high_id = pattern >= (tpa / 2)
    sx = 0
    sy = pattern * th
    if wraps && high_id
      sx = tw
      sy -= th * (tpa / 2)
    end
    sx += frame * tw * (wraps ? 2 : 1)
    # Safety clamp — out-of-bounds sy produces invisible blit silently.
    sy = 0 if sy + th > expanded.height
    Rect.new(sx, sy, tw, th)
  end

  #---------------------------------------------------------------------------
  # Blit a single tile onto a bitmap at (px, py) at animation frame `frame`.
  # tile_data (optional) carries cross-tileset / extra autotile info from
  # ShadowSourceTile — falls back to the map's own tileset/autotiles.
  # Honors per-tile flipH/flipV/rotation so shadow silhouettes match the
  # painted tile's actual shape (editor-side does the same in shadow-generator).
  #---------------------------------------------------------------------------
  def blit_tile_to_bitmap(dest, tile_id, px, py, map, tile_data = nil, frame = 0)
    flipH = tile_data && tile_data["flipH"]
    flipV = tile_data && tile_data["flipV"]
    rotation = ((tile_data && tile_data["rotation"]) || 0).to_i % 360
    if flipH || flipV || rotation != 0
      tw = MakerStudio::TILE_WIDTH
      th = MakerStudio::TILE_HEIGHT
      tmp = Bitmap.new(tw, th)
      blit_tile_to_bitmap_raw(tmp, tile_id, 0, 0, map, tile_data, frame)
      apply_tile_transform_blit(dest, tmp, px, py, flipH, flipV, rotation)
      tmp.dispose
      return
    end
    blit_tile_to_bitmap_raw(dest, tile_id, px, py, map, tile_data, frame)
  end

  #---------------------------------------------------------------------------
  # Pixel-level transform copy: rotate (0/90/180/270) then flipH/flipV.
  # Used for shadow silhouette generation where per-tile flip/rotation must
  # be reflected in the alpha mask. Slow (per-pixel), but shadow bitmaps are
  # cached so this only runs once per shadow generation.
  #---------------------------------------------------------------------------
  def apply_tile_transform_blit(dest, src, dx, dy, flipH, flipV, rotation)
    sw = src.width
    sh = src.height
    rot = rotation % 360
    out_w = (rot == 90 || rot == 270) ? sh : sw
    out_h = (rot == 90 || rot == 270) ? sw : sh
    out_w.times do |i|
      out_h.times do |j|
        case rot
        when 90  then sx = j;             sy = sw - 1 - i
        when 180 then sx = sw - 1 - i;    sy = sh - 1 - j
        when 270 then sx = sh - 1 - j;    sy = i
        else          sx = i;             sy = j
        end
        c = src.get_pixel(sx, sy)
        next if c.alpha == 0
        x = flipH ? (out_w - 1 - i) : i
        y = flipV ? (out_h - 1 - j) : j
        dest.set_pixel(dx + x, dy + y, c)
      end
    end
  end

  def blit_tile_to_bitmap_raw(dest, tile_id, px, py, map, tile_data = nil, frame = 0)
    tw = MakerStudio::TILE_WIDTH
    th = MakerStudio::TILE_HEIGHT
    tpa = MakerStudio::TILES_PER_AUTOTILE

    # Case A: Extra autotile by name — use expanded autotile bitmap (48-row layout)
    if tile_data && tile_data["autotile_name"]
      name = tile_data["autotile_name"]
      raw = MakerStudio.get_extra_autotile(name)
      return unless raw && !raw.disposed?
      expanded = (defined?(AutotileExpander) ? AutotileExpander.expand(raw) : raw)
      return unless expanded && !expanded.disposed?
      pattern = (tile_data["autotile_pattern"] || 0).to_i
      fc = autotile_raw_frame_count(raw)
      f = fc > 0 ? frame % fc : 0
      dest.blt(px, py, expanded, autotile_src_rect(expanded, pattern, f, tw, th))
      return
    end

    # Case B: Cross-tileset reference — blit from referenced tileset
    if tile_data && tile_data["tileset_id"]
      ts = $data_tilesets[tile_data["tileset_id"].to_i]
      if ts
        src = MakerStudio.get_extra_tileset(ts.tileset_name)
        if src && !src.disposed?
          if tile_id >= MakerStudio::TILESET_START_ID
            i = tile_id - MakerStudio::TILESET_START_ID
            src_x = (i % MakerStudio::TILESET_TILES_PER_ROW) * tw
            src_y = (i / MakerStudio::TILESET_TILES_PER_ROW) * th
            dest.blt(px, py, src, Rect.new(src_x, src_y, tw, th))
          elsif tile_id > 0
            autotile_index = (tile_id / tpa) - 1
            if autotile_index >= 0 && autotile_index < ts.autotile_names.length
              name = ts.autotile_names[autotile_index]
              raw = MakerStudio.get_extra_autotile(name)
              if raw && !raw.disposed?
                expanded = (defined?(AutotileExpander) ? AutotileExpander.expand(raw) : raw)
                pattern = tile_id % tpa
                fc = autotile_raw_frame_count(raw)
                f = fc > 0 ? frame % fc : 0
                dest.blt(px, py, expanded, autotile_src_rect(expanded, pattern, f, tw, th))
              end
            end
          end
        end
      end
      return
    end

    # Case C: Default — map's own tileset/autotiles
    if tile_id >= MakerStudio::TILESET_START_ID
      filename = map.tileset_name
      src = @tilesets[filename]
      return unless src && !src.disposed?
      i = tile_id - MakerStudio::TILESET_START_ID
      src_x = (i % MakerStudio::TILESET_TILES_PER_ROW) * tw
      src_y = (i / MakerStudio::TILESET_TILES_PER_ROW) * th
      dest.blt(px, py, src, Rect.new(src_x, src_y, tw, th))
    elsif tile_id > 0
      autotile_index = (tile_id / tpa) - 1
      return if autotile_index < 0 || autotile_index >= map.autotile_names.length
      filename = map.autotile_names[autotile_index]
      src = @autotiles[filename]
      return unless src && !src.disposed?
      pattern = tile_id % tpa
      fc = @autotiles.frame_count(filename)
      f = fc > 0 ? frame % fc : 0
      dest.blt(px, py, src, autotile_src_rect(src, pattern, f, tw, th))
    end
  end

  #---------------------------------------------------------------------------
  # Dispose extended layer sprites
  #---------------------------------------------------------------------------
  def dispose_extended_sprites
    @extended_tile_sprites.each { |spr| spr.dispose rescue nil }
    @extended_tile_sprites.clear
    @tile_sprites_by_map_row = {}
    @shadow_sprites.clear if @shadow_sprites
    @last_visible_extended_sprites.clear if @last_visible_extended_sprites
    @__shadow_anim_logged = false
    # Fog sprites are managed per-map in ensure_extended_sprites — do NOT call
    # dispose_all_fog_sprites here (it clears scroll offsets unnecessarily).
  end

  #---------------------------------------------------------------------------
  # Check if a factory map's display area overlaps the screen viewport.
  # Used to skip per-frame work for off-screen connected maps.
  #---------------------------------------------------------------------------
  def map_screen_visible?(map, mdx, mdy)
    # Camera viewport in map-local coords: [mdx, mdx+Graphics.width) x [mdy, mdy+Graphics.height)
    # Map tile area: [0, map_pw) x [0, map_ph)
    # Visible when the two rectangles overlap.
    map_pw = map.width * DISPLAY_TILE_WIDTH
    map_ph = map.height * DISPLAY_TILE_HEIGHT
    return false if mdx >= map_pw
    return false if mdx + Graphics.width <= 0
    return false if mdy >= map_ph
    return false if mdy + Graphics.height <= 0
    return true
  end

  #---------------------------------------------------------------------------
  # Apply native layer per-tile properties to existing tile sprites.
  # Called every frame after the native renderer updates @tiles.
  # Uses the sparse nativeProperties map to only visit tiles with properties.
  # Now supports extra autotiles and cross-tileset tiles on native layers.
  #---------------------------------------------------------------------------
  def apply_native_tile_properties
    return unless $map_factory
    scr_w = @tiles_horizontal_count
    scr_h = @tiles_vertical_count
    tone = @tone
    color = @color
    $map_factory.maps.each do |map|
      ext_data = MakerStudio.get_extended_data_for(map.map_id)
      if !ext_data
        next unless map&.instance_variable_get(:@map)
        ext_data = DataStore.get_extended_data(map.map_id, map.width, map.height, map)
        MakerStudio.load_extended_layers_for_map(map.map_id, map) if ext_data
      end
      next unless ext_data
      # Row-indexed view: skips all property entries on rows outside the viewport
      # without iterating them. Huge win on maps with many native extra autotile
      # / per-tile-property tiles spread across rows the camera doesn't see.
      by_row = MakerStudio.native_props_by_row_for(map.map_id)
      next unless by_row

      # Calculate per-map display offset (same formula as the native update loop)
      map_display_x = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      map_display_x = ((map_display_x + (Graphics.width / 2)) * ZOOM_X) - (Graphics.width / 2) if ZOOM_X != 1
      map_display_y = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      map_display_y = ((map_display_y + (Graphics.height / 2)) * ZOOM_Y) - (Graphics.height / 2) if ZOOM_Y != 1
      map_dx_tile = map_display_x / DISPLAY_TILE_WIDTH
      map_dy_tile = map_display_y / DISPLAY_TILE_HEIGHT
      # Skip off-screen maps — avoid iterating native properties for maps
      # whose display area is completely outside the viewport.
      next unless map_screen_visible?(map, map_display_x, map_display_y)

      min_row = map_dy_tile
      max_row = map_dy_tile + scr_h - 1
      min_col = map_dx_tile
      max_col = map_dx_tile + scr_w - 1

      MakerStudio::NATIVE_LAYERS.times do |layer|
        rows = by_row[layer]
        next unless rows
        rows.each do |tile_y, entries|
          next if tile_y < min_row || tile_y > max_row
          screen_j = tile_y - map_dy_tile
          # Entries are sorted by col, so we can stop iterating as soon as
          # we pass max_col instead of scanning the whole row.
          entries.each do |entry|
            tile_x = entry[0]
            next if tile_x < min_col
            break if tile_x > max_col
            screen_i = tile_x - map_dx_tile
            props = entry[1]
            has_effects = entry[2]
            sprite = @tiles[screen_i][screen_j][layer]
            next if sprite.disposed?
            apply_native_tile_props_to_sprite(sprite, props, has_effects, map, screen_i, screen_j, tone, color)
          end
        end
      end
    end
  end

  #---------------------------------------------------------------------------
  # Per-sprite hot path. Cheap when the binding + effects signatures match
  # the previous frame (most frames, unless the base renderer reassigned
  # the sprite by scrolling).
  #---------------------------------------------------------------------------
  def apply_native_tile_props_to_sprite(sprite, props, has_effects, map, screen_i, screen_j, tone, color)
    # ---- Extra autotile on native layer -------------------------------------
    autotile_name = props["autotile_name"]
    if autotile_name
      target_bmp = @autotiles[autotile_name]
      unless target_bmp && !target_bmp.disposed?
        register_extra_autotile_in_engine(autotile_name)
        target_bmp = @autotiles[autotile_name]
      end
      if target_bmp && !target_bmp.disposed?
        pattern = (props["autotile_pattern"] || 0).to_i
        virtual_tile_id = 8 * MakerStudio::TILES_PER_AUTOTILE + pattern
        priority = resolve_tile_priority(0, props, map)
        sprite.set_bitmap(autotile_name, virtual_tile_id, true, true, priority, target_bmp)
        @autotiles.set_src_rect(sprite, virtual_tile_id)
        sprite.visible = true
      else
        sprite.visible = false
      end
      finalize_native_prop_sprite(sprite, props, has_effects, map, screen_i, screen_j, 0, tone, color)
      return
    end

    # ---- Cross-tileset reference on native layer ----------------------------
    ts_id = props["tileset_id"]
    if ts_id
      ts = $data_tilesets[ts_id.to_i]
      tile_id = sprite.tile_id
      if ts && setup_cross_tileset_sprite_bitmap(sprite, tile_id, ts, props, map)
        sprite.visible = true
      else
        sprite.visible = false
      end
      finalize_native_prop_sprite(sprite, props, has_effects, map, screen_i, screen_j, tile_id, tone, color)
      return
    end

    # ---- Standard native tile with per-tile properties only -----------------
    return if !sprite.visible
    pri = props["priority"]
    if pri
      pri = pri.to_i
      sprite.priority = pri if sprite.priority != pri
    end
    finalize_native_prop_sprite(sprite, props, has_effects, map, screen_i, screen_j, sprite.tile_id, tone, color)
  end

  #---------------------------------------------------------------------------
  # Apply per-tile visual state (opacity / rotation / flip / hue / sat / etc).
  # When `has_effects` is false (the common case — props carries only
  # collision/terrain overrides), skip the apply_to_sprite hot path and reset
  # the sprite to defaults directly. Saves ~15 hash lookups + a hash alloc
  # (no `props.merge`) per visible native-prop tile per frame.
  #---------------------------------------------------------------------------
  def apply_native_visual_state(sprite, props, has_effects, tile_id, tone, color)
    if has_effects
      sprite.zoom_y = ZOOM_Y if sprite.zoom_y < 0
      enriched = props.merge("tile_id" => tile_id)
      MakerStudio::TileEffects.apply_to_sprite(sprite, enriched, @tilesets, @autotiles)
    else
      # Trivial props — bring sprite back to defaults so any stale state from
      # a previous frame's tile assignment is cleared.
      sprite.opacity = 255
      sprite.angle = 0
      sprite.tone = MakerStudio::TileEffects::ZERO_TONE
      sprite.mirror = false
      sprite.zoom_y = ZOOM_Y if sprite.zoom_y < 0
      sprite.ox = 0
      sprite.oy = 0
    end
    sprite.tone = tone if tone
    sprite.color = color if color
  end

  #---------------------------------------------------------------------------
  # Register an extra autotile bitmap with @autotiles (the engine's
  # AutotileBitmaps). Pulled out of the hot loop so the common path
  # (bitmap already registered) is one hash lookup + identity check.
  #---------------------------------------------------------------------------
  def register_extra_autotile_in_engine(autotile_name)
    raw_bmp = MakerStudio.get_extra_autotile(autotile_name)
    return unless raw_bmp && !raw_bmp.disposed?
    durations = @autotiles.instance_variable_get(:@frame_durations)
    unless durations.key?(autotile_name)
      durations[autotile_name] = TilemapRenderer::AUTOTILE_FRAME_DURATION.to_f / 20
    end
    expanded_bmp = AutotileExpander.expand(raw_bmp)
    return unless expanded_bmp
    @autotiles[autotile_name] = expanded_bmp
    load_counts = @autotiles.instance_variable_get(:@load_counts)
    load_counts[autotile_name] ||= 1 if load_counts
    if expanded_bmp.height > MakerStudio::TILE_HEIGHT &&
       expanded_bmp.height < MakerStudio::TILES_PER_AUTOTILE * MakerStudio::TILE_HEIGHT
      wraps_hash = @autotiles.instance_variable_get(:@bitmap_wraps)
      wraps_hash[autotile_name] = true if wraps_hash
      @autotiles.frame_count(autotile_name, true)
    end
  end

  #---------------------------------------------------------------------------
  # Set native tile z. A native tile keeps its OWN priority, but only renders
  # overhead (above the player) when its layer is above the cell's highest
  # ground tile (cell_ground_cap) — a ground tile on a higher layer covers
  # everything beneath it. Otherwise it's a ground tile:
  #   ground:   passable z=0 → shadow z=1 → non-passable / source z=2
  #             (shadow split; z=0 when no shadows)
  #   overhead: z = screen-y based + own priority, above the player, + a tiny
  #             per-native-layer offset (kept below the extended layers' z
  #             offset so extended draws above native)
  # Runs every frame because the engine reuses the screen-sized sprite grid and
  # resets native z as the map scrolls. Extended tiles get their z in
  # create_extended_sprites_for_map / Pass 2.
  # ponytail: per-frame triple loop over visible native cells for every map;
  # the cap lookup is O(1) (cached). Bake a screen-region buffer if it lags.
  #---------------------------------------------------------------------------
  def adjust_ground_z_for_shadows
    return unless $map_factory
    $map_factory.maps.each do |map|
      next unless map
      rpg_map = map.instance_variable_get(:@map)
      next unless rpg_map
      ext_data = MakerStudio.get_extended_data_for(map.map_id)
      next unless ext_data
      caps = MakerStudio.cell_caps_for(map)
      map_w = map.width

      # Shadow-split data — only needed for GROUND cells when this map has
      # visible shadows. Overhead cells render above shadows regardless.
      shadows = ext_data["shadowLayers"] || []
      shadows = [ext_data["shadowLayer"]].compact if shadows.empty?
      has_shadows = !shadows.empty? && shadows.any? { |s| s["visible"] }
      source_keys = nil
      passages = nil
      if has_shadows
        tileset = $data_tilesets[rpg_map.tileset_id]
        if tileset
          passages = tileset.passages
          # Cached per map: integer key (y*map_w+x) => tile_id, no per-frame strings.
          cache = MakerStudio.instance_variable_get(:@shadow_source_tiles_cache)
          source_entry = cache[map.map_id]
          if !source_entry || source_entry[:map_w] != map_w
            sk = {}
            shadows.each do |shadow|
              next unless shadow["visible"]
              (shadow["sourceTiles"] || []).each do |st|
                sk[st["y"].to_i * map_w + st["x"].to_i] = st["tileId"].to_i
              end
            end
            source_entry = { map_w: map_w, keys: sk }
            cache[map.map_id] = source_entry
          end
          source_keys = source_entry[:keys]
        else
          has_shadows = false
        end
      end

      # Compute display offset: screen coords → map coords
      mdx = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      mdx = ((mdx + (Graphics.width / 2)) * ZOOM_X) - (Graphics.width / 2) if ZOOM_X != 1
      mdy = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      mdy = ((mdy + (Graphics.height / 2)) * ZOOM_Y) - (Graphics.height / 2) if ZOOM_Y != 1
      dx_tile = mdx / DISPLAY_TILE_WIDTH
      dy_tile = mdy / DISPLAY_TILE_HEIGHT
      # Skip off-screen maps whose display area is outside the viewport.
      next unless map_screen_visible?(map, mdx, mdy)

      # Native props loaded for both overhead own-priority resolution and the
      # shadow-split passage lookup.
      native_props = ext_data["nativeProperties"]
      map_h = map.height
      scr_w = @tiles_horizontal_count
      scr_h = @tiles_vertical_count
      MakerStudio::NATIVE_LAYERS.times do |layer|
        layer_props = native_props ? native_props[layer] : nil
        (0...scr_w).each do |i|
          tile_x = i + dx_tile
          next if tile_x < 0 || tile_x >= map_w
          (0...scr_h).each do |j|
            sprite = @tiles[i][j][layer]
            next if !sprite || sprite.disposed? || !sprite.visible
            tid = sprite.tile_id
            next if tid <= 0
            tile_y = j + dy_tile
            # Skip tiles outside this map's bounds (belong to a connected map).
            next if tile_y < 0 || tile_y >= map_h
            idx = tile_y * map_w + tile_x
            entry = layer_props ? layer_props["#{tile_x},#{tile_y}"] : nil
            # Native layer index IS its unified layer (0-2). Overhead iff above
            # the cell's highest ground tile (then the tile keeps its own priority).
            if layer > (caps[idx] || -1)
              own_pri = resolve_tile_priority(tid, entry, map)
              sprite.z = (j * SOURCE_TILE_HEIGHT) +
                         (own_pri * SOURCE_TILE_HEIGHT) +
                         SOURCE_TILE_HEIGHT + 1 + (layer * 0.0001)
            elsif has_shadows
              p = resolve_shadow_tile_passage(tid, entry, passages)
              if source_keys[idx] == tid || (p && (p & 0x0F) == 0x0F)
                sprite.z = 2  # source / non-passable: above shadow
              else
                sprite.z = 0  # passable ground: below shadow
              end
            else
              sprite.z = 0  # ground, no shadows
            end
          end
        end
      end
    end
  end

  alias __mkst__update update unless method_defined?(:__mkst__update)
  def update
    __mkst__update
    if MakerStudio::ENABLED
      ensure_extended_sprites
      MakerStudio.update_fog_sprites
      # Build per-map display offset table and viewport visibility set
      map_offsets = {}
      visible_map_ids = {}
      if $map_factory
        $map_factory.maps.each do |map|
          mdx = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
          mdx = ((mdx + (Graphics.width / 2)) * ZOOM_X) - (Graphics.width / 2) if ZOOM_X != 1
          mdy = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
          mdy = ((mdy + (Graphics.height / 2)) * ZOOM_Y) - (Graphics.height / 2) if ZOOM_Y != 1
          map_offsets[map.map_id] = [mdx, mdy]
          visible_map_ids[map.map_id] = map_screen_visible?(map, mdx, mdy)
        end
      end
      # Pre-compute screen bounds for off-screen culling
      scr_w = @tiles_horizontal_count
      scr_h = @tiles_vertical_count
      # --- Pass 1: Hide only sprites that were visible last frame ---
      # Iterating @extended_tile_sprites in full meant 5000+ setter calls per
      # frame on big maps. last_visible holds exactly the sprites Pass 2/3
      # turned on previously — usually a small fraction of total.
      last_visible = @last_visible_extended_sprites
      last_visible.each do |sprite|
        next if sprite.disposed?
        sprite.visible = false
      end
      last_visible.clear
      # --- Pass 2: Position tile sprites via spatial row index ---
      # Only iterates sprites in rows overlapping the viewport. Skips the
      # majority of sprites on large maps with many extended layers, extra
      # autotiles, and cross-tileset tiles.
      pass_tone = @tone
      pass_color = @color
      visible_map_ids.each do |map_id, is_visible|
        next unless is_visible
        rows = @tile_sprites_by_map_row[map_id]
        next unless rows
        offsets = map_offsets[map_id]
        next unless offsets
        mdx, mdy = offsets
        # Hoist division/modulo out of inner loops — these are per-map constants.
        dx_tile = mdx / DISPLAY_TILE_WIDTH
        dy_tile = mdy / DISPLAY_TILE_HEIGHT
        dx_rem = mdx % DISPLAY_TILE_WIDTH
        dy_rem = mdy % DISPLAY_TILE_HEIGHT
        min_row = dy_tile - 8
        max_row = dy_tile + scr_h + 8
        rows.each do |row, sprites|
          next if row < min_row || row > max_row
          sprites.each do |sprite|
            next if sprite.disposed?
            i = sprite.map_x - dx_tile
            j = sprite.map_y - dy_tile
            next if i < -8 || j < -8 || i > scr_w + 8 || j > scr_h + 8
            sprite.visible = true
            last_visible << sprite
            sprite.tone = pass_tone if pass_tone
            sprite.color = pass_color if pass_color
            sprite.x = (i * DISPLAY_TILE_WIDTH) - dx_rem
            sprite.y = (j * DISPLAY_TILE_HEIGHT) - dy_rem
            if sprite.ox != 0 || sprite.oy != 0
              sprite.x += (sprite.ox * sprite.zoom_x.abs).round
              sprite.y += (sprite.oy * sprite.zoom_y.abs).round
            end
            # Recompute z for OVERHEAD-band sprites in screen-y space. The band
            # (effective priority — own priority when above the cell's ground cap,
            # else 0) is stored on the sprite at creation.
            cb = sprite.cell_band
            if cb && cb > 0
              sprite.z = (j * SOURCE_TILE_HEIGHT) +
                         (cb * SOURCE_TILE_HEIGHT) +
                         SOURCE_TILE_HEIGHT + 1 + (sprite.ext_z_offset || 0)
            end
            if sprite.animated
              @autotiles.set_src_rect(sprite, sprite.tile_id)
            end
          end
        end
      end
      # --- Pass 3: Shadow sprites via dedicated list ---
      # Shadow sprites span multiple rows so the spatial row index doesn't
      # apply. @shadow_sprites holds only shadows, skipping the per-iteration
      # `next unless sprite.shadow_frame_count` filter the old flat scan paid.
      @shadow_sprites.each do |sprite|
        next if sprite.disposed?
        next unless visible_map_ids[sprite.map_id]
        offsets = map_offsets[sprite.map_id]
        next unless offsets
        mdx, mdy = offsets
        dx_tile = mdx / DISPLAY_TILE_WIDTH
        dy_tile = mdy / DISPLAY_TILE_HEIGHT
        i = sprite.map_x - dx_tile
        j = sprite.map_y - dy_tile
        bmp_tw = (sprite.shadow_frame_w || 32) / DISPLAY_TILE_WIDTH
        bmp_th = (sprite.bitmap&.height || 32) / DISPLAY_TILE_HEIGHT
        next if (i + bmp_tw) < -8 || (j + bmp_th) < -8 || i > scr_w + 8 || j > scr_h + 8
        sprite.visible = true
        last_visible << sprite
        sprite.tone = pass_tone if pass_tone
        sprite.color = pass_color if pass_color
        sprite.x = (i * DISPLAY_TILE_WIDTH) - (mdx % DISPLAY_TILE_WIDTH)
        sprite.y = (j * DISPLAY_TILE_HEIGHT) - (mdy % DISPLAY_TILE_HEIGHT)
        if sprite.ox != 0 || sprite.oy != 0
          sprite.x += (sprite.ox * sprite.zoom_x.abs).round
          sprite.y += (sprite.oy * sprite.zoom_y.abs).round
        end
        # Animated shadow sprites: cycle src_rect.x through frame columns.
        if sprite.shadow_frame_count > 1
          fc = sprite.shadow_frame_count
          src_frame =
            if sprite.shadow_anim_source_name &&
               (cf = @autotiles.current_frames[sprite.shadow_anim_source_name])
              cf % fc
            else
              MakerStudio.shadow_current_frame(fc)
            end
          frame = (fc - 1) - src_frame
          sprite.src_rect.x = frame * sprite.shadow_frame_w
          unless @__shadow_anim_logged
            Console.echoln("MakerStudio Shadow anim: fc=#{fc} fw=#{sprite.shadow_frame_w} src=#{src_frame} shown=#{frame} sync=#{sprite.shadow_anim_source_name || 'timer'}") if defined?(Console)
            @__shadow_anim_logged = true
          end
        end
      end
      # Apply native layer per-tile properties (rotation, flip, opacity, etc.)
      apply_native_tile_properties
      # Adjust native ground z-ordering for shadow pass splitting
      adjust_ground_z_for_shadows
    end
  end
end
