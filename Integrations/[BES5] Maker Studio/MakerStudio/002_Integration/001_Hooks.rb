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
      # Mirror panorama/battleback too, so base-map "Change Battleback" and
      # tileset-panorama edits apply on live reload — apply_map_background_overrides
      # (below) re-bridges battleback onto metadata and re-suppresses the native
      # panorama when MS panorama layers exist.
      $game_map.instance_variable_set(:@panorama_name, ts.panorama_name)
      $game_map.instance_variable_set(:@panorama_hue, ts.panorama_hue)
      $game_map.instance_variable_set(:@battleback_name, ts.battleback_name)
      $game_map.instance_variable_set(:@passages, ts.passages)
      $game_map.instance_variable_set(:@priorities, ts.priorities)
      $game_map.instance_variable_set(:@terrain_tags, ts.terrain_tags)
    end
    # Rebuild events from the fresh map so new/edited/deleted events
    # appear without a full game restart.
    if fresh_map.events
      new_events = {}
      fresh_map.events.each do |key, rpg_event|
        new_events[key] = Game_Event.new(map_id, rpg_event, $game_map)
      end
      $game_map.instance_variable_set(:@events, new_events)
    end
  end
  MakerStudio.load_extended_layers_for_map(map_id, $game_map)
  # Re-apply per-map panorama / battleback + native-fog suppression after reload.
  if MakerStudio.respond_to?(:apply_map_background_overrides)
    MakerStudio.apply_map_background_overrides($game_map, map_id)
  end
  ov = MakerStudio.current_overlay
  ov.rebuild if ov && !ov.disposed?
  # Rebuild spriteset so character sprites match the refreshed events
  if $scene.respond_to?(:disposeSpritesets) && $scene.respond_to?(:createSpritesets)
    $scene.disposeSpritesets
    $scene.createSpritesets
  end
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
      cmds = [_INTL("Open Maker Studio"), _INTL("Reload Map Data"),
              _INTL("Live Reload: {1}", MakerStudio.live_reload_state_text), _INTL("Cancel")]
      c = pbShowCommands(nil, cmds, -1)
      case c
      when 0 then pbOpenMakerStudio
      when 1 then pbReloadCurrentMapData
      when 2
        on = MakerStudio.live_reload_toggle
        pbMessage(on ? _INTL("Live reload ON.") : _INTL("Live reload OFF."))
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
# Continue with a matching magic_number takes the setMapChanged branch in
# PScreen_Load, which does NOT call Game_Map#setup — the whole $MapFactory
# (Game_Map objects with their already-instantiated Game_Events) is restored
# straight from the save. Events added or edited in the editor since that save
# therefore never appeared until a manual hot-reload. Re-reading the map's
# .rxdata here is the same refresh the "Reload Map Data" debug command runs.
#
# The class is PokemonMapFactory — the SCRIPT is named MapFactory, the class is
# not. `class MapFactory` would silently define a brand-new empty class and the
# alias would NameError at load. Guarded so a base without it just skips.
#---------------------------------------------------------------------------
if defined?(PokemonMapFactory) && PokemonMapFactory.method_defined?(:setMapChanged)
  class PokemonMapFactory
    unless method_defined?(:__mkst__setMapChanged)
      alias_method :__mkst__setMapChanged, :setMapChanged
      def setMapChanged(prev_map)
        __mkst__setMapChanged(prev_map)
        return unless MakerStudio::ENABLED
        return unless $game_map && defined?(pbRefreshLiveMapData)
        pbRefreshLiveMapData($game_map.map_id)
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
