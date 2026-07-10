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
      # Apply hue shift
      bmp.hue_change(hue) if hue != 0
      # Apply saturation (desaturate by blending with grayscale)
      if saturation != 100
        apply_saturation(bmp, saturation)
      end
      return bmp
    rescue => e
      echoln("MakerStudio ERROR: bitmap effect error: #{e.message}")
      bmp.dispose if bmp
      return nil
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
          # 1.8-safe clamp (no Comparable#clamp)
          r = [[(gray + (color.red - gray) * factor), 0].max, 255].min.round
          g = [[(gray + (color.green - gray) * factor), 0].max, 255].min.round
          b = [[(gray + (color.blue - gray) * factor), 0].max, 255].min.round
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
