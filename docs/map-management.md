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

Enter the new width and height. The map expands or shrinks from the top-left corner. Any tiles, events, or shadows outside the new bounds are permanently removed.

### Shifting

Use the directional pad in the dialog to shift all tiles, events, and shadows by a set number of tiles in any direction. Shifting uses toroidal wrapping, meaning tiles that move off one edge reappear on the opposite side.

### Preview

The dialog shows live counts of tiles and events that will be affected before you commit, so you can verify the impact before making changes.

## Changing a Map's Tileset

Right-click a map in the Map Tree and choose Change Tileset, or use Edit then Change Tileset from the menu. Pick from the searchable list. Changing the tileset only affects the native layers. Extended layers can continue to use tiles from any tileset.

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

## Running the Game

Click the green Run button in the toolbar (or use Project then Run Game). The editor saves all open maps with unsaved changes, then launches `Game.exe` in debug mode from your project folder.

## Close Confirmation

When you close a tab that has unsaved changes, the editor asks you to confirm:

- **Save**: Saves the map, then closes the tab.
- **Discard**: Closes the tab without saving.
- **Cancel**: Returns to the editor without closing.
