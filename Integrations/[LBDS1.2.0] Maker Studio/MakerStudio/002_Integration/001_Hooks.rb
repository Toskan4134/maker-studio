#===============================================================================
# MakerStudio - Hooks & Menu Integration
# Uses the Tauri v2 desktop app for tile editing (reads .rxdata directly).
#===============================================================================

#---------------------------------------------------------------------------
# Debug menu entries under MakerStudio
#---------------------------------------------------------------------------
if $DEBUG
  unless MenuHandlers.get(:debug_menu, :maker_studio_menu)
    MenuHandlers.add(:debug_menu, :maker_studio_menu, {
      "name"        => _INTL("Maker Studio..."),
      "parent"      => :main,
      "description" => _INTL("Maker Studio plugin.")
    })
  end

  # Command: Open Maker Studio (launches Tauri editor directly with current project)
  MenuHandlers.add(:debug_menu, :ms_open_editor, {
    "name"        => _INTL("Open Maker Studio"),
    "parent"      => :maker_studio_menu,
    "description" => _INTL("Open Maker Studio for this project."),
    "effect"      => proc {
      pbOpenMakerStudio
    }
  })

  # Command: Reload Map Data
  MenuHandlers.add(:debug_menu, :ms_reload_map_data, {
    "name"        => _INTL("Reload Map Data"),
    "parent"      => :maker_studio_menu,
    "description" => _INTL("Hot-reload current map: clears cache, reloads .rxdata and extended layers, refreshes renderer."),
    "effect"      => proc {
      pbReloadCurrentMapData
    }
  })
end

#---------------------------------------------------------------------------
# Locate the installed (or portable) Maker Studio editor.
# The app is no longer bundled with the plugin — it is installed separately
# from the Releases page (MakerStudio::DOWNLOAD_URL) and auto-updates itself.
# Returns the path to launch, or nil if not found.
#   1. Portable copy dropped at EDITOR_EXE_PATH (next to the plugin).
#   2. Per-OS install location of the packaged app.
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
    # 1. Portable copy next to the plugin
    portable = File.expand_path(EDITOR_EXE_PATH)
    return portable if File.exist?(portable)

    # 2. Per-OS install location
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
# Launch Maker Studio with the current project path. No map picker needed —
# the editor has its own map browser. Falls back to the download link.
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
    # .app bundle → use `open`; a bare executable → run directly
    if editor.end_with?(".app")
      system("open", "-a", editor, "--args", root_path)
    else
      system(editor, root_path)
    end
  else # linux
    system(editor, root_path)
  end
end

#---------------------------------------------------------------------------
# Refresh in-memory map data so changes are visible immediately
#---------------------------------------------------------------------------
def pbRefreshLiveMapData(map_id)
  return unless $game_map && $game_map.map_id == map_id
  # Reload tileset data so graphic name / passage / priority changes from the
  # editor are visible immediately without restarting the game.
  fresh_tilesets = load_data("Data/Tilesets.rxdata") rescue nil
  if fresh_tilesets
    $data_tilesets = fresh_tilesets
    # Clear RPG::Cache tileset entries so stale bitmaps are not reused
    RPG::Cache.clear if defined?(RPG::Cache)
  end
  # Reload native tile data from the updated .rxdata into $game_map
  fresh_map = load_data(sprintf("Data/Map%03d.rxdata", map_id)) rescue nil
  if fresh_map && $game_map.data
    # Update the RPG::Map reference so DataStore can read @extended_layers
    $game_map.instance_variable_set(:@map, fresh_map)
    w = [$game_map.data.xsize, fresh_map.data.xsize].min
    h = [$game_map.data.ysize, fresh_map.data.ysize].min
    z_max = [$game_map.data.zsize, fresh_map.data.zsize].min
    w.times do |x|
      h.times do |y|
        z_max.times do |z|
          $game_map.data[x, y, z] = fresh_map.data[x, y, z]
        end
      end
    end
  end
  # Reload extended layers (now reads from embedded @extended_layers in fresh_map)
  MakerStudio.load_extended_layers_for_map(map_id, $game_map)
  # Force the TilemapRenderer to rebuild all tile sprites
  if $scene.respond_to?(:map_renderer) && $scene.map_renderer
    $scene.map_renderer.refresh
  end
end

#---------------------------------------------------------------------------
# Hot-reload current map data (debug helper)
#---------------------------------------------------------------------------
def pbReloadCurrentMapData
  return unless $game_map
  map_id = $game_map.map_id
  # 1. Full cache nuke: extended data + shadow bitmaps + extra autotile/tileset
  #    bitmaps. Needed because editor changes may have altered source tiles,
  #    shadow config, or extra-autotile assets.
  MakerStudio.clear_all_caches
  MakerStudio::TileEffects.clear_cache
  # 2-4. Reload .rxdata, extended layers JSON, and force renderer refresh
  pbRefreshLiveMapData(map_id)
  # 5. Display brief confirmation message
  pbMessage(_INTL("Map data reloaded"))
end

#---------------------------------------------------------------------------
# Event handler: Load extended layers on new game start
# (:on_game_map_setup may not fire for the very first map load)
#---------------------------------------------------------------------------
EventHandlers.add(:on_new_game, :maker_studio_new_game,
  proc {
    next unless MakerStudio::ENABLED
    next unless $game_map
    MakerStudio.load_extended_layers_for_map($game_map.map_id, $game_map)
  }
)

#---------------------------------------------------------------------------
# Event handler: Load extended layer data when entering a map
#---------------------------------------------------------------------------
EventHandlers.add(:on_game_map_setup, :maker_studio_load,
  proc { |map_id, map, tileset|
    next unless MakerStudio::ENABLED
    MakerStudio.load_extended_layers_for_map(map_id, map)
  }
)

#---------------------------------------------------------------------------
# Event handler: Clean up on map change
#---------------------------------------------------------------------------
EventHandlers.add(:on_leave_map, :maker_studio_cleanup,
  proc { |new_map_id, new_map|
    MakerStudio.clear_extended_layers
  }
)

#---------------------------------------------------------------------------
# Save-load refresh: Game.load_map skips Game_Map#setup when the script
# magic_number matches (the common case), which means the cached @map.data
# inside the save file shadows any edits made to .rxdata after the save.
# Alias load_map to force a refresh from disk so editor changes show up
# immediately on Continue, instead of requiring "Reload Map Data" by hand.
#---------------------------------------------------------------------------
module Game
  class << self
    unless method_defined?(:__mkst__load_map) || private_method_defined?(:__mkst__load_map)
      alias_method :__mkst__load_map, :load_map
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
end
