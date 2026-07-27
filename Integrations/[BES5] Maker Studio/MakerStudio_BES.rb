###############################################################################
# Maker Studio ? Essentials BES v5 (v16.2) ? SINGLE-FILE BUILD
#
# Paste as ONE section in the RMXP Script Editor, just ABOVE "Main". Works on
# both RGSS (Game.exe, Ruby 1.8) and mkxp (Game_Vanilla.exe). Ruby-1.8-safe,
# bundles its own JSON parser. Split MakerStudio/ folder is maintenance source.
#
# Identity read back by the editor (Help -> Check Game Integration). This build
# installs as a pasted script, not a Plugins/ folder, so there is no meta.txt or
# BUILD file to read - these two comment lines ARE the version stamp. Keep the
# exact 'MakerStudio-Build:' / 'MakerStudio-Version:' prefixes; the release
# workflow rewrites the version line.
# MakerStudio-Build: BES5
# MakerStudio-Version: 1.2.1
###############################################################################


###############################################################################
# >>> 000_Settings.rb
###############################################################################
#===============================================================================
# MakerStudio - Settings
#===============================================================================
module MakerStudio
  # Enable/disable the plugin
  ENABLED = true

  # Gate verbose Console.echoln diagnostics (shadow bitmap sizes,
  # extra-autotile loads, etc). Keep off in normal play — on map transfer
  # through connected maps this spams the log.
  DEBUG_LOG = false

  # Layer settings
  NATIVE_LAYERS        = 3   # RPG Maker's native layer count
  MAX_TOTAL_LAYERS     = 16  # Maximum total layers (native + extended)
  DEFAULT_EXT_LAYERS   = 3   # Additional extended layers created by default

  # Tile size constants (must match TilemapRenderer)
  TILE_WIDTH  = 32
  TILE_HEIGHT = 32

  # Visual effect ranges
  # NOTE: Ruby 1.8 (RGSS) hash syntax — `:key => val`, not `key: val`.
  EFFECT_RANGES = {
    :opacity    => { :min => 0,    :max => 255, :default => 255 },
    :rotation   => { :min => 0,    :max => 360, :default => 0   },
    :saturation => { :min => 0,    :max => 200, :default => 100 },
    :hue        => { :min => 0,    :max => 360, :default => 0   },
    :lighting   => { :min => -255, :max => 255, :default => 0   }
  }.freeze

  # Plugin directory path (relative to game root)
  PLUGIN_DIR = "Plugins/MakerStudio"

  # Tauri v2 desktop editor.
  # The editor app is NOT bundled — install it from the download page below, or drop
  # the executable at EDITOR_EXE_PATH for portable use. The launcher checks the portable
  # path first, then the per-OS install location (see 002_Integration/001_Hooks.rb).
  DOWNLOAD_URL    = "https://github.com/Toskan4134/maker-studio/releases/latest"
  EDITOR_EXE_PATH = "Plugins/MakerStudio/003_Editor/maker-studio.exe"

  # Tileset rendering constants (must match TilemapRenderer)
  TILESET_TILES_PER_ROW = 8
  AUTOTILES_COUNT        = 8
  TILES_PER_AUTOTILE     = 48
  TILESET_START_ID       = AUTOTILES_COUNT * TILES_PER_AUTOTILE  # 384
end


###############################################################################
# >>> 001_Core/001_DataStore.rb
###############################################################################
#===============================================================================
# MakerStudio - Data Store (Essentials BES v5 / v16.2)
#
# Maker Studio embeds extended-layer data as a JSON string inside the .rxdata.
# BES targets the original RGSS runtime (Ruby 1.8.1), which has no `json`
# library and lacks several modern syntax features. So this file:
#   * bundles a small pure-Ruby, 1.8-safe JSON parser (MakerStudio::JSON), and
#   * avoids 1.9+ syntax (symbol-key hashes, &., String#each_char, byte vs char
#     indexing) so it loads on both RGSS (Ruby 1.8) and mkxp (Ruby 3).
#===============================================================================
module MakerStudio
  #---------------------------------------------------------------------------
  # Minimal JSON parser (objects, arrays, strings, numbers, true/false/null).
  # Hand-rolled and 1.8-safe: uses str[pos, 1] (returns a String in 1.8 AND
  # 1.9+, unlike str[pos] which returns a Fixnum byte in 1.8).
  #---------------------------------------------------------------------------
  module JSON
    def self.parse(str)
      Parser.new(str).parse
    end

    class Parser
      def initialize(str)
        @str = str.to_s
        @len = @str.length
        @pos = 0
      end

      def parse
        skip_ws
        v = parse_value
        skip_ws
        v
      end

      private

      def cur
        @pos < @len ? @str[@pos, 1] : nil
      end

      def skip_ws
        while @pos < @len
          c = @str[@pos, 1]
          break if c != " " && c != "\t" && c != "\n" && c != "\r"
          @pos += 1
        end
      end

      def parse_value
        c = cur
        case c
        when "{" then parse_object
        when "[" then parse_array
        when '"' then parse_string
        when "t" then parse_literal("true", true)
        when "f" then parse_literal("false", false)
        when "n" then parse_literal("null", nil)
        else          parse_number
        end
      end

      def parse_literal(lit, val)
        if @str[@pos, lit.length] == lit
          @pos += lit.length
          return val
        end
        raise "MakerStudio::JSON: expected '#{lit}' at #{@pos}"
      end

      def parse_object
        obj = {}
        @pos += 1 # consume {
        skip_ws
        if cur == "}"
          @pos += 1
          return obj
        end
        loop do
          skip_ws
          key = parse_string
          skip_ws
          raise "MakerStudio::JSON: expected ':' at #{@pos}" if cur != ":"
          @pos += 1
          skip_ws
          obj[key] = parse_value
          skip_ws
          c = cur
          if c == ","
            @pos += 1
            next
          elsif c == "}"
            @pos += 1
            break
          else
            raise "MakerStudio::JSON: expected ',' or '}' at #{@pos}"
          end
        end
        obj
      end

      def parse_array
        arr = []
        @pos += 1 # consume [
        skip_ws
        if cur == "]"
          @pos += 1
          return arr
        end
        loop do
          skip_ws
          arr.push(parse_value)
          skip_ws
          c = cur
          if c == ","
            @pos += 1
            next
          elsif c == "]"
            @pos += 1
            break
          else
            raise "MakerStudio::JSON: expected ',' or ']' at #{@pos}"
          end
        end
        arr
      end

      def parse_string
        raise "MakerStudio::JSON: expected string at #{@pos}" if cur != '"'
        @pos += 1
        result = ""
        while @pos < @len
          c = @str[@pos, 1]
          @pos += 1
          if c == '"'
            return result
          elsif c == "\\"
            e = @str[@pos, 1]
            @pos += 1
            case e
            when '"'  then result << '"'
            when "\\" then result << "\\"
            when "/"  then result << "/"
            when "n"  then result << "\n"
            when "t"  then result << "\t"
            when "r"  then result << "\r"
            when "b"  then result << "\b"
            when "f"  then result << "\f"
            when "u"
              hex = @str[@pos, 4]
              @pos += 4
              begin
                result << [hex.to_i(16)].pack("U")
              rescue
                result << "?"
              end
            else
              result << e.to_s
            end
          else
            result << c
          end
        end
        raise "MakerStudio::JSON: unterminated string"
      end

      def parse_number
        start = @pos
        while @pos < @len
          c = @str[@pos, 1]
          break if !(c =~ /[-+0-9.eE]/)
          @pos += 1
        end
        num = @str[start, @pos - start]
        raise "MakerStudio::JSON: invalid number at #{start}" if num == ""
        (num =~ /[.eE]/) ? num.to_f : num.to_i
      end
    end
  end

  #---------------------------------------------------------------------------
  # Extended layer data store
  #---------------------------------------------------------------------------
  module DataStore
    module_function

    # Resolve the RPG::Map from a Game_Map (has @map) or an RPG::Map directly.
    # Avoids instance_variable_defined? (absent on Ruby 1.8.1).
    def resolve_rpg_map(obj)
      return nil unless obj
      rpg = obj.instance_variable_get(:@map)
      return rpg if rpg
      return obj if !obj.instance_variable_get(:@extended_layers).nil? ||
                    !obj.instance_variable_get(:@tileset_id).nil?
      nil
    end

    # Load + parse the embedded @extended_layers JSON.
    def load_extended_data(map_id, game_map = nil)
      rpg_map = resolve_rpg_map(game_map)
      return nil unless rpg_map
      embedded = rpg_map.instance_variable_get(:@extended_layers)
      return nil unless embedded && !embedded.empty?
      begin
        return MakerStudio::JSON.parse(embedded)
      rescue => e
        echoln("MakerStudio ERROR: failed to parse extended data for map #{map_id}: #{e.message}")
        return nil
      end
    end

    def create_default_extended_data(map_id, map_width, map_height)
      layers = []
      DEFAULT_EXT_LAYERS.times do |i|
        layer_index = NATIVE_LAYERS + i
        layers.push({
          "id"      => layer_index,
          "name"    => "Extended #{layer_index + 1}",
          "visible" => true,
          "opacity" => EFFECT_RANGES[:opacity][:default],
          "tiles"   => {}
        })
      end
      {
        "map_id"     => map_id,
        "map_width"  => map_width,
        "map_height" => map_height,
        "layers"     => layers
      }
    end

    def get_extended_data(map_id, map_width = nil, map_height = nil, game_map = nil)
      data = load_extended_data(map_id, game_map)
      if data.nil?
        map_width  ||= (game_map && game_map.width)  || ($game_map && $game_map.width)  || 20
        map_height ||= (game_map && game_map.height) || ($game_map && $game_map.height) || 15
        data = create_default_extended_data(map_id, map_width, map_height)
      end
      data
    end

    # Expanded autotile lookup (from @expanded_autotiles JSON on tileset objects).
    #---------------------------------------------------------------------------
    # Expanded autotile config, parsed ONCE into { name => entry }.
    #
    # The raw JSON lives on the tileset objects and only changes when the tilesets
    # are reloaded, but passable? / bush? / deepBush? / terrain_tag ask for it on
    # every step of every character. Re-parsing every tileset's config on each of
    # those calls cost ~1.1 ms per lookup (vs 0.002 ms on a plain cell), so walking
    # on a Maker Studio autotile — grass, most visibly — dropped the frame rate.
    #---------------------------------------------------------------------------
    def expanded_autotile_index
      return @expanded_autotile_index if @expanded_autotile_index
      index = {}
      ($data_tilesets || []).each do |ts|
        next unless ts
        raw = ts.instance_variable_get(:@expanded_autotiles)
        next unless raw.is_a?(String) && !raw.empty?
        begin
          parsed = MakerStudio::JSON.parse(raw)
          next unless parsed.is_a?(Array)
          parsed.each do |e|
            next unless e.is_a?(Hash) && e["name"]
            # First tileset wins, matching the old first-match-scan behaviour.
            index[e["name"]] = e unless index[e["name"]]
          end
        rescue
        end
      end
      @expanded_autotile_index = index
    end

    # Call whenever the tilesets are reloaded (editor hot-reload).
    def clear_expanded_autotile_index
      @expanded_autotile_index = nil
    end

    def get_expanded_autotile(autotile_name)
      return nil unless autotile_name && $data_tilesets
      expanded_autotile_index[autotile_name]
    end
  end
