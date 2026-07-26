#===============================================================================
# MakerStudio - Tile Effects
# Applies per-tile visual effects (opacity, rotation, saturation, hue, lighting)
# to sprites in the game renderer.
#===============================================================================
module MakerStudio
  module TileEffects
    # Cache for effect-modified bitmaps to avoid recreating them each frame
    @bitmap_cache = {}
    # Colour-baked copies of expanded autotile strips, keyed by autotile name +
    # effect combo. Value is [strip_bitmap, { pattern => true }] — see
    # colored_autotile_strip for why the copy is full-size but filled sparsely.
    @strip_cache = {}
    STRIP_CACHE_MAX = 32
    # Shared zero Tone to avoid Tone.new per sprite per frame
    ZERO_TONE = Tone.new(0, 0, 0, 0)

    module_function

    #---------------------------------------------------------------------------
    # Apply visual effects to a TileSprite based on extended layer tile data
    # tile_data is a hash: { "tile_id", "opacity", "rotation", "saturation", "hue", "lighting" }
    #---------------------------------------------------------------------------
    def apply_to_sprite(sprite, tile_data, tileset_bitmap = nil, autotile_bitmaps = nil)
      return unless tile_data && sprite && !sprite.disposed?
      # Opacity
      sprite.opacity = (tile_data["opacity"] || EFFECT_RANGES[:opacity][:default]).to_i
      # Autotiles are POSITIONAL: the pattern a cell shows is chosen from its
      # neighbours, so rotating or mirroring one breaks the edge it was picked to
      # match. The editor refuses to transform them (render-tile-effects.ts) and
      # its UI won't even offer it, so honouring a stale transform here would
      # render the tile differently in-game than on the map the maker drew.
      is_autotile = autotile_tile?(tile_data)
      # Rotation — negate angle to match editor's clockwise convention
      # (RGSS sprite.angle is clockwise, but we store CCW in the rotation value
      #  to keep the editor's Canvas 2D clockwise display correct)
      angle = is_autotile ? 0 : (tile_data["rotation"] || EFFECT_RANGES[:rotation][:default]).to_i
      sprite.angle = -angle
      # Hue / saturation / lighting are baked into the tile's bitmap: the renderer
      # drives the day/night filter through sprite.tone, so anything written there
      # is overwritten. Lighting used to be a Tone for exactly that reason and was
      # silently erased on every bind.
      hue = (tile_data["hue"] || EFFECT_RANGES[:hue][:default]).to_i
      saturation = (tile_data["saturation"] || EFFECT_RANGES[:saturation][:default]).to_i
      lighting = (tile_data["lighting"] || EFFECT_RANGES[:lighting][:default]).to_i
      baked = false
      if hue != 0 || saturation != 100 || lighting != 0
        baked = apply_bitmap_effects(sprite, tile_data, tileset_bitmap, autotile_bitmaps)
      end
      sprite.tone = ZERO_TONE
      # Autotiles bake into a copy of their expanded strip (apply_autotile_strip_effects).
      # When that cannot happen — strip missing, cache full — lighting falls back to a
      # Tone: the renderer ADDS ms_light to its day/night tone instead of overwriting it.
      sprite.ms_light = baked ? 0 : lighting if sprite.respond_to?(:ms_light=)
      flip_h = !is_autotile && tile_data["flipH"]
      flip_v = !is_autotile && tile_data["flipV"]
      # Horizontal flip (uses RPG Maker's built-in mirror property)
      sprite.mirror = flip_h ? true : false
      # Vertical flip (achieved via negative zoom_y)
      if flip_v
        sprite.zoom_y = -sprite.zoom_y
      end
      # Set center origin when rotation or flipV is active to prevent displacement.
      # The update loop compensates by adding ox*|zoom_x|, oy*|zoom_y| to position.
      needs_center = angle != 0 || flip_v
      sprite.ox = needs_center ? TILE_WIDTH / 2 : 0
      sprite.oy = needs_center ? TILE_HEIGHT / 2 : 0
    end

    # An autotile cell: painted by name (tile_id is 0 on native layers) or an id
    # in the autotile range. Same predicate the colour path uses.
    def autotile_tile?(tile_data)
      return true if tile_data["autotile_name"]
      id = tile_data["tile_id"].to_i
      id > 0 && id < TILESET_START_ID
    end

    #---------------------------------------------------------------------------
    # Reset a sprite to default visual state (no effects)
    #---------------------------------------------------------------------------
    def reset_sprite(sprite)
      return unless sprite && !sprite.disposed?
      sprite.opacity = EFFECT_RANGES[:opacity][:default]
      sprite.angle   = EFFECT_RANGES[:rotation][:default]
      sprite.tone    = ZERO_TONE
    end

    #---------------------------------------------------------------------------
    # Apply bitmap-level effects (hue, saturation) using cached modified bitmaps
    #---------------------------------------------------------------------------
    # Returns true when the effects were baked into a (cached) bitmap.
    def apply_bitmap_effects(sprite, tile_data, tileset_bitmap, autotile_bitmaps)
      tile_id = tile_data["tile_id"].to_i
      hue = (tile_data["hue"] || 0).to_i
      saturation = (tile_data["saturation"] || 100).to_i
      lighting = (tile_data["lighting"] || 0).to_i
      ts_id = tile_data["tileset_id"]
      at_name = tile_data["autotile_name"]
      if autotile_tile?(tile_data)
        return apply_autotile_strip_effects(sprite, tile_data, autotile_bitmaps,
                                            hue, saturation, lighting)
      end
      cache_key = "#{tile_id}_ts#{ts_id}_at#{at_name}_h#{hue}_s#{saturation}_l#{lighting}"
      cached = @bitmap_cache[cache_key]
      if cached && !cached.disposed?
        sprite.bitmap = cached
        return true
      end
      # Create a modified bitmap
      src_bitmap = get_source_bitmap(tile_id, tileset_bitmap, autotile_bitmaps, tile_data)
      return false unless src_bitmap && !src_bitmap.disposed?
      modified = create_modified_bitmap(src_bitmap, tile_id, hue, saturation, lighting, tileset_bitmap)
      return false unless modified
      # Cache it (limit cache size)
      @bitmap_cache.delete_if { |_k, v| v.disposed? }
      @bitmap_cache = {} if @bitmap_cache.size > 500
      @bitmap_cache[cache_key] = modified
      sprite.bitmap = modified
      true
    end

    #---------------------------------------------------------------------------
    # Colour an autotile by baking into a COPY OF ITS WHOLE EXPANDED STRIP.
    #
    # An autotile sprite does not own a 32x32 bitmap: it is bound to the shared
    # expanded strip and addresses one cell through src_rect, which the renderer
    # rewrites every animation frame (`@autotiles.set_src_rect`). Handing it a
    # 32x32 bake would freeze the animation and send the engine's next src_rect
    # out of bounds, which is why this path used to bail out and leave autotiles
    # uncoloured. The copy therefore keeps the strip's exact dimensions so all
    # existing src_rect math still lands; only the sprite's own bitmap swaps.
    #
    # Returns true when the colour (including lighting) is baked, so the caller
    # knows not to also park lighting on ms_light.
    #---------------------------------------------------------------------------
    def apply_autotile_strip_effects(sprite, tile_data, autotile_bitmaps, hue, saturation, lighting)
      name = autotile_strip_name(tile_data)
      return false unless name
      src = autotile_bitmaps ? autotile_bitmaps[name] : nil
      return false unless src && !src.disposed?
      pattern = if tile_data["autotile_name"]
                  (tile_data["autotile_pattern"] || 0).to_i
                else
                  tile_data["tile_id"].to_i % TILES_PER_AUTOTILE
                end
      strip = colored_autotile_strip(src, name, pattern, hue, saturation, lighting)
      return false unless strip
      # src_rect is already pointing at this cell's pattern/frame — capture it by
      # VALUE first, because assigning a bitmap resets the sprite's src_rect.
      r = sprite.src_rect
      sx = r.x; sy = r.y; sw = r.width; sh = r.height
      sprite.bitmap = strip
      sprite.src_rect = Rect.new(sx, sy, sw, sh)
      true
    rescue => e
      Console.echo_error("MakerStudio: autotile strip effect error: #{e.message}") if defined?(Console)
      false
    end

    # Autotile filename behind a tile: painted by name, borrowed from another
    # tileset, or the map's own slot. Mirrors get_source_bitmap's resolution.
    def autotile_strip_name(tile_data)
      return tile_data["autotile_name"] if tile_data["autotile_name"]
      idx = (tile_data["tile_id"].to_i / TILES_PER_AUTOTILE) - 1
      return nil if idx < 0
      names = if tile_data["tileset_id"]
                ts = $data_tilesets[tile_data["tileset_id"].to_i]
                ts && ts.autotile_names
              else
                $game_map && $game_map.autotile_names
              end
      names ? names[idx] : nil
    end

    # A full 48-pattern strip is ~196k pixels — far too much to run the per-pixel
    # filter over on map load. The copy is allocated full-size (so src_rect math
    # is unchanged) but only the patterns actually painted are filled in, ~4k
    # pixels each. Every sprite passes through here at bind, so a pattern is
    # always coloured before the sprite that needs it is shown.
    def colored_autotile_strip(src, name, pattern, hue, saturation, lighting)
      key = "#{name}_h#{hue}_s#{saturation}_l#{lighting}"
      entry = @strip_cache[key]
      if entry.nil? || entry[0].nil? || entry[0].disposed?
        clear_strip_cache if @strip_cache.size >= STRIP_CACHE_MAX
        entry = [Bitmap.new(src.width, src.height), {}]
        @strip_cache[key] = entry
      end
      strip = entry[0]
      done = entry[1]
      unless done[pattern]
        autotile_strip_frames(src).times do |f|
          r = autotile_pattern_rect(src, pattern, f)
          next unless r
          strip.blt(r.x, r.y, src, r)
          apply_css_color_filters(strip, hue, saturation, lighting, r)
        end
        done[pattern] = true
      end
      strip
    end

    # Animation frames in an expanded strip, derived from the strip's own
    # geometry. AutotileBitmaps#frame_count is NOT usable here: it reports 2x for
    # wrap-layout extras (see 002_RendererOverride.rb#source_tile_frame_count),
    # and over-counting would leave frames unpainted.
    def autotile_strip_frames(expanded)
      return [expanded.width / TILE_WIDTH, 1].max if expanded.height <= TILE_HEIGHT
      wraps = expanded.height < (TILES_PER_AUTOTILE * TILE_HEIGHT)
      [expanded.width / (TILE_WIDTH * (wraps ? 2 : 1)), 1].max
    end

    # Where one (pattern, frame) sits inside an expanded strip. Same layout math
    # as TilemapRenderer#autotile_src_rect, except an out-of-range rect returns
    # nil (skip) instead of being clamped to row 0 — baking the wrong row would
    # be a visible mis-colour, whereas the renderer needs a drawable rect.
    def autotile_pattern_rect(expanded, pattern, frame)
      tw = TILE_WIDTH
      th = TILE_HEIGHT
      tpa = TILES_PER_AUTOTILE
      return Rect.new(frame * tw, 0, tw, th) if expanded.height <= th
      wraps = expanded.height < (tpa * th)
      sx = 0
      sy = pattern * th
      if wraps && pattern >= (tpa / 2)
        sx = tw
        sy -= th * (tpa / 2)
      end
      sx += frame * tw * (wraps ? 2 : 1)
      return nil if sy < 0 || sy + th > expanded.height || sx + tw > expanded.width
      Rect.new(sx, sy, tw, th)
    end

    def clear_strip_cache
      @strip_cache.each_value { |v| v[0].dispose rescue nil }
      @strip_cache.clear
    end

    #---------------------------------------------------------------------------
    # Get the source bitmap for a tile ID
    # tileset_bitmaps is a TilesetBitmaps, autotile_bitmaps is an AutotileBitmaps
    # tile_data is the extended layer tile data hash (optional, for cross-tileset)
    #---------------------------------------------------------------------------
    def get_source_bitmap(tile_id, tileset_bitmaps, autotile_bitmaps, tile_data = nil)
      # Extra autotile by name
      if tile_data && tile_data["autotile_name"]
        bmp = MakerStudio.get_extra_autotile(tile_data["autotile_name"])
        return (bmp && !bmp.disposed?) ? bmp : nil
      end
      # Cross-tileset reference
      if tile_data && tile_data["tileset_id"]
        ts = $data_tilesets[tile_data["tileset_id"].to_i]
        return nil unless ts
        bmp = MakerStudio.get_extra_tileset(ts.tileset_name)
        return (bmp && !bmp.disposed?) ? bmp : nil
      end
      # Default behavior
      if tile_id >= TILESET_START_ID
        filename = $game_map&.tileset_name
        return nil unless filename
        bmp = tileset_bitmaps[filename]
        return (bmp && !bmp.disposed?) ? bmp : nil
      elsif tile_id > 0
        autotile_index = (tile_id / TILES_PER_AUTOTILE) - 1
        filename = $game_map&.autotile_names&.dig(autotile_index)
        return nil unless filename
        bmp = autotile_bitmaps[filename]
        return (bmp && !bmp.disposed?) ? bmp : nil
      end
      return nil
    end

    #---------------------------------------------------------------------------
    # Create a bitmap with hue/saturation modifications
    #---------------------------------------------------------------------------
    def create_modified_bitmap(src_bitmap, tile_id, hue, saturation, lighting, tileset_bitmap)
      # Extract the tile region
      bmp = Bitmap.new(TILE_WIDTH, TILE_HEIGHT)
      if tile_id >= TILESET_START_ID
        # Regular tile from tileset
        ts_id = tile_id - TILESET_START_ID
        src_x = (ts_id % TILESET_TILES_PER_ROW) * TILE_WIDTH
        src_y = (ts_id / TILESET_TILES_PER_ROW) * TILE_HEIGHT
        rect = Rect.new(src_x, src_y, TILE_WIDTH, TILE_HEIGHT)
        # A tileset taller than the GPU's max texture size (a mega surface) is folded
        # into side-by-side 256px columns by the engine (TilesetWrapper), so a tall
        # tileset's tiles do NOT live at the naive y offset. The map's own tileset
        # arrives here already folded (it comes from the renderer's TilesetBitmaps),
        # while a cross-tileset source is the raw bitmap. Detect the fold by width —
        # an unfolded tileset is exactly TILESET_TILES_PER_ROW tiles wide.
        if src_bitmap.width > TILE_WIDTH * TILESET_TILES_PER_ROW &&
           defined?(TilemapRenderer::TilesetWrapper)
          rect = (TilemapRenderer::TilesetWrapper.getWrappedRect(rect) rescue rect)
        end
        bmp.blt(0, 0, src_bitmap, rect)
      else
        # Autotiles never reach here — apply_bitmap_effects routes them to
        # apply_autotile_strip_effects, which bakes into a copy of the strip.
        return nil
      end
      apply_css_color_filters(bmp, hue, saturation, lighting)
      return bmp
    rescue => e
      Console.echo_error("MakerStudio: Bitmap effect error: #{e.message}") if defined?(Console)
      bmp&.dispose
      return nil
    end

    #---------------------------------------------------------------------------
    # Replicate the editor's CSS filter chain on a bitmap, in CSS order:
    #   hue-rotate(deg) -> saturate(pct/100) -> brightness(1 + lighting/255)
    # Uses the W3C feColorMatrix matrices (Rec.709 luma) so in-game matches the
    # editor canvas exactly. Bitmap#hue_change is a true HSV rotation and reads
    # far more saturated than CSS hue-rotate's linear approximation — never use
    # it here. Same math as the OverlayRenderer copies in PE19.1/BES5.
    #---------------------------------------------------------------------------
    # `rect` limits the pass to one region (autotile strips bake pattern by
    # pattern); nil covers the whole bitmap.
    def apply_css_color_filters(bmp, hue_deg, sat_pct, lighting, rect = nil)
      do_hue = (hue_deg % 360) != 0
      do_sat = sat_pct != 100
      do_bri = lighting != 0
      return unless do_hue || do_sat || do_bri
      x0 = rect ? rect.x : 0
      y0 = rect ? rect.y : 0
      x1 = rect ? rect.x + rect.width : bmp.width
      y1 = rect ? rect.y + rect.height : bmp.height
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
      (y0...y1).each do |y|
        (x0...x1).each do |x|
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
    # Clear the bitmap cache
    #---------------------------------------------------------------------------
    def clear_cache
      @bitmap_cache.each_value { |bmp| bmp.dispose rescue nil }
      @bitmap_cache.clear
      clear_strip_cache
    end
  end
end
