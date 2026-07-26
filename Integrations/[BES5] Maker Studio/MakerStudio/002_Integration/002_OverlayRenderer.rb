#===============================================================================
# MakerStudio - Overlay Renderer (Essentials BES v5 / v16.2)
#
# BES renders the map with the classic Ruby CustomTilemap (Tilemap_XP), which
# composites the three native layers into a few shared layer bitmaps — there are
# NO per-tile sprites to manipulate (unlike v21.1's TilemapRenderer, which the
# original integration patches directly).
#
# So this build draws everything Maker Studio adds — extended layers, per-tile
# effects, native-layer "extra" tiles, and shadows — as an INDEPENDENT set of
# Sprites attached to the map's viewport (Spriteset_Map@viewport1). They are
# positioned every frame from $game_map.display_x/y using the exact same screen
# math BES uses for events/player, so overlay tiles stay glued to the map and to
# characters in every tilemap view mode.
#
# Injection points (all old-style BES Events, since EventHandlers is defined but
# never triggered on BES):
#   Events.onSpritesetCreate  -> build the overlay in the new viewport
#   Spriteset_Map#update      -> (aliased) drive per-frame overlay update
#   Spriteset_Map#dispose     -> (aliased) tear the overlay down
#
# Tile bitmaps are composed with BES's TileDrawingHelper (handles RMXP autotile
# assembly + animation), so AutotileExpander/AutotileBitmaps are not needed.
#===============================================================================

# BES Game_Map exposes tileset_name but NOT tileset_id (only the RPG::Map it
# wraps does). The renderer/shadow code needs the id to look up tilesets, so add
# a reader that delegates to the wrapped RPG::Map. Modern engines already define
# tileset_id, so only add it when missing.
class Game_Map
  unless method_defined?(:tileset_id)
    def tileset_id
      @map ? @map.tileset_id : 0
    end
  end
end

