# Maker Studio (Essentials v17.1 build)

A Maker Studio build for **vanilla Pokémon Essentials v17.1** that provides an advanced external tilemap editor, replacing RPG Maker XP's native editor with a multi-layer system, per-tile visual effects, cross-tileset painting, unlimited autotiles, and a shadow system.

> **This folder is maintenance source.** v17.1 has no `Plugins/` auto-loader — install the build by
> pasting the generated `../MakerStudio_PE17.rb` into the RMXP Script Editor (above `Main`). The build
> is Ruby-1.8-safe and bundles its own JSON parser, so it runs on the stock RGSS runtime (`Game.exe`,
> Ruby 1.8) and on modern-Ruby mkxp ports unchanged. See the parent folder's `README.md` for full
> install steps and the v17.1-specific compatibility notes. The feature list below describes the
> editor itself (shared across all engine builds).

## Features

### Multi-Layer System
- Up to **16 simultaneous drawing layers** (3 native + 13 extended)
- Layer visibility toggling, reordering, naming, per-layer opacity
- Extended layers stored inside `.rxdata` — single-file-per-map, atomic saves

### Per-Tile Visual Effects
Every tile on extended layers supports individual modifications:
- **Opacity** (0–255), **Rotation** (0–360°), **Hue** (0–360°)
- **Saturation** (0–200%), **Lighting** (−255 to 255), **Flip H/V**

### Advanced Tile Placement
- **Multi-tileset**: paint tiles from any tileset on extended layers
- **Unlimited autotiles**: named autotiles beyond RMXP's 8-slot limit
- **Per-tile game properties**: passage, priority, terrain tag overrides
- Full autotile smart-painting with neighbor pattern recalculation

### Shadow System
- Multiple shadows per map, generated from tile selections
- Animated shadows from autotile sources
- Stretch, opacity, and offset configuration per shadow
- Runtime computation in-game — no image storage needed

### Event Editor
- Full RMXP-style event CRUD with multi-page support
- Command list editor with typed parameter forms for ~45 commands
- Block auto-close (Conditional Branch, Loop, Show Choices)
- Command search, drag-reorder, copy/paste

### Editor Tools
Brush, Eraser, Fill, Rectangle, Eyedropper, Select (drag-to-move), Pan
- Multi-tile stamps with origin-anchored grid snap
- Brush size 1×1 to 5×5, Q/W rotation
- Copy/paste with cross-layer support

### Map Management
- Create, resize, and shift maps with toroidal wrapping
- Export maps as JSON, PNG, or animated GIF
- Import maps from JSON
- Map tree with drag-drop hierarchy, rename, delete

### Tauri Desktop Application
- Native desktop app (not browser-based)
- Reads/writes `.rxdata` directly — no JSON import/export workflow
- Dark/light theme, dockable panels, minimap
- Mod system for extending the editor itself, with dual mod sources (project-level and global)

## Installation

v17.1 has **no `Plugins/` auto-loader**, so you do NOT copy this folder in. Instead:

1. Open your project in RPG Maker XP → **Tools ▸ Script Editor** (F11).
2. Paste the contents of **`../MakerStudio_PE17.rb`** into a new section just **above `Main`**.
3. Save and run (`Game.exe`).

(This `MakerStudio/` folder is the maintainable split source the merged file is generated from.)

## Usage

### Opening the Editor
1. Run the game in **Debug mode**
2. Open the **Debug Menu** (F9)
3. Select **"Maker Studio"** → **"Open Maker Studio"**
4. The Tauri desktop app opens with your project loaded

