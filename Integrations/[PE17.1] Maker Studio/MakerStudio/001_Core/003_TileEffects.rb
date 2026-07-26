#===============================================================================
# MakerStudio - Tile Effects
# Applies per-tile visual effects (opacity, rotation, saturation, hue, lighting)
# to sprites in the game renderer.
#===============================================================================
module MakerStudio
  module TileEffects
    # Cache for effect-modified bitmaps to avoid recreating them each frame
    @bitmap_cache = {}
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
      # Rotation — negate angle to match editor's clockwise convention
      # (RGSS sprite.angle is clockwise, but we store CCW in the rotation value
      #  to keep the editor's Canvas 2D clockwise display correct)
      # Autotiles are POSITIONAL: the pattern a cell shows is chosen from its
      # neighbours, so rotating or mirroring one breaks the edge it was picked to
      # match. The editor refuses to transform them (render-tile-effects.ts) and
      # its UI won't even offer it, so honouring a stale transform here would
      # render the tile differently in-game than on the map the maker drew.
      is_autotile = autotile_tile?(tile_data)
      angle = is_autotile ? 0 : (tile_data["rotation"] || EFFECT_RANGES[:rotation][:default]).to_i
      sprite.angle = -angle
      # Lighting via Tone
      lighting = (tile_data["lighting"] || EFFECT_RANGES[:lighting][:default]).to_i
      if lighting != 0
        r = [lighting, 0].max
        g = [lighting, 0].max
        b = [lighting, 0].max
        gray = [-lighting, 0].max
        sprite.tone = Tone.new(r, g, b, gray)
      else
        sprite.tone = ZERO_TONE
      end
      # Hue and Saturation require bitmap modification
      hue = (tile_data["hue"] || EFFECT_RANGES[:hue][:default]).to_i
      saturation = (tile_data["saturation"] || EFFECT_RANGES[:saturation][:default]).to_i
      if hue != 0 || saturation != 100
        apply_bitmap_effects(sprite, tile_data, tileset_bitmap, autotile_bitmaps)
      end
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
    # in the autotile range.
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
    def apply_bitmap_effects(sprite, tile_data, tileset_bitmap, autotile_bitmaps)
      tile_id = tile_data["tile_id"].to_i
      hue = (tile_data["hue"] || 0).to_i
      saturation = (tile_data["saturation"] || 100).to_i
      ts_id = tile_data["tileset_id"]
      at_name = tile_data["autotile_name"]
      cache_key = "#{tile_id}_ts#{ts_id}_at#{at_name}_h#{hue}_s#{saturation}"
      cached = @bitmap_cache[cache_key]
      if cached && !cached.disposed?
        sprite.bitmap = cached
        return
      end
      # Create a modified bitmap
      src_bitmap = get_source_bitmap(tile_id, tileset_bitmap, autotile_bitmaps, tile_data)
      return unless src_bitmap && !src_bitmap.disposed?
      modified = create_modified_bitmap(src_bitmap, tile_id, hue, saturation, tileset_bitmap)
      return unless modified
      # Cache it (limit cache size)
      @bitmap_cache.delete_if { |_k, v| v.disposed? }
      @bitmap_cache = {} if @bitmap_cache.size > 500
      @bitmap_cache[cache_key] = modified
      sprite.bitmap = modified
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
      # Default behavior (1.8-safe: no &./dig)
      if tile_id >= TILESET_START_ID
        filename = $game_map ? $game_map.tileset_name : nil
        return nil unless filename
        bmp = tileset_bitmaps[filename]
        return (bmp && !bmp.disposed?) ? bmp : nil
      elsif tile_id > 0
        autotile_index = (tile_id / TILES_PER_AUTOTILE) - 1
        names = $game_map ? $game_map.autotile_names : nil
        filename = names ? names[autotile_index] : nil
        return nil unless filename
        bmp = autotile_bitmaps[filename]
        return (bmp && !bmp.disposed?) ? bmp : nil
      end
      return nil
    end

    #---------------------------------------------------------------------------
    # Create a bitmap with hue/saturation modifications
    #---------------------------------------------------------------------------
    def create_modified_bitmap(src_bitmap, tile_id, hue, saturation, tileset_bitmap)
      # Extract the tile region
      bmp = Bitmap.new(TILE_WIDTH, TILE_HEIGHT)
      if tile_id >= TILESET_START_ID
        # Regular tile from tileset
        ts_id = tile_id - TILESET_START_ID
        src_x = (ts_id % TILESET_TILES_PER_ROW) * TILE_WIDTH
        src_y = (ts_id / TILESET_TILES_PER_ROW) * TILE_HEIGHT
        bmp.blt(0, 0, src_bitmap, Rect.new(src_x, src_y, TILE_WIDTH, TILE_HEIGHT))
      else
        # Autotile - blit current src_rect
        return nil # Autotile bitmap effects are complex, skip for now
      end
      # Lighting stays Tone-based in this variant, so bake hue/sat only.
      apply_css_color_filters(bmp, hue, saturation, 0)
      return bmp
    rescue => e
      echoln("MakerStudio ERROR: bitmap effect error: #{e.message}")
      bmp.dispose if bmp
      return nil
    end

    #---------------------------------------------------------------------------
    # Replicate the editor's CSS filter chain on a bitmap, in CSS order:
    #   hue-rotate(deg) -> saturate(pct/100) -> brightness(1 + lighting/255)
    # Uses the W3C feColorMatrix matrices (Rec.709 luma) so in-game matches the
    # editor canvas exactly. Bitmap#hue_change is a true HSV rotation and reads
    # far more saturated than CSS hue-rotate's linear approximation — never use
    # it here. Same math as this integration's OverlayRenderer copy. 1.8-safe.
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
    # Clear the bitmap cache
    #---------------------------------------------------------------------------
    def clear_cache
      @bitmap_cache.each_value { |bmp| bmp.dispose rescue nil }
      @bitmap_cache.clear
    end
  end
end
