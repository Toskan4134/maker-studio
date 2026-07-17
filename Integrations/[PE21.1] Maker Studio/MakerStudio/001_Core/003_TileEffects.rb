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
      angle = (tile_data["rotation"] || EFFECT_RANGES[:rotation][:default]).to_i
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
      # Autotiles have no bakeable per-tile bitmap (their sprite shares the whole
      # expanded strip), so their lighting falls back to a Tone. The renderer adds
      # ms_light to its day/night tone instead of overwriting it.
      sprite.ms_light = baked ? 0 : lighting if sprite.respond_to?(:ms_light=)
      # Horizontal flip (uses RPG Maker's built-in mirror property)
      sprite.mirror = tile_data["flipH"] ? true : false
      # Vertical flip (achieved via negative zoom_y)
      if tile_data["flipV"]
        sprite.zoom_y = -sprite.zoom_y
      end
      # Set center origin when rotation or flipV is active to prevent displacement.
      # The update loop compensates by adding ox*|zoom_x|, oy*|zoom_y| to position.
      needs_center = angle != 0 || tile_data["flipV"]
      sprite.ox = needs_center ? TILE_WIDTH / 2 : 0
      sprite.oy = needs_center ? TILE_HEIGHT / 2 : 0
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
        # Autotile - blit current src_rect
        return nil # Autotile bitmap effects are complex, skip for now
      end
      # Editor order: hue-rotate -> saturate -> brightness. Keep it.
      bmp.hue_change(hue) if hue != 0
      # Apply saturation (desaturate by blending with grayscale)
      if saturation != 100
        apply_saturation(bmp, saturation)
      end
      apply_brightness(bmp, lighting) if lighting != 0
      return bmp
    rescue => e
      Console.echo_error("MakerStudio: Bitmap effect error: #{e.message}") if defined?(Console)
      bmp&.dispose
      return nil
    end

    #---------------------------------------------------------------------------
    # Lighting, matching the editor's CSS `brightness(1 + lighting/255)` — a
    # MULTIPLIER, not the additive Tone the plugin used to reach for (which the
    # renderer's day/night tone overwrote anyway).
    #---------------------------------------------------------------------------
    def apply_brightness(bitmap, lighting)
      factor = 1.0 + (lighting / 255.0)
      factor = 0.0 if factor < 0.0
      w = bitmap.width
      h = bitmap.height
      (0...h).each do |y|
        (0...w).each do |x|
          color = bitmap.get_pixel(x, y)
          next if color.alpha == 0
          bitmap.set_pixel(x, y, Color.new(
            (color.red * factor).round.clamp(0, 255),
            (color.green * factor).round.clamp(0, 255),
            (color.blue * factor).round.clamp(0, 255),
            color.alpha
          ))
        end
      end
    end

    #---------------------------------------------------------------------------
    # Apply saturation adjustment to a bitmap
    #---------------------------------------------------------------------------
    def apply_saturation(bitmap, saturation_pct)
      return if saturation_pct == 100
      w = bitmap.width
      h = bitmap.height
      factor = saturation_pct / 100.0
      (0...h).each do |y|
        (0...w).each do |x|
          color = bitmap.get_pixel(x, y)
          next if color.alpha == 0
          gray = (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114).round
          r = (gray + (color.red - gray) * factor).clamp(0, 255).round
          g = (gray + (color.green - gray) * factor).clamp(0, 255).round
          b = (gray + (color.blue - gray) * factor).clamp(0, 255).round
          bitmap.set_pixel(x, y, Color.new(r, g, b, color.alpha))
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
