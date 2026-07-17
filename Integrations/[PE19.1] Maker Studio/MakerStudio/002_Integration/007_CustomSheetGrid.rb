#===============================================================================
# MakerStudio - Custom Sheet Grid
# Patches Sprite_Character to support non-standard character sheet layouts.
# Events with @sheet_cols/@sheet_rows in their page graphic (set via
# Maker Studio's CharacterPicker) will use those values instead of the
# hardcoded 4×4 RMXP convention.
#===============================================================================

module MakerStudio
  # Extract sheet grid dimensions from a character's current graphic data.
  # Returns [cols, rows] — defaults to [4, 4] for standard RMXP sheets.
  def self.character_sheet_grid(character)
    if character.is_a?(Game_Event)
      # Game_Event stores the active page in @page (no public attr_reader).
      page = character.instance_variable_get(:@page)
      if page
        graphic = page.graphic
        if graphic
          cols = graphic.instance_variable_get(:@sheet_cols)
          rows = graphic.instance_variable_get(:@sheet_rows)
          return [cols || 4, rows || 4]
        end
      end
    end
    # Player and other characters always use standard 4×4
    return [4, 4]
  end
end

#===============================================================================
# Patch Sprite_Character to use custom grid dimensions.
# Hook point differs per base: customized bases expose update_bitmap, v21.1
# splits the graphic reload into refresh_graphic — v19.1 has NEITHER: it
# computes @cw/@ch and the frame src_rect inline in #update. So hook #update
# and re-derive them (mirroring what the base does right after sizing the cell).
#===============================================================================
class Sprite_Character
  unless method_defined?(:__mkst__update)
    alias __mkst__update update
  end

  def update
    __mkst__update
    return unless self.bitmap && !self.bitmap.disposed?
    return unless @tile_id == 0   # charset graphics only, never map tiles
    cols, rows = MakerStudio.character_sheet_grid(@character)
    # Only override when the grid differs from 4×4
    if cols != 4 || rows != 4
      @cw = self.bitmap.width / cols
      @ch = self.bitmap.height / rows
      sx = @character.pattern * @cw
      sy = ((@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
      self.ox = @cw / 2
      self.oy = (@spriteoffset) ? @ch - 16 : @ch
      self.oy -= @character.bob_height if @character.respond_to?(:bob_height)
      @character.sprite_size = [@cw, @ch] if @character.respond_to?(:sprite_size=)
    end
  end
end
