# Getting Started

## Prerequisites

You need an RPG Maker XP project folder -- specifically, a directory that contains `Game.exe` and a `Data/` subdirectory with your map and tileset files. The editor reads and writes `.rxdata` files directly, so no export or conversion step is required.

## Launching

Run the editor executable. On first launch you will see a welcome screen prompting you to select a game folder. Click **Browse** and navigate to your RPG Maker XP project root (the folder containing `Game.exe`).

The editor remembers your last-opened project, so subsequent launches go straight to the map tree.

## Opening a Map

The Map Tree panel on the left shows every map in your project, organized in the same hierarchy you set up in RPG Maker XP. Double-click any map to open it in a new editor tab. Maps with a dot indicator next to their name have unsaved changes.

When you open a project, a "Loading project..." card appears in the map editor area listing each load step (maps, tilesets, system data, opening the first map, and tileset graphics) with a progress count. The rest of the layout stays visible around it, and the card disappears once everything -- including all tileset graphics -- has loaded, leaving the first map ready to edit.

## Navigation

Moving around the canvas is straightforward:

- **Pan**: Hold Space and drag, or middle-click and drag, or Shift and drag.
- **Zoom**: Ctrl + scroll wheel, or use the + / - buttons in the toolbar. Zoom ranges from 5% to 400% — the low end lets you see a large map in full at once.
- **Status Bar**: Shows your cursor coordinates (X, Y) along the bottom edge of the window.

## Saving

Press Ctrl+S to save the current map. Changes are written directly to the corresponding `.rxdata` file. Every save first backs up the previous file into `Data/map-backups/` (the newest 10 backups per file are kept), so you can always revert if something goes wrong, and writes are crash-safe — a crash or power loss mid-save can never leave a half-written file. Unsaved work is also autosaved in the background every few minutes; see [Map Management → Autosave and Crash Recovery](map-management.md#autosave-and-crash-recovery).

## Building from Source

If you prefer to build the editor yourself:

```bash
npx tauri build              # Production build
npm run tauri:dev            # Dev mode with hot reload
```
