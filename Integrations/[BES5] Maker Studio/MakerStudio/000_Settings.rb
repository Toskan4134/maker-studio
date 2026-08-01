#===============================================================================
# MakerStudio - Settings
#===============================================================================
module MakerStudio
  # Enable/disable the plugin
  ENABLED = true

  # Re-apply the map in place when Maker Studio saves it, while the game is
  # running. Costs one File.file? per second and can only ever fire while the
  # editor is open on this project — it is the editor that writes the sentinel
  # the check looks for. Not gated on $DEBUG: older engines leave it false for
  # a normal Game.exe run, which is exactly when playtesting happens.
  LIVE_RELOAD = true

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