module MakerStudio
  # ---- module-level caches -------------------------------------------------
  @extended_data_cache  = {}   # map_id => parsed extended data hash
  @tdh_cache            = {}   # tileset_id => TileDrawingHelper (map/cross tilesets)
  @extra_autotile_tdh   = {}   # autotile name => TileDrawingHelper (autotiles=[bmp])
  @tile_strip_cache     = {}   # signature => [strip_bitmap, frame_count]
  @shadow_bitmap_cache  = {}   # key => [bitmap, frame_count, frame_w]
  @tinted_tile_cache    = {}   # sig => 32x32 tinted Bitmap
  @blanked_cells        = {}   # map_id => { "x,y,layer" => original_tile_id }
  # Plain native tiles blanked because they sat ABOVE a native-extra autotile
  # at the same cell (see blank_covered_plain_tiles). Kept separate from
  # @blanked_cells so collision can yield ONLY these (demoted-priority blanks
  # must stay collision-invisible — their covering ground tile decides).
  @covered_plain_cells  = {}   # map_id => { "x,y,layer" => original_tile_id }
  # Per-map "ground cap": { map_id => { (y*w + x) => cap_layer } }. cap_layer =
  # the highest UNIFIED layer (native 0-2, then NATIVE_LAYERS+ext_id) holding a
  # priority-0 (ground) tile at the cell; absent = -1. An OVERLAY tile renders
  # overhead (above the player) iff its own priority >= 1 AND its layer is above
  # the cap — so a ground tile on a higher layer covers everything beneath it,
  # while each tile keeps its own priority. (Plain native priority tiles are
  # composited by the engine CustomTilemap and not affected — see file header.)
  @cell_band_cache      = {}

  module_function

  # Frames per autotile animation step — same constant the native CustomTilemap
  # uses, so overlay autotiles/shadows stay in lockstep with the map's autotiles.
  # NOTE: BES defines it as CustomTilemap::Animated_Autotiles_Frames (= 15), NOT
  # a top-level constant — referencing the bare name fell back to 5, making
  # autotiles ~3x too fast.
  def anim_step
    if defined?(CustomTilemap) && defined?(CustomTilemap::Animated_Autotiles_Frames)
      CustomTilemap::Animated_Autotiles_Frames
    elsif defined?(Animated_Autotiles_Frames)
      Animated_Autotiles_Frames
    else
      15
    end
  end

  #---------------------------------------------------------------------------
  # Extended data load / lookup (reuses DataStore — engine-agnostic JSON)
  #---------------------------------------------------------------------------
  def load_extended_layers_for_map(map_id, map)
    @extended_data_cache[map_id] = DataStore.get_extended_data(map_id, map.width, map.height, map)
    @cell_band_cache.delete(map_id) if @cell_band_cache
  end

  def get_extended_data_for(map_id)
    @extended_data_cache[map_id]
  end

  def current_extended_data
    return nil unless $game_map
    @extended_data_cache[$game_map.map_id]
  end

  def clear_extended_layers
    @extended_data_cache = {}
    @blanked_cells = {}
    @covered_plain_cells = {}
    @cell_band_cache = {}
  end

  # The Overlay bound to the active Spriteset_Map (set on creation). Lets the
  # "Reload Map Data" debug command force a rebuild without hunting the scene.
  def set_current_overlay(ov)
    @current_overlay = ov
  end

  def current_overlay
    @current_overlay
  end

  # Full flush — dispose cached bitmaps. Called on editor-driven reloads.
  def clear_all_caches
    # The tilesets may have been re-saved by the editor — drop the parsed
    # expanded-autotile config so the next lookup re-reads them.
    DataStore.clear_expanded_autotile_index if DataStore.respond_to?(:clear_expanded_autotile_index)
    @shadow_bitmap_cache.each_value do |v|
      bmp = v.is_a?(Array) ? v[0] : v
      bmp.dispose if bmp && !bmp.disposed?
    end
    @tile_strip_cache.each_value do |v|
      bmp = v.is_a?(Array) ? v[0] : v
      bmp.dispose if bmp && !bmp.disposed?
    end
    @tinted_tile_cache.each_value { |bmp| bmp.dispose if bmp && !bmp.disposed? }
    @shadow_bitmap_cache = {}
    @tile_strip_cache    = {}
    @tinted_tile_cache   = {}
    @tdh_cache           = {}
    @extra_autotile_tdh  = {}
    MakerStudio::TileEffects.clear_cache if defined?(MakerStudio::TileEffects)
    dispose_all_fog_sprites if respond_to?(:dispose_all_fog_sprites)
    clear_extended_layers
  end

  #---------------------------------------------------------------------------
  # TileDrawingHelper accessors (cached). One per tileset id; a dedicated one
  # per extra-autotile name (its single autotile bitmap parked at slot index 0).
  #---------------------------------------------------------------------------
  def tdh_for_tileset(ts_id)
    h = @tdh_cache[ts_id]
    return h if h
    ts = $data_tilesets[ts_id]
    return nil unless ts
    begin
      h = TileDrawingHelper.fromTileset(ts)
    rescue => e
      echoln("MakerStudio ERROR: TileDrawingHelper for tileset #{ts_id}: #{e.message}")
      return nil
    end
    @tdh_cache[ts_id] = h
    h
  end

  def tdh_for_extra_autotile(name)
    h = @extra_autotile_tdh[name]
    return h if h && h.autotiles[0] && !h.autotiles[0].disposed?
    begin
      bmp = pbGetAutotile(name)   # AnimatedBitmap#deanimate -> Bitmap (full strip)
    rescue => e
      echoln("MakerStudio ERROR: load extra autotile '#{name}': #{e.message}")
      return nil
    end
    return nil unless bmp && !bmp.disposed?
    # @tileset nil (extra autotiles never use the regular-tile path); autotiles[0] = bmp
    h = TileDrawingHelper.new(nil, [bmp])
    @extra_autotile_tdh[name] = h
    h
  end

  # Frame count of an autotile bitmap: mini (32px tall) = width/32 frames;
  # standard RMXP (3-tile-wide block) = width/96 frames.
  def autotile_frames(bmp)
    return 1 unless bmp && !bmp.disposed?
    if bmp.height <= MakerStudio::TILE_HEIGHT
      return [bmp.width / MakerStudio::TILE_WIDTH, 1].max
    end
    [bmp.width / (3 * MakerStudio::TILE_WIDTH), 1].max
  end

  #---------------------------------------------------------------------------
  # Compose a tile (extended OR native-extra) into a horizontal frame strip
  # bitmap (32*frames wide x 32 tall) and bake hue/saturation into it.
  # Returns [strip_bitmap, frame_count] or nil. Cached by content signature.
  # `base_tile_id` is the tile id stored in the layer/Table (may be 0 for an
  # extra autotile painted via autotile_name).
  #---------------------------------------------------------------------------
  def compose_tile_strip(base_tile_id, tile_data, map)
    tw = MakerStudio::TILE_WIDTH
    th = MakerStudio::TILE_HEIGHT
    hue = (tile_data["hue"] || 0).to_i
    sat = (tile_data["saturation"] || 100).to_i
    lighting = (tile_data["lighting"] || 0).to_i
    sig = "#{base_tile_id}|#{tile_data['autotile_name']}|#{tile_data['tileset_id']}|" \
          "#{tile_data['autotile_pattern']}|m#{map.tileset_id}|h#{hue}|s#{sat}|L#{lighting}"
    cached = @tile_strip_cache[sig]
    return cached if cached && cached[0] && !cached[0].disposed?

    helper = nil
    blit = nil          # proc { |strip, frame| ... }
    frames = 1

    if tile_data["autotile_name"]
      helper = tdh_for_extra_autotile(tile_data["autotile_name"])
      return nil unless helper
      frames = autotile_frames(helper.autotiles[0])
      pattern = (tile_data["autotile_pattern"] || 0).to_i
      id = 48 + (pattern % 48)
      blit = proc { |strip, f| helper.bltAutotile(strip, f * tw, 0, id, f) }
    elsif tile_data["tileset_id"]
      ts_id = tile_data["tileset_id"].to_i
      helper = tdh_for_tileset(ts_id)
      return nil unless helper
      if base_tile_id >= MakerStudio::TILESET_START_ID
        frames = 1
        blit = proc { |strip, _f| helper.bltRegularTile(strip, 0, 0, base_tile_id) }
      elsif base_tile_id > 0
        slot = base_tile_id / MakerStudio::TILES_PER_AUTOTILE
        frames = autotile_frames(helper.autotiles[slot - 1])
        blit = proc { |strip, f| helper.bltAutotile(strip, f * tw, 0, base_tile_id, f) }
      else
        return nil
      end
    else
      helper = tdh_for_tileset(map.tileset_id)
      return nil unless helper
      if base_tile_id >= MakerStudio::TILESET_START_ID
        frames = 1
        blit = proc { |strip, _f| helper.bltRegularTile(strip, 0, 0, base_tile_id) }
      elsif base_tile_id > 0
        slot = base_tile_id / MakerStudio::TILES_PER_AUTOTILE
        frames = autotile_frames(helper.autotiles[slot - 1])
        blit = proc { |strip, f| helper.bltAutotile(strip, f * tw, 0, base_tile_id, f) }
      else
        return nil
      end
    end

    frames = 1 if frames < 1
    strip = Bitmap.new(tw * frames, th)
    frames.times { |f| blit.call(strip, f) }
    # Bake hue/saturation/lighting to MATCH the editor, which uses CSS canvas
    # filters: hue-rotate(deg), saturate(%), brightness(1 + lighting/255). RGSS
    # hue_change / Rec.601 desaturation / additive tone do NOT match those, so
    # we replicate the exact CSS color matrices per pixel here.
    apply_css_color_filters(strip, hue, sat, lighting) if hue != 0 || sat != 100 || lighting != 0

    result = [strip, frames]
    @tile_strip_cache[sig] = result
    result
  end

  #---------------------------------------------------------------------------
  # Replicate the editor's CSS filter chain on a bitmap, in CSS order:
  #   hue-rotate(deg) -> saturate(pct/100) -> brightness(1 + lighting/255)
  # Uses the W3C feColorMatrix matrices (Rec.709 luma) so in-game matches the
  # canvas exactly. Per-pixel; only runs on cache miss.
  #---------------------------------------------------------------------------
  def apply_css_color_filters(bmp, hue_deg, sat_pct, lighting)
    w = bmp.width
    h = bmp.height
    do_hue = (hue_deg % 360) != 0
    do_sat = sat_pct != 100
    do_bri = lighting != 0
    if do_hue
      a = hue_deg * Math::PI / 180.0
      c = Math.cos(a)
      s = Math.sin(a)
      hrr = 0.213 + c * 0.787 - s * 0.213; hrg = 0.715 - c * 0.715 - s * 0.715; hrb = 0.072 - c * 0.072 + s * 0.928
      hgr = 0.213 - c * 0.213 + s * 0.143; hgg = 0.715 + c * 0.285 + s * 0.140; hgb = 0.072 - c * 0.072 - s * 0.283
      hbr = 0.213 - c * 0.213 - s * 0.787; hbg = 0.715 - c * 0.715 + s * 0.715; hbb = 0.072 + c * 0.928 + s * 0.072
    end
    if do_sat
      sv = sat_pct / 100.0
      srr = 0.213 + 0.787 * sv; srg = 0.715 - 0.715 * sv; srb = 0.072 - 0.072 * sv
      sgr = 0.213 - 0.213 * sv; sgg = 0.715 + 0.285 * sv; sgb = 0.072 - 0.072 * sv
      sbr = 0.213 - 0.213 * sv; sbg = 0.715 - 0.715 * sv; sbb = 0.072 + 0.928 * sv
    end
    bri = do_bri ? (1.0 + lighting / 255.0) : 1.0
    # Chromium renders each filter function to an intermediate surface that
    # clamps to [0,255] BETWEEN stages; without these clamps chained
    # hue+saturate reads visibly brighter in-game (verified vs headless
    # Chromium: unclamped drifts up to 42/channel, clamped matches within 1).
    (0...h).each do |y|
      (0...w).each do |x|
        col = bmp.get_pixel(x, y)
        next if col.alpha == 0
        r = col.red.to_f; g = col.green.to_f; b = col.blue.to_f
        if do_hue
          nr = r * hrr + g * hrg + b * hrb
          ng = r * hgr + g * hgg + b * hgb
          nb = r * hbr + g * hbg + b * hbb
          r = nr < 0 ? 0.0 : (nr > 255 ? 255.0 : nr)
          g = ng < 0 ? 0.0 : (ng > 255 ? 255.0 : ng)
          b = nb < 0 ? 0.0 : (nb > 255 ? 255.0 : nb)
        end
        if do_sat
          nr = r * srr + g * srg + b * srb
          ng = r * sgr + g * sgg + b * sgb
          nb = r * sbr + g * sbg + b * sbb
          r = nr < 0 ? 0.0 : (nr > 255 ? 255.0 : nr)
          g = ng < 0 ? 0.0 : (ng > 255 ? 255.0 : ng)
          b = nb < 0 ? 0.0 : (nb > 255 ? 255.0 : nb)
        end
        if do_bri
          r *= bri; g *= bri; b *= bri
        end
        r = 0 if r < 0; r = 255 if r > 255
        g = 0 if g < 0; g = 255 if g > 255
        b = 0 if b < 0; b = 255 if b > 255
        bmp.set_pixel(x, y, Color.new(r.round, g.round, b.round, col.alpha))
      end
    end
  end

  #---------------------------------------------------------------------------
  # Priority lookup mirroring resolve_tile_priority on the v21 build.
  #---------------------------------------------------------------------------
  def resolve_priority(base_tile_id, tile_data, map)
    return tile_data["priority"].to_i if tile_data["priority"]
    if tile_data["autotile_name"]
      entry = MakerStudio::DataStore.get_expanded_autotile(tile_data["autotile_name"])
      return entry["priority"].to_i if entry
      if map.respond_to?(:autotile_names)
        idx = map.autotile_names.index(tile_data["autotile_name"])
        return (map.priorities[(idx + 1) * 48] || 0) if idx
      end
      return 0
    end
    if tile_data["tileset_id"]
      ts = $data_tilesets[tile_data["tileset_id"].to_i]
      return (ts && ts.priorities[base_tile_id]) ? ts.priorities[base_tile_id] : 0
    end
    map.priorities[base_tile_id] || 0
  end

  #---------------------------------------------------------------------------
  # Ground-cap resolution (see @cell_band_cache). Mirrors the v21.1 build's cap
  # model for OVERLAY tiles: an overlay tile is overhead iff its own priority
  # >= 1 AND its layer is above the cell's highest priority-0 (ground) tile.
  #---------------------------------------------------------------------------
  def unified_layer(ext_id)
    MakerStudio::NATIVE_LAYERS + ext_id.to_i
  end

  # Priority of a native cell, guarding the nil-props case (resolve_priority
  # dereferences tile_data). Plain native cells fall back to the map tileset.
  def native_cell_priority(map, tid, td)
    return resolve_priority(tid, td, map) if td
    map.priorities[tid] || 0
  end

  # Scan every cell once, recording the highest unified layer holding a
  # priority-0 (ground) tile (native 0-2, then NATIVE_LAYERS+ext_id). Absent = -1.
  def compute_cell_caps(map, ext_data)
    rpg = map.instance_variable_get(:@map)
    return {} unless rpg && rpg.data
    w = rpg.data.xsize
    h = rpg.data.ysize
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
            if native_cell_priority(map, tid, entry) == 0
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
          next unless resolve_priority(tid, td, map) == 0
          comma = key.index(",")
          next unless comma
          idx = key[comma + 1..-1].to_i * w + key[0, comma].to_i
          caps[idx] = ul if (caps[idx] || -1) < ul
        end
      end
    end
    caps
  end

  # Memoized per-map ground-cap index, plus its map width (for index math).
  def cell_caps_for(map)
    @cell_band_cache[map.map_id] ||= begin
      caps = compute_cell_caps(map, @extended_data_cache[map.map_id])
      rpg = map.instance_variable_get(:@map)
      { :caps => caps, :w => (rpg && rpg.data ? rpg.data.xsize : map.width) }
    end
  end

  # Effective render priority for an OVERLAY tile at (mx,my) on unified layer ul:
  # 0 = ground (below player), else own priority when overhead (above the cap).
  def overlay_effective_priority(map, mx, my, ul, own_pri)
    return 0 if own_pri < 1
    c = cell_caps_for(map)
    cap = c[:caps][my * c[:w] + mx] || -1
    ul > cap ? own_pri : 0
  end

  #---------------------------------------------------------------------------
  # Native-layer blanking. Cross-tileset native tiles would otherwise be drawn
  # by the CustomTilemap from the WRONG (map) tileset; effect-only native tiles
  # can't be recoloured in the shared layer bitmap. For both we zero the cell in
  # the in-memory Table (saved data on disk is untouched) and redraw it as an
  # overlay sprite. Extra-autotile native tiles are stored as 0 in the Table
  # already, so they need no blanking. The original tile id is recorded so the
  # Game_Map collision patch (each_native_extra_tile_at) can still resolve it.
  #---------------------------------------------------------------------------
  # Only cross-tileset native tiles MUST be blanked: the CustomTilemap would
  # otherwise draw their tile id from the map's own tileset (wrong graphic).
  # Effect-only and extra-autotile native tiles are NOT blanked — the original
  # tile stays drawn (keeping its native collision) and we overlay the effect
  # copy on top. (Extra-autotile native cells are stored as 0 in the Table, so
  # the CustomTilemap already draws nothing there.)
  def needs_blank?(tile_data)
    !tile_data["autotile_name"] && !tile_data["tileset_id"].nil?
  end

  def props_has_visual_effects?(props)
    return true if props["flipH"] || props["flipV"]
    v = props["opacity"];    return true if v && v.to_i != 255
    v = props["rotation"];   return true if v && v.to_i != 0
    v = props["hue"];        return true if v && v.to_i != 0
    v = props["saturation"]; return true if v && v.to_i != 100
    v = props["lighting"];   return true if v && v.to_i != 0
    false
  end

  def apply_native_blanks(map)
    ext = @extended_data_cache[map.map_id]
    return unless ext
    native_props = ext["nativeProperties"]
    return unless native_props
    rpg = map.instance_variable_get(:@map)
    return unless rpg && rpg.data
    record = (@blanked_cells[map.map_id] ||= {})
    MakerStudio::NATIVE_LAYERS.times do |layer|
      props = native_props[layer]
      next unless props
      props.each do |key, td|
        next unless td && needs_blank?(td)
        comma = key.index(",")
        next unless comma
        x = key[0, comma].to_i
        y = key[comma + 1..-1].to_i
        next if x < 0 || y < 0 || x >= rpg.data.xsize || y >= rpg.data.ysize
        ck = "#{x},#{y},#{layer}"
        record[ck] = rpg.data[x, y, layer] unless record.key?(ck)
        rpg.data[x, y, layer] = 0
      end
    end
  end

  # Blank native priority>=1 tiles that are DEMOTED — a priority-0 (ground) tile
  # sits on a higher layer, so the engine CustomTilemap would wrongly draw this
  # tile overhead. We zero it (CustomTilemap stops drawing it) and redraw it as a
  # ground-band overlay sprite instead. Returns the plain map-tileset cells for
  # collect_native_priority_cells; effect cells are redrawn by collect_native_extra.
  # Collision-safe: the higher priority-0 tile is decisive in the [2,1,0] passable
  # scan, so the blanked tile beneath it never changes passability.
  # NOTE: requires the ground cap computed from the UN-blanked Table — call
  # cell_caps_for(map) BEFORE this and apply_native_blanks (see Overlay#rebuild).
  # Limitation: when the covering ground tile is itself a plain native tile, the
  # engine bakes it into the z=0 floor, so the demoted overlay (z>=2) can still
  # sit above it — only an EXTENDED (or higher native-extra) cover is fully fixed.
  def blank_demoted_native_priority(map)
    ext = @extended_data_cache[map.map_id]
    rpg = map.instance_variable_get(:@map)
    return [] unless rpg && rpg.data
    native_props = ext ? ext["nativeProperties"] : nil
    c = cell_caps_for(map)
    caps = c[:caps]
    w = c[:w]
    h = rpg.data.ysize
    record = (@blanked_cells[map.map_id] ||= {})
    plain = []
    MakerStudio::NATIVE_LAYERS.times do |layer|
      lp = native_props ? native_props[layer] : nil
      y = 0
      while y < h
        x = 0
        while x < w
          tid = rpg.data[x, y, layer]
          # Recover already-blanked cells (blanking persists across in-session
          # rebuilds) so demoted tiles are re-detected and redrawn each rebuild.
          tid = original_native_tile_id(map.map_id, x, y, layer, tid) if tid == 0
          if tid && tid != 0 && layer < (caps[y * w + x] || -1)
            td = lp ? lp["#{x},#{y}"] : nil
            if native_cell_priority(map, tid, td) >= 1
              ck = "#{x},#{y},#{layer}"
              record[ck] = tid unless record.key?(ck)
              rpg.data[x, y, layer] = 0
              # Plain map-tileset cells (no props) need a fresh overlay sprite;
              # effect cells are redrawn by collect_native_extra_cells.
              plain << [x, y, layer, tid] if td.nil?
            end
          end
          x += 1
        end
        y += 1
      end
    end
    plain
  end

  # Blank plain native tiles that sit ABOVE a native-extra autotile at the same
  # cell. Ground native-extra overlays draw at z >= 2 — above the ENTIRE z=0
  # floor bitmap the plain tile is baked into — so without this the autotile
  # covered tiles on higher native layers. Blanked cells are redrawn by
  # collect_covered_plain_cells at ord = their own layer (correct order vs the
  # autotile's ord = its layer). Registered in @covered_plain_cells so collision
  # (ms_each_tile_at) still sees their passage/priority.
  # Cells that qualify as DEMOTED (priority >= 1 below the ground cap) are left
  # to blank_demoted_native_priority. Cells with props are already redrawn by
  # collect_native_extra_cells at their own layer order and are skipped.
  # NOTE: like blank_demoted, call cell_caps_for BEFORE this (un-blanked Table).
  def blank_covered_plain_tiles(map)
    ext = @extended_data_cache[map.map_id]
    rpg = map.instance_variable_get(:@map)
    return [] unless ext && rpg && rpg.data
    native_props = ext["nativeProperties"]
    return [] unless native_props
    c = cell_caps_for(map)
    caps = c[:caps]
    w = c[:w]
    record = (@blanked_cells[map.map_id] ||= {})
    cov = (@covered_plain_cells[map.map_id] = {})
    covered = []
    (MakerStudio::NATIVE_LAYERS - 1).times do |layer|
      props = native_props[layer]
      next unless props
      props.each do |key, td|
        next unless td && td["autotile_name"]
        comma = key.index(",")
        next unless comma
        x = key[0, comma].to_i
        y = key[comma + 1..-1].to_i
        next if x < 0 || y < 0 || x >= rpg.data.xsize || y >= rpg.data.ysize
        ((layer + 1)...MakerStudio::NATIVE_LAYERS).each do |above|
          ap = native_props[above]
          next if ap && ap[key]   # has props → collect_native_extra_cells redraws it
          tid = rpg.data[x, y, above]
          tid = original_native_tile_id(map.map_id, x, y, above, tid) if tid == 0
          next if tid.nil? || tid == 0
          ck = "#{x},#{y},#{above}"
          next if cov.key?(ck)
          # Demoted cells belong to blank_demoted_native_priority.
          next if native_cell_priority(map, tid, nil) >= 1 && above < (caps[y * w + x] || -1)
          record[ck] = rpg.data[x, y, above] unless record.key?(ck)
          rpg.data[x, y, above] = 0
          cov[ck] = tid
          covered << [x, y, above, tid]
        end
      end
    end
    covered
  end

  # Yield [tid, {}] for plain native tiles blanked by blank_covered_plain_tiles
  # at (x,y), top layer first — collision must keep honouring them even though
  # the Table now reads 0 there.
  def each_covered_plain_tile_at(map_id, x, y)
    rec = @covered_plain_cells[map_id]
    return unless rec
    (MakerStudio::NATIVE_LAYERS - 1).downto(0) do |layer|
      tid = rec["#{x},#{y},#{layer}"]
      yield tid, {} if tid && tid != 0
    end
  end

  # Original Table id for a (possibly blanked) native cell.
  def original_native_tile_id(map_id, x, y, layer, fallback)
    rec = @blanked_cells[map_id]
    ck = "#{x},#{y},#{layer}"
    return rec[ck] if rec && rec.key?(ck)
    fallback
  end

  #---------------------------------------------------------------------------
  # Collision helpers used by 003_GameMapOverride. They take an explicit map_id
  # because collision is queried per Game_Map instance — for connected maps the
  # Game_Map being checked is NOT $game_map, so reading $game_map's data here
  # broke collision on connection maps entirely. Cross-tileset tiles report
  # their recorded original Table id.
  #---------------------------------------------------------------------------
  def each_native_extra_tile_at(map_id, x, y)
    ext = @extended_data_cache[map_id]
    return unless ext
    native_props = ext["nativeProperties"]
    return unless native_props
    key = "#{x},#{y}"
    (MakerStudio::NATIVE_LAYERS - 1).downto(0) do |layer|
      props = native_props[layer]
      next unless props
      td = props[key]
      next unless td
      if td["autotile_name"]
        yield 0, td
      elsif td["tileset_id"]
        tid = original_native_tile_id(map_id, x, y, layer, 0)
        yield tid, td
      end
    end
  end

  def each_extended_tile_at(map_id, x, y)
    ext = @extended_data_cache[map_id]
    return unless ext
    layers = (ext["layers"] || []).select { |l| l["visible"] }.sort_by { |l| -l["id"] }
    layers.each do |layer|
      td = (layer["tiles"] || {})["#{x},#{y}"]
      next unless td
      tid = td["tile_id"].to_i
      next unless tid > 0 || td["autotile_name"]
      yield tid, td
    end
  end