end


###############################################################################
# >>> 001_Core/003_TileEffects.rb
###############################################################################
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
      # Match the editor's CSS filter chain — Bitmap#hue_change is a true HSV
      # rotation and reads far more saturated than CSS hue-rotate's linear
      # approximation. Lighting stays Tone-based in this variant, so hue/sat only.
      MakerStudio.apply_css_color_filters(bmp, hue, saturation, 0)
      return bmp
    rescue => e
      echoln("MakerStudio ERROR: bitmap effect error: #{e.message}")
      bmp.dispose if bmp
      return nil
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


###############################################################################
# >>> 002_Integration/001_Hooks.rb
###############################################################################
#===============================================================================
# MakerStudio - Hooks & Menu Integration (Essentials BES v5 / v16.2)
#
# BES differences from the v21.1 build handled here:
#   * No MenuHandlers-driven debug menu — the F9 menu (pbDebugMenu) is a hardcoded
#     CommandList with an inline case dispatch, so we can't inject a command into
#     it. Instead pbDebugMenu is aliased to offer a top-level chooser whose
#     DEFAULT is the normal debug menu (so just pressing C behaves as before),
#     with "Maker Studio..." as the second entry.
#   * No :on_new_game / :on_game_map_setup triggers — Game_Map#setup is aliased to
#     load extended layers (covers new game, transfer and connected-map loads).
#   * No Game.load_map — Continue/transfer reload .rxdata via Game_Map#setup, and
#     the overlay rebuilds in Events.onSpritesetCreate, so no save hook is needed.
#===============================================================================

#---------------------------------------------------------------------------
# Locate the installed (or portable) Maker Studio editor (identical to v21.1).
#---------------------------------------------------------------------------
module MakerStudio
  def self.host_os
    case RUBY_PLATFORM
    when /mswin|mingw|cygwin/i then :windows
    when /darwin/i             then :macos
    else                            :linux
    end
  end

  def self.find_editor_executable
    portable = File.expand_path(EDITOR_EXE_PATH)
    return portable if File.exist?(portable)
    case host_os
    when :windows
      [ENV["LOCALAPPDATA"], ENV["PROGRAMFILES"], ENV["PROGRAMFILES(X86)"], ENV["APPDATA"]].each do |base|
        next unless base
        exe = File.join(base, "Maker Studio", "maker-studio.exe")
        return exe if File.exist?(exe)
      end
    when :macos
      app = "/Applications/Maker Studio.app"
      return app if File.exist?(app)
    when :linux
      ["/usr/bin/maker-studio", "/usr/local/bin/maker-studio",
       File.expand_path("~/.local/bin/maker-studio")].each do |p|
        return p if File.exist?(p)
      end
    end
    nil
  end
end

#---------------------------------------------------------------------------
# Launch Maker Studio with the current project path (identical to v21.1).
#---------------------------------------------------------------------------
def pbOpenMakerStudio
  root_path = File.expand_path(Dir.pwd)
  editor = MakerStudio.find_editor_executable
  unless editor
    pbMessage(_INTL("Maker Studio is not installed.\nDownload it from:\n{1}", MakerStudio::DOWNLOAD_URL))
    return
  end
  case MakerStudio.host_os
  when :windows
    system("start \"\" \"#{editor.gsub("/", "\\")}\" \"#{root_path.gsub("/", "\\")}\"")
  when :macos
    if editor =~ /\.app\z/   # 1.8-safe (no String#end_with?)
      system("open", "-a", editor, "--args", root_path)
    else
      system(editor, root_path)
    end
  else
    system(editor, root_path)
  end
