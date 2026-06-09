# Map Management

## Creating a New Map

Choose Map then New Map from the menu, or click the **+** button in the **Maps panel header** (next to the map list, mirroring the add-layer **+** in the Layers panel). Fill in the details:

- **Name**: The map's display name.
- **Width / Height**: Dimensions in tiles.
- **Tileset**: Which tileset the map uses for its native layers.
- **Parent map**: Where the map sits in the hierarchy tree.

Click Create to add the map to your project.

## Opening Maps

Double-click any map in the Map Tree to open it in a new editor tab.

## Duplicating a Map

To make a full copy of a map as a **brand-new map** (a separate `map_id`, not a version):

- Right-click a map in the Map Tree and choose **Duplicate Map**, or
- Open the map and choose **Map → Duplicate Map** from the menu.

The copy is named *"<original> (copy)"*, placed under the same parent, and opened automatically. It is a faithful clone — tiles, events, layers, shadows/fog, **and any map versions** come along. If the source map has unsaved edits, they're saved first so the copy is current. This is different from a **map version** (same map, swapped in-game); use Duplicate Map when you want an independent map you can change without affecting the original.

## Resizing and Shifting Maps

Open the resize dialog from Map then Resize / Shift Map, or right-click a map in the Map Tree and choose Resize/Shift.

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

Right-click a map in the Map Tree and choose Change Tileset, or use Map then Change Tileset from the menu. Pick from the searchable list and click Apply — the map repaints with the new tileset's graphics right away, no reload needed. Changing the tileset only affects the native layers, and does not remap tile IDs (existing tiles keep their numbers, so they may look different under the new tileset). Extended layers can continue to use tiles from any tileset.

## Panorama and Battleback

In RPG Maker XP the **panorama** (the scrolling background image behind a map) and the **battleback** (the battle background) belong to the *tileset*, so every map sharing a tileset shares them. Maker Studio lets you change them right from the map you're editing — and each [map version](map-versions.md) can carry its own override.

There are three ways to change them, all opening the same image picker:

- **Menu bar → Map → Change Panorama…** or **Change Battleback…** (next to Change Tileset…).
- **Right-click a map** in the Map Tree → **Change Panorama…** or **Change Battleback…**.
- When you're editing a [map version](map-versions.md), the version's right-click submenu has **Change Panorama (this version)…** / **Change Battleback (this version)…**.

Pick an image from `Graphics/Panoramas/` (panorama) or `Graphics/Battlebacks/` (battleback). The panorama picker also has a **hue** slider; battlebacks have no hue. Leave the name blank to clear it.

What the change does depends on what you're editing:

- **On the base map, you are editing the tileset** — exactly like RPG Maker XP. The new panorama/battleback is written to the tileset immediately and applies to **every map that uses that tileset** (other open maps update on the spot). This works in any game, with no plugin needed, so these menu items show no MS badge while you're on the base map.
- **On a map version, you set a per-version override** — a "destroyed" version can have a different sky than the normal one. Version overrides are stored in the map file (press **Ctrl+S** to keep them) and applied in-game by the MakerStudio plugin, so these items carry the MS badge.

Either way:

- The **panorama is drawn on the editor canvas**, tiled beneath your tiles, so you can see exactly how it looks while mapping.
- The **battleback is not shown on the map canvas** — it only appears in battles in-game — but it is stored and editable here.

> Maps saved with an older Maker Studio build may still contain a per-map base override; the editor now ignores it (the base map always shows the tileset's settings) and removes it the next time you save that map. Unrelated to panoramas but handled by the same in-game plugin: when a map uses Maker Studio fog layers, the plugin stops the tileset's own fog from drawing twice.

## Deleting a Map

Right-click a map in the Map Tree and choose Delete Map, then confirm the deletion. Any child maps are moved up to the deleted map's parent so they are not lost. The map's `.rxdata` file is removed from disk.

## Exporting Maps

The editor supports four export formats. All exports stream their work in the background — the bottom status bar shows a progress bar while frames render and encode, and a toast pops up when the export finishes with an **Open folder** button that reveals the output file in your OS file explorer.

### Export as JSON

Map then Export Map then Export as JSON saves a complete dump of the map including extended layers and shadow data. This is useful for backups, sharing, or re-importing.

### Export as PNG

Map then Export Map then Export as PNG renders the entire map to a PNG image at full resolution.

### Export as GIF (Animated)

Map then Export Map then Export as GIF creates an animated GIF showing autotile and shadow animations in motion. GIF is limited to a 256-color palette, so heavily shaded maps may look posterized — prefer WebP for those.

### Export as WebP (Animated)

Map then Export Map then Export as WebP creates an animated WebP. WebP supports the full 24-bit color space, so it preserves shadow gradients and fog colors GIF cannot. Before saving, the editor asks whether the animation should loop forever or play once and stop — pick "Play once" if you intend to embed the file somewhere that should not repeat. Output is lossless by default.

## Importing Maps

Map then Import Map from JSON loads a previously exported JSON file as a new map in your project.

## Setting the Player Start Position

The player start position is where the player appears when a new game begins. To set it:

1. Right-click any tile on the map you want the game to start on.
2. Choose **Set as Player Start** from the menu.

A green **Start** marker appears on that tile, and the position is saved to your project immediately (no map save needed). There is only one start position per project — setting a new one moves it. The marker is only drawn on the map it belongs to. To move it, right-click a different tile (on any map) and choose Set as Player Start again.

## Running the Game

Click the green Run button in the toolbar (or use File then Run Game). The editor saves all open maps with unsaved changes, then launches `Game.exe` in debug mode from your project folder.

### Running on Linux (Proton / Wine)

`Game.exe` is a Windows executable, so on Linux the editor runs it through **Proton** or **Wine**. The first time you press Run, a dialog lets you pick how to launch:

- **Proton**: choose an installed Proton version (and, if needed, the Steam app id to use). The editor sets up a dedicated Wine prefix for your game the first time.
- **Wine**: launch through your system Wine instead.

Your choice is remembered per project, so later runs launch straight away without asking again.

### Saves Button

After your first Run, a **Saves** button appears in the toolbar that opens the folder where the game writes its save files:

- **Windows / macOS**: opens the native saves folder (on Windows, `%AppData%\<Game>`).
- **Linux**: opens the relevant folder inside the Proton/Wine prefix the game ran in.

This makes it easy to back up or clear save files while testing.

## Close Confirmation

When you close a tab that has unsaved changes, the editor asks you to confirm:

- **Save**: Saves the map, then closes the tab.
- **Discard**: Closes the tab without saving.
- **Cancel**: Returns to the editor without closing.

## Switching Projects with Unsaved Changes

If you choose **File → Open Project…** or pick a project from **File → Open Recent** while any open map has unsaved changes, the editor opens a Save All / Discard / Cancel dialog before swapping projects:

- **Save All**: Saves every dirty map, then switches to the new project.
- **Discard**: Switches without saving — unsaved edits are lost.
- **Cancel**: Stays on the current project.

This is the same prompt used by Reset App and View → Layout → Reset Layout, so unsaved work cannot be lost silently by opening a different project.

## "Not a Project Folder" Dialog

When you point the editor at a folder that does not look like an RPG Maker XP project (no `Data/MapInfos.rxdata` inside), it shows a **Not a Project Folder** dialog with two buttons:

- **Choose Another…**: Re-opens the folder picker so you can try a different folder.
- **Go Back**: Returns to your previous project (or to the welcome screen if this was the first launch).

This replaces the previous behaviour where picking a non-game folder left the editor in an empty / stuck state.
