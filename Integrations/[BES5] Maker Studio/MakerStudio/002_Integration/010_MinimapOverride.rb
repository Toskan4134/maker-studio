#===============================================================================
# MakerStudio - Minimap Override
#
# The debug map-preview screens render maps through the engine-global
# createMinimap:
#   * DEBUG > "Editores de archivos PBS" > "Editar map_connections.txt"
#     (the map-connections editor, MapSprite / createMinimap)
#   * DEBUG > "Opciones de campo..." > "Saltar a mapa"
#     (the warp-to-map picker, MapLister#refresh -> createMinimap)
#
# Stock createMinimap only blits the 3 NATIVE layers from the map's OWN tileset
# at 4px/tile. It ignores everything Maker Studio adds, so the preview shows the
# "raw" map: no extended layers, no per-tile properties (rotation / flip /
# opacity / hue / saturation / lighting), no cross-tileset tiles, and no extra
# (named) autotiles.
#
# This override composites the FULL Maker Studio map at the SAME 4px/tile scale
# the connection editor depends on (it maps mouse clicks back to tiles via /4
# and lays maps out at width*4), so the preview matches what the player sees.
#
# Cross-engine: it relies only on primitives present in every supported engine
# (v21.1 / LBDS / BES): the native TileDrawingHelper for tile/autotile assembly
# (handles mega tilesets where the engine does), DataStore for the embedded
# extended-layer JSON, and the shared MakerStudio constants. The two places the
# engines genuinely diverge are picked at runtime:
#   * extra autotiles by name — v21 expands via TilemapRenderer::AutotileExpander
#     (BES has no such class), BES wraps a lone autotile bitmap in a
#     TileDrawingHelper (whose #initialize tolerates a nil tileset; v21's does
#     not), and
#   * the output bitmap class — BitmapWrapper (a Bitmap subclass) on BES, plain
#     Bitmap elsewhere.
#
# On ANY failure (or when the plugin is disabled) it returns nil so the caller
# falls back to the stock createMinimap — the preview is never worse than before.
#===============================================================================
module MakerStudio
  # px per tile — MUST stay 4 to match the connection editor's hit-testing and
  # map layout math.
  MINIMAP_TILE_SCALE = 4

  module_function

  #---------------------------------------------------------------------------
  # Build the full minimap Bitmap for `mapid`. Returns nil on any failure.
  #---------------------------------------------------------------------------
  def build_minimap(mapid)
    return nil unless defined?(TileDrawingHelper)
    map = load_data(sprintf("Data/Map%03d.rxdata", mapid)) rescue nil
    return nil unless map && map.respond_to?(:data) && map.data
    tilesets = (defined?($data_tilesets) && $data_tilesets) ? $data_tilesets :
                                              (load_data("Data/Tilesets.rxdata") rescue nil)
    return nil unless tilesets
    tileset = tilesets[map.tileset_id]
    return nil unless tileset

    scale = MINIMAP_TILE_SCALE
    out = minimap_new_bitmap(map.width * scale, map.height * scale)

    # Map's own-tileset helper (also handles its 7 autotiles). Built once; the
    # cache is keyed by tileset id so cross-tileset references reuse helpers too.
    tdh_cache = {}
    map_helper = minimap_tdh(map.tileset_id, tilesets, tdh_cache)
    if !map_helper
      out.dispose rescue nil
      return nil
    end

    # Extended-layer data (embedded JSON). Missing data -> draw native only.
    ext = (DataStore.get_extended_data(mapid, map.width, map.height, map) rescue nil)
    native_props = ext && ext["nativeProperties"]
    ext_layers = []
    if ext && ext["layers"]
      ext_layers = ext["layers"].select { |l| l && l["visible"] }.
                                sort_by { |l| l["id"].to_i }   # ascending = bottom -> top
    end

    # Scratch bitmaps + caches reused across every cell.
    tmp        = Bitmap.new(TILE_WIDTH, TILE_HEIGHT)  # one tile, pre-effects
    exp_cache  = {}   # autotile name => expanded bitmap (v21 path)
    bes_cache  = {}   # autotile name => TileDrawingHelper (BES path)
    to_dispose = []   # fresh expanded bitmaps we own and must free
    fx_cache   = {}   # [source, effects] key => baked 32x32 bitmap (owned; disposed below)

    # Native per-tile props are uncommon; when none exist, skip the per-cell
    # "x,y" key string + hash lookups entirely (they allocate w*h strings).
    has_native_props = false
    if native_props
      NATIVE_LAYERS.times do |z|
        p = native_props[z]
        has_native_props = true if p && !p.empty?
      end
    end

    # Three passes so the z-order matches the in-game renderer: native ground
    # first, then shadows (z=1, on the ground but under objects), then extended
    # layers + objects on top. Each cell only writes its own 4px square, so a
    # per-cell native/extended order would equal the global order EXCEPT for
    # shadows, which span many cells — hence the split.
    # --- Pass 1: native layers 0..2 (bottom to top) ---
    map.height.times do |y|
      map.width.times do |x|
        px = x * scale
        py = y * scale
        key = has_native_props ? "#{x},#{y}" : nil
        NATIVE_LAYERS.times do |z|
          tid = map.data[x, y, z] || 0
          props = key && native_props[z] && native_props[z][key]
          if props.nil?
            # Plain native tile — fast path identical to stock createMinimap.
            map_helper.bltSmallTile(out, px, py, scale, scale, tid, 0) if tid > 0
          else
            minimap_paint(out, px, py, scale, map, tilesets, map_helper,
                          tdh_cache, exp_cache, bes_cache, to_dispose, tmp,
                          tid, props, 255, fx_cache)
          end
        end
      end
    end

    # --- Pass 2: shadow layers (editor-baked PNGs) ---
    minimap_draw_shadows(out, map, ext, scale) if ext

    # --- Pass 3: extended layers. Sparse: iterate each layer's painted-tile
    # hash instead of scanning the whole w*h grid per layer (extended layers
    # are usually a few hundred tiles on a many-thousand-cell map). Layer-major
    # order is per-cell identical to the old cell-major scan because every draw
    # only touches its own 4px square. ---
    ext_layers.each do |layer|
      tiles = layer["tiles"]
      next unless tiles && !tiles.empty?
      lop = (layer["opacity"] || 255).to_i
      tiles.each do |key, td|
        next unless td
        tid = td["tile_id"].to_i
        next unless tid > 0 || td["autotile_name"]
        x, y = key.split(",")
        x = x.to_i
        y = y ? y.to_i : -1
        next if x < 0 || y < 0 || x >= map.width || y >= map.height
        minimap_paint(out, x * scale, y * scale, scale, map, tilesets, map_helper,
                      tdh_cache, exp_cache, bes_cache, to_dispose, tmp,
                      tid, td, lop, fx_cache)
      end
    end

    tmp.dispose rescue nil
    fx_cache.each_value { |b| b.dispose rescue nil }
    to_dispose.each { |b| b.dispose rescue nil }
    minimap_border(out)
    out
  rescue => e
    Console.echo_error("MakerStudio: build_minimap failed: #{e.message}") if defined?(Console)
    (out.dispose rescue nil) if out
    nil
  end

  #---------------------------------------------------------------------------
  # Paint one tile (native-with-properties or extended) into the output cell,
  # applying cross-tileset / extra-autotile resolution and per-tile effects.
  #
  # The color filters and the transform are per-pixel Ruby loops (~1k
  # get/set_pixel each), so running them per OCCURRENCE froze the debug map
  # previews on maps with many effect tiles. Each unique (source, effects)
  # combo now bakes ONCE into fx_cache and repeats are a plain stretch_blt.
  # Opacity stays outside the key (applied at blit time).
  #---------------------------------------------------------------------------
  def minimap_paint(out, px, py, scale, map, tilesets, map_helper,
                    tdh_cache, exp_cache, bes_cache, to_dispose, tmp, tid, td, layer_opacity, fx_cache)
    name  = td && td["autotile_name"]
    ts_id = td && td["tileset_id"]

    # Effective opacity = layer opacity * per-tile opacity.
    opacity = layer_opacity
    opacity = (opacity * td["opacity"].to_i / 255.0).round if td && td["opacity"]
    opacity = 0 if opacity < 0
    opacity = 255 if opacity > 255
    return if opacity <= 0

    hue = (td && td["hue"])        ? td["hue"].to_i        : 0
    sat = (td && td["saturation"]) ? td["saturation"].to_i : 100
    lig = (td && td["lighting"])   ? td["lighting"].to_i   : 0
    has_color = (hue % 360 != 0) || (sat != 100) || (lig != 0)

    flipH = td && td["flipH"]
    flipV = td && td["flipV"]
    rot   = minimap_snap90(td ? (td["rotation"].to_i) : 0)
    has_xform = flipH || flipV || rot != 0

    # Fast path: plain own-tileset tile, full opacity, no effects.
    if !name && !ts_id && !has_color && !has_xform && opacity >= 255
      map_helper.bltSmallTile(out, px, py, scale, scale, tid, 0) if tid > 0
      return
    end

    ck = [name, ts_id, tid, name ? (td["autotile_pattern"] || 0).to_i : 0,
          hue, sat, lig, flipH ? 1 : 0, flipV ? 1 : 0, rot]
    baked = fx_cache[ck]
    if !baked
      tmp.clear
      return unless minimap_blit_base(tmp, name, ts_id, tid, td, map, tilesets,
                                      map_helper, tdh_cache, exp_cache, bes_cache, to_dispose)

      minimap_color_filters(tmp, hue, sat, lig) if has_color

      if has_xform
        baked = minimap_transform(tmp, flipH, flipV, rot)
      else
        baked = Bitmap.new(tmp.width, tmp.height)
        baked.blt(0, 0, tmp, Rect.new(0, 0, tmp.width, tmp.height))
      end
      # Pathological maps (thousands of distinct effect combos) could balloon
      # the cache: drop everything and rebuild rather than track LRU order.
      if fx_cache.size >= 512
        fx_cache.each_value { |b| b.dispose rescue nil }
        fx_cache.clear
      end
      fx_cache[ck] = baked
    end

    out.stretch_blt(Rect.new(px, py, scale, scale), baked,
                    Rect.new(0, 0, baked.width, baked.height), opacity)
  end

  #---------------------------------------------------------------------------
  # Draw one untransformed tile into the 32x32 scratch bitmap. Returns false
  # when the tile could not be resolved (missing asset) so the caller skips it.
  #---------------------------------------------------------------------------
  def minimap_blit_base(tmp, name, ts_id, tid, td, map, tilesets,
                        map_helper, tdh_cache, exp_cache, bes_cache, to_dispose)
    if name
      return minimap_blit_extra_autotile(tmp, name, (td["autotile_pattern"] || 0).to_i,
                                         exp_cache, bes_cache, to_dispose)
    end
    if ts_id
      helper = minimap_tdh(ts_id.to_i, tilesets, tdh_cache)
      return false unless helper
      return false if tid <= 0
      helper.bltTile(tmp, 0, 0, tid, 0)
      return true
    end
    return false if tid <= 0
    map_helper.bltTile(tmp, 0, 0, tid, 0)
    true
  end

  #---------------------------------------------------------------------------
  # Extra (named) autotile -> 32x32 scratch. Engine-adaptive: v21 expands the
  # raw strip through AutotileExpander; BES wraps the raw strip in a nil-tileset
  # TileDrawingHelper and uses its autotile assembler.
  #---------------------------------------------------------------------------
  def minimap_blit_extra_autotile(tmp, name, pattern, exp_cache, bes_cache, to_dispose)
    pattern %= TILES_PER_AUTOTILE
    if defined?(TilemapRenderer::AutotileExpander)
      exp = exp_cache[name]
      unless exp
        raw = get_extra_autotile(name)
        return false unless raw && !raw.disposed?
        exp = TilemapRenderer::AutotileExpander.expand(raw)
        return false unless exp && !exp.disposed?
        exp_cache[name] = exp
        to_dispose << exp unless exp.equal?(raw)   # expand returns input for 32px-tall minis
      end
      tmp.blt(0, 0, exp, minimap_autotile_src_rect(exp, pattern))
      return true
    end
    # BES path
    helper = bes_cache[name]
    unless helper
      bmp = pbGetAutotile(name) rescue nil
      return false unless bmp && !bmp.disposed?
      helper = TileDrawingHelper.new(nil, [bmp])
      bes_cache[name] = helper
    end
    helper.bltAutotile(tmp, 0, 0, TILES_PER_AUTOTILE + pattern, 0)
    true
  end

  #---------------------------------------------------------------------------
  # Source rect for an expanded-autotile pattern (mirrors the in-game renderer's
  # autotile_src_rect; minimap always uses frame 0).
  #---------------------------------------------------------------------------
  def minimap_autotile_src_rect(expanded, pattern)
    tpa = TILES_PER_AUTOTILE
    tw  = TILE_WIDTH
    th  = TILE_HEIGHT
    return Rect.new(0, 0, tw, th) if expanded.height <= th  # single-row mini autotile
    wraps   = expanded.height < (tpa * th)
    high_id = pattern >= (tpa / 2)
    sx = 0
    sy = pattern * th
    if wraps && high_id
      sx = tw
      sy -= th * (tpa / 2)
    end
    sy = 0 if sy + th > expanded.height
    Rect.new(sx, sy, tw, th)
  end

  #---------------------------------------------------------------------------
  # Cached TileDrawingHelper for a tileset id (own + cross-tileset tiles).
  #---------------------------------------------------------------------------
  def minimap_tdh(ts_id, tilesets, cache)
    h = cache[ts_id]
    return h if h
    ts = tilesets[ts_id]
    return nil unless ts
    h = (TileDrawingHelper.fromTileset(ts) rescue nil)
    cache[ts_id] = h if h
    h
  end

  #---------------------------------------------------------------------------
  # Snap an arbitrary rotation to the nearest right angle. At 4px/tile the
  # difference between exact and snapped rotation is imperceptible, and per-pixel
  # right-angle rotation keeps the preview cheap.
  #---------------------------------------------------------------------------
  def minimap_snap90(rotation)
    r = rotation % 360
    r += 360 if r < 0
    (((r + 45) / 90).floor * 90) % 360
  end

  #---------------------------------------------------------------------------
  # Right-angle rotate (0/90/180/270) then flip, into a fresh 32x32 bitmap.
  # Order matches the in-game shadow/transform bake (rotate, then flip).
  #---------------------------------------------------------------------------
  def minimap_transform(src, flipH, flipV, rotation)
    sw  = src.width
    sh  = src.height
    rot = minimap_snap90(rotation)
    dest = Bitmap.new(sw, sh)   # square tile: dimensions unchanged by rotation
    sw.times do |i|
      sh.times do |j|
        case rot
        when 90  then sx = j;          sy = sw - 1 - i
        when 180 then sx = sw - 1 - i; sy = sh - 1 - j
        when 270 then sx = sh - 1 - j; sy = i
        else          sx = i;          sy = j
        end
        next if sx < 0 || sy < 0 || sx >= sw || sy >= sh
        c = src.get_pixel(sx, sy)
        next if c.alpha == 0
        ox = flipH ? (sw - 1 - i) : i
        oy = flipV ? (sh - 1 - j) : j
        dest.set_pixel(ox, oy, c)
      end
    end
    dest
  end

  #---------------------------------------------------------------------------
  # Bake hue / saturation / lighting onto a bitmap in place, replicating the
  # editor's CSS filter chain (hue-rotate -> saturate -> brightness) with the
  # W3C feColorMatrix matrices so the preview matches the editor exactly.
  #---------------------------------------------------------------------------
  def minimap_color_filters(bmp, hue_deg, sat_pct, lighting)
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
  # Draw shadow layers from their editor-baked PNGs (Graphics/Shadows/<map>_<id>).
  # Positioned with the SAME layout anchor math the in-game renderer uses for the
  # baked-PNG fast path, then scaled to the 4px grid with the shadow's opacity.
  # Runtime-generated shadows (no baked PNG) are skipped — generating the
  # silhouette here would need the live TilemapRenderer's tileset/autotile pool.
  #---------------------------------------------------------------------------
  def minimap_draw_shadows(out, map, ext, scale)
    shadows = ext["shadowLayers"]
    if !shadows || shadows.empty?
      single = ext["shadowLayer"]
      shadows = single ? [single] : []
    end
    return if shadows.empty?
    tw = TILE_WIDTH
    th = TILE_HEIGHT
    f = scale.to_f / tw   # full-res pixel -> minimap pixel
    shadows.each_with_index do |shadow, idx|
      next unless shadow && shadow["visible"]
      config = shadow["config"]
      source_tiles = shadow["sourceTiles"]
      next unless config && source_tiles && !source_tiles.empty?
      next if config["height"].nil? || config["direction"].nil?   # legacy config
      shadow_id = shadow["id"] || idx
      bmp = (Bitmap.new(sprintf("Graphics/Shadows/%03d_%d", map.map_id, shadow_id)) rescue nil)
      next unless bmp && !bmp.disposed?
      begin
        xs = source_tiles.map { |t| t["x"].to_i }
        ys = source_tiles.map { |t| t["y"].to_i }
        min_x = xs.min
        min_y = ys.min
        bh = ys.max - min_y + 1
        bw = xs.max - min_x + 1
        layout = minimap_shadow_layout(config, bw * tw, bh * th, tw, th)
        if layout
          frame_w = (shadow["frameWidth"] || bmp.width).to_i
          frame_w = bmp.width if frame_w <= 0 || frame_w > bmp.width
          origin_x = min_x * tw - layout[:anchor_x]
          origin_y = (min_y + bh) * th - layout[:anchor_y]
          op = ((config["shadowOpacity"] || 51).to_i * (shadow["opacity"] || 255).to_i / 255.0).round
          op = 0 if op < 0
          op = 255 if op > 255
          if op > 0
            dest = Rect.new((origin_x * f).round, (origin_y * f).round,
                            [(frame_w * f).round, 1].max, [(bmp.height * f).round, 1].max)
            out.stretch_blt(dest, bmp, Rect.new(0, 0, frame_w, bmp.height), op)
          end
        end
      ensure
        bmp.dispose rescue nil   # baked PNG is freshly loaded; we own it
      end
    end
  end

  #---------------------------------------------------------------------------
  # Shadow bitmap anchor (top-left of the baked PNG in map-pixel space). Ports
  # the in-game renderer's compute_shadow_layout / drop_geometry / placed_extents
  # (pure math, identical across engines). Only the anchor is needed here — the
  # baked PNG already carries its own width/height.
  #---------------------------------------------------------------------------
  def minimap_shadow_layout(config, src_w, src_h, tw, th)
    drop = minimap_drop_geometry((config["direction"] || 180).to_f,
                                 (config["height"] || 0.6).to_f.abs, src_w, src_h)
    return nil unless drop
    placements = []
    placements << { :gx => 0, :gy => 0,
                    :ox => ((config["offsetX"] || 0).to_f * tw).round,
                    :oy => ((config["offsetY"] || 0).to_f * th).round }
    if config["threeDShadow"]
      placements << { :gx => 0, :gy => -src_h,
                      :ox => ((config["secondOffsetX"] || 0).to_f * tw).round,
                      :oy => ((config["secondOffsetY"] || 0).to_f * th).round }
    end
    left_max = above_max = 0
    placements.each do |p|
      ext = minimap_placed_extents(drop, p[:gx], p[:gy], p[:ox], p[:oy])
      left_max  = ext[:left]  if ext[:left]  > left_max
      above_max = ext[:above] if ext[:above] > above_max
    end
    pad = 4 * tw
    { :anchor_x => pad + ((left_max + tw - 1) / tw) * tw,
      :anchor_y => pad + ((above_max + th - 1) / th) * th }
  end

  def minimap_drop_geometry(direction, height_val, src_w, src_h)
    rad = direction * Math::PI / 180.0
    dir_x = Math.sin(rad)
    dir_y = -Math.cos(rad)
    l = height_val * src_h
    skew_x = (l * dir_x).round
    abs_skew = skew_x.abs
    flat_h = [1, [4, abs_skew].min, (l * dir_y.abs).round].max
    downward = dir_y > 0
    {
      :flat_h => flat_h, :inner_w => src_w + abs_skew,
      :slab_anchor_x => (skew_x < 0 ? abs_skew : 0),
      :slab_anchor_y => (downward ? 0 : [0, flat_h - 1].max)
    }
  end

  def minimap_placed_extents(g, group_x, group_y, off_x, off_y)
    tl_x = group_x - g[:slab_anchor_x] + off_x
    tl_y = group_y - g[:slab_anchor_y] + off_y
    { :left => [0, -tl_x].max, :above => [0, -tl_y].max }
  end

  #---------------------------------------------------------------------------
  # 1px black frame around the minimap (matches stock createMinimap).
  #---------------------------------------------------------------------------
  def minimap_border(out)
    black = Color.new(0, 0, 0)
    out.fill_rect(0, 0, out.width, 1, black)
    out.fill_rect(0, out.height - 1, out.width, 1, black)
    out.fill_rect(0, 0, 1, out.height, black)
    out.fill_rect(out.width - 1, 0, 1, out.height, black)
  end

  #---------------------------------------------------------------------------
  # Allocate the output bitmap with the engine's preferred class. BES needs
  # BitmapWrapper (a refcounted Bitmap subclass) for >max-texture-size maps,
  # exactly like its own createMinimap.
  #---------------------------------------------------------------------------
  def minimap_new_bitmap(w, h)
    defined?(BitmapWrapper) ? BitmapWrapper.new(w, h) : Bitmap.new(w, h)
  end