end

#---------------------------------------------------------------------------
# Refresh in-memory map data so editor changes show without restarting.
#---------------------------------------------------------------------------
def pbRefreshLiveMapData(map_id)
  return unless $game_map && $game_map.map_id == map_id
  fresh_tilesets = (load_data("Data/Tilesets.rxdata") rescue nil)
  $data_tilesets = fresh_tilesets if fresh_tilesets
  fresh_map = (load_data(sprintf("Data/Map%03d.rxdata", map_id)) rescue nil)
  if fresh_map
    ts = $data_tilesets[fresh_map.tileset_id]
    $game_map.instance_variable_set(:@map, fresh_map)
    if ts
      $game_map.instance_variable_set(:@tileset_name, ts.tileset_name)
      $game_map.instance_variable_set(:@autotile_names, ts.autotile_names)
      $game_map.instance_variable_set(:@passages, ts.passages)
      $game_map.instance_variable_set(:@priorities, ts.priorities)
      $game_map.instance_variable_set(:@terrain_tags, ts.terrain_tags)
    end
  end
  MakerStudio.load_extended_layers_for_map(map_id, $game_map)
  # Re-apply per-map panorama / battleback + native-fog suppression after reload.
  if MakerStudio.respond_to?(:apply_map_background_overrides)
    MakerStudio.apply_map_background_overrides($game_map, map_id)
  end
  ov = MakerStudio.current_overlay
  ov.rebuild if ov && !ov.disposed?
  # Re-point the native CustomTilemap at the (freshly blanked) map data.
  sp = MakerStudio.instance_variable_get(:@current_spriteset)
  if sp
    tm = (sp.instance_variable_get(:@tilemap) rescue nil)
    begin
      if tm
        tm.tileset = pbGetTileset($game_map.tileset_name)
        tm.priorities = $game_map.priorities
        tm.map_data = $game_map.data
      end
    rescue
    end
  end
end

#---------------------------------------------------------------------------
# Hot-reload current map data (debug helper).
#---------------------------------------------------------------------------
def pbReloadCurrentMapData
  return unless $game_map
  map_id = $game_map.map_id
  MakerStudio.clear_all_caches
  pbRefreshLiveMapData(map_id)
  pbMessage(_INTL("Map data reloaded"))
end

#---------------------------------------------------------------------------
# Small Maker Studio debug submenu.
#---------------------------------------------------------------------------
module MakerStudio
  def self.pbMakerStudioMenu
    loop do
      cmds = [_INTL("Open Maker Studio"), _INTL("Reload Map Data"), _INTL("Cancel")]
      c = pbShowCommands(nil, cmds, -1)
      case c
      when 0 then pbOpenMakerStudio
      when 1 then pbReloadCurrentMapData
      else        break
      end
    end
  end
end

#---------------------------------------------------------------------------
# Debug menu: alias pbDebugMenu to offer Maker Studio (default = normal menu).
#---------------------------------------------------------------------------
if !defined?($__mkst_pbdebug_aliased) || !$__mkst_pbdebug_aliased
  $__mkst_pbdebug_aliased = true
  alias __mkst__pbDebugMenu pbDebugMenu
  def pbDebugMenu
    if MakerStudio::ENABLED
      c = pbShowCommands(nil, [_INTL("Debug Menu"), _INTL("Maker Studio...")], -1, 0)
      if c == 1
        MakerStudio.pbMakerStudioMenu
        return
      end
    end
    __mkst__pbDebugMenu
  end
end

#---------------------------------------------------------------------------
# Lifecycle: load extended layers whenever a Game_Map is set up (new game,
# transfer, connected-map load). Replaces v21.1's :on_new_game/:on_game_map_setup.
#---------------------------------------------------------------------------
class Game_Map
  unless method_defined?(:__mkst__setup)
    alias_method :__mkst__setup, :setup
    def setup(map_id)
      __mkst__setup(map_id)
      # Parse the map's extended-layer JSON only if not already cached. setup runs
      # on every transfer AND for each connected map each time it (re)enters the
      # factory; re-parsing the (large) JSON through the Ruby-1.8 char parser every
      # time froze map/connection transitions. Cache is keyed by map_id and the
      # "Reload Map Data" debug command flushes it, so live edits still refresh.
      if MakerStudio::ENABLED && !MakerStudio.get_extended_data_for(map_id)
        MakerStudio.load_extended_layers_for_map(map_id, self)
      end
    end
  end
end

#---------------------------------------------------------------------------
# NOTE: do NOT clear the extended-data cache on Events.onMapChange. Each map's
# data is (re)loaded by the Game_Map#setup alias and keyed by map_id, and
# connected maps are set up before onMapChange fires — clearing here wiped the
# data collision needs on connected maps. Stale entries are harmless (overwritten
# on the next setup of that map); the explicit Reload command flushes everything.
#---------------------------------------------------------------------------


###############################################################################
# >>> 002_Integration/002_OverlayRenderer.rb
###############################################################################
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


