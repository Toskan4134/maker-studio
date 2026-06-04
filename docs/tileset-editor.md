# Tileset Editor

## Opening the Tileset Editor

Open the **Tileset Manager** from the **Tilesets** tab of the Database (**Tools → Database…**, or the toolbar **Database** button). The manager lists every tileset (with a searchable list); select one and click **Edit Properties...** to open the Tileset Editor for it.

(The separate **Map → Change Tileset...** command is different — it swaps which tileset a *map* uses for its native layers; see [Map Management](map-management.md). It does not edit tile properties.)

## Overview

The Tileset Editor lets you modify base properties for every tile in a tileset. These are the same settings you find in RPG Maker XP under Database then Tilesets. Changes made here apply to every map that uses this tileset.

## Editing Modes

### Passage

Click a tile to toggle between fully passable (all directions open) and fully blocked (displayed as a red x). Right-click to reset a tile to its default passage setting.

### Passage (4 Direction)

Click one of the four quadrants within a tile to block or unblock that specific direction (Up, Down, Left, Right). Each direction can be toggled independently, giving you fine control over exactly how the player can move through a tile.

### Priority

Click to cycle through priority levels 0 through 5:

- **0** = Ground. Renders below events.
- **1--5** = Overhead. Renders above events and is shifted upward by the priority level.

### Bush Flag

Toggle the bush flag on or off. When enabled, tiles under a bush overlay appear partially hidden, simulating tall grass or foliage.

### Counter Flag

Toggle the counter flag. This allows interaction across the tile -- useful for things like shop counters where the player talks to an event on the other side.

### Terrain Tag

Pick a terrain tag from the searchable dropdown, then click a tile (or drag-select a region and press **Apply**) to assign it. The list ships with named tags 0–17 (the Pokemon Essentials defaults), and you can filter by name or number. Installed mods can add their own named tags to this same dropdown. Terrain tags are used by events and scripts for terrain-specific behavior, such as changing movement speed on sand versus road, and are read in-game via the engine's terrain tag.

## Editing Autotile Properties

Autotile passage/priority/terrain are edited separately from regular tilesets. In the Tileset Manager, choose the **Autotiles** entry (shown as `000: Autotiles` at the top of the list) and click **Edit Properties...**. This opens a dedicated grid of every autotile (native slots + named extra autotiles). Editing a property for an autotile applies it to all 48 pattern tiles of that autotile at once and is saved across every tileset that uses it.

## Saving

Click **Save** to write your changes to `Tilesets.rxdata`. A backup of the original file is created automatically on first save. The editor stays open after saving, so you can keep adjusting properties — press **Ctrl+S** (or **Cmd+S** on macOS) to save again without closing, or use **Close** when you're done. If you close with unsaved changes, you'll be asked whether to save, discard, or cancel.

After saving, collision and priority overlays update immediately on all open maps that use the tileset — including tiles you placed earlier. This applies to every placed tile: normal tiles, tiles painted from another tileset, extra (named) autotiles, and tiles you rotated or flipped. Rotated and flipped tiles automatically re-apply the new passage in the correct orientation, in the editor and in-game.