end

#===============================================================================
# Override the engine-global createMinimap. Falls back to the stock version
# (aliased once) when disabled or on any failure.
#===============================================================================
class Object
  # Alias the original ONCE. Re-defining createMinimap unconditionally (outside
  # the guard) survives an mkxp F12 soft-reset: the engine re-runs its own
  # createMinimap (restoring stock), then this file re-installs the override
  # while __mkst_orig_createMinimap keeps pointing at the genuine original.
  if (private_method_defined?(:createMinimap) || method_defined?(:createMinimap)) &&
     !(private_method_defined?(:__mkst_orig_createMinimap) || method_defined?(:__mkst_orig_createMinimap))
    alias_method :__mkst_orig_createMinimap, :createMinimap
  end

  def createMinimap(mapid)
    if defined?(MakerStudio) && MakerStudio::ENABLED
      result = MakerStudio.build_minimap(mapid)
      return result if result && !result.disposed?
    end
    # respond_to?(:sym, true) would be cleaner but is not Ruby-1.8-safe (RGSS),
    # and the alias is a PRIVATE method so 1-arg respond_to? returns false —
    # query Object's method table directly (checks ancestors).
    if Object.private_method_defined?(:__mkst_orig_createMinimap) ||
       Object.method_defined?(:__mkst_orig_createMinimap)
      return __mkst_orig_createMinimap(mapid)
    end
    # No stock implementation to fall back to (shouldn't happen).
    MakerStudio.build_minimap(mapid) || Bitmap.new(32, 32)
  end
end
