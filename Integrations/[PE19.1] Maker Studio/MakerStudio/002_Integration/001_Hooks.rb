#===============================================================================
# MakerStudio - Hooks & Menu Integration (Pokémon Essentials v19.1)
#
# v19.1 sits between the BES and v21.1 builds:
#   * NO EventHandlers (:on_game_map_setup / :on_leave_map arrived in v20) — so
#     Game_Map#setup is aliased to load extended layers (covers new game, transfer
#     and connected-map loads), exactly like the BES build.
#   * NO MenuHandlers — the F9 debug menu is built from DebugMenuCommands
#     (string keys, "parent" chaining), so the Maker Studio submenu registers
#     there instead of aliasing pbDebugMenu the way the BES build has to.
#   * HAS Game.load_map — on a magic-number-matching Continue the engine skips
#     Game_Map#setup, so (as on v21.1) load_map is the ONLY refresh path and is
#     aliased below.
#   * Runs on mkxp → an F12 soft-reset re-evals every script, so every override
#     here aliases the original ONCE but (re)defines unconditionally (Pattern A).
#===============================================================================

#---------------------------------------------------------------------------
# Debug menu entries under "Maker Studio..." (v19.1 DebugMenuCommands).
# Registration is idempotent — the handler hash overwrites by key.
#---------------------------------------------------------------------------
if $DEBUG
  DebugMenuCommands.register("maker_studio_menu", {
    "parent"      => "main",
    "name"        => _INTL("Maker Studio..."),
    "description" => _INTL("Maker Studio plugin.")
  })

  DebugMenuCommands.register("ms_open_editor", {
    "parent"      => "maker_studio_menu",
    "name"        => _INTL("Open Maker Studio"),
    "description" => _INTL("Open Maker Studio for this project."),
    "effect"      => proc {
      pbOpenMakerStudio
    }
  })

  DebugMenuCommands.register("ms_reload_map_data", {
    "parent"      => "maker_studio_menu",
    "name"        => _INTL("Reload Map Data"),
    "description" => _INTL("Hot-reload current map: clears cache, reloads .rxdata and extended layers, rebuilds the overlay."),
    "effect"      => proc {
      pbReloadCurrentMapData
    }
  })
end

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
    if editor =~ /\.app\z/
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
  if fresh_tilesets
    $data_tilesets = fresh_tilesets
    RPG::Cache.clear if defined?(RPG::Cache)
  end
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
  MakerStudio::TileEffects.clear_cache if defined?(MakerStudio::TileEffects)
  pbRefreshLiveMapData(map_id)
  pbMessage(_INTL("Map data reloaded"))
end

#---------------------------------------------------------------------------
# Lifecycle: load extended layers whenever a Game_Map is set up (new game,
# transfer, connected-map load). v19.1 has no :on_game_map_setup event.
#---------------------------------------------------------------------------
class Game_Map
  unless method_defined?(:__mkst__setup)
    alias_method :__mkst__setup, :setup
  end

  def setup(map_id)
    __mkst__setup(map_id)
    # Parse the map's extended-layer JSON only if it is not already cached. setup
    # runs on every transfer AND for each connected map each time it (re)enters the
    # factory; re-parsing the (large) JSON every time stalls map transitions. The
    # cache is keyed by map_id and the "Reload Map Data" command flushes it, so live
    # edits still refresh.
    if MakerStudio::ENABLED && !MakerStudio.get_extended_data_for(map_id)
      MakerStudio.load_extended_layers_for_map(map_id, self)
    end
  end
end

#---------------------------------------------------------------------------
# Save-load refresh: on a Continue whose magic_number matches (the common case)
# Game.load_map does NOT call Game_Map#setup, so the alias above never fires and
# the map data stored in the save file shadows every edit made to the .rxdata
# after saving. Alias load_map to force a reload from disk — it is the ONLY
# Maker Studio refresh path on that Continue, so it must survive an F12
# soft-reset (Pattern A: alias once, def outside the guard).
#---------------------------------------------------------------------------
module Game
  class << self
    unless method_defined?(:__mkst__load_map) || private_method_defined?(:__mkst__load_map)
      alias_method :__mkst__load_map, :load_map
    end

    def load_map
      __mkst__load_map
      return unless MakerStudio::ENABLED
      return unless $game_map
      MakerStudio.clear_all_caches if MakerStudio.respond_to?(:clear_all_caches)
      MakerStudio::TileEffects.clear_cache if defined?(MakerStudio::TileEffects)
      pbRefreshLiveMapData($game_map.map_id)
    end
  end
end

#---------------------------------------------------------------------------
# NOTE: do NOT clear the extended-data cache on Events.onMapChange. Each map's
# data is (re)loaded by the Game_Map#setup alias and keyed by map_id, and
# connected maps are set up before onMapChange fires — clearing there wiped the
# data collision had just loaded. Stale entries are harmless (overwritten on the
# next setup of that map); the explicit Reload command flushes everything.
#---------------------------------------------------------------------------