end

#===============================================================================
# Overlay — owns all Maker Studio sprites for one Spriteset_Map's viewport.
#===============================================================================
module MakerStudio
# One Overlay per Spriteset_Map. BES (Scene_Map#createSpritesets) builds a
# separate Spriteset_Map for EACH map in $MapFactory, so each overlay renders
# ONLY its own spriteset's map — never the whole factory (doing the latter
# created N² sprites across N connected maps: lag + overlapping z).
class Overlay
  # Screen-cell sprite pool: the overlay holds sprites for the cells the camera
  # can see (plus a small ring around them), NOT one sprite per painted tile of
  # the map. A 500x500 map with ten full extended layers therefore costs the same
  # per frame as a 20x20 one. POOL_MARGIN is that ring, so a rotated/scaled tile
  # and a hard camera cut always find a sprite ready.
  POOL_MARGIN = 2

  def initialize(viewport, map, tilemap = nil)
    @viewport = viewport
    @map      = map
    @map_id   = map ? map.map_id : nil
    @tilemap  = tilemap   # spriteset's TilemapLoader — source of day/night tone
    # (y * map_w + x) => [entry, ...], entry = [base_tid, td, ord, eff_priority, layer_opacity]
    @cells    = {}
    @max_slots = 0
    @pool     = []   # @pool[i][j][slot] — screen-sized, sprites created on demand
    @pool_ready = false
    @visible_pool = []
    @gen      = 0    # bumped on rebuild; forces every pooled sprite to rebind
    @shadows  = []   # shadow sprites (one map-sized bitmap each, few)
    @last_visible_shadows = []
    rebuild
  end

  def dispose
    each_pool_sprite { |s| s.dispose rescue nil }
    @pool = []
    @pool_ready = false
    @visible_pool = []
    @shadows.each { |s| s.dispose rescue nil }
    @shadows.clear
    @last_visible_shadows.clear
    # Dispose only THIS map's fog (other maps have their own spriteset/overlay).
    MakerStudio.dispose_fog_sprites(@map_id) if @map_id && MakerStudio.respond_to?(:dispose_fog_sprites)
  end

  def disposed?
    @viewport.nil? || @viewport.disposed?
  end

  def each_pool_sprite
    @pool.each do |col|
      next unless col
      col.each do |cell|
        next unless cell
        cell.each { |s| yield s if s && !s.disposed? }
      end
    end
  end

  #---------------------------------------------------------------------------
  # Index THIS overlay's single map: what does each cell hold? No sprites are
  # created here — the pool binds them as the camera reaches each cell.
  #---------------------------------------------------------------------------
  def rebuild
    @shadows.each { |s| s.dispose rescue nil }
    @shadows = []
    @last_visible_shadows = []
    @cells = {}
    @max_slots = 0
    @gen += 1
    # PERF state — force the next #update to run a full position + tone pass.
    @last_dx = @last_dy = @last_frame = nil
    @tr = @tg = @tb = @tgr = nil
    return unless @map && @map.instance_variable_get(:@map)
    unless MakerStudio.get_extended_data_for(@map_id)
      MakerStudio.load_extended_layers_for_map(@map_id, @map)
    end
    # Cap MUST be computed from the un-blanked Table (cross-tileset tiles still
    # present), so do it before any blanking.
    MakerStudio.cell_caps_for(@map)
    MakerStudio.apply_native_blanks(@map)
    demoted = MakerStudio.blank_demoted_native_priority(@map)
    covered = MakerStudio.blank_covered_plain_tiles(@map)
    ext = MakerStudio.get_extended_data_for(@map_id)
    return unless ext
    collect_extended_cells(@map, ext)
    collect_native_extra_cells(@map, ext)
    collect_native_priority_cells(@map, demoted)
    collect_covered_plain_cells(@map, covered)
    @cells.each_value { |entries| @max_slots = entries.length if entries.length > @max_slots }
    build_shadow_sprites(@map, ext)
    MakerStudio.create_fog_sprites_for_map(@map_id, @map) if MakerStudio.respond_to?(:create_fog_sprites_for_map)
  end

  def add_cell_entry(mx, my, entry)
    idx = my * @map.width + mx
    (@cells[idx] ||= []) << entry
  end

  #---------------------------------------------------------------------------
  # Extended layer tiles
  #---------------------------------------------------------------------------
  def collect_extended_cells(map, ext)
    layers = (ext["layers"] || []).select { |l| l["visible"] }.sort_by { |l| l["id"] }
    layers.each_with_index do |layer, order|
      layer_opacity = (layer["opacity"] || 255).to_i
      (layer["tiles"] || {}).each do |key, td|
        next unless td
        tid = td["tile_id"].to_i
        next unless tid > 0 || td["autotile_name"]
        comma = key.index(",")
        next unless comma
        mx = key[0, comma].to_i
        my = key[comma + 1..-1].to_i
        ul = MakerStudio::NATIVE_LAYERS + layer["id"].to_i
        eff = MakerStudio.overlay_effective_priority(map, mx, my, ul, MakerStudio.resolve_priority(tid, td, map))
        # ord keeps extended ABOVE native overlay tiles in the ground band
        # (native ord = 0-2; extended = NATIVE_LAYERS+order = 3+).
        add_cell_entry(mx, my, [tid, td, MakerStudio::NATIVE_LAYERS + order, eff, layer_opacity])
      end
    end
  end

  #---------------------------------------------------------------------------
  # Native-layer extra tiles (autotile_name / cross-tileset / effects), drawn
  # on top of the (blanked, where needed) native layers.
  #---------------------------------------------------------------------------
  def collect_native_extra_cells(map, ext)
    native_props = ext["nativeProperties"]
    return unless native_props
    rpg = map.instance_variable_get(:@map)
    return unless rpg && rpg.data
    MakerStudio::NATIVE_LAYERS.times do |layer|
      props = native_props[layer]
      next unless props
      props.each do |key, td|
        next unless td
        # Only redraw cells that actually change the graphic — autotile_name,
        # cross-tileset, or a visual effect. Pure passage/terrain overrides have
        # nothing to draw.
        next unless td["autotile_name"] || td["tileset_id"] ||
                    MakerStudio.props_has_visual_effects?(td)
        comma = key.index(",")
        next unless comma
        mx = key[0, comma].to_i
        my = key[comma + 1..-1].to_i
        # Base tile id to draw: extra autotiles use autotile_name (base 0);
        # cross-tileset cells were blanked so use the recorded original; effect-
        # only cells keep their Table id (not blanked).
        if td["autotile_name"]
          base_tid = 0
        else
          tbl = (mx >= 0 && my >= 0 && mx < rpg.data.xsize && my < rpg.data.ysize) ? rpg.data[mx, my, layer] : 0
          base_tid = MakerStudio.original_native_tile_id(map.map_id, mx, my, layer, tbl)
          next if base_tid <= 0
        end
        eff = MakerStudio.overlay_effective_priority(map, mx, my, layer, MakerStudio.resolve_priority(base_tid, td, map))
        add_cell_entry(mx, my, [base_tid, td, layer, eff, 255])
      end
    end
  end

  #---------------------------------------------------------------------------
  # Plain map-tileset native priority tiles that were demoted + blanked
  # (blank_demoted_native_priority) — redraw them as ground-band overlay tiles
  # so they sit below the higher ground tile that covers them. eff = 0 (ground).
  #---------------------------------------------------------------------------
  def collect_native_priority_cells(map, demoted)
    demoted.each do |x, y, layer, tid|
      # Render BELOW the engine floor (z=0): the pool uses z = 2 + ord for ground
      # (pri 0), so ord = layer - NATIVE_LAYERS - 2 gives z = layer - NATIVE_LAYERS
      # (< 0). The covering native ground tile (baked into the z=0 floor bitmap)
      # then hides this demoted tile — fixing native-vs-native layer order (a
      # lower-layer priority tile no longer floats above a higher native ground
      # tile). Lower layers get a more-negative z (further below).
      ord = layer - MakerStudio::NATIVE_LAYERS - 2
      add_cell_entry(x, y, [tid, { "tile_id" => tid }, ord, 0, 255])
    end
  end

  #---------------------------------------------------------------------------
  # Plain native tiles blanked because a native-extra autotile sits BELOW them
  # at the same cell (blank_covered_plain_tiles) — redraw at ord = their own
  # layer so they sit ABOVE the autotile overlay (ord = its lower layer),
  # restoring native layer order. Effective priority comes from the cap model
  # so overhead tiles keep interleaving with characters.
  #---------------------------------------------------------------------------
  def collect_covered_plain_cells(map, covered)
    covered.each do |x, y, layer, tid|
      eff = MakerStudio.overlay_effective_priority(
        map, x, y, layer, MakerStudio.native_cell_priority(map, tid, nil)
      )
      add_cell_entry(x, y, [tid, { "tile_id" => tid }, layer, eff, 255])
    end
  end

  #---------------------------------------------------------------------------
  # Bind one pooled sprite to one cell entry. Runs only when that sprite starts
  # showing a different cell (the camera crossed a tile) or after a rebuild.
  #---------------------------------------------------------------------------
  def bind_pool_sprite(spr, entry, map, idx)
    spr.instance_variable_set(:@ms_cell, idx)
    spr.instance_variable_set(:@ms_gen, @gen)
    composed = MakerStudio.compose_tile_strip(entry[0], entry[1], map)
    unless composed
      spr.bitmap = nil
      spr.visible = false
      spr.instance_variable_set(:@ms_frames, 0)
      return
    end
    strip, frames = composed
    spr.bitmap = strip
    # Reset transform state before re-applying effects: this sprite may still
    # carry a previous cell's flip (negative zoom_y) or rotation.
    spr.zoom_x = 1.0
    spr.zoom_y = 1.0
    spr.src_rect.set(0, 0, MakerStudio::TILE_WIDTH, MakerStudio::TILE_HEIGHT)
    spr.instance_variable_set(:@ms_frames, frames)
    # Effective (cap-model) priority, not the tile's raw priority — so an overlay
    # tile below a higher ground tile drops to the ground band. See @cell_band_cache.
    spr.instance_variable_set(:@ms_priority, entry[3])
    spr.instance_variable_set(:@ms_order, entry[2])
    # Sprite-level effects (opacity/rotation/flip/lighting). hue/sat are already
    # baked into the strip. IMPORTANT: do NOT assign sprite.tone for non-lighting
    # tiles — the spriteset sets @viewport1.tone = $game_screen.tone (day/night +
    # weather), and our sprites share that viewport, so leaving the default tone
    # lets the screen filter reach them exactly like native tiles.
    apply_tile_effects(spr, entry[1])
    layer_opacity = entry[4]
    spr.opacity = (spr.opacity * layer_opacity / 255.0).round if layer_opacity < 255
    # The ambient (day/night) tone is only re-applied when it CHANGES, so a
    # freshly bound sprite has to pick up the current one here.
    spr.tone = @dn_tone if @dn_tone
    spr.visible = false
  end

  def apply_tile_effects(spr, td)
    spr.opacity = (td["opacity"] || 255).to_i
    angle = (td["rotation"] || 0).to_i
    spr.angle = -angle
    spr.mirror = td["flipH"] ? true : false
    spr.zoom_y = -spr.zoom_y if td["flipV"]
    # NOTE: hue/saturation/lighting are baked into the tile bitmap (CSS-filter
    # match) — do NOT set sprite.tone here, so the ambient/day-night tone the
    # update loop copies from the tilemap is the only tone on the sprite.
    needs_center = angle != 0 || td["flipV"]
    spr.ox = needs_center ? MakerStudio::TILE_WIDTH / 2 : 0
    spr.oy = needs_center ? MakerStudio::TILE_HEIGHT / 2 : 0
  end

  # Build the (empty) pool grid once. Sprites inside it are created on demand.
  def ensure_pool(gw, gh, tw, th)
    return if @pool_ready
    h = (gw / tw) + 1 + (POOL_MARGIN * 2)
    v = (gh / th) + 1 + (POOL_MARGIN * 2)
    h.times do |i|
      col = (@pool[i] ||= [])
      v.times { |j| col[j] ||= [] }
    end
    @pool_ready = true
  end

  #---------------------------------------------------------------------------
  # Shadows — load editor-baked PNG when present, else generate at runtime.
  #---------------------------------------------------------------------------
  def build_shadow_sprites(map, ext)
    shadows = ext["shadowLayers"]
    if !shadows || shadows.empty?
      single = ext["shadowLayer"]
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
      next if config["height"].nil? || config["direction"].nil?
      shadow_id = shadow["id"] || idx
      fc_sig = source_tiles.map { |st| MakerStudio.shadow_source_frames(st, map) }.max || 1
      cache_key = "shadow_#{map.map_id}_#{shadow_id}_fc#{fc_sig}"
      cached = MakerStudio.instance_variable_get(:@shadow_bitmap_cache)[cache_key]
      bmp = cached.is_a?(Array) ? cached[0] : cached
      frame_count = cached.is_a?(Array) ? cached[1] : 1
      frame_w = cached.is_a?(Array) ? cached[2] : (bmp ? bmp.width : 0)
      unless bmp && !bmp.disposed?
        baked = load_baked_shadow(map.map_id, shadow_id)
        if baked
          bmp = baked
          frame_count = [(shadow["frameCount"] || 1).to_i, 1].max
          frame_w = (shadow["frameWidth"] || bmp.width).to_i
          frame_w = bmp.width if frame_w <= 0 || frame_w > bmp.width
        else
          result = (MakerStudio.generate_shadow_bitmap(map, config, source_tiles, tw, th) rescue nil)
          next unless result
          bmp, frame_count, frame_w = result
        end
        MakerStudio.instance_variable_get(:@shadow_bitmap_cache)[cache_key] = [bmp, frame_count, frame_w]
      end

      min_x = source_tiles.map { |t| t["x"].to_i }.min
      min_y = source_tiles.map { |t| t["y"].to_i }.min
      max_x = source_tiles.map { |t| t["x"].to_i }.max
      max_y = source_tiles.map { |t| t["y"].to_i }.max
      bw = max_x - min_x + 1
      bh = max_y - min_y + 1
      layout = MakerStudio.compute_shadow_layout(config, bw * tw, bh * th, tw, th)
      next unless layout
      map_origin_px_x = min_x * tw - layout[:anchor_x]
      map_origin_px_y = (min_y + bh) * th - layout[:anchor_y]
      sprite_map_x = (map_origin_px_x.to_f / tw).floor
      sprite_map_y = (map_origin_px_y.to_f / th).floor
      sprite_ox = sprite_map_x * tw - map_origin_px_x
      sprite_oy = sprite_map_y * th - map_origin_px_y

      spr = Sprite.new(@viewport)
      spr.bitmap = bmp
      spr.src_rect.set(0, 0, frame_w, bmp.height)
      spr.ox = sprite_ox
      spr.oy = sprite_oy
      shadow_opacity = (config["shadowOpacity"] || 51).to_i
      layer_opacity = (shadow["opacity"] || 255).to_i
      spr.opacity = (shadow_opacity * layer_opacity / 255.0).round
      spr.instance_variable_set(:@ms_mx, sprite_map_x)
      spr.instance_variable_set(:@ms_my, sprite_map_y)
      spr.instance_variable_set(:@ms_map_id, map.map_id)
      spr.instance_variable_set(:@ms_frame_w, frame_w)
      spr.instance_variable_set(:@ms_frames, frame_count)
      spr.visible = false
      @shadows << spr
    end
  end

  def load_baked_shadow(map_id, shadow_id)
    Bitmap.new(sprintf("Graphics/Shadows/%03d_%d", map_id, shadow_id))
  rescue
    nil
  end

  #---------------------------------------------------------------------------
  # Per-frame update: bind the pool to the cells the camera is over, position
  # them from the map's display offset, and set z so they interleave correctly
  # with the native tilemap + characters.
  #---------------------------------------------------------------------------
  def update
    return unless @map
    # Fog is global (own viewports, not per-spriteset). Update it once, from the
    # current map's overlay only, so connected-map overlays don't redo the work.
    if @map == $game_map && MakerStudio.respond_to?(:update_fog_sprites)
      MakerStudio.update_fog_sprites
    end

    frame = Graphics.frame_count / MakerStudio.anim_step
    dx = @map.display_x
    dy = @map.display_y
    # Day/night ("ambient") tone: BES tints native tiles via the tilemap's tone
    # (PBDayNight, applied per-tile — NOT via the viewport). We mirror it onto our
    # sprites so they darken/brighten with time exactly like native tiles. The
    # viewport's $game_screen.tone (weather/tint events) still applies on top.
    dn_tone = (@tilemap ? (@tilemap.tone rescue nil) : nil)
    tone_changed = dn_tone && (dn_tone.red != @tr || dn_tone.green != @tg ||
                               dn_tone.blue != @tb || dn_tone.gray != @tgr)

    # PERF: if the map hasn't scrolled, the autotile frame hasn't advanced, and
    # the day/night tone is unchanged, nothing about any sprite changes — RGSS
    # keeps them where they are — so skip the whole pass.
    return if dx == @last_dx && dy == @last_dy && frame == @last_frame && !tone_changed
    @last_dx = dx; @last_dy = dy; @last_frame = frame

    # Tone changes only at dawn/dusk. Sprite#tone= is a per-sprite native call, so
    # (re)apply it only when it actually changes — never per frame. Cells bound
    # later pick @dn_tone up in bind_pool_sprite.
    if tone_changed
      @dn_tone = dn_tone
      each_pool_sprite { |s| s.tone = dn_tone }
      @shadows.each { |s| s.tone = dn_tone unless s.disposed? }
      @tr = dn_tone.red; @tg = dn_tone.green; @tb = dn_tone.blue; @tgr = dn_tone.gray
    end

    tw = MakerStudio::TILE_WIDTH
    th = MakerStudio::TILE_HEIGHT
    realx = Game_Map.realResX
    realy = Game_Map.realResY
    gw = Graphics.width
    gh = Graphics.height

    @visible_pool.each { |s| s.visible = false unless s.disposed? }
    @visible_pool = []

    unless @cells.empty?
      ensure_pool(gw, gh, tw, th)
      map_w = @map.width
      map_h = @map.height
      # floor(), not just "/": display_x is a FLOAT while a character is mid-step
      # (v19.1's move_speed_real scales by 40.0 / frame_rate), and a Float cell
      # index never matches @cells' Integer keys — every step would blank out
      # everything Maker Studio draws until the character landed on the tile.
      base_tx = (dx / realx).floor
      base_ty = (dy / realy).floor
      slots = @max_slots
      @pool.each_index do |i|
        mx = base_tx + i - POOL_MARGIN
        next if mx < 0 || mx >= map_w
        sx = (mx * realx - dx + 3) / 4
        col = @pool[i]
        col.each_index do |j|
          my = base_ty + j - POOL_MARGIN
          next if my < 0 || my >= map_h
          idx = my * map_w + mx
          entries = @cells[idx]
          next unless entries
          cell = col[j]
          sy = (my * realy - dy + 3) / 4
          slot = 0
          while slot < slots
            entry = entries[slot]
            break unless entry
            spr = cell[slot]
            unless spr
              spr = Sprite.new(@viewport)
              spr.visible = false
              cell[slot] = spr
            end
            if spr.instance_variable_get(:@ms_cell) != idx ||
               spr.instance_variable_get(:@ms_gen) != @gen
              bind_pool_sprite(spr, entry, @map, idx)
            end
            frames = spr.instance_variable_get(:@ms_frames) || 0
            if frames > 0
              spr.x = sx
              spr.y = sy
              # Centre-origin effects (rotation/flipV) offset the sprite — compensate.
              ox = spr.ox; oy = spr.oy
              if ox != 0 || oy != 0
                spr.x += (ox * spr.zoom_x.abs).round
                spr.y += (oy * spr.zoom_y.abs).round
              end
              pri = spr.instance_variable_get(:@ms_priority) || 0
              ord = spr.instance_variable_get(:@ms_order) || 0
              # z mirrors the native CustomTilemap: priority 0 sits just above the
              # ground layer (z=0); priority>0 uses screen-y so it interleaves with
              # characters.
              spr.z = (pri == 0) ? (2 + ord) : (sy + pri * th + th + ord)
              spr.src_rect.x = (frame % frames) * tw if frames > 1
              spr.visible = true
              @visible_pool << spr
            end
            slot += 1
          end
        end
      end
    end

    @last_visible_shadows.each { |s| s.visible = false unless s.disposed? }
    @last_visible_shadows = []
    @shadows.each do |spr|
      next if spr.disposed?
      mx = spr.instance_variable_get(:@ms_mx)
      my = spr.instance_variable_get(:@ms_my)
      sx = (mx * realx - dx + 3) / 4
      sy = (my * realy - dy + 3) / 4
      fw = spr.instance_variable_get(:@ms_frame_w) || tw
      bh = spr.bitmap ? spr.bitmap.height : th
      next if sx + fw <= -tw || sy + bh <= -th || sx >= gw + tw || sy >= gh + th
      spr.x = sx
      spr.y = sy
      # Shadow sits on the ground (above the floor bitmap z=0, below objects).
      spr.z = 1
      frames = spr.instance_variable_get(:@ms_frames) || 1
      if frames > 1
        # Source autotiles animate forward; shadow strip is stored reversed.
        src = frame % frames
        spr.src_rect.x = ((frames - 1) - src) * fw
      end
      spr.visible = true
      @last_visible_shadows << spr
    end
  end
