#===============================================================================
# MakerStudio - Graphic Region (partial graphics)
#
# Lets a graphic use only PART of its image file — the tiles picked off a
# tileset in Maker Studio's graphic picker. That is the point of the feature:
# giving an event a tile out of a tileset, which RPG Maker can only do through
# @tile_id (map tilesets, current map only).
#
# Nothing here knows about tiles. The region is a plain pixel rect; the editor
# is what constrains it to whole tiles, so this file stays one blt.
#
# The region is four numbers (x, y, w, h) in source-image pixels. w or h of 0
# means "whole image", which is what every graphic authored without Maker Studio
# reads as — so this plugin changes nothing until a region is actually set.
#
# Where the numbers live, and why they are invisible to vanilla RGSS:
#
#   event page graphic  @src_x/@src_y/@src_w/@src_h on RPG::Event::Page::Graphic
#                       (extra ivars, the same trick 007_CustomSheetGrid uses)
#   move route 41       @parameters[4..7]  (RMXP reads 0..3)
#   Show Picture 231    @parameters[10..13] (RMXP reads 0..9)
#
# A map saved with regions therefore still runs without this plugin: the extra
# ivars and parameters are ignored and the whole image is drawn.
#
# The region REPLACES the image everywhere downstream — the sheet grid from
# 007_CustomSheetGrid divides the region, not the file — so one tile with a 1x1
# sheet grid is a static sprite, and a 3x4 block of tiles still animates. The
# editor sets that grid from the tile selection, so both come out right.
#===============================================================================

module MakerStudio
  # [x, y, w, h] or nil. A region set by a move route (41) wins over the page's,
  # so a route can re-cut the same sheet; Game_Event#refresh drops it below.
  def self.character_src_rect(character)
    return nil if character.nil?
    r = character.instance_variable_get(:@ms_src_rect)
    return r if r
    return nil unless character.is_a?(Game_Event)
    page = character.instance_variable_get(:@page)
    graphic = page && page.graphic
    return nil unless graphic
    src_rect_ivars(graphic)
  end

  # The four ivars off any object, or nil when they say "whole image".
  def self.src_rect_ivars(obj)
    w = obj.instance_variable_get(:@src_w).to_i
    h = obj.instance_variable_get(:@src_h).to_i
    return nil if w <= 0 || h <= 0
    [obj.instance_variable_get(:@src_x).to_i, obj.instance_variable_get(:@src_y).to_i, w, h]
  end

  # Four command parameters, or nil. Missing/short parameter arrays (a map
  # written by RMXP itself) read as "whole image".
  def self.src_rect_params(params, at)
    return nil if params.nil?
    w = params[at + 2].to_i
    h = params[at + 3].to_i
    return nil if w <= 0 || h <= 0
    [params[at].to_i, params[at + 1].to_i, w, h]
  end

  # A fresh Bitmap holding just the region. Clamped to the source, so a region
  # left over from a larger version of the file still draws something.
  def self.cropped_bitmap(src, rect)
    x, y, w, h = rect
    x = 0 if x < 0
    y = 0 if y < 0
    x = src.width - 1 if x >= src.width
    y = src.height - 1 if y >= src.height
    w = src.width - x if w > src.width - x
    h = src.height - y if h > src.height - y
    w = 1 if w < 1
    h = 1 if h < 1
    out = Bitmap.new(w, h)
    out.blt(0, 0, src, Rect.new(x, y, w, h))
    out
  end
end

#===============================================================================
# Characters (event page graphics + move route "Change Graphic").
#
# The region is applied by replacing @charbitmap — the SOURCE the base class
# reads every frame — not self.bitmap. PE21.1's update_bitmap reassigns
# self.bitmap = @charbitmap.bitmap on every update; fighting that by overwriting
# self.bitmap AFTER update leaves one frame where @cw/@ch (still full-file
# dimensions) made update_charset_frame point src_rect at the wrong cell, so the
# whole tileset flashed through. Once @charbitmap IS the crop, the base's own
# update_bitmap / update_charset_frame / src_rect logic produces the right
# result every frame with zero fighting. The hook still runs every update, but
# only does work when the crop actually changes.
#===============================================================================
class Sprite_Character
  unless method_defined?(:__mkst__region_update)
    alias __mkst__region_update update
  end

  def update
    __mkst__region_update
    ms_region_refresh
  end

  def ms_region_refresh
    char = @character
    return if char.nil?
    return if char.respond_to?(:tile_id) && char.tile_id.to_i >= 384

    # refresh_graphic replaced @charbitmap under us (name/hue changed) —
    # our saved original and crop are stale, start fresh.
    if @ms_crop_bitmap && !@charbitmap.equal?(@ms_crop_bitmap)
      @ms_original_charbitmap = nil
      @ms_crop_bitmap = nil
      @ms_region_key = nil
    end

    rect = MakerStudio.character_src_rect(char)

    # No crop: restore the original charbitmap if we had replaced it.
    if rect.nil?
      if @ms_original_charbitmap
        @charbitmap = @ms_original_charbitmap
        @charbitmapAnimated = @ms_original_animated
        @ms_original_charbitmap = nil
        @ms_crop_bitmap.dispose if @ms_crop_bitmap
        @ms_crop_bitmap = nil
        @ms_region_key = nil
        @character_name = nil   # force refresh_graphic to reload
      end
      return
    end

    return if @charbitmap.nil?

    # Source bitmap to crop from: the original (pre-crop) if we saved one,
    # else the current @charbitmap (first crop of this graphic).
    source = @ms_original_charbitmap || @charbitmap
    source_bmp = source.respond_to?(:bitmap) ? source.bitmap : source
    return if source_bmp.nil? || source_bmp.disposed?

    key = "#{source_bmp.object_id}|#{rect.join(',')}"
    return if key == @ms_region_key

    @ms_region_key = key

    # Save original on first crop of this graphic.
    unless @ms_original_charbitmap
      @ms_original_charbitmap = @charbitmap
      @ms_original_animated = @charbitmapAnimated
    end

    old_crop = @ms_crop_bitmap
    @ms_crop_bitmap = MakerStudio.cropped_bitmap(source_bmp, rect)
    old_crop.dispose if old_crop && !old_crop.disposed?

    # Replace @charbitmap so the base's own update_bitmap, update_charset_frame
    # and src_rect logic all operate on the crop every frame.
    @charbitmap = @ms_crop_bitmap
    @charbitmapAnimated = false
    self.bitmap = @ms_crop_bitmap

    cols, rows = MakerStudio.character_sheet_grid(char)
    cols = 1 if cols < 1
    rows = 1 if rows < 1
    @cw = @ms_crop_bitmap.width / cols
    @ch = @ms_crop_bitmap.height / rows
    @cw = 1 if @cw < 1
    @ch = 1 if @ch < 1
    self.ox = @cw / 2
    char.sprite_size = [@cw, @ch] if char.respond_to?(:sprite_size=)

    # update_charset_frame already ran this frame with the old @cw/@ch; redo
    # src_rect so the first frame after a crop change is correct.
    row = (char.direction - 2) / 2
    row = rows - 1 if row > rows - 1
    row = 0 if row < 0
    col = char.pattern.to_i
    col = cols - 1 if col > cols - 1
    col = 0 if col < 0
    self.src_rect.set(col * @cw, row * @ch, @cw, @ch)
  end