Or launch the installed Maker Studio app directly — it installs separately and is **not** bundled
with this build (get it from the [Releases](https://github.com/Toskan4134/maker-studio/releases/latest) page).

### Editing Tiles
1. Open a map from the **Map Tree** (double-click)
2. Pick a tile from the **Tile Palette** (right panel)
3. Select the **layer** in the **Layer Panel** (left panel)
4. Paint with the **Brush** tool (B key)
5. Press **Ctrl+S** to save — writes directly to `.rxdata`

### Reloading In-Game
- Debug Menu → **"Reload Map Data"** hot-reloads the current map without restarting
- Or re-enter the map

## Configuration

Edit `000_Settings.rb`:

| Setting | Default | Description |
|---------|---------|-------------|
| `ENABLED` | `true` | Master toggle |
| `MAX_TOTAL_LAYERS` | 16 | Maximum layers (native + extended) |
| `DEFAULT_EXT_LAYERS` | 3 | Extended layers created by default |
| `TILE_WIDTH` / `TILE_HEIGHT` | 32 | Tile dimensions |
| `DEBUG_LOG` | `false` | Verbose console logging |

Visual effect ranges are also configurable (opacity, rotation, saturation, hue, lighting).

## File Structure

```
[PE17.1] Maker Studio/
  MakerStudio_PE17.rb             - SHIPPED build: paste this one file into the Script Editor
  MakerStudio/                    - split source (regenerate the merged file after editing):
    meta.txt                      - metadata (informational only; v17.1 does not read it)
    000_Settings.rb               - Configuration constants
    001_Core/
      001_DataStore.rb            - Extended-layer loading + bundled MakerStudio::JSON parser
      003_TileEffects.rb          - Saturation helper (CSS-filter baking lives in the renderer)
    002_Integration/
      001_Hooks.rb                - Debug menu (aliases pbDebugMenu), lifecycle, editor launcher
      002_OverlayRenderer.rb      - Overlay sprite renderer (extended layers + native extras + shadows)
      003_GameMapOverride.rb      - Game_Map collision/terrain via PBTerrain
      004_FogOverride.rb          - Multi-fog rendering
    003_Editor/
      README.txt                  - editor download/launch notes (the app is NOT bundled)
      Mods/                       - Project-level JS mods (per-game extensions)
```

## How It Works (v17.1)

1. The desktop editor reads `.rxdata` directly (RMXP Marshal format) and embeds extended data as an
   `@extended_layers` JSON string; **Ctrl+S** patches the file in place (backs it up to `Data/map-backups/` first).
2. v17.1 has no per-tile sprites (it composites layers with the Ruby `CustomTilemap` or the hardware
   `SynchronizedTilemap`), so this build draws extended layers, native-layer "extra" tiles, shadows
   and fog as an **independent overlay sprite layer** attached to each map's `Spriteset_Map`
   (via `Events.onSpritesetCreate`).
3. `002_OverlayRenderer.rb` composes each tile with the engine's `TileDrawingHelper` and bakes
   hue/saturation/lighting using the **same CSS color matrices the editor uses** so in-game matches the editor.
4. `003_GameMapOverride.rb` patches `Game_Map` collision/terrain for extended + native-extra tiles using
   the integer **`PBTerrain`** system (v17.1 has no `GameData::TerrainTag`).
5. Day/night ("ambient") tone is copied from the spriteset's tilemap onto the overlay sprites each frame
   so they tint with time exactly like native tiles (in tilemap view mode 0 the engine's own
   screen-wide viewport tint covers them instead).

## Data Storage

- **Native layers** (0–2): Standard `Data/MapXXX.rxdata` Table3
- **Extended layers** (3+): Embedded as `@extended_layers` JSON string inside the same `.rxdata`
- **Shadows**: Source tiles + config only (no PNG), runtime bitmap generation
- **Backups**: Every save copies the original into `Data/map-backups/` as `<file>.<timestamp>.backup`, keeping the newest 10 per file

## Credits

- **Author**: Toskan4134
- **Framework**: Pokémon Essentials v17.1. Credit the Essentials scripters/spriters per the base's own terms.
- **Editor**: Tauri v2, React 19, TypeScript, Rust (the editor app is shared across all integrations)

## License

This plugin is provided as-is for use with Pokémon Essentials v17.1 projects. Pokémon Essentials is a fan-made, non-commercial project; respect its license and credit requirements.