###############################################################################
# >>> 002_Integration/003_GameMapOverride.rb
###############################################################################
#===============================================================================
# MakerStudio - Game Map Override (Essentials BES v5 / v16.2)
#
# Patches Game_Map collision + terrain so they account for Maker Studio's
# extended layers and native-layer "extra" tiles (extra autotiles, cross-tileset
# tiles). Each Maker Studio tile is checked BEFORE deferring to BES's own native
# logic (which still handles plain native tiles, events, surf/ice/ledge, etc.).
#
# BES has NO GameData::TerrainTag — terrain is the integer PBTerrain system, and
# Game_Map#terrain_tag returns an Integer. So this is a full reimplementation of
# the v21.1 override against PBTerrain predicates:
#
#   GameData::TerrainTag           ->  PBTerrain integer + predicate
#   terrain.bridge                 ->  PBTerrain.isBridge?(tag)
#   terrain.can_surf (passable)    ->  PBTerrain.isPassableWater?(tag)
#   terrain.waterfall              ->  PBTerrain.isWaterfall?(tag)
#   terrain.must_walk(_or_run)     ->  PBTerrain.onlyWalk?(tag)   (TallGrass/Ice)
#   terrain.deep_bush              ->  tag == PBTerrain::TallGrass
#   terrain.ignore_passability     ->  (no equivalent on BES — dropped)
#   terrain.id != :None            ->  tag != 0 && tag != PBTerrain::Neutral
#
# Cross-tileset native cells are blanked in the Table by the renderer; their
# original tile id is recovered via MakerStudio.each_native_extra_tile_at, so
# collision still resolves from the referenced tileset's tables.
#
# NOTE (documented limitation): pure per-tile passage/priority/terrain OVERRIDES
# painted on the NATIVE layers (without an autotile_name or tileset_id) are not
# applied here — BES's untouched native logic is used for those cells. Overrides
# on extended layers, extra autotiles and cross-tileset tiles work fully.
#===============================================================================
class Game_Map
  NEUTRAL_TT = (defined?(PBTerrain) ? PBTerrain::Neutral : 13)

  #---------------------------------------------------------------------------
  # Resolve [passage, priority, terrain] for an extra autotile from tile_data,
  # falling back to expanded_autotiles config, then any tileset that lists the
  # autotile by name. Returns nil if nothing is known.
  #---------------------------------------------------------------------------
  def ms_extra_autotile_data(td)
    if td["passage"]
      return [td["passage"].to_i, (td["priority"] || 0).to_i, (td["terrain_tag"] || 0).to_i]
    end
    name = td["autotile_name"]
    return nil unless name
    entry = MakerStudio::DataStore.get_expanded_autotile(name)
    return [entry["passage"].to_i, entry["priority"].to_i, entry["terrain_tag"].to_i] if entry
    # Game_Map (self) carries autotile_names on BES; the RPG::Map (@map) does not.
    if autotile_names
      idx = autotile_names.index(name)
      if idx
        base = (idx + 1) * 48
        return [@passages[base] || 0, @priorities[base] || 0, @terrain_tags[base] || 0]
      end
    end
    if $data_tilesets
      $data_tilesets.each do |ts|
        next unless ts && ts.autotile_names
        idx = ts.autotile_names.index(name)
        next unless idx
        base = (idx + 1) * 48
        return [ts.passages[base] || 0, ts.priorities[base] || 0, ts.terrain_tags[base] || 0]
      end
    end
    nil
  end
  private :ms_extra_autotile_data

  # Integer terrain tag for a Maker Studio tile.
  def ms_tile_terrain(tid, td)
    # An editor-set per-tile terrain_tag override wins for any tile type.
    tt = td["terrain_tag"]
    return tt.to_i if tt && tt.to_i != 0
    if td["autotile_name"]
      resolved = ms_extra_autotile_data(td)
      return resolved ? resolved[2] : 0
    elsif td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.terrain_tags[tid] || 0) : 0
    else
      return @terrain_tags[tid] || 0
    end
  end
  private :ms_tile_terrain

  def ms_tile_passage(tid, td)
    return td["passage"].to_i if td["passage"]
    if td["autotile_name"]
      resolved = ms_extra_autotile_data(td)
      return resolved ? resolved[0] : 0
    elsif td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.passages[tid] || 0) : 0
    end
    @passages[tid] || 0
  end
  private :ms_tile_passage

  def ms_tile_priority(tid, td)
    return td["priority"].to_i if td["priority"]
    if td["autotile_name"]
      resolved = ms_extra_autotile_data(td)
      return resolved ? resolved[1] : 0
    elsif td["tileset_id"]
      ts = $data_tilesets[td["tileset_id"].to_i]
      return ts ? (ts.priorities[tid] || 0) : 0
    end
    @priorities[tid] || 0
  end
  private :ms_tile_priority

  # Yield [tid, td, native_extra] for every Maker Studio tile at (x,y):
  # extended FIRST (extended layers sit above every native layer), then
  # native-extra (top layer down). Uses THIS map's id (not $game_map) so
  # collision works on connected maps too. The native_extra flag lets the
  # passability checks refuse to let a ground native-layer tile DECIDE the
  # cell (see playerPassable?).
  def ms_each_tile_at(x, y)
    mid = map_id
    MakerStudio.each_extended_tile_at(mid, x, y) { |tid, td| yield tid, td, false }
    MakerStudio.each_native_extra_tile_at(mid, x, y) { |tid, td| yield tid, td, true }
    # Plain native tiles blanked by the overlay renderer because an extra
    # autotile sits below them (blank_covered_plain_tiles) — the Table reads 0
    # there, so BES's native scan can't see them anymore. Keep honouring their
    # passage here (block-only, like other native-layer extras).
    if MakerStudio.respond_to?(:each_covered_plain_tile_at)
      MakerStudio.each_covered_plain_tile_at(mid, x, y) { |tid, td| yield tid, td, true }
    end
  end
  private :ms_each_tile_at

  #---------------------------------------------------------------------------
  # playerPassable? — terrain-aware (bridge / surf / cycling), mirrors BES.
  #---------------------------------------------------------------------------
  alias __mkst__playerPassable playerPassable? unless method_defined?(:__mkst__playerPassable)
  def playerPassable?(x, y, d, self_event = nil)
    return __mkst__playerPassable(x, y, d, self_event) unless MakerStudio::ENABLED
    bit = (1 << (d / 2 - 1)) & 0x0f
    ms_each_tile_at(x, y) do |tid, td, native_extra|
      terrain = ms_tile_terrain(tid, td)
      if terrain != 0 && terrain != NEUTRAL_TT
        if PBTerrain.isBridge?(terrain)
          if $PokemonGlobal && $PokemonGlobal.bridge == 0
            next
          else
            passage = ms_tile_passage(tid, td)
            return (passage & bit == 0 && passage & 0x0f != 0x0f)
          end
        end
        if $PokemonGlobal && $PokemonGlobal.surfing && PBTerrain.isPassableWater?(terrain)
          return true
        end
        if $PokemonGlobal && $PokemonGlobal.bicycle && PBTerrain.onlyWalk?(terrain)
          return false
        end
      end
      passage = ms_tile_passage(tid, td)
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      # A ground extended tile decides the cell (extended sits above every
      # native layer). A ground NATIVE-layer extra tile must NOT decide:
      # plain native tiles on layers above it are only checked by the BES
      # fallback (bitmap-composited CustomTilemap — no per-layer interleave
      # here), so deciding would erase their impassability.
      return true if ms_tile_priority(tid, td) == 0 && !native_extra
      # else: fall through to the next Maker Studio tile / BES native logic
    end
    __mkst__playerPassable(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # passable? — for the player defer to playerPassable? (BES does too); for
  # other events do a basic passage/priority check on Maker Studio tiles, then
  # fall back to BES's native event logic.
  #---------------------------------------------------------------------------
  alias __mkst__passable passable? unless method_defined?(:__mkst__passable)
  def passable?(x, y, d, self_event = nil)
    return __mkst__passable(x, y, d, self_event) unless MakerStudio::ENABLED
    return playerPassable?(x, y, d, self_event) if self_event == $game_player
    bit = (1 << (d / 2 - 1)) & 0x0f
    ms_each_tile_at(x, y) do |tid, td, native_extra|
      passage = ms_tile_passage(tid, td)
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      # Ground native-layer extras must not decide — see playerPassable?.
      return true if ms_tile_priority(tid, td) == 0 && !native_extra
    end
    __mkst__passable(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # passableStrict?
  #---------------------------------------------------------------------------
  alias __mkst__passableStrict passableStrict? unless method_defined?(:__mkst__passableStrict)
  def passableStrict?(x, y, d, self_event = nil)
    return __mkst__passableStrict(x, y, d, self_event) unless MakerStudio::ENABLED
    ms_each_tile_at(x, y) do |tid, td, native_extra|
      passage = ms_tile_passage(tid, td)
      return false if passage & 0x0f != 0
      # Ground native-layer extras must not decide — see playerPassable?.
      return true if ms_tile_priority(tid, td) == 0 && !native_extra
    end
    __mkst__passableStrict(x, y, d, self_event)
  end

  #---------------------------------------------------------------------------
  # terrain_tag — returns an Integer (BES convention). Extended/native-extra
  # tiles take priority; fall back to BES's native terrain_tag.
  #---------------------------------------------------------------------------
  alias __mkst__terrain_tag terrain_tag unless method_defined?(:__mkst__terrain_tag)
  def terrain_tag(x, y, countBridge = false)
    return __mkst__terrain_tag(x, y, countBridge) unless MakerStudio::ENABLED
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      next if terrain == 0 || terrain == NEUTRAL_TT
      next if !countBridge && PBTerrain.isBridge?(terrain) && $PokemonGlobal && $PokemonGlobal.bridge == 0
      return terrain
    end
    __mkst__terrain_tag(x, y, countBridge)
  end

  #---------------------------------------------------------------------------
  # bush? — passage bit 0x40 (and not a bridge tile while on a bridge).
  #---------------------------------------------------------------------------
  alias __mkst__bush bush? unless method_defined?(:__mkst__bush)
  def bush?(x, y)
    result = __mkst__bush(x, y)
    return result unless MakerStudio::ENABLED
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      return false if PBTerrain.isBridge?(terrain) && $PokemonGlobal && $PokemonGlobal.bridge > 0
      return true if ms_tile_passage(tid, td) & 0x40 == 0x40
    end
    false
  end

  #---------------------------------------------------------------------------
  # deepBush? — passage bit 0x40 AND TallGrass terrain.
  #---------------------------------------------------------------------------
  alias __mkst__deepBush deepBush? unless method_defined?(:__mkst__deepBush)
  def deepBush?(x, y)
    result = __mkst__deepBush(x, y)
    return result unless MakerStudio::ENABLED
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      terrain = ms_tile_terrain(tid, td)
      return false if PBTerrain.isBridge?(terrain) && $PokemonGlobal && $PokemonGlobal.bridge > 0
      return true if ms_tile_passage(tid, td) & 0x40 == 0x40 && terrain == PBTerrain::TallGrass
    end
    false
  end

  #---------------------------------------------------------------------------
  # counter? — passage bit 0x80.
  #---------------------------------------------------------------------------
  alias __mkst__counter counter? unless method_defined?(:__mkst__counter)
  def counter?(x, y)
    result = __mkst__counter(x, y)
    return result unless MakerStudio::ENABLED
    return true if result
    ms_each_tile_at(x, y) do |tid, td|
      return true if ms_tile_passage(tid, td) & 0x80 == 0x80
    end
    false
  end
end


###############################################################################
# >>> 002_Integration/004_FogOverride.rb
###############################################################################
#===============================================================================
# MakerStudio - Graphic Layer Groups (Fog / Panorama / Custom) Override
# Renders the Maker Studio graphic layer groups as Plane sprites:
#   - fogLayers          at viewport z = 3000  (above all tiles/events)
#   - panoramaLayers     at viewport z = -1000 (beneath all tiles)
#   - customLayerGroups  at viewport z = group "priority" (mod-defined)
# Every layer shares the same config: graphic, hue, opacity, blend_type, zoom,
# sx/sy scroll, follow_player, parallax. Groups are clipped to each map's
# boundaries using a per-map per-group Viewport so connected maps don't overlap.
#
# Scroll convention: positive sx = layer moves right, positive sy = down.
# Camera follow: follow_player = screen-locked. Otherwise the "parallax"
# factor scales camera tracking: 1 = world-anchored (moves 1:1 with the map,
# classic fog), 0.5 = RMXP native panorama half-speed, 0 = screen-locked.
#
# Sprites are created for ALL maps in the map factory and remain visible for
# all connected maps (not just the current game map). Each map's Viewports clip
# its layers to that map's bounds. Scroll offsets persist across
# map-connection transitions.
#
# Written to stay Ruby 1.8-compatible so the SAME file works in every
# framework build (BES5 / PE17 / LBDS / PE21).
#===============================================================================
module MakerStudio
  FOG_DIR = File.join("Graphics", "Fogs")
  PANORAMA_DIR = File.join("Graphics", "Panoramas")
  FOG_GROUP_Z = 3000
  PANORAMA_GROUP_Z = -1000

  # Module-level sprite cache — { map_id => [plane_sprite, ...] } (all groups)
  @fog_sprites_cache = {}
  # Per-map per-group viewports for clipping — { map_id => { group_key => Viewport } }
  @fog_viewports_cache = {}
  # Per-layer scroll offsets — { "group_key:layer_id" => { :ox => 0, :oy => 0 } }
  @fog_scroll_offsets = {}

  module_function

  # RGSS1 (Essentials v17.x) has NO Viewport#disposed? — Sprite/Plane/Bitmap all
  # define it, Viewport does not, and the v17 base hits the same gap in
  # pbSetResizeFactor2 (it guards its Viewport pass with `rescue RGSSError`).
  # Newer RGSS builds and mkxp do define it, so ask before calling.
  def viewport_disposed?(vp)
    vp.nil? || (vp.respond_to?(:disposed?) && vp.disposed?)
  end

  # The engine's map factory ($map_factory in Essentials v19+/LBDS,
  # $MapFactory in BES/v16/v17). Nil when no factory is alive.
  def ms_map_factory
    return $map_factory if defined?($map_factory) && $map_factory
    return $MapFactory if defined?($MapFactory) && $MapFactory
    nil
  end

  #---------------------------------------------------------------------------
  # Resolve a map's renderable graphic layer groups from its extended data.
  # Returns an array of [group_key, viewport_z, graphics_dir, layers].
  #---------------------------------------------------------------------------
  def plane_groups_for(ext_data)
    groups = []
    fogs = ext_data["fogLayers"]
    if fogs && !fogs.empty?
      groups.push(["fog", FOG_GROUP_Z, FOG_DIR, fogs])
    end
    panos = ext_data["panoramaLayers"]
    if panos && !panos.empty?
      groups.push(["panorama", PANORAMA_GROUP_Z, PANORAMA_DIR, panos])
    end
    customs = ext_data["customLayerGroups"]
    if customs
      customs.each do |g|
        next unless g
        layers = g["layers"]
        next unless layers && !layers.empty?
        key = g["key"]
        next if key.nil? || key.empty? || key == "fog" || key == "panorama"
        folder = g["folder"]
        # Single path component only — never honour traversal from map data.
        next if folder.nil? || folder.empty?
        next if folder.include?("/") || folder.include?("\\") || folder.include?("..") || folder.include?(":")
        groups.push([key, (g["priority"] || 0).to_i, File.join("Graphics", folder), layers])
      end
    end
    groups
  end

  #---------------------------------------------------------------------------
  # Create the graphic-group sprites for a map from extended data.
  # Skips creation if sprites already exist (preserves scroll offsets across
  # map-connection transitions). Layers are visible for all factory maps.
  #---------------------------------------------------------------------------
  def create_fog_sprites_for_map(map_id, map)
    # Skip if sprites already exist — preserves scroll offsets and avoids
    # expensive bitmap reload on map-connection transitions.
    existing = @fog_sprites_cache[map_id]
    return if existing && !existing.empty?

    ext_data = @extended_data_cache[map_id]
    return unless ext_data
    groups = plane_groups_for(ext_data)
    return if groups.empty?

    sprites = []
    viewports = {}
    groups.each do |group|
      group_key = group[0]
      group_z   = group[1]
      dir       = group[2]
      layers    = group[3]

      # Clipping viewport, one per group so each group sits at its own z.
      # Sized to the SCREEN, not to the map: a Plane fills its whole viewport
      # rect, so a map-sized viewport made every fog/panorama layer draw a
      # map-sized surface (a 500x500 map = 16000x16000 px) every frame, most of
      # it off-camera. update_fog_sprites re-clips it to the visible part of the
      # map each frame and shifts the plane to compensate.
      vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
      vp.z = group_z
      vp.visible = true
      viewports[group_key] = vp

      layers.each do |layer|
        next unless layer["visible"] != false
        config = layer["config"] || {}
        graphic_name = config["graphicName"]
        next if graphic_name.nil? || graphic_name.empty?

        # Load layer bitmap
        path = find_group_graphic(dir, graphic_name)
        next unless path

        begin
          bmp = Bitmap.new(path)
        rescue
          next
        end

        # Apply hue rotation if needed
        hue = (config["hue"] || 0).to_i
        bmp.hue_change(hue) if hue != 0

        # Create Plane sprite clipped to the group viewport
        sprite = Plane.new(vp)
        sprite.bitmap = bmp
        sprite.z = 0
        sprite.opacity = (layer["opacity"] || 255).to_i
        sprite.blend_type = (config["blendType"] || 0).to_i

        zoom = (config["zoom"] || 1.0).to_f
        zoom = 0.1 if zoom < 0.1
        sprite.zoom_x = zoom
        sprite.zoom_y = zoom

        # Store metadata on the sprite for update loop
        layer_id = layer["id"]
        sprite.instance_variable_set(:@fog_id, layer_id)
        sprite.instance_variable_set(:@ms_group, group_key)
        sprite.instance_variable_set(:@fog_sx, (config["sx"] || 0).to_f)
        sprite.instance_variable_set(:@fog_sy, (config["sy"] || 0).to_f)
        sprite.instance_variable_set(:@fog_follow, config["followPlayer"] == true)
        par = config["parallax"]
        sprite.instance_variable_set(:@ms_parallax, par.nil? ? 1.0 : par.to_f)
        sprite.instance_variable_set(:@map_id, map_id)

        # Initialize scroll offset (preserve if already exists for transitions)
        scroll_key = "#{group_key}:#{layer_id}"
        @fog_scroll_offsets[scroll_key] ||= { :ox => 0, :oy => 0 }

        sprite.visible = true

        sprites.push(sprite)
      end
    end

    @fog_sprites_cache[map_id] = sprites
    @fog_viewports_cache[map_id] = viewports
  end

  #---------------------------------------------------------------------------
  # Update group sprites (scroll animation + viewport tracking)
  # Shows layers for ALL maps in the factory (not just current).
  # Each map's viewports clip its layers to that map's bounds.
  #---------------------------------------------------------------------------
  def update_fog_sprites
    return if @fog_sprites_cache.empty?
    factory = ms_map_factory
    return unless factory

    # Build set of factory map IDs for visibility toggling
    factory_maps = {}
    factory.maps.each do |map|
      next unless map
      factory_maps[map.map_id] = map
    end

    @fog_sprites_cache.each do |map_id, sprites|
      next if sprites.nil? || sprites.empty?
      map = factory_maps[map_id]
      in_factory = !!map

      # Where this map sits on screen, and how much of it the camera actually
      # sees. The viewport is clipped to that intersection, so each layer paints
      # at most one screenful — never the whole map.
      clip_dx = 0
      clip_dy = 0
      on_screen = false
      if in_factory
        vx = -(map.display_x / 4.0).round
        vy = -(map.display_y / 4.0).round
        cx = [vx, 0].max
        cy = [vy, 0].max
        cw = [vx + (map.width * 32), Graphics.width].min - cx
        ch = [vy + (map.height * 32), Graphics.height].min - cy
        on_screen = cw > 0 && ch > 0
        # Pixels of the map clipped off the left/top edge: the plane's pattern
        # has to shift by the same amount to stay anchored to the map.
        clip_dx = cx - vx
        clip_dy = cy - vy
      end

      vps = @fog_viewports_cache[map_id]
      if vps
        vps.each do |group_key, vp|
          next if viewport_disposed?(vp)
          if on_screen
            vp.rect.set(cx, cy, cw, ch)
            # Apply screen shake so layers wobble with the map. viewport1
            # receives `+= $game_screen.shake` in Spriteset_Map; these
            # viewports are separate so we must re-apply it here ourselves.
            vp.ox = $game_screen ? $game_screen.shake : 0
            vp.visible = true
          else
            vp.visible = false
          end
        end
      end

      sprites.each do |sprite|
        next if sprite.nil? || sprite.disposed?

        # Hide layers for maps that left the factory or are fully off-camera.
        sprite.visible = on_screen
        next unless in_factory

        layer_id = sprite.instance_variable_get(:@fog_id)
        next unless layer_id
        group_key = sprite.instance_variable_get(:@ms_group) || "fog"
        sx = sprite.instance_variable_get(:@fog_sx) || 0
        sy = sprite.instance_variable_get(:@fog_sy) || 0
        follow = sprite.instance_variable_get(:@fog_follow)
        par = sprite.instance_variable_get(:@ms_parallax)

        # Accumulate scroll.
        # Plane.ox positive shifts pattern LEFT, so negate sx/sy so that
        # positive values move the layer RIGHT / DOWN (matching editor).
        # Accumulated for every factory map, on-camera or not, so a layer's scroll
        # phase doesn't depend on which maps happen to be visible.
        scroll = @fog_scroll_offsets["#{group_key}:#{layer_id}"]
        if scroll
          scroll[:ox] -= sx * 0.1667 if sx != 0
          scroll[:oy] -= sy * 0.1667 if sy != 0
        end
        next unless on_screen

        # Camera-follow with a camera-tracking viewport. The viewport moves
        # with the camera (vx = -display_x/4); Plane.ox is relative to it.
        # Generalised over the parallax factor p (0 = screen-locked, 1 =
        # world-anchored, 0.5 = native RMXP panorama):
        #   Plane.ox = -(display_x/4) * (1 - p) + scroll
        #   p=1 -> ox = scroll                (viewport handles positioning)
        #   p=0 -> ox = -(display_x/4)+scroll (fixed on screen)
        p = follow ? 0.0 : (par.nil? ? 1.0 : par.to_f)
        comp = 1.0 - p
        # clip_dx/clip_dy re-anchor the pattern after the viewport was clipped to
        # the visible part of the map (its origin moved right/down by that much).
        sprite.ox = -(map.display_x / 4.0) * comp + clip_dx + (scroll ? scroll[:ox] : 0)
        sprite.oy = -(map.display_y / 4.0) * comp + clip_dy + (scroll ? scroll[:oy] : 0)
      end
    end
  end

  #---------------------------------------------------------------------------
  # Dispose group sprites and viewports for a map
  #---------------------------------------------------------------------------
  def dispose_fog_sprites(map_id)
    sprites = @fog_sprites_cache.delete(map_id)
    if sprites
      sprites.each do |sprite|
        next if sprite.nil? || sprite.disposed?
        sprite.bitmap.dispose if sprite.bitmap
        sprite.dispose
      end
    end
    vps = @fog_viewports_cache.delete(map_id)
    if vps
      vps.each do |group_key, vp|
        vp.dispose unless viewport_disposed?(vp)
      end
    end
  end

  #---------------------------------------------------------------------------
  # Dispose all group sprites and viewports
  #---------------------------------------------------------------------------
  def dispose_all_fog_sprites
    @fog_sprites_cache.keys.each do |map_id|
      dispose_fog_sprites(map_id)
    end
    @fog_scroll_offsets.clear
  end

  #---------------------------------------------------------------------------
  # Find a group graphic file in `dir` (case-insensitive, multiple extensions)
  #---------------------------------------------------------------------------
  def find_group_graphic(dir, name)
    extensions = [".png", ".bmp", ".gif", ".jpg", ".jpeg"]

    # Try exact name with extensions
    extensions.each do |ext|
      path = File.join(dir, name + ext)
      return path if File.exist?(path)
    end

    # Case-insensitive search
    if File.directory?(dir)
      Dir.entries(dir).each do |entry|
        next if entry[0, 1] == "."   # 1.8-safe (no String#start_with?)
        ext = File.extname(entry)
        base = File.basename(entry, ".*")
        if base.downcase == name.downcase && extensions.include?(ext.downcase)
          return File.join(dir, entry)
        end
      end
    end

    return nil
  end

  # Back-compat helper (008_FogCommands and older code look fogs up here).
  def find_fog_graphic(name)
    find_group_graphic(FOG_DIR, name)
  end
end


###############################################################################
# >>> 002_Integration/007_CustomSheetGrid.rb
###############################################################################
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
  # BES/RGSS Sprite_Character has no #update_bitmap (that split exists only on
  # newer Essentials). Cell size (@cw/@ch) and the frame src_rect are computed
  # inline in #update, so hook #update and re-derive them for custom grids.
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
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
      self.oy = (@character_name[/offset/]) ? @ch - 16 : @ch
    end
  end
end


###############################################################################
# >>> 002_Integration/008_FogCommands.rb
###############################################################################
#===============================================================================
# MakerStudio - Fog Event Commands + Map Background Overrides
#
# 1. Per-map background overrides (applied right after Game_Map#setup, once the
#    map's extended layers are cached by 002_RendererOverride):
#      - Suppress the native tileset fog when the map carries Maker Studio fog
#        layers, so the engine's single tileset fog does not double-render over
#        the multi-fog planes created in 004_FogOverride.rb.
#      - Apply the per-map panorama / battleback stored in @extended_layers
#        "mapSettings" over the tileset defaults. Maker Studio stores these on
#        the map (and per map-version) instead of the shared tileset.
#
# 2. Fog event commands retargeted to a specific Maker Studio fog layer by id
#    (the editor picks the layer from a list; the id rides in the command
#    parameters). Falls back to the engine's native single-fog behaviour when
#    the map has no Maker Studio fog layer with that id.
#      - command_204 (Change Map Settings, type 1 = Fog): applies EVERY fog
#        property (graphic, hue, blend, zoom, scroll x/y, follow, opacity).
#      - command_205 (Change Fog Color Tone): tones that fog plane, optionally
#        animated over `frames`.
#      - command_206 (Change Fog Opacity): fades that fog plane's opacity,
#        optionally animated over `frames`.
#
# The `frames` transition is stepped once per fog update (update_fog_sprites is
# aliased below to advance in-progress tone/opacity fades each frame).
#
# Written to stay Ruby 1.8-compatible so the SAME file works in every framework
# build (BES5 / LBDS / PE21).
#===============================================================================
module MakerStudio
  module_function

  #---------------------------------------------------------------------------
  # Apply per-map panorama / battleback + native-fog suppression onto a
  # Game_Map. Reads the cached extended-layers hash (loaded during setup).
  # Idempotent; safe to call again after a map-version swap or hot-reload.
  #---------------------------------------------------------------------------
  def apply_map_background_overrides(game_map, map_id)
    return unless game_map
    ext = (respond_to?(:get_extended_data_for) ? get_extended_data_for(map_id) : nil)
    return unless ext

    # Suppress native tileset fog when Maker Studio fog layers exist here.
    fogs = ext["fogLayers"]
    if fogs && !fogs.empty?
      game_map.instance_variable_set(:@fog_name, "")
      game_map.instance_variable_set(:@fog_opacity, 0)
    end

    # Suppress the native panorama when Maker Studio panorama layers exist —
    # they are rendered as Planes by 004_FogOverride (multi-panorama), so the
    # engine's single panorama would double-render beneath them.
    panos = ext["panoramaLayers"]
    has_ms_panoramas = panos && !panos.empty?
    if has_ms_panoramas
      game_map.instance_variable_set(:@panorama_name, "")
      game_map.instance_variable_set(:@panorama_hue, 0)
    end

    ms = ext["mapSettings"]
    return unless ms

    pano = ms["panoramaName"]
    if pano && !pano.empty? && !has_ms_panoramas
      game_map.instance_variable_set(:@panorama_name, pano)
      game_map.instance_variable_set(:@panorama_hue, (ms["panoramaHue"] || 0).to_i)
    end

    bback = ms["battlebackName"]
    if bback && !bback.empty?
      game_map.instance_variable_set(:@battleback_name, bback)
    end
  end

  #---------------------------------------------------------------------------
  # Maker Studio fog sprite accessors. Operate on the @fog_sprites_cache that
  # 004_FogOverride.rb builds (a module ivar shared on this same module object).
  #---------------------------------------------------------------------------
  def find_fog_sprite(map_id, fog_id)
    return nil unless @fog_sprites_cache
    sprites = @fog_sprites_cache[map_id]
    return nil unless sprites
    sprites.each do |sprite|
      next if sprite.nil? || sprite.disposed?
      # The cache now holds ALL graphic groups (fog/panorama/custom) — the fog
      # event commands must only retarget fog-group sprites.
      group = sprite.instance_variable_get(:@ms_group)
      next unless group.nil? || group == "fog"
      return sprite if sprite.instance_variable_get(:@fog_id) == fog_id
    end
    nil
  end

  # Coerce a command's tone parameter (an RPG::Tone at runtime, or a [r,g,b,gray]
  # array) into a fresh Tone. Returns nil when it is neither.
  def to_fog_tone(tone)
    if defined?(Tone) && tone.is_a?(Tone)
      Tone.new(tone.red, tone.green, tone.blue, tone.gray)
    elsif tone.is_a?(Array)
      Tone.new(tone[0] || 0, tone[1] || 0, tone[2] || 0, tone[3] || 0)
    else
      nil
    end
  end

  # Fade a fog layer's opacity to `opacity` over `frames` (instant when frames<=0).
  def set_fog_opacity(map_id, fog_id, opacity, frames = 0)
    sprite = find_fog_sprite(map_id, fog_id)
    return false unless sprite
    target = opacity.to_i
    if frames.to_i <= 0
      sprite.opacity = target
      sprite.instance_variable_set(:@ms_op_dur, 0)
    else
      sprite.instance_variable_set(:@ms_op_target, target)
      sprite.instance_variable_set(:@ms_op_dur, frames.to_i)
    end
    true
  end

  # Tone a fog layer to `tone` over `frames` (instant when frames<=0).
  def set_fog_tone(map_id, fog_id, tone, frames = 0)
    sprite = find_fog_sprite(map_id, fog_id)
    return false unless sprite
    return false unless sprite.respond_to?(:tone=)
    target = to_fog_tone(tone)
    return false unless target
    if frames.to_i <= 0
      sprite.tone = Tone.new(target.red, target.green, target.blue, target.gray)
      sprite.instance_variable_set(:@ms_tone_dur, 0)
    else
      sprite.instance_variable_set(:@ms_tone_target, target)
      sprite.instance_variable_set(:@ms_tone_dur, frames.to_i)
    end
    true
  end

  # Reload a fog layer's graphic (and re-apply hue). Empty name clears it.
  def set_fog_graphic(map_id, fog_id, name, hue)
    sprite = find_fog_sprite(map_id, fog_id)
    return false unless sprite
    apply_fog_graphic(sprite, name, hue)
    true
  end

  # Internal: swap a sprite's bitmap to graphic `name` (hue-rotated). Empty name
  # clears the bitmap. No-op (keeps current bitmap) when name is nil.
  def apply_fog_graphic(sprite, name, hue)
    return if name.nil?
    if name.empty?
      old = sprite.bitmap
      sprite.bitmap = nil
      old.dispose if old && !old.disposed?
      return
    end
    path = find_fog_graphic(name)
    return unless path
    begin
      bmp = Bitmap.new(path)
    rescue
      return
    end
    h = (hue || 0).to_i
    bmp.hue_change(h) if h != 0
    old = sprite.bitmap
    sprite.bitmap = bmp
    old.dispose if old && !old.disposed?
  end

  # Apply the Edit-Fog property set to a fog layer (command_204 / type 1).
  # Any nil argument is left unchanged. Opacity is NOT touched here — use the
  # Change Fog Opacity command (206) for that.
  def set_fog_properties(map_id, fog_id, name, hue, blend_type, zoom, sx, sy, follow)
    sprite = find_fog_sprite(map_id, fog_id)
    return false unless sprite
    apply_fog_graphic(sprite, name, hue)
    sprite.blend_type = blend_type.to_i unless blend_type.nil?
    unless zoom.nil?
      z = zoom.to_f
      z = 0.1 if z < 0.1
      sprite.zoom_x = z
      sprite.zoom_y = z
    end
    sprite.instance_variable_set(:@fog_sx, sx.to_f) unless sx.nil?
    sprite.instance_variable_set(:@fog_sy, sy.to_f) unless sy.nil?
    sprite.instance_variable_set(:@fog_follow, follow.to_i == 1) unless follow.nil?
    true
  end

  #---------------------------------------------------------------------------
  # Per-frame transition stepping for fog tone / opacity fades. Uses RPG Maker's
  # incremental-average interpolation so a fade reaches its target exactly on
  # the final frame. Called once per fog update (see the update_fog_sprites
  # alias below).
  #---------------------------------------------------------------------------
  def step_fog_transition(sprite)
    return if sprite.nil? || sprite.disposed?

    odur = sprite.instance_variable_get(:@ms_op_dur)
    if odur && odur >= 1
      target = sprite.instance_variable_get(:@ms_op_target) || sprite.opacity
      cur = sprite.opacity
      sprite.opacity = ((cur * (odur - 1) + target) / odur)
      odur -= 1
      sprite.opacity = target if odur == 0
      sprite.instance_variable_set(:@ms_op_dur, odur)
    end

    tdur = sprite.instance_variable_get(:@ms_tone_dur)
    if tdur && tdur >= 1 && sprite.respond_to?(:tone) && sprite.respond_to?(:tone=)
      tgt = sprite.instance_variable_get(:@ms_tone_target)
      if tgt
        cur = sprite.tone
        nr  = (cur.red   * (tdur - 1) + tgt.red)   / tdur
        ng  = (cur.green * (tdur - 1) + tgt.green) / tdur
        nb  = (cur.blue  * (tdur - 1) + tgt.blue)  / tdur
        ngr = (cur.gray  * (tdur - 1) + tgt.gray)  / tdur
        sprite.tone = Tone.new(nr, ng, nb, ngr)
        tdur -= 1
        sprite.tone = Tone.new(tgt.red, tgt.green, tgt.blue, tgt.gray) if tdur == 0
        sprite.instance_variable_set(:@ms_tone_dur, tdur)
      end
    end
  end

  def update_fog_transitions
    return unless @fog_sprites_cache
    @fog_sprites_cache.each do |map_id, sprites|
      next unless sprites
      sprites.each { |sprite| step_fog_transition(sprite) }
    end
  end
end

#-------------------------------------------------------------------------------
# Advance in-progress fog tone/opacity fades each frame. update_fog_sprites is
# already called once per frame by the renderer; chain the transition stepper
# onto it so `frames`-based fades animate.
#-------------------------------------------------------------------------------
class << MakerStudio
  # Alias ONCE, but (re)define UNCONDITIONALLY so an mkxp F12 soft-reset (which
  # re-runs 004_FogOverride's original update_fog_sprites) can't drop the chain.
  unless method_defined?(:__mkst__update_fog_sprites) || private_method_defined?(:__mkst__update_fog_sprites)
    alias_method :__mkst__update_fog_sprites, :update_fog_sprites
  end
  def update_fog_sprites
    __mkst__update_fog_sprites
    update_fog_transitions
  end
end

#-------------------------------------------------------------------------------
# Re-apply per-map background overrides right after the engine finishes a normal
# Game_Map#setup. setup triggers :on_game_map_setup (002_RendererOverride loads
# the extended layers there), so by the time the alias returns the cache is warm.
#-------------------------------------------------------------------------------
class Game_Map
  unless method_defined?(:__mkst__setup_bg) || private_method_defined?(:__mkst__setup_bg)
    alias_method :__mkst__setup_bg, :setup
  end

  def setup(map_id)
    __mkst__setup_bg(map_id)
    if defined?(MakerStudio) && MakerStudio::ENABLED
      MakerStudio.apply_map_background_overrides(self, map_id)
    end
  end
end

#-------------------------------------------------------------------------------
# Fog event commands retargeted to a Maker Studio fog layer by id.
#-------------------------------------------------------------------------------
if defined?(Interpreter)
class Interpreter
  unless method_defined?(:__mkst__command_204) || private_method_defined?(:__mkst__command_204)
    alias_method :__mkst__command_204, :command_204
  end
  def command_204
    if defined?(MakerStudio) && MakerStudio::ENABLED && @parameters[0] == 1 && $game_map
      fog_id = @parameters[3]
      if MakerStudio.find_fog_sprite($game_map.map_id, fog_id)
        MakerStudio.set_fog_properties($game_map.map_id, fog_id,
          @parameters[1], @parameters[2], @parameters[4], @parameters[5],
          @parameters[6], @parameters[7], @parameters[8])
        return true
      end
    end
    __mkst__command_204
  end

  unless method_defined?(:__mkst__command_205) || private_method_defined?(:__mkst__command_205)
    alias_method :__mkst__command_205, :command_205
  end
  def command_205
    if defined?(MakerStudio) && MakerStudio::ENABLED && $game_map
      fog_id = @parameters[2]
      return true if MakerStudio.set_fog_tone($game_map.map_id, fog_id, @parameters[0], @parameters[1])
    end
    __mkst__command_205
  end

  unless method_defined?(:__mkst__command_206) || private_method_defined?(:__mkst__command_206)
    alias_method :__mkst__command_206, :command_206
  end
  def command_206
    if defined?(MakerStudio) && MakerStudio::ENABLED && $game_map
      fog_id = @parameters[2]
      return true if MakerStudio.set_fog_opacity($game_map.map_id, fog_id, @parameters[0], @parameters[1])
    end
    __mkst__command_206
  end
end
end


###############################################################################
# >>> 002_Integration/009_FrameCommands.rb
###############################################################################
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


###############################################################################
# >>> 002_Integration/010_MinimapOverride.rb
###############################################################################
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
