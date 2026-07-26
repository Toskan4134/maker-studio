#===============================================================================
# MakerStudio - Frame Commands
# Adds custom Set Move Route actions that step/set which character-sheet frame
# an event (or the player) displays, honouring the per-page @sheet_cols /
# @sheet_rows grid (see 007_CustomSheetGrid.rb).
#
# Column = horizontal frame (drives @pattern). Row = vertical frame (a manual
# override of the direction-derived row, so sheets taller than 4 rows are
# reachable). The editor stores these as ordinary "Script" move sub-commands
# (RMXP code 45) whose text is one of the ms_frame_* calls below, so the route
# round-trips through vanilla .rxdata and needs no move_type_custom rewrite —
# vanilla's `when 45` already evals the call in Game_Character context.
#
# NOTE: these set the frame manually, so the target should have Move Animation
# and Stop Animation turned OFF — otherwise vanilla pattern animation overwrites
# the column each frame.
#===============================================================================

class Game_Character
  # Manual frame override. nil = follow vanilla @pattern / @direction.
  attr_accessor :ms_frame_col   # horizontal frame (column), 0-based
  attr_accessor :ms_frame_row   # vertical frame (row), 0-based

  # Lazily seed col/row from the current visual frame, and return [cols, rows].
  def ms_frame_ensure
    cols, rows = MakerStudio.character_sheet_grid(self)
    cols = 4 if cols.nil? || cols < 1
    rows = 4 if rows.nil? || rows < 1
    @ms_frame_col = (@pattern || 0) % cols if @ms_frame_col.nil?
    @ms_frame_row = (((@direction || 2) - 2) / 2) % rows if @ms_frame_row.nil?
    return cols, rows
  end

  # Push col/row to the engine. @pattern drives the column for Sprite_Character;
  # the row is applied by the Sprite_Character#update patch below.
  def ms_frame_apply
    @pattern = @ms_frame_col
    @original_pattern = @ms_frame_col   # stop vanilla from animating back to original
  end
  private :ms_frame_apply

  # Next horizontal frame; wrap to the start of the next row at the end of a row
  # (and back to the first frame after the last).
  def ms_frame_next
    cols, rows = ms_frame_ensure
    @ms_frame_col += 1
    if @ms_frame_col >= cols
      @ms_frame_col = 0
      @ms_frame_row = (@ms_frame_row + 1) % rows
    end
    ms_frame_apply
  end

  # Previous horizontal frame; wrap to the end of the previous row at the start.
  def ms_frame_prev
    cols, rows = ms_frame_ensure
    @ms_frame_col -= 1
    if @ms_frame_col < 0
      @ms_frame_col = cols - 1
      @ms_frame_row = (@ms_frame_row - 1) % rows
    end
    ms_frame_apply
  end

  # Next/previous horizontal frame, wrapping within the current row only.
  def ms_frame_next_h
    cols, _rows = ms_frame_ensure
    @ms_frame_col = (@ms_frame_col + 1) % cols
    ms_frame_apply
  end

  def ms_frame_prev_h
    cols, _rows = ms_frame_ensure
    @ms_frame_col = (@ms_frame_col - 1) % cols
    ms_frame_apply
  end

  # Next/previous vertical frame, wrapping within the column only.
  def ms_frame_next_v
    _cols, rows = ms_frame_ensure
    @ms_frame_row = (@ms_frame_row + 1) % rows
    ms_frame_apply
  end

  def ms_frame_prev_v
    _cols, rows = ms_frame_ensure
    @ms_frame_row = (@ms_frame_row - 1) % rows
    ms_frame_apply
  end

  # Set the frame directly. col / row are 0-based; pass nil to leave that axis
  # unchanged. Values wrap modulo the grid size.
  def ms_frame_set(col = nil, row = nil)
    cols, rows = ms_frame_ensure
    @ms_frame_col = ((col % cols) + cols) % cols unless col.nil?
    @ms_frame_row = ((row % rows) + rows) % rows unless row.nil?
    ms_frame_apply
  end
end

#===============================================================================
# Patch Sprite_Character so a manual vertical frame (@ms_frame_row) overrides the
# direction-derived row. The column is left to vanilla (driven by @pattern, which
# ms_frame_apply keeps in sync), so this only rewrites the src_rect's y.
#===============================================================================
class Sprite_Character
  unless method_defined?(:__mkst_fc_update)
    alias __mkst_fc_update update
  end

  def update
    __mkst_fc_update
    ch = @character
    return unless ch && ch.respond_to?(:ms_frame_row)
    row = ch.ms_frame_row
    return if row.nil?
    return unless ch.tile_id == 0           # only character-sheet sprites
    return unless self.bitmap && !self.bitmap.disposed?
    cell_w = self.src_rect.width
    cell_h = (@ch && @ch > 0) ? @ch : self.src_rect.height
    self.src_rect.set(self.src_rect.x, row * cell_h, cell_w, cell_h)
  end
end
