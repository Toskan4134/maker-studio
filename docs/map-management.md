# Map Management

## Creating a New Map

Choose File then New Map from the menu, or click the + button in the toolbar. Fill in the details:

- **Name**: The map's display name.
- **Width / Height**: Dimensions in tiles.
- **Tileset**: Which tileset the map uses for its native layers.
- **Parent map**: Where the map sits in the hierarchy tree.

Click Create to add the map to your project.

## Opening Maps

Double-click any map in the Map Tree to open it in a new editor tab.

## Resizing and Shifting Maps

Open the resize dialog from Edit then Resize / Shift Map, or right-click a map in the Map Tree and choose Resize/Shift.

### Resizing

Enter the new width and height. A **9-way anchor pad** decides where the existing content lands in the new canvas — pick the center to keep the map centered as it grows or shrinks, or a corner/edge to anchor there. The dialog auto-computes the shift from your anchor choice.

### Wrap

A **Wrap** toggle (on by default) controls what happens to content that falls outside the new bounds:

- **Wrap on**: tiles, events, and shadows that move off one edge reappear on the opposite side (toroidal wrap).
- **Wrap off**: anything outside the new bounds is dropped.

You can also shift content manually by overriding the computed shift values.

### Preview & Undo

An SVG preview shows where your content will sit inside the new canvas before you commit. The resize is a single undo step — press Ctrl+Z afterward to restore the original size and content.

## Changing a Map's Tileset

Right-click a map in the Map Tree and choose Change Tileset, or use Edit then Change Tileset from the menu. Pick from the searchable list and click Apply — the map repaints with the new tileset's graphics right away, no reload needed. Changing the tileset only affects the native layers, and does not remap tile IDs (existing tiles keep their numbers, so they may look different under the new tileset). Extended layers can continue to use tiles from any tileset.

## Deleting a Map

Right-click a map in the Map Tree and choose Delete Map, then confirm the deletion. Any child maps are moved up to the deleted map's parent so they are not lost. The map's `.rxdata` file is removed from disk.

## Exporting Maps

The editor supports four export formats. All exports stream their work in the background — the bottom status bar shows a progress bar while frames render and encode, and a toast pops up when the export finishes with an **Open folder** button that reveals the output file in your OS file explorer.

### Export as JSON

File then Export Map as JSON saves a complete dump of the map including extended layers and shadow data. This is useful for backups, sharing, or re-importing.

### Export as PNG

File then Export Map as PNG renders the entire map to a PNG image at full resolution.

### Export as GIF (Animated)

File then Export Map as GIF creates an animated GIF showing autotile and shadow animations in motion. GIF is limited to a 256-color palette, so heavily shaded maps may look posterized — prefer WebP for those.

### Export as WebP (Animated)

File then Export Map as WebP creates an animated WebP. WebP supports the full 24-bit color space, so it preserves shadow gradients and fog colors GIF cannot. Before saving, the editor asks whether the animation should loop forever or play once and stop — pick "Play once" if you intend to embed the file somewhere that should not repeat. Output is lossless by default.

## Importing Maps

File then Import Map from JSON loads a previously exported JSON file as a new map in your project.

## Setting the Player Start Position

The player start position is where the player appears when a new game begins. To set it:

1. Right-click any tile on the map you want the game to start on.
2. Choose **Set as Player Start** from the menu.

A green **Start** marker appears on that tile, and the position is saved to your project immediately (no map save needed). There is only one start position per project — setting a new one moves it. The marker is only drawn on the map it belongs to. To move it, right-click a different tile (on any map) and choose Set as Player Start again.

## Running the Game

Click the green Run button in the toolbar (or use Project then Run Game). The editor saves all open maps with unsaved changes, then launches `Game.exe` in debug mode from your project folder.

## Close Confirmation

When you close a tab that has unsaved changes, the editor asks you to confirm:

- **Save**: Saves the map, then closes the tab.
- **Discard**: Closes the tab without saving.
- **Cancel**: Returns to the editor without closing.
