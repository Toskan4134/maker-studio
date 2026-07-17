# Maker Studio

A Pokemon Essentials v20.1 plugin that provides an advanced external tilemap editor, replacing RPG Maker XP's native editor with a multi-layer system, per-tile visual effects, cross-tileset painting, unlimited autotiles, and a shadow system.

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

1. Copy the `MakerStudio` folder to your project's `Plugins/` directory
2. The plugin loads automatically with Pokemon Essentials

## Usage

### Opening the Editor
1. Run the game in **Debug mode**
2. Open the **Debug Menu** (F9)
3. Select **"Maker Studio"** → **"Open Maker Studio"**
4. The Tauri desktop app opens with your project loaded

Or launch the installed Maker Studio app directly. It installs separately from the plugin — it is
**not** bundled in `003_Editor/`; get it from the [Releases](https://github.com/Toskan4134/maker-studio/releases/latest) page.

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
MakerStudio/
  meta.txt                        - Plugin metadata (name, version, author)
  000_Settings.rb                 - Configuration constants
  001_Core/
    001_DataStore.rb              - Extended-layer loading/saving + bundled MakerStudio::JSON parser
    003_TileEffects.rb            - Per-tile visual effects (opacity, hue, saturation, flip)
  002_Integration/
    001_Hooks.rb                  - Debug menu entries, lifecycle handlers, editor launcher
    002_RendererOverride.rb       - TilemapRenderer extension, extended layers + shadows
    003_GameMapOverride.rb        - Game_Map collision/terrain patches for extended layers
    004_FogOverride.rb            - Multi-fog rendering (scroll, hue, opacity, blend)
    005_CompilerFix.rb            - Guards the event compiler against the editor's nil event scripts
  003_Editor/
    README.txt                    - editor download + launch notes (the app is NOT bundled)
    Mods/                         - Project-level JS mods (per-game extensions)
```

## How It Works

1. The Tauri editor reads `.rxdata` files directly via the `alox-48` Marshal library
2. Users edit tiles with full visual feedback and per-tile effects
3. **Ctrl+S** patches the `.rxdata` file in-place (backs it up to `Data/map-backups/` first)
4. Extended layers are embedded as `@extended_layers` JSON inside the Marshal stream
5. `RendererOverride` patches `TilemapRenderer` to render extended layers with effects in-game
6. `GameMapOverride` patches `Game_Map` for collision/terrain on extended layers

## Data Storage

- **Native layers** (0–2): Standard `Data/MapXXX.rxdata` Table3
- **Extended layers** (3+): Embedded as `@extended_layers` JSON string inside the same `.rxdata`
- **Shadows**: Source tiles + config only (no PNG), runtime bitmap generation
- **Backups**: Every save copies the original into `Data/map-backups/` as `<file>.<timestamp>.backup`, keeping the newest 10 per file

## Credits

- **Author**: Toskan4134
- **Framework**: Pokemon Essentials v20.1
- **Editor**: Tauri v2, React 19, TypeScript, Rust

## License

This plugin is provided as-is for use with Pokemon Essentials v20.1 projects.
