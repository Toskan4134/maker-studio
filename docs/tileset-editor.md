# Tileset Editor

## Opening the Tileset Editor

Open the **Tileset Manager** from the **Tilesets** tab of the Database (**Tools → Database…**, or the toolbar **Database** button). The manager lists every tileset (with a searchable list); select one and click **Edit Properties...** to open the Tileset Editor for it.

The manager's detail pane also shows a **thumbnail of the selected tileset's graphic**, so
you can tell at a glance which tileset you are about to edit. The **…** button beside the
graphic name opens the normal graphic picker, so you see the image you are switching to —
with zoom, pan and favourites — instead of picking blind from a list of filenames.

A faster route for a tile you can already see: **right-click that tile in the Tile
Palette → Edit Properties…**. The editor opens scrolled to that exact tile with it
already selected, instead of at the top of a long sheet. Press **Esc** to close the
editor (it still asks about unsaved changes).

**Copying, cutting, and pasting a whole tileset**: right-click a row in the tileset list for **Copy
Tileset** / **Cut Tileset** / **Paste Tileset (Replace)** / **Paste as New Tileset** / **Duplicate
Tileset** — see [Copying, Cutting, and Pasting Records](database.md#copying-cutting-and-pasting-records)
in the Database docs. None of these are available on the virtual **Autotiles** row. Cutting a
tileset goes through the same delete confirmation as deleting one outright — other maps may still use
it. Click a row to focus the list, then Ctrl+C/Ctrl+X/Ctrl+V/Ctrl+J copy/cut/paste/duplicate and
Ctrl+Z/Ctrl+Y undo/redo the change, including on-disk writes.

**Deleting a tileset** (the trash icon in the detail pane) now asks with the same confirmation dialog
used everywhere else in the editor, instead of its own custom popup — and deleting is undoable:
**Ctrl+Z** right after confirming writes the tileset straight back into its old slot.

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

- **0** = Ground. The player walks in front of the tile.
- **1--5** = Overhead. The player walks behind the tile (e.g. treetops), in-game and in the Game Simulator.

**Each level has its own colour.** Priority 1 is yellow, 2 orange, 3 pink, 4 purple and 5 blue; the star and number drawn on every tile use that colour, and the priority dropdown shows a matching colour chip next to each value. Priority 0 stays plain white. So you can now tell a level-1 fringe from a level-3 roof at a glance instead of counting numbers. (Levels added by [mods](marketplace.md) reuse the same five colours in order, unless the mod gives its level a colour of its own. A mod can also restyle the markers wholesale — the passage, bush, counter and terrain colours as well as the priority ones.)

Priority controls **player occlusion in-game**, not editor draw order — on the editor canvas tiles are always drawn in layer order (see [Layers](layers.md)). In-game and in the Game Simulator, occlusion is decided **per tile** by its own priority, except that a ground tile on a higher layer covers the tiles beneath it on that square. See [Layers](layers.md#priority-and-layer-order) for details.

### Bush Flag

Toggle the bush flag on or off. When enabled, tiles under a bush overlay appear partially hidden, simulating tall grass or foliage.

### Counter Flag

Toggle the counter flag. This allows interaction across the tile -- useful for things like shop counters where the player talks to an event on the other side.

### Terrain Tag

Pick a terrain tag from the searchable dropdown, then click a tile (or drag-select a region and press **Apply**) to assign it. The list ships with named tags 0–17 (the Pokemon Essentials defaults), and you can filter by name or number. Installed mods can add their own named tags to this same dropdown. Terrain tags are used by events and scripts for terrain-specific behavior, such as changing movement speed on sand versus road, and are read in-game via the engine's terrain tag.

**Grass rustle sound.** When the player steps onto a tile whose terrain tag rustles (such as **Grass**), the engine — not Maker Studio — plays **animation 1** ("Grass rustle") from your project's Animations database. In a vanilla Pokemon Essentials project that animation has no SE timing, so the rustle plays silently; some kits (La Base de Sky, for one) ship a sound in it. To add the sound, give animation 1 an SE timing in the **Animations** tab of the [Database](database.md). The terrain tag itself is working correctly — the sound lives in the animation.

## Custom terrain tags & priorities

The Terrain Tag and Priority dropdowns are not limited to the built-in values. The editor does three extra things for you:

- **Names read from your game.** The Terrain Tag dropdown reads the names your base actually defines — `PBS/terrain_tags.txt`, `GameData::TerrainTag` registrations, `module PBTerrain` constants, and any custom registration helper your project uses (e.g. `ChronoverseManager.register_terrain_tag`) — scanning the core scripts, the loose `Data/Scripts/` tree, and `Plugins/`. A tag your base or a plugin defines (Grass, Ledge, Water, a custom Mirror tag…) shows its real name instead of a bare number. If none are found, the list falls back to the hardcoded 0–17 Pokemon Essentials defaults. Priority has no equivalent in-game registry (RMXP priorities are the positional 0–5 z-levels), so it always starts from the standard 0–5 names.
- **Auto-detected values.** If your game already uses a terrain tag or priority level beyond the built-in list — for example a value a script or an older tool wrote to a tile — the editor scans every tileset and autotile, finds the highest value in use, and raises the dropdown maximum so every value the game actually uses is selectable.
- **Your own labels, and you can rename anything.** In the sidebar's Terrain Tag or Priority mode, click **Add new…** at the bottom of the list to open an inline form — pick an id, type a name, and (for both terrain tags and priorities) choose a marker colour that tints the on-canvas marker and the dropdown chip. Every row is editable: the pencil icon on any row renames it, including built-in defaults and names a [mod](marketplace.md) added — and your label wins. The trash icon appears only on rows you've overridden or added; on a default it reverts to the original name, on a tag you added it removes it. (The right-click context-menu picker stays a plain selector.) The controls are icons, not text characters. Custom labels are saved per-project in `.maker-studio/tile-labels.json` inside your game folder, so they travel with the game.

So you can translate a default name (for example rename "Grass" to "Hierba"), give a colour to a terrain tag the way priorities already have one, and put a name on any auto-detected id.

## Editing Autotile Properties

Autotile passage/priority/terrain are edited separately from regular tilesets. In the Tileset Manager, choose the **Autotiles** entry (shown as `000: Autotiles` at the top of the list) and click **Edit Properties...**. This opens a dedicated grid of every autotile (native slots + named extra autotiles). Editing a property for an autotile applies it to all 48 pattern tiles of that autotile at once.

Autotile properties are **per graphic**: the grid shows each autotile's current values from whichever tileset natively contains it, and saving applies those values to every tileset that uses that graphic (matched by its file name). Tilesets that don't contain the graphic are left untouched, so each tileset's other autotile settings are preserved.

Two conveniences in this view: hovering an autotile shows its **file name** (in the Tile Info
panel and as a tooltip) — the grid is sorted by name, not by slot, so the name is what
identifies it — and **Open Autotiles Folder** in the sidebar opens `Graphics/Autotiles` in your
file manager, for dropping in or editing graphics. Files you add or change there are picked up
automatically; there is no need to reopen the editor.

## Saving

The editor has two buttons:

- **Apply** — writes your changes to `Tilesets.rxdata` and **stays open**, so you can keep adjusting properties. It's greyed out when there is nothing to save. **Ctrl+S** (or **Cmd+S** on macOS) does the same thing.
- **Save** — writes your changes and **closes** the Database window, the way OK works in the Event Editor.

A backup of the original file is created automatically on first save. If you close with unsaved changes, you'll be asked whether to save, discard, or cancel.

### Switching to Another Tileset with Unsaved Changes

Picking a different tileset — from the list, from the Tile Palette's right-click **Edit Properties…**, or from the tileset picker — starts editing that tileset instead. If the one you're leaving has unsaved changes, the editor now asks first: **Discard** throws the changes away and switches, **Keep editing** stays where you are. Use **Apply** before switching if you want to keep them.

After saving, collision and priority overlays update immediately on all open maps that use the tileset — including tiles you placed earlier. This applies to every placed tile: normal tiles, tiles painted from another tileset, extra (named) autotiles, and tiles you rotated or flipped. Rotated and flipped tiles automatically re-apply the new passage in the correct orientation, in the editor and in-game.

## How the Collision Overlay Reads a Stack

**Show Collision** (View menu, or the **Col** toolbar button) now answers each tile exactly like the game
does. It walks the cell from the top layer down and stops at the first tile that either blocks everything
or is a **ground** tile (priority 0) — that tile decides. A tile that is passable but has priority **1 or
higher** (a fringe, a treetop, a roof edge) is *see-through* for collision, so the overlay keeps reading
down and shows the collision of the tile underneath it. Put a passable **priority 0** tile on top instead
and the cell reads as open, because that is what happens in-game.

Bush, counter and terrain-tag markers are not cut off by that ground tile: they show if **any** tile in
the stack carries them, matching how the game answers them.
