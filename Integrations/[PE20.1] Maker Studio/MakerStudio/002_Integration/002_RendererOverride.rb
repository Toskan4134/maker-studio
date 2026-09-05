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
  # Sprite-bindable copies of the above: a tileset taller than the GPU's max
  # texture size is a mega surface, which mkxp refuses to bind to a Sprite, so it
  # gets folded into columns (see get_extra_tileset_for_sprite). Keyed by tileset
  # name; @extra_tileset_wrapped records which ones were actually folded (their
  # src_rects must be folded too).
  @extra_tileset_sprite_cache = {}
  @extra_tileset_wrapped = {}
  # Cache for shadow layer bitmaps (by shadow layer id + map_id) — value is
  # [bitmap, frame_count, frame_w] when the shadow contains animated autotiles.
  @shadow_bitmap_cache = {}
  # Shared timer for shadow frame animation
  @shadow_timer_start = nil
  # Cache for pre-tinted 32×32 tile silhouettes used by shadow generation.
  # Keyed by tile identity + frame + tint hex; survives across all shadows on
  # all maps in the session so the costly per-pixel tint loop runs at most once
  # per (tile, tint, frame) combination instead of per shadow.
  @tinted_tile_cache = {}
  # Per-map cell index of native layer properties:
  #   { map_id => [ layer_idx => { (y * map_w + x) => [props, has_visual_effects?] } ] }
  # Integer keys (no per-frame "x,y" string building). Looked up only when the
  # engine (re)binds a cell's tile sprite — never scanned per frame.
  #
  # has_visual_effects? is precomputed once per props: when false, the bind path
  # replaces the TileEffects.apply_to_sprite call with cheap direct setters. The
  # bulk of native extra-autotile / per-tile-property tiles carry only collision
  # or terrain overrides, so most entries are trivial.
  @native_props_index_cache = {}
  # Per-map extended layer index, sorted by layer id, VISIBLE layers only:
  #   { map_id => [ { "id", "opacity", :tiles => { (y * map_w + x) => tile_data } } ] }
  # The screen-cell sprite pool asks "what sits at this cell on this layer?" and
  # nothing else, so extended tiles cost what the camera sees, not what the map holds.
  @ext_layer_index_cache = {}
  # Per-map shadow environment: { has_shadows, source_keys, passages }. Decides
  # whether a ground tile draws above or below the map's shadows.
  @shadow_env_cache = {}
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
    # v20.1 has no System.uptime (added in v21.1) — its own TilemapRenderer
    # animates autotiles off Graphics.delta_s, so derive elapsed seconds from
    # the frame counter, which is monotonic on every RGSS/mkxp build.
    duration = TilemapRenderer::AUTOTILE_FRAME_DURATION.to_f / 20
    return 0 if duration <= 0
    rate = Graphics.frame_rate
    return 0 if !rate || rate <= 0
    elapsed = Graphics.frame_count.to_f / rate
    return (elapsed / duration).floor % frame_count
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
    drop_map_indices(map_id)
  end

  # Drop every lazily-built per-map index derived from the extended data.
  def drop_map_indices(map_id)
    @native_props_index_cache.delete(map_id) if @native_props_index_cache
    @ext_layer_index_cache.delete(map_id) if @ext_layer_index_cache
    @shadow_env_cache.delete(map_id) if @shadow_env_cache
    @cell_band_cache.delete(map_id) if @cell_band_cache
  end

  #---------------------------------------------------------------------------
  # Ground-cap resolution (see @cell_band_cache).
  #---------------------------------------------------------------------------

  # Priority of a single tile, self-contained (mirrors resolve_tile_priority /
  # resolve_autotile_priority but callable at module level for cap building).
  # Live-first like the editor's resolveTilePriority: the autotile config /
  # referenced tileset wins so tileset property edits reach already-painted
  # tiles in-game. The baked per-tile "priority" (embedded at paint time) is
  # only a fallback when the live data no longer resolves the tile (e.g.
  # Tilesets.rxdata was never re-saved with the expanded_autotiles config).
  def resolve_band_priority(map, tid, td)
    if td && td["autotile_name"]
      entry = DataStore.get_expanded_autotile(td["autotile_name"])
      return entry["priority"].to_i if entry
      idx = map.autotile_names.index(td["autotile_name"])
      return (map.priorities[(idx + 1) * MakerStudio::TILES_PER_AUTOTILE] || 0) if idx
      return td["priority"] ? td["priority"].to_i : 0
    end
    if td && td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return (ts.priorities[tid] || 0) if ts
      return td["priority"] ? td["priority"].to_i : 0
    end
    return td["priority"].to_i if td && td["priority"]
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
          entry = lp ? lp["#{x},#{y}"] : nil
          # Extra autotiles / cross-tileset overrides live at tile_id=0 with
          # props — they must raise the cap too (mirrors the sim's groundCap:
          # skip only when tid==0 AND no autotile_name AND no tileset_id).
          if (tid && tid != 0) || (entry && (entry["autotile_name"] || entry["tileset_id"]))
            if resolve_band_priority(map, tid || 0, entry) == 0
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
    @native_props_index_cache = {}
    @ext_layer_index_cache = {}
    @shadow_env_cache = {}
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
    # The tilesets may have been re-saved by the editor — drop the parsed
    # expanded-autotile config so the next lookup re-reads them.
    DataStore.clear_expanded_autotile_index if DataStore.respond_to?(:clear_expanded_autotile_index)
    if @shadow_bitmap_cache
      @shadow_bitmap_cache.each_value do |v|
        bmp = v.is_a?(Array) ? v[0] : v
        bmp.dispose if bmp && !bmp.disposed?
      end
    end
    @shadow_bitmap_cache = {}
    @extra_autotile_cache = {}
    @extra_tileset_cache = {}
    # Only the FOLDED copies are ours to dispose; the raw ones belong to RPG::Cache.
    if @extra_tileset_sprite_cache
      @extra_tileset_sprite_cache.each_pair do |k, bmp|
        next unless @extra_tileset_wrapped && @extra_tileset_wrapped[k]
        bmp.dispose if bmp && !bmp.disposed?
      end
    end
    @extra_tileset_sprite_cache = {}
    @extra_tileset_wrapped = {}
    @native_props_index_cache = {}
    @ext_layer_index_cache = {}
    @shadow_env_cache = {}
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
  # Cell-indexed view of nativeProperties for one map, built lazily and dropped
  # whenever the map's extended data is rewritten (see drop_map_indices).
  # Returns: [ layer_idx => { (y * map_w + x) => [props, has_effects?] } ]
  #---------------------------------------------------------------------------
  def native_props_index_for(map_id, map_w)
    cached = @native_props_index_cache[map_id]
    return cached if cached
    ext_data = @extended_data_cache[map_id]
    return nil unless ext_data
    native_props = ext_data["nativeProperties"]
    return nil unless native_props
    by_layer = []
    MakerStudio::NATIVE_LAYERS.times do |layer|
      layer_props = native_props[layer]
      next unless layer_props && !layer_props.empty?
      cells = {}
      layer_props.each do |key, props|
        comma = key.index(",")
        next unless comma
        idx = key[comma + 1..].to_i * map_w + key[0, comma].to_i
        cells[idx] = [props, props_has_visual_effects?(props)]
      end
      by_layer[layer] = cells
    end
    @native_props_index_cache[map_id] = by_layer
    by_layer
  end

  # Properties of one native cell, or nil. [props, has_visual_effects?].
  def native_props_at(map_id, map_w, layer, idx)
    by_layer = native_props_index_for(map_id, map_w)
    return nil unless by_layer
    cells = by_layer[layer]
    cells ? cells[idx] : nil
  end

  #---------------------------------------------------------------------------
  # Cell-indexed view of the map's VISIBLE extended layers, sorted by layer id.
  # Each entry: { "id", "opacity", :tiles => { (y * map_w + x) => tile_data } }.
  # Feeds the screen-cell sprite pool.
  #---------------------------------------------------------------------------
  def ext_layers_index_for(map_id, map_w)
    cached = @ext_layer_index_cache[map_id]
    return cached if cached
    ext_data = @extended_data_cache[map_id]
    return (@ext_layer_index_cache[map_id] = []) unless ext_data
    layers = (ext_data["layers"] || [])
      .select { |l| l["visible"] }
      .sort_by { |l| l["id"].to_i }
    index = layers.map do |layer|
      cells = {}
      (layer["tiles"] || {}).each do |key, td|
        next unless td
        next unless td["tile_id"].to_i > 0 || td["autotile_name"]
        comma = key.index(",")
        next unless comma
        idx = key[comma + 1..].to_i * map_w + key[0, comma].to_i
        cells[idx] = td
      end
      { "id" => layer["id"].to_i, "opacity" => (layer["opacity"] || 255).to_i, :tiles => cells }
    end
    @ext_layer_index_cache[map_id] = index
    index
  end

  #---------------------------------------------------------------------------
  # Shadow environment for one map: does it have visible shadows, and which
  # cells are shadow sources? Ground tiles that are a shadow source (or are
  # impassable) draw ABOVE the shadow; passable ground draws below it.
  #---------------------------------------------------------------------------
  def shadow_env_for(map)
    cached = @shadow_env_cache[map.map_id]
    return cached if cached
    ext_data = @extended_data_cache[map.map_id]
    shadows = ext_data ? (ext_data["shadowLayers"] || []) : []
    shadows = [ext_data["shadowLayer"]].compact if ext_data && shadows.empty?
    visible = shadows.select { |s| s && s["visible"] }
    env = { :has_shadows => !visible.empty?, :source_keys => {} }
    if env[:has_shadows]
      map_w = map.width
      visible.each do |shadow|
        (shadow["sourceTiles"] || []).each do |st|
          env[:source_keys][st["y"].to_i * map_w + st["x"].to_i] = st["tileId"].to_i
        end
      end
    end
    @shadow_env_cache[map.map_id] = env
    env
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

  #---------------------------------------------------------------------------
  # Sprite-bindable bitmap for a foreign (cross-tileset) tileset.
  #
  # A tileset taller than the GPU's max texture size is a "mega surface" in mkxp:
  # it can be blitted FROM (the effect/shadow strips do that with the raw bitmap
  # above), but binding it to a Sprite raises
  #   MKXPError: Operation not supported for mega surfaces
  # The engine handles its OWN tileset in TilesetBitmaps#add by folding it into
  # side-by-side columns (TilesetWrapper.wrapTileset) and folding tile src_rects
  # to match (TilesetBitmaps#set_src_rect). Cross-tileset tiles never go through
  # that collection, so fold them here — once per tileset name.
  #
  # The folded bitmap is OURS (disposed in clear_all_caches); the raw one belongs
  # to RPG::Cache and must never be disposed here.
  #---------------------------------------------------------------------------
  def get_extra_tileset_for_sprite(name)
    return nil unless name
    bmp = @extra_tileset_sprite_cache[name]
    return bmp if bmp && !bmp.disposed?
    raw = get_extra_tileset(name)
    return nil unless raw && !raw.disposed?
    folded = raw
    if raw.respond_to?(:mega?) && raw.mega? && defined?(TilemapRenderer::TilesetWrapper)
      folded = (TilemapRenderer::TilesetWrapper.wrapTileset(raw) rescue raw)
    end
    @extra_tileset_wrapped[name] = !folded.equal?(raw)
    @extra_tileset_sprite_cache[name] = folded
    folded
  end

  # src_rect of a regular tile in a foreign tileset, folded when that tileset was
  # wrapped above (mirrors TilemapRenderer::TilesetBitmaps#set_src_rect).
  def extra_tileset_src_rect(name, tile_id)
    i = tile_id - MakerStudio::TILESET_START_ID
    rect = Rect.new(
      (i % MakerStudio::TILESET_TILES_PER_ROW) * MakerStudio::TILE_WIDTH,
      (i / MakerStudio::TILESET_TILES_PER_ROW) * MakerStudio::TILE_HEIGHT,
      MakerStudio::TILE_WIDTH,
      MakerStudio::TILE_HEIGHT
    )
    if @extra_tileset_wrapped[name] && defined?(TilemapRenderer::TilesetWrapper)
      rect = (TilemapRenderer::TilesetWrapper.getWrappedRect(rect) rescue rect)
    end
    rect
  end
