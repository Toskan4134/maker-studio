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
# Patch Sprite_Character to use custom grid dimensions
#===============================================================================
class Sprite_Character
  unless method_defined?(:__mkst__update_bitmap)
    alias __mkst__update_bitmap update_bitmap
  end

  def update_bitmap
    __mkst__update_bitmap
    return unless self.bitmap && !self.bitmap.disposed?
    cols, rows = MakerStudio.character_sheet_grid(@character)
    # Only override when the grid differs from 4×4
    if cols != 4 || rows != 4
      @cw = self.bitmap.width / cols
      @ch = self.bitmap.height / rows
    end
  end
end
