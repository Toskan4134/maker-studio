# Getting Started

## Prerequisites

You need an RPG Maker XP project folder -- specifically, a directory that contains `Game.exe` and a `Data/` subdirectory with your map and tileset files. The editor reads and writes `.rxdata` files directly, so no export or conversion step is required.

## Launching

Run the editor executable. On first launch you will see a welcome screen prompting you to select a game folder. Click **Browse** and navigate to your RPG Maker XP project root (the folder containing `Game.exe`).

The editor remembers your last-opened project, so subsequent launches go straight to the map tree.

## Opening a Map

The Map Tree panel on the left shows every map in your project, organized in the same hierarchy you set up in RPG Maker XP. Double-click any map to open it in a new editor tab. Maps with a dot indicator next to their name have unsaved changes.

## Navigation

Moving around the canvas is straightforward:

- **Pan**: Hold Space and drag, or middle-click and drag, or Shift and drag.
- **Zoom**: Ctrl + scroll wheel, or use the + / - buttons in the toolbar.
- **Status Bar**: Shows your cursor coordinates (X, Y) along the bottom edge of the window.

## Saving

Press Ctrl+S to save the current map. Changes are written directly to the corresponding `.rxdata` file. A backup of the original file is created automatically on the first save, so you can always revert if something goes wrong.

## Building from Source

If you prefer to build the editor yourself:

```bash
npx tauri build              # Production build
npm run tauri:dev            # Dev mode with hot reload
```