end

#===============================================================================
# Move route "Change Graphic" (code 41): read the region out of the command
# before the engine runs it. Peeking beats re-implementing the command — the
# base keeps full control of name/hue/direction/pattern.
#===============================================================================
class Game_Character
  if method_defined?(:update_move_route) || private_method_defined?(:update_move_route)
    unless method_defined?(:__mkst__region_update_move_route) ||
           private_method_defined?(:__mkst__region_update_move_route)
      alias __mkst__region_update_move_route update_move_route
    end

    def update_move_route
      route = @move_route
      if route && @move_route_index && @move_route_index < route.list.size
        command = route.list[@move_route_index]
        if command && command.code == 41
          # Always written, so switching to an uncropped graphic clears the
          # region the page (or an earlier command) had set.
          @ms_src_rect = MakerStudio.src_rect_params(command.parameters, 4)
        end
      end
      __mkst__region_update_move_route
    end
  end
end

# A page change re-reads the graphic from the page, so a region a move route
# left behind must not outlive it.
class Game_Event
  unless method_defined?(:__mkst__region_refresh)
    alias __mkst__region_refresh refresh
  end

  def refresh
    @ms_src_rect = nil
    __mkst__region_refresh
  end
end

#===============================================================================
# Show Picture (231). The region rides past RMXP's ten parameters and is stashed
# on the Game_Picture; Sprite_Picture cuts the bitmap the same way characters
# are cut, so origin, zoom and rotation all measure from the region.
#===============================================================================
if defined?(Interpreter) && (Interpreter.method_defined?(:command_231) ||
                             Interpreter.private_method_defined?(:command_231))
class Interpreter
  unless method_defined?(:__mkst__region_command_231) ||
         private_method_defined?(:__mkst__region_command_231)
    alias __mkst__region_command_231 command_231
  end

  def command_231
    result = __mkst__region_command_231
    begin
      number = @parameters[0] + (@event_id > 0 ? 50 : 0)
      picture = $game_screen && $game_screen.pictures[number]
      if picture
        picture.instance_variable_set(:@ms_src_rect,
          MakerStudio.src_rect_params(@parameters, 10))
      end
    rescue StandardError
      # A base with its own picture bookkeeping just gets the whole image.
    end
    result
  end
end
end

if defined?(Sprite_Picture) && Sprite_Picture.method_defined?(:update)
class Sprite_Picture
  unless method_defined?(:__mkst__region_update)
    alias __mkst__region_update update
  end

  def update
    __mkst__region_update
    ms_region_refresh
  end

  def ms_region_refresh
    return if @picture.nil?
    rect = @picture.instance_variable_get(:@ms_src_rect)
    if rect.nil?
      @ms_region_key = nil
      @ms_region_source = nil
      @ms_region_bitmap = nil
      return
    end
    current = self.bitmap
    return if current.nil? || current.disposed?
    source = current.equal?(@ms_region_bitmap) ? @ms_region_source : current
    return if source.nil? || source.disposed?

    key = "#{source.object_id}|#{rect.join(',')}"
    if key != @ms_region_key
      @ms_region_key = key
      @ms_region_source = source
      stale = @ms_region_bitmap
      @ms_region_bitmap = MakerStudio.cropped_bitmap(source, rect)
      self.bitmap = @ms_region_bitmap
      stale.dispose if stale && !stale.disposed?
    elsif !current.equal?(@ms_region_bitmap)
      self.bitmap = @ms_region_bitmap
    else
      return
    end

    # The base centred on the whole image; the region is the image now.
    if @picture.origin == 0
      self.ox = 0
      self.oy = 0
    else
      self.ox = @ms_region_bitmap.width / 2
      self.oy = @ms_region_bitmap.height / 2
    end
  end
end
end