end
end

#===============================================================================
# Shadow generation (ported from the v21 build — pure RGSS bitmap math, with
# tile blitting routed through BES TileDrawingHelper).
#===============================================================================
module MakerStudio
  module_function

  def shadow_source_frames(st, map)
    if st["autotile_name"]
      h = tdh_for_extra_autotile(st["autotile_name"])
      return h ? autotile_frames(h.autotiles[0]) : 1
    end
    tid = st["tileId"].to_i
    if st["tileset_id"]
      h = tdh_for_tileset(st["tileset_id"].to_i)
      return 1 unless h
      if tid > 0 && tid < MakerStudio::TILESET_START_ID
        return autotile_frames(h.autotiles[tid / MakerStudio::TILES_PER_AUTOTILE - 1])
      end
      return 1
    end
    if tid > 0 && tid < MakerStudio::TILESET_START_ID
      h = tdh_for_tileset(map.tileset_id)
      return h ? autotile_frames(h.autotiles[tid / MakerStudio::TILES_PER_AUTOTILE - 1]) : 1
    end
    1
  end

  # Blit one source tile (with optional flip/rotation) into dest at (px,py),
  # at animation `frame`. Mirrors the v21 blit_tile_to_bitmap behaviour.
  def shadow_blit_tile(dest, st, px, py, map, frame)
    flipH = st["flipH"]
    flipV = st["flipV"]
    rot = ((st["rotation"] || 0).to_i) % 360
    if flipH || flipV || rot != 0
      tmp = Bitmap.new(MakerStudio::TILE_WIDTH, MakerStudio::TILE_HEIGHT)
      shadow_blit_tile_raw(tmp, st, 0, 0, map, frame)
      apply_tile_transform_blit(dest, tmp, px, py, flipH, flipV, rot)
      tmp.dispose
      return
    end
    shadow_blit_tile_raw(dest, st, px, py, map, frame)
  end

  def shadow_blit_tile_raw(dest, st, px, py, map, frame)
    tw = MakerStudio::TILE_WIDTH
    th = MakerStudio::TILE_HEIGHT
    tid = st["tileId"].to_i
    if st["autotile_name"]
      h = tdh_for_extra_autotile(st["autotile_name"])
      return unless h
      pattern = (st["autotile_pattern"] || 0).to_i
      fc = autotile_frames(h.autotiles[0])
      f = fc > 0 ? frame % fc : 0
      tmp = Bitmap.new(tw, th)
      h.bltAutotile(tmp, 0, 0, 48 + (pattern % 48), f)
      dest.blt(px, py, tmp, Rect.new(0, 0, tw, th))
      tmp.dispose
      return
    end
    helper = st["tileset_id"] ? tdh_for_tileset(st["tileset_id"].to_i) : tdh_for_tileset(map.tileset_id)
    return unless helper
    tmp = Bitmap.new(tw, th)
    if tid >= MakerStudio::TILESET_START_ID
      helper.bltRegularTile(tmp, 0, 0, tid)
    elsif tid > 0
      fc = autotile_frames(helper.autotiles[tid / MakerStudio::TILES_PER_AUTOTILE - 1])
      f = fc > 0 ? frame % fc : 0
      helper.bltAutotile(tmp, 0, 0, tid, f)
    end
    dest.blt(px, py, tmp, Rect.new(0, 0, tw, th))
    tmp.dispose
  end

  def apply_tile_transform_blit(dest, src, dx, dy, flipH, flipV, rotation)
    sw = src.width; sh = src.height
    rot = rotation % 360
    out_w = (rot == 90 || rot == 270) ? sh : sw
    out_h = (rot == 90 || rot == 270) ? sw : sh
    out_w.times do |i|
      out_h.times do |j|
        case rot
        when 90  then sx = j;          sy = sw - 1 - i
        when 180 then sx = sw - 1 - i; sy = sh - 1 - j
        when 270 then sx = sh - 1 - j; sy = i
        else          sx = i;          sy = j
        end
        c = src.get_pixel(sx, sy)
        next if c.alpha == 0
        x = flipH ? (out_w - 1 - i) : i
        y = flipV ? (out_h - 1 - j) : j
        dest.set_pixel(dx + x, dy + y, c)
      end
    end
  end

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

  def generate_shadow_bitmap(map, config, source_tiles, tw, th)
    min_x = source_tiles.map { |t| t["x"].to_i }.min
    min_y = source_tiles.map { |t| t["y"].to_i }.min
    max_x = source_tiles.map { |t| t["x"].to_i }.max
    max_y = source_tiles.map { |t| t["y"].to_i }.max
    bw = max_x - min_x + 1
    bh = max_y - min_y + 1
    src_w = bw * tw
    src_h = bh * th

    frame_count = 1
    source_tiles.each do |st|
      fc = shadow_source_frames(st, map)
      frame_count = fc if fc > frame_count
    end

    tint_hex = (config["tintColor"] || "#000000").to_s
    tr = tg = tb = 0
    if tint_hex =~ /^#?([0-9a-fA-F]{6})$/
      n = $1.to_i(16); tr = (n >> 16) & 0xff; tg = (n >> 8) & 0xff; tb = n & 0xff
    end
    tint_color = Color.new(tr, tg, tb, 255)

    src_bmp = Bitmap.new(src_w * frame_count, src_h)
    source_tiles.each do |st|
      tid = st["tileId"].to_i
      next if tid <= 0 && !st["autotile_name"]
      px = (st["x"].to_i - min_x) * tw
      py = (st["y"].to_i - min_y) * th
      frame_count.times do |frame|
        sig = "m#{map.map_id}_t#{tid}_a#{st['autotile_name']}_ts#{st['tileset_id']}_p#{st['autotile_pattern']}_h#{st['flipH'] ? 1 : 0}_v#{st['flipV'] ? 1 : 0}_r#{st['rotation'].to_i}_f#{frame}_c#{tint_hex.downcase}"
        tinted = cached_tinted_tile(sig, tw, th, tint_color) do |bmp|
          shadow_blit_tile(bmp, st, 0, 0, map, frame)
        end
        src_bmp.blt(frame * src_w + px, py, tinted, Rect.new(0, 0, tw, th))
      end
    end

    layout = compute_shadow_layout(config, src_w, src_h, tw, th)
    unless layout
      src_bmp.dispose
      return nil
    end
    drop = layout[:drop]
    placements = layout[:placements]
    drop_slab = build_drop_slab(src_bmp, src_w, src_h, frame_count, drop)
    src_bmp.dispose

    out_w = layout[:out_w]; out_h = layout[:out_h]
    anchor_x = layout[:anchor_x]; anchor_y = layout[:anchor_y]
    shadow_bmp = Bitmap.new(out_w * frame_count, out_h)
    frame_count.times do |frame|
      col_x = frame * out_w
      placements.each { |p| blt_slab_placement(shadow_bmp, col_x, drop_slab, drop, frame, anchor_x, anchor_y, p) }
      connect_shadow_columns(shadow_bmp, col_x, 0, out_w, out_h, tint_color) if placements.size > 1
    end
    drop_slab.dispose
    [shadow_bmp, frame_count, out_w]
  end

  def connect_shadow_columns(bitmap, col_x, col_y, w, h, tint_color)
    w.times do |x|
      bx = col_x + x
      min_y = -1; max_y = -1
      h.times do |y|
        if bitmap.get_pixel(bx, col_y + y).alpha > 0
          min_y = y if min_y < 0
          max_y = y
        end
      end
      next if min_y < 0 || min_y == max_y
      gap = max_y - min_y - 1
      next if gap <= 0
      bitmap.fill_rect(bx, col_y + min_y + 1, 1, gap, tint_color)
    end
  end

  def compute_shadow_layout(config, src_w, src_h, tw, th)
    height_val = (config["height"] || 0.6).to_f.abs
    direction = (config["direction"] || 180).to_f
    drop = drop_geometry(direction, height_val, src_w, src_h)
    return nil unless drop
    uox = ((config["offsetX"] || 0).to_f * tw).round
    uoy = ((config["offsetY"] || 0).to_f * th).round
    uox2 = ((config["secondOffsetX"] || 0).to_f * tw).round
    uoy2 = ((config["secondOffsetY"] || 0).to_f * th).round
    placements = [{ :group_x => 0, :group_y => 0, :off_x => uox, :off_y => uoy }]
    placements << { :group_x => 0, :group_y => -src_h, :off_x => uox2, :off_y => uoy2 } if config["threeDShadow"]
    left_max = right_max = above_max = below_max = 0
    placements.each do |p|
      ext = placed_extents(drop, p[:group_x], p[:group_y], p[:off_x], p[:off_y])
      left_max  = ext[:left]  if ext[:left]  > left_max
      right_max = ext[:right] if ext[:right] > right_max
      above_max = ext[:above] if ext[:above] > above_max
      below_max = ext[:below] if ext[:below] > below_max
    end
    pad = 4 * tw
    anchor_x = pad + ((left_max + tw - 1) / tw) * tw
    anchor_y = pad + ((above_max + th - 1) / th) * th
    { :anchor_x => anchor_x, :anchor_y => anchor_y,
      :out_w => anchor_x + right_max + pad, :out_h => anchor_y + below_max + pad,
      :drop => drop, :placements => placements }
  end

  def drop_geometry(direction, height_val, src_w, src_h)
    rad = direction * Math::PI / 180.0
    dir_x = Math.sin(rad)
    dir_y = -Math.cos(rad)
    l = height_val * src_h
    skew_x = (l * dir_x).round
    abs_skew = skew_x.abs
    skew_floor = [4, abs_skew].min
    flat_h = [1, skew_floor, (l * dir_y.abs).round].max
    downward = dir_y > 0
    { :flat_h => flat_h, :skew_x => skew_x, :abs_skew => abs_skew,
      :inner_w => src_w + abs_skew, :downward => downward,
      :slab_anchor_x => (skew_x < 0 ? abs_skew : 0),
      :slab_anchor_y => (downward ? 0 : [0, flat_h - 1].max) }
  end

  def placed_extents(g, group_x, group_y, off_x, off_y)
    tl_x = group_x - g[:slab_anchor_x] + off_x
    tl_y = group_y - g[:slab_anchor_y] + off_y
    br_x = tl_x + g[:inner_w]
    br_y = tl_y + g[:flat_h]
    { :left => [0, -tl_x].max, :right => [0, br_x].max, :above => [0, -tl_y].max, :below => [0, br_y].max }
  end

  def build_drop_slab(src_bmp, src_w, src_h, frame_count, g)
    flat_h = g[:flat_h]; inner_w = g[:inner_w]; skew_x = g[:skew_x]
    abs_skew = g[:abs_skew]; downward = g[:downward]
    wide_flat = Bitmap.new(src_w * frame_count, flat_h)
    temp_bmp = Bitmap.new(src_w * frame_count, flat_h)
    temp_bmp.stretch_blt(Rect.new(0, 0, src_w * frame_count, flat_h), src_bmp, Rect.new(0, 0, src_w * frame_count, src_h))
    if downward
      (0...flat_h).each { |y| wide_flat.blt(0, flat_h - 1 - y, temp_bmp, Rect.new(0, y, src_w * frame_count, 1)) }
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
        slab_bmp.blt(dst_col_x + slab_anchor_x_local + off, r, wide_flat, Rect.new(src_col_x, r, src_w, 1))
      end
    end
    wide_flat.dispose
    slab_bmp
  end

  def blt_slab_placement(shadow_bmp, col_x, slab_bmp, g, frame, anchor_x, anchor_y, p)
    draw_x = col_x + anchor_x + p[:group_x] - g[:slab_anchor_x] + p[:off_x]
    draw_y = anchor_y + p[:group_y] - g[:slab_anchor_y] + p[:off_y]
    shadow_bmp.blt(draw_x, draw_y, slab_bmp, Rect.new(frame * g[:inner_w], 0, g[:inner_w], g[:flat_h]))
  end