end

#===============================================================================
# Add map coordinate tracking to TileSprite for extended layers
#===============================================================================
class TilemapRenderer::TileSprite
  attr_accessor :map_x, :map_y
  attr_accessor :map_id   # which map this sprite belongs to (for connections)
  # Tile id to feed @autotiles.set_src_rect with when this sprite shows an EXTRA
  # autotile (painted by name, so the map Table holds 0 and the engine's own
  # tile_id can't address it). nil for ordinary tiles.
  attr_accessor :ms_src_id
  # Ground-band z for this cell (0 = below the map's shadows, 2 = above them).
  # Resolved once per bind; the per-frame z refresh just reads it.
  attr_accessor :ms_ground_z
  # Pool bookkeeping for extended-layer sprites: which data generation this
  # sprite was bound against (a reload bumps it, forcing a rebind).
  attr_accessor :ms_gen
  # Per-tile "lighting" that could NOT be baked into a bitmap (autotiles). The
  # renderer ADDS it to its day/night tone; writing it straight to sprite.tone
  # would just be overwritten by that tone.
  attr_accessor :ms_light
  # Shadow animation: width of one frame within a sprite-sheet shadow bitmap
  # and total frame count.  When frame_count > 1, sprite.src_rect.x is updated
  # each Graphics frame to cycle through frames.
  attr_accessor :shadow_frame_w, :shadow_frame_count
  # Name of the source autotile whose animation drives this shadow's frame
  # index — looked up in @autotiles.current_frames each tick so shadow stays
  # in lockstep with the source tile (instead of drifting on its own timer).
  attr_accessor :shadow_anim_source_name
  # Per-extended-layer z bias applied on top of the priority-based z formula.
  # Recorded at creation so the per-frame z recompute (which uses screen-y
  # instead of map-y) can preserve layer stacking order. MUST be a whole
  # number: Sprite#z is an Integer, so a fractional bias truncates to 0 and
  # leaves stacked extended layers sharing one z, where the draw order falls
  # back to sprite creation order — which the lazily-filled pool varies with
  # the camera, so the tiles flicker as the player walks.
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
  # z step per extended layer, above the ground band (see #ext_z_offset).
  EXT_LAYER_Z_OFFSET = 1

  # Extra ring of pooled cells kept around the screen, so a tile that rotates or
  # scales past its own cell (and a hard camera cut) still has a sprite ready.
  EXT_POOL_MARGIN = 2

  alias __mkst__initialize initialize unless method_defined?(:__mkst__initialize)
  def initialize(viewport)
    __mkst__initialize(viewport)
    # Screen-cell sprite pool for extended layers: @ext_pool[i][j][slot], sized to
    # the viewport (+ margin), NOT to the map. Sprites are created lazily and
    # rebound as the camera scrolls, so a 500x500 map with ten full extended
    # layers costs the same as a 20x20 one.
    @ext_pool = []
    @ext_gen = 0
    @ext_visible = []               # pool sprites shown last frame
    @shadow_sprites = []            # shadow sprites (map-sized bitmaps, few)
    @last_visible_shadows = []
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
    # transition frame (before the pool rebinds them).
    @ext_gen += 1
    each_ext_pool_sprite { |spr| spr.visible = false }
    @shadow_sprites.each { |spr| spr.visible = false unless spr.disposed? }
  end

  def each_ext_pool_sprite
    @ext_pool.each do |col|
      next unless col
      col.each do |cell|
        next unless cell
        cell.each { |spr| yield spr if spr && !spr.disposed? }
      end
    end
  end

  #---------------------------------------------------------------------------
  # ENGINE BIND HOOKS
  #
  # The engine rebinds a native tile sprite only when that sprite starts showing
  # a different map cell (scroll, map change, refresh) — never per frame. Maker
  # Studio's native-layer content (extra autotiles, cross-tileset tiles, per-tile
  # effects, cap-model z) is applied from inside those same hooks, so it costs
  # what changes, not what is on screen.
  #
  # An extra autotile lives in the Table as tile_id 0, so the sprite's tile_id is
  # left at the Table's value (keeping the engine's dirty check quiet) and the
  # autotile's virtual id is kept in ms_src_id for src_rect refreshes.
  #---------------------------------------------------------------------------
  alias __mkst__refresh_tile refresh_tile unless method_defined?(:__mkst__refresh_tile)
  def refresh_tile(tile, x, y, map, layer, tile_id)
    __mkst__refresh_tile(tile, x, y, map, layer, tile_id)
    return unless MakerStudio::ENABLED
    tile.ms_src_id = nil
    tile.cell_band = nil
    tile.ms_ground_z = 0
    # A recycled sprite may still carry the previous cell's lighting tone; the
    # engine's own rebind does not touch tone.
    if tile.ms_light && tile.ms_light != 0
      tile.ms_light = 0
      tile.tone = @tone if @tone
    end
    ext_data = MakerStudio.get_extended_data_for(map.map_id)
    return unless ext_data
    offs = ms_tile_offsets(map)
    tile_x = x + offs[0]
    tile_y = y + offs[1]
    tile.map_id = map.map_id
    tile.map_x = tile_x
    tile.map_y = tile_y
    return if tile_x < 0 || tile_y < 0 || tile_x >= map.width || tile_y >= map.height
    idx = tile_y * map.width + tile_x
    entry = MakerStudio.native_props_at(map.map_id, map.width, layer, idx)
    props = entry ? entry[0] : nil
    bind_native_prop_tile(tile, props, entry && entry[1], map, tile_id) if props
    # The engine took shows_reflection / bridge from the MAP's tileset terrain tag
    # for the id in the Table. A cross-tileset tile keeps its FOREIGN tileset's id
    # there, so that terrain belongs to an unrelated tile — re-derive both from the
    # tileset the tile actually came from.
    apply_cross_tileset_terrain_flags(tile, props) if props && props["tileset_id"]
    # Cap model: a tile only renders overhead (above the player) when its OWN
    # priority is >= 1 AND its layer sits above the cell's highest ground tile.
    own_pri = props ? resolve_tile_priority(tile.tile_id, props, map) : tile.priority
    tile.cell_band = (own_pri >= 1 && layer > MakerStudio.cell_ground_cap(map, tile_x, tile_y)) ? own_pri : 0
    tile.ms_ground_z = ground_band_z(map, idx, tile.tile_id, props)
    refresh_tile_coordinates(tile, x, y)
    refresh_tile_z(tile, map, y, layer, tile_id)
    # set_bitmap re-arms need_refresh; leaving it armed would make the engine
    # rebind this sprite again next frame, and every frame after that.
    tile.need_refresh = false
  end

  # Bind an extra autotile / cross-tileset tile / per-tile effects onto a native
  # layer sprite. Runs on (re)bind only.
  def bind_native_prop_tile(tile, props, has_effects, map, table_tile_id)
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
        tile.set_bitmap(autotile_name, virtual_tile_id, true, true, priority, target_bmp)
        @autotiles.set_src_rect(tile, virtual_tile_id)
        tile.ms_src_id = virtual_tile_id
        # The Table holds 0 here; keeping the sprite's tile_id in sync with it
        # stops the engine from re-refreshing this sprite every single frame.
        tile.tile_id = table_tile_id
        tile.visible = true
      else
        tile.visible = false
      end
      apply_native_visual_state(tile, props, has_effects, 0)
      return
    end

    ts_id = props["tileset_id"]
    if ts_id
      ts = $data_tilesets[ts_id.to_i]
      tile_id = tile.tile_id
      if ts && setup_cross_tileset_sprite_bitmap(tile, tile_id, ts, props, map)
        tile.visible = true
      else
        tile.visible = false
      end
      apply_native_visual_state(tile, props, has_effects, tile_id)
      return
    end

    return unless tile.visible
    pri = props["priority"]
    tile.priority = pri.to_i if pri
    apply_native_visual_state(tile, props, has_effects, tile.tile_id)
  end

  # A tile's lighting and the renderer's day/night filter are both a Tone, so they
  # have to be COMBINED. Every bind path used to assign the day/night tone last,
  # which silently erased the tile's lighting.
  def ms_tone_with_light(light)
    return @tone if light.nil? || light == 0
    up = light > 0 ? light : 0
    gray = light < 0 ? -light : 0
    base = @tone
    return Tone.new(up, up, up, gray) unless base
    Tone.new(ms_clamp_tone(base.red + up), ms_clamp_tone(base.green + up),
             ms_clamp_tone(base.blue + up), ms_clamp_tone(base.gray + gray))
  end

  def ms_clamp_tone(v)
    return 255 if v > 255
    return -255 if v < -255
    v
  end

  # Reflection / bridge flags for a cross-tileset tile, from ITS tileset.
  def apply_cross_tileset_terrain_flags(tile, props)
    ts = $data_tilesets[props["tileset_id"].to_i]
    return unless ts
    data = GameData::TerrainTag.try_get(ts.terrain_tags[tile.tile_id] || 0)
    tile.shows_reflection = data ? !!data.shows_reflections : false
    tile.bridge = data ? !!data.bridge : false
  end

  # Ground-band z for a cell: shadow sources and impassable tiles sit ABOVE the
  # map's shadows (z=2), passable ground below them (z=0).
  def ground_band_z(map, idx, tile_id, props)
    env = MakerStudio.shadow_env_for(map)
    return 0 unless env[:has_shadows]
    return 2 if env[:source_keys][idx] == tile_id
    p = resolve_shadow_tile_passage(tile_id, props, map.passages)
    (p && (p & 0x0F) == 0x0F) ? 2 : 0
  end

  # Map-cell offset of screen cell (0, 0) for one map. Recomputed only when that
  # map's display position changes.
  def ms_tile_offsets(map)
    @ms_offsets ||= {}
    cached = @ms_offsets[map.map_id]
    dx_raw = map.display_x
    dy_raw = map.display_y
    return cached if cached && cached[2] == dx_raw && cached[3] == dy_raw
    mdx = (dx_raw.to_f / Game_Map::X_SUBPIXELS).round
    mdx = ((mdx + (Graphics.width / 2)) * ZOOM_X) - (Graphics.width / 2) if ZOOM_X != 1
    mdy = (dy_raw.to_f / Game_Map::Y_SUBPIXELS).round
    mdy = ((mdy + (Graphics.height / 2)) * ZOOM_Y) - (Graphics.height / 2) if ZOOM_Y != 1
    offs = [mdx / DISPLAY_TILE_WIDTH, mdy / DISPLAY_TILE_HEIGHT, dx_raw, dy_raw, mdx, mdy]
    @ms_offsets[map.map_id] = offs
    offs
  end

  # Animated autotiles: an extra autotile addresses its frames through ms_src_id
  # (the Table's tile_id is 0 and would pick the wrong pattern).
  alias __mkst__refresh_tile_frame refresh_tile_frame unless method_defined?(:__mkst__refresh_tile_frame)
  def refresh_tile_frame(tile, tile_id)
    if MakerStudio::ENABLED && tile.ms_src_id
      @autotiles.set_src_rect(tile, tile.ms_src_id)
      return
    end
    __mkst__refresh_tile_frame(tile, tile_id)
  end

  # Rotated / vertically-flipped tiles are drawn from their centre (ox/oy), which
  # shifts them by half a tile — compensate whenever the engine repositions them.
  alias __mkst__refresh_tile_coordinates refresh_tile_coordinates unless method_defined?(:__mkst__refresh_tile_coordinates)
  def refresh_tile_coordinates(tile, x, y)
    __mkst__refresh_tile_coordinates(tile, x, y)
    return unless MakerStudio::ENABLED
    return if tile.ox == 0 && tile.oy == 0
    tile.x += (tile.ox * tile.zoom_x.abs).round
    tile.y += (tile.oy * tile.zoom_y.abs).round
  end

  # Cap-model z for native tiles (see @cell_band_cache). Reflection tiles and
  # engine-managed bridge tiles keep the engine's own z.
  alias __mkst__refresh_tile_z refresh_tile_z unless method_defined?(:__mkst__refresh_tile_z)
  def refresh_tile_z(tile, map, y, layer, tile_id)
    band = MakerStudio::ENABLED ? tile.cell_band : nil
    return __mkst__refresh_tile_z(tile, map, y, layer, tile_id) if band.nil?
    return __mkst__refresh_tile_z(tile, map, y, layer, tile_id) if tile.shows_reflection
    # The engine forces active-bridge tiles to z=0 (player walks the deck);
    # a band-0 tile that sits above the map's shadows (z=2) would sink under
    # the shadow sprite (z=1), so those keep our z.
    if tile.bridge && $PokemonGlobal.bridge > 0
      above_shadow = band == 0 && tile.ms_ground_z && tile.ms_ground_z > 0
      return __mkst__refresh_tile_z(tile, map, y, layer, tile_id) unless above_shadow
    end
    if band == 0
      # Ground band: below the map's shadows (0) or above them (2).
      tile.z = tile.ms_ground_z || 0
    else
      tile.z = ms_overhead_tile_z(y, band)
    end
  end

  # z of an overhead (priority >= 1) tile at SCREEN row `y`.
  #
  # The engine's own formula is a whole-row value while Game_Character#screen_z is
  # measured in screen PIXELS and so includes the sub-tile scroll offset. Over the
  # last pixels of every row of camera scroll that difference inverts the pair,
  # which is why a taller-than-one-tile event under a priority-1 tile flickered
  # between in-front and behind while the player walked. Subtracting the same
  # offset the tile's own y uses puts both in one space, so the gap is constant
  # and the order can't flip mid-scroll.
  #
  # The `+ 1` is v21.1's — v20.1's engine formula ends at `+ 32`, which makes a
  # ONE-tile-tall sprite tie exactly with the overhead tile on the row above it,
  # and RGSS resolves an equal z arbitrarily (the same flicker, for short sprites).
  # Carried here so the ordering is deterministic; it only breaks that tie.
  #
  # @pixel_offset_y counts DISPLAY pixels while screen_z counts SOURCE ones, so
  # un-zoom it (ZOOM_Y is 1 on every shipping base — TILE_HEIGHT 32 — but a
  # scaled base must not shift the z by the zoom factor).
  def ms_overhead_tile_z(y, band)
    off = @pixel_offset_y || 0
    off = (off / ZOOM_Y).round if ZOOM_Y && ZOOM_Y > 0 && ZOOM_Y != 1
    (y * SOURCE_TILE_HEIGHT) + (band * SOURCE_TILE_HEIGHT) + SOURCE_TILE_HEIGHT + 1 - off
  end

  #---------------------------------------------------------------------------
  # Load extended data for every map in the factory and build the sprites that
  # are NOT pooled (shadows, fog). Runs once per data change, not per frame.
  #---------------------------------------------------------------------------
  def ensure_extended_sprites
    # Detect when the cache was cleared/rebuilt (size + map_id signature changes)
    cache = MakerStudio.instance_variable_get(:@extended_data_cache)
    cache_sig = cache.object_id ^ cache.size
    return if @extended_data_loaded && cache_sig == @last_extended_cache_sig
    return unless $map_factory
    # Shadows are map-sized bitmaps and few per map — still built up-front. Only
    # the per-tile sprites are pooled. Dispose first: refresh() can reset
    # @extended_data_loaded without changing cache_sig, and failing to dispose
    # would stack duplicate shadow sprites (progressive darkening).
    dispose_shadow_sprites
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
      create_shadow_sprites_for_map(map, ext_data)
      MakerStudio.create_fog_sprites_for_map(map.map_id, map)
    end
    # Dispose fog sprites only for maps that left the factory entirely. Fog
    # sprites persist for all factory maps (hidden via visible=false when not
    # current) so scroll offsets survive transitions.
    factory_map_ids = $map_factory.maps.map { |m| m.map_id }
    fog_cache = MakerStudio.instance_variable_get(:@fog_sprites_cache)
    fog_cache.keys.each do |cached_map_id|
      unless factory_map_ids.include?(cached_map_id)
        MakerStudio.dispose_fog_sprites(cached_map_id)
      end
    end
    # New data: rebind the whole pool, and make the engine rebind its own native
    # sprites (that is where Maker Studio's native-layer content is applied).
    @ext_gen += 1
    @need_refresh = true
    @ms_offsets = nil
    @extended_data_loaded = true
    # Signature taken AFTER the lazy load above, which is itself a cache change —
    # reading it before would make the next frame think the data changed again.
    @last_extended_cache_sig = cache.object_id ^ cache.size
  end

  #---------------------------------------------------------------------------
  # Extended layers: bind the screen-cell sprite pool to whatever the camera is
  # currently over. Mirrors the engine's own tile loop — a sprite is rebound only
  # when it starts showing a different cell; otherwise it is just repositioned.
  #---------------------------------------------------------------------------
  def update_extended_pool
    return unless $map_factory
    ensure_ext_pool
    # Day/night tone + screen colour reach pooled sprites only when they CHANGE
    # (the engine does the same for its own tile sprites). Freshly bound sprites
    # pick the current values up in bind_ext_pool_sprite.
    if @tone && @ext_old_tone != @tone
      @ext_old_tone = @tone.clone
      each_ext_pool_sprite { |spr| spr.tone = ms_tone_with_light(spr.ms_light) }
    end
    if @color && @ext_old_color != @color
      @ext_old_color = @color.clone
      each_ext_pool_sprite { |spr| spr.color = @color }
    end
    @ext_visible.each { |spr| spr.visible = false unless spr.disposed? }
    @ext_visible.clear
    h_count = @tiles_horizontal_count + (EXT_POOL_MARGIN * 2)
    v_count = @tiles_vertical_count + (EXT_POOL_MARGIN * 2)
    $map_factory.maps.each do |map|
      next unless map&.instance_variable_get(:@map)
      layers = MakerStudio.ext_layers_index_for(map.map_id, map.width)
      next if layers.empty?
      offs = ms_tile_offsets(map)
      dx_tile = offs[0]
      dy_tile = offs[1]
      pixel_off_x = offs[4] % DISPLAY_TILE_WIDTH
      pixel_off_y = offs[5] % DISPLAY_TILE_HEIGHT
      # Screen cells covered by this map, in pool coordinates (0 = margin edge).
      start_x = [-dx_tile + EXT_POOL_MARGIN, 0].max
      start_y = [-dy_tile + EXT_POOL_MARGIN, 0].max
      end_x = [h_count - 1, map.width - 1 - dx_tile + EXT_POOL_MARGIN].min
      end_y = [v_count - 1, map.height - 1 - dy_tile + EXT_POOL_MARGIN].min
      next if start_x > end_x || start_y > end_y
      (start_x..end_x).each do |i|
        tile_x = i + dx_tile - EXT_POOL_MARGIN
        col = @ext_pool[i]
        (start_y..end_y).each do |j|
          tile_y = j + dy_tile - EXT_POOL_MARGIN
          idx = tile_y * map.width + tile_x
          cell = col[j]
          layers.each_with_index do |layer, slot|
            td = layer[:tiles][idx]
            sprite = cell[slot]
            next if td.nil? && sprite.nil?
            sprite = (cell[slot] = TileSprite.new(@viewport)) unless sprite
            if sprite.map_x != tile_x || sprite.map_y != tile_y ||
               sprite.map_id != map.map_id || sprite.ms_gen != @ext_gen
              bind_ext_pool_sprite(sprite, map, layer, slot, td, tile_x, tile_y)
            end
            next unless sprite.bitmap
            sprite.x = ((i - EXT_POOL_MARGIN) * DISPLAY_TILE_WIDTH) - pixel_off_x
            sprite.y = ((j - EXT_POOL_MARGIN) * DISPLAY_TILE_HEIGHT) - pixel_off_y
            if sprite.ox != 0 || sprite.oy != 0
              sprite.x += (sprite.ox * sprite.zoom_x.abs).round
              sprite.y += (sprite.oy * sprite.zoom_y.abs).round
            end
            band = sprite.cell_band
            if band && band > 0
              # Overhead tiles interleave with the player, so their z follows the
              # sprite's SCREEN row, not its map row — pixel-aligned like the
              # native path (see ms_overhead_tile_z).
              z = ms_overhead_tile_z(j - EXT_POOL_MARGIN, band) + (sprite.ext_z_offset || 0)
              sprite.z = z if sprite.z != z
            end
            @autotiles.set_src_rect(sprite, sprite.ms_src_id || sprite.tile_id) if sprite.animated
            sprite.visible = true
            @ext_visible << sprite
          end
        end
      end
    end
  end

  # Bind one pooled sprite to the tile (possibly none) at a map cell.
  def bind_ext_pool_sprite(sprite, map, layer, slot, tile_data, tile_x, tile_y)
    sprite.map_id = map.map_id
    sprite.map_x = tile_x
    sprite.map_y = tile_y
    sprite.ms_gen = @ext_gen
    sprite.ms_src_id = nil
    sprite.cell_band = nil
    # Cleared first: setup_extended_sprite_bitmap leaves the bitmap untouched when
    # it cannot resolve the tile, which would keep the previous cell's graphic.
    sprite.bitmap = nil
    unless tile_data
      sprite.visible = false
      return
    end
    tile_id = tile_data["tile_id"].to_i
    sprite.zoom_x = ZOOM_X
    sprite.zoom_y = ZOOM_Y
    setup_extended_sprite_bitmap(sprite, tile_id, map, tile_data)
    unless sprite.bitmap
      sprite.visible = false
      return
    end
    sprite.ms_src_id = sprite.tile_id if tile_data["autotile_name"]
    MakerStudio::TileEffects.apply_to_sprite(sprite, tile_data, @tilesets, @autotiles)
    layer_opacity = layer["opacity"]
    if layer_opacity < 255
      sprite.opacity = (sprite.opacity * layer_opacity / 255.0).round.clamp(0, 255)
    end
    sprite.tone = ms_tone_with_light(sprite.ms_light)
    sprite.color = @color.clone if @color
    # A tile keeps its OWN priority but only renders OVERHEAD (above the player)
    # when its layer sits above the cell's highest ground tile — a ground tile on
    # a higher layer covers everything beneath it.
    own_pri = MakerStudio.resolve_band_priority(map, tile_id, tile_data)
    ul = MakerStudio.unified_layer(layer["id"])
    eff = (own_pri >= 1 && ul > MakerStudio.cell_ground_cap(map, tile_x, tile_y)) ? own_pri : 0
    z_offset = (slot + 1) * EXT_LAYER_Z_OFFSET
    sprite.ext_z_offset = z_offset
    sprite.cell_band = eff
    sprite.z = 2 + z_offset if eff == 0   # ground band, above shadows (z=1)
    sprite.visible = false                # positioned first, shown by the caller
  end

  # Build the (empty) pool grid once. Sprites inside it are created on demand, so
  # a map with no extended tiles allocates nothing.
  def ensure_ext_pool
    return if @ext_pool_ready
    h_count = @tiles_horizontal_count + (EXT_POOL_MARGIN * 2)
    v_count = @tiles_vertical_count + (EXT_POOL_MARGIN * 2)
    h_count.times do |i|
      col = (@ext_pool[i] ||= [])
      v_count.times { |j| col[j] ||= [] }
    end
    @ext_pool_ready = true
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
    # Sprite-bindable (mega tilesets folded into columns) — NOT the raw bitmap.
    ts_bitmap = MakerStudio.get_extra_tileset_for_sprite(ts.tileset_name)
    return false unless ts_bitmap && !ts_bitmap.disposed?
    priority = resolve_tile_priority(tile_id, tile_data, map)
    if tile_id >= MakerStudio::TILESET_START_ID
      sprite.set_bitmap(ts.tileset_name, tile_id, false, false, priority, ts_bitmap)
      r = MakerStudio.extra_tileset_src_rect(ts.tileset_name, tile_id)
      sprite.src_rect.set(r.x, r.y, r.width, r.height)
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
  # Resolve priority for a tile. LIVE-FIRST — mirrors the editor's
  # resolveTilePriority: the autotile config / referenced tileset is
  # authoritative so tileset property edits reach already-painted tiles
  # in-game. The baked per-tile "priority" (embedded into TileData at paint
  # time) is only a fallback when live data can't resolve the tile (e.g.
  # Tilesets.rxdata never re-saved with the expanded_autotiles config).
  #---------------------------------------------------------------------------
  def resolve_tile_priority(tile_id, tile_data, map)
    # Extra autotile: resolve live from config / autotile slots
    if tile_data && tile_data["autotile_name"]
      pri = resolve_autotile_priority(tile_data["autotile_name"], map)
      return pri if pri
      return tile_data["priority"] ? tile_data["priority"].to_i : 0
    end
    # Cross-tileset: use referenced tileset
    if tile_data && tile_data["tileset_id"]
      ts = $data_tilesets[tile_data["tileset_id"].to_i]
      return (ts.priorities[tile_id] || 0) if ts
      return tile_data["priority"] ? tile_data["priority"].to_i : 0
    end
    # Per-tile override on a plain native tile
    if tile_data && tile_data["priority"]
      return tile_data["priority"].to_i
    end
    # Default: map tileset
    return map.priorities[tile_id] || 0
  end

  #---------------------------------------------------------------------------
  # Look up priority for an extra autotile by searching all tilesets.
  # Returns nil when the autotile is unknown everywhere, so the caller can
  # fall back to the baked per-tile priority.
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
    return nil
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
      @shadow_sprites << sprite
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
  # Dispose Maker Studio sprites. Fog sprites are managed per-map in
  # ensure_extended_sprites — do NOT dispose them here (it would drop their
  # scroll offsets unnecessarily).
  #---------------------------------------------------------------------------
  def dispose_extended_sprites
    each_ext_pool_sprite { |spr| spr.dispose rescue nil }
    @ext_pool = []
    @ext_pool_ready = false
    @ext_visible.clear
    dispose_shadow_sprites
  end

  def dispose_shadow_sprites
    @shadow_sprites.each { |spr| spr.dispose rescue nil }
    @shadow_sprites.clear
    @last_visible_shadows.clear
    @__shadow_anim_logged = false
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
  # Apply per-tile visual state (opacity / rotation / flip / hue / sat / etc).
  # When `has_effects` is false (the common case — props carries only
  # collision/terrain overrides), skip the apply_to_sprite path and reset the
  # sprite to defaults directly (no `props.merge` allocation).
  #---------------------------------------------------------------------------
  def apply_native_visual_state(sprite, props, has_effects, tile_id)
    if has_effects
      sprite.zoom_y = ZOOM_Y if sprite.zoom_y < 0
      enriched = props.merge("tile_id" => tile_id)
      MakerStudio::TileEffects.apply_to_sprite(sprite, enriched, @tilesets, @autotiles)
    else
      # Trivial props — bring sprite back to defaults so any stale state from
      # a previous tile assignment is cleared.
      sprite.opacity = 255
      sprite.angle = 0
      sprite.tone = MakerStudio::TileEffects::ZERO_TONE
      sprite.mirror = false
      sprite.zoom_y = ZOOM_Y if sprite.zoom_y < 0
      sprite.ox = 0
      sprite.oy = 0
    end
    # The engine only re-applies its tone/colour to tile sprites when they
    # CHANGE, so a freshly bound sprite has to pick up the current values here
    # or it would ignore the day/night filter until the next change.
    sprite.tone = ms_tone_with_light(sprite.ms_light)
    sprite.color = @color if @color
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

  alias __mkst__update update unless method_defined?(:__mkst__update)
  def update
    __mkst__update
    return unless MakerStudio::ENABLED
    ensure_extended_sprites
    # The engine re-applies its day/night tone to EVERY native tile sprite when it
    # changes, wiping the lighting composed into that tone — put it back.
    if @tone && @ms_old_tone != @tone
      @ms_old_tone = @tone.clone
      refresh_native_lighting_tones
    end
    MakerStudio.update_fog_sprites
    update_extended_pool
    update_shadow_sprites
  end

  def refresh_native_lighting_tones
    @tiles.each do |col|
      col.each do |cell|
        cell.each do |tile|
          next if !tile || tile.disposed?
          light = tile.ms_light
          next if light.nil? || light == 0
          tile.tone = ms_tone_with_light(light)
        end
      end
    end
  end

  #---------------------------------------------------------------------------
  # Shadow sprites carry one map-sized bitmap each (not one per tile), so they
  # are positioned directly rather than pooled — there are only a handful.
  #---------------------------------------------------------------------------
  def update_shadow_sprites
    return if @shadow_sprites.empty?
    @last_visible_shadows.each { |spr| spr.visible = false unless spr.disposed? }
    @last_visible_shadows.clear
    return unless $map_factory
    scr_w = @tiles_horizontal_count
    scr_h = @tiles_vertical_count
    maps = {}
    $map_factory.maps.each { |m| maps[m.map_id] = m if m }
    @shadow_sprites.each do |sprite|
      next if sprite.disposed?
      map = maps[sprite.map_id]
      next unless map
      offs = ms_tile_offsets(map)
      next unless map_screen_visible?(map, offs[4], offs[5])
      i = sprite.map_x - offs[0]
      j = sprite.map_y - offs[1]
      bmp_tw = (sprite.shadow_frame_w || 32) / DISPLAY_TILE_WIDTH
      bmp_th = (sprite.bitmap&.height || 32) / DISPLAY_TILE_HEIGHT
      next if (i + bmp_tw) < -8 || (j + bmp_th) < -8 || i > scr_w + 8 || j > scr_h + 8
      sprite.visible = true
      @last_visible_shadows << sprite
      sprite.tone = @tone if @tone
      sprite.color = @color if @color
      sprite.x = (i * DISPLAY_TILE_WIDTH) - (offs[4] % DISPLAY_TILE_WIDTH)
      sprite.y = (j * DISPLAY_TILE_HEIGHT) - (offs[5] % DISPLAY_TILE_HEIGHT)
      if sprite.ox != 0 || sprite.oy != 0
        sprite.x += (sprite.ox * sprite.zoom_x.abs).round
        sprite.y += (sprite.oy * sprite.zoom_y.abs).round
      end
      # Animated shadow: cycle src_rect.x through the bitmap's frame columns.
      next unless sprite.shadow_frame_count > 1
      fc = sprite.shadow_frame_count
      src_frame =
        if sprite.shadow_anim_source_name &&
           (cf = @autotiles.current_frames[sprite.shadow_anim_source_name])
          cf % fc
        else
          MakerStudio.shadow_current_frame(fc)
        end
      # The shadow strip is stored reversed relative to the source autotile.
      sprite.src_rect.x = ((fc - 1) - src_frame) * sprite.shadow_frame_w
    end
  end
end