end

#===============================================================================
# Spriteset hooks — attach the overlay on creation, drive + dispose with the
# spriteset. BES fires Events.onSpritesetCreate from Spriteset_Map#initialize.
#===============================================================================
Events.onSpritesetCreate += proc { |_sender, e|
  if MakerStudio::ENABLED
    spriteset, viewport = e
    map = (spriteset.respond_to?(:map) ? spriteset.map : nil) || $game_map
    tilemap = (spriteset.instance_variable_get(:@tilemap) rescue nil)
    if viewport && map
      ov = MakerStudio::Overlay.new(viewport, map, tilemap)
      spriteset.instance_variable_set(:@mkst_overlay, ov)
      # Track only the CURRENT map's overlay/spriteset (for the Reload command).
      if map == $game_map
        MakerStudio.set_current_overlay(ov)
        MakerStudio.instance_variable_set(:@current_spriteset, spriteset)
      end
      # Re-composite native layers now that cells needing overlay treatment were
      # blanked, so the CustomTilemap stops drawing the stand-in tiles.
      begin
        tm = spriteset.instance_variable_get(:@tilemap)
        tm.map_data = map.data if tm
      rescue
      end
    end
  end
}

class Spriteset_Map
  unless method_defined?(:__mkst__update)
    alias_method :__mkst__update, :update
    def update
      __mkst__update
      ov = instance_variable_get(:@mkst_overlay)
      ov.update if ov && !ov.disposed?
    end
  end

  unless method_defined?(:__mkst__dispose)
    alias_method :__mkst__dispose, :dispose
    def dispose
      ov = instance_variable_get(:@mkst_overlay)
      if ov
        ov.dispose
        instance_variable_set(:@mkst_overlay, nil)
      end
      __mkst__dispose
    end
  end
end
