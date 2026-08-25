# Tools Guide

## Available Tools

| Tool | Key | Description |
|------|-----|-------------|
| Brush | B | Paint tiles. A translucent preview of the tile(s) you're about to place follows the cursor. Supports multi-tile stamps and adjustable brush size. Shift+click draws a line from the last painted position. Ctrl+drag locks painting to a single axis. |
| Eraser | E | Erase tiles back to empty. Has its own adjustable eraser size. Shift+click draws a line from the last erased position. Ctrl+drag locks erasing to a single axis. |
| Fill | F | Flood-fill a contiguous area with the selected tile — or with the selected multi-tile pattern, repeated across the filled area. |
| Rectangle | R | Click and drag to fill a rectangular area. Tile pattern preview shown while dragging. |
| Eyedropper | I | Pick a tile and its properties from the canvas. |
| Select | S | Click and drag to select an area. Drag the selection to move tiles. Ctrl+drag to add tiles, Shift+drag to remove tiles from selection. |
| Pan | Space (hold) | Pan the viewport. |

> **Switching layers clears the selection** whenever you cross into or out of the Events layer: a tile selection is dropped when you go to Events, and selected events are dropped when you go back to a normal layer.

> **On the Events layer**, only **Brush**, **Eraser**, **Select**, and **Pan** apply — Fill, Rectangle, and Eyedropper are disabled, and brush size has no effect. Select box-selects events for group move/delete. See [Events Editor](events-editor.md#tools-on-the-events-layer).

> **Autotile previews:** when an autotile is selected, the Brush hover preview and the Rectangle drag preview show it fully edge-bordered — corners, edges and interior render just as they will be placed, and the preview connects to matching autotile already on the map. A locked autotile detail part previews as the exact part you picked. The placed result matches the preview.

## Brush Properties

When a tool is active you can adjust per-tile properties before painting. These are set in the Tile Properties panel:

- **Opacity**: 0--255 (how transparent the tile appears).
- **Rotation**: 0--360 degrees.
- **Hue**: 0--360 (color shift).
- **Saturation**: 0--200 (color intensity).
- **Lighting**: -255 to 255 (brightness).
- **Flip H / Flip V**: Flip the tile horizontally or vertically.

Rotation and flipping do not apply to autotiles: an autotile picks its pattern from the tiles around it, so a rotated or mirrored one would no longer match the edge it was chosen for. While an autotile is selected the four transform controls are greyed out ("Autotiles cannot be rotated or flipped — their pattern depends on the surrounding tiles"), and the Edit menu items and Q / W keys do nothing.

### Lock

The lock button in the Tile Properties panel header (an open or closed padlock icon) controls what happens when you pick a different tile.

- **Unlocked** (default): selecting another tile resets all brush properties to defaults — you start each tile fresh.
- **Locked**: the current brush properties stay applied to whatever you pick next, so you can paint many different tiles with the same effect.

The lock state is remembered across sessions. The Eyedropper always applies the picked tile's properties regardless of the lock state — picking with the eyedropper is treated as "give me this exact tile."

### Presets

Click **Presets…** in the Tile Properties panel header to open the preset manager. From here you can:

- **Save current** as a new named preset — useful for combinations you reuse (e.g. "Faded Night", "Sepia").
- **Use** a saved preset on the current brush — the dialog closes after using it (double-clicking a preset does the same).
- **Rename** an existing preset.
- **Overwrite** a preset with the current brush values.
- **Delete** a preset.
- **Export…** your presets — choose a folder and each preset is saved as its own `ms_<name>_<index>_preset.json` file. **If you have presets selected, only those are exported**; with nothing selected the whole library goes out. The button tells you which it is (`Export 3…` when three are selected).
- **Import…** one or more preset files at once — select several files in the picker and they all merge in. Presets merge by name (a matching name is overwritten); files holding a different kind of preset (e.g. shadow presets) are skipped.

A preview canvas shows what the highlighted preset would look like applied to the currently selected tile. Presets are stored per-install (shared across all your projects) and remembered across sessions.

**Selecting several.** Click a preset to select it, **Ctrl+click** to add or remove one, **Shift+click** to take everything between. Clicking a **folder's name** selects the folder and everything inside it (the arrow beside the name folds it instead). With more than one thing selected, the right side swaps to a list of what you picked plus **Move to…**, **Export…** and **Delete** — so you can file, share or clear a handful of presets in one go instead of one at a time.

**Folders.** The **+** button offers *New Preset…* and *New Folder…*. A folder can be empty — it stays until you delete it. Presets go in and out of folders by **dragging** (the whole selection travels if you drag one of the selected ones) or with **Move to…**: drop one on a folder (or on any preset inside it) to file it there, and drop it in the loose area below the folders to take it back out. Dropping one preset on another also reorders. Right-click a folder to rename it or delete it; deleting asks whether the presets inside should go with it or simply move out. Deleting a **selected** folder from the bulk panel always takes its presets with it.

## Brush & Eraser Size

Use the `[` and `]` keys to decrease or increase the brush size while the brush tool is active, or the eraser size while the eraser tool is active. Alt + scroll also adjusts the active tool's size.

## Line Painting (Shift+Click)

With the Brush or Eraser tool active, paint at one position, then hold Shift and paint at another position. A straight line is drawn between the two points using Bresenham's algorithm. The line width matches your current brush or eraser size. This works diagonally as well as on axis-aligned lines. A preview of the line is shown while Shift is held.

## Axis-Locked Painting (Ctrl+Drag)

With the Brush or Eraser tool active, hold Ctrl and drag. The first tile you move off the click position picks the axis (horizontal or vertical, whichever you moved farther on), and all subsequent painting snaps to that single axis. Releasing Ctrl mid-stroke unlocks and resumes free painting. Useful for clean straight lines without needing to reach for Shift+click.

## Custom Shape Brush

A Custom Shape Brush lets you build a reusable brush from a shape, a weighted pool of tiles, and a set of paint properties. It works with the Brush, Eraser, Fill, and Rectangle tools.

### Opening the editor

Open the Brush Editor from either of:

- The **Brush tool's hover popover** in the toolbar (hover the Brush tool button).
- **Tools → Brush Editor…** in the menu bar.

The Brush hover popover also has a **quick switcher** — a dropdown listing your saved brush presets plus **Default (square)** and **Custom (unsaved)**. Pick one to activate it immediately without opening the editor.

Once you've used a custom brush, a compact indicator on the toolbar shows its **name** (its preset name, or "Custom") and works as an **on/off switch** between that brush and the default square brush. Click the toggle (or press **A**) to flip between them — the indicator stays visible, dimmed, while switched off so you can flip back. Click the **✕** to clear the brush entirely and forget it (the indicator disappears, leaving you on the default square brush).

### Building a brush

The editor has three sections:

- **Shape** — pick **Square**, **Circle**, **Diamond**, **Plus**, or **Custom**. The size slider sets the footprint, bounded by the **Min size** / **Max size** you set below it. There is no hard upper limit on size — set Max as large as you like. **Custom** instead gives you a grid: set its Width and Height, then click cells to toggle them on or off and draw any shape you like. Resizing the grid keeps the cells you've already drawn.
- **Tiles** — build a weighted pool of tiles the brush draws from.
  - **Add fixed tile** adds the tile currently selected in the palette.
  - **Add Current Tile** adds a special entry that always uses whatever tile is selected at the moment you paint (you can have at most one of these).
  - You can also add **multi-tile groups** — a small grid of tiles that always paint together, aligned to the map grid. Groups stay coherent within a stroke (no stray tiles breaking them up mid-group), while single tiles scatter independently per cell.
  - Each entry has a **weight**; the percentage shown next to it is the chance that entry is picked, normalized against the others. Remove an entry with its **✕**.
  - Leave the pool empty to simply paint the currently selected tile.
- **Shared Properties** — the visual properties baked into painted tiles: **Hue**, **Saturation**, **Lighting**, **Opacity**, and a **Transform** group (rotate 90° either way, flip horizontal/vertical — ignored for autotiles). These apply to the whole brush. To give a specific tile in the pool its own values, select it and edit — it then carries an override. Click **Clear (follow shared)** on a tile to drop its override and go back to using the shared set. (Priority, terrain tag, and passage are not set here — painted tiles inherit those from the tileset.)

A **live preview** in the editor shows the brush's shape filled with a representative sample of its tile pool and properties, so you can see the result before painting.

Click **Apply** to save the brush, or **Close** to discard your changes.

### Size, Eraser, and other tools

- **Brush size**: drag the size slider in the Brush hover popover, or use `[` / `]`, or **Alt + scroll**. The size is clamped to the brush's Min/Max range. A "Brush N×N" hint flashes on the canvas as you resize.
- **Eraser**: while a custom brush is active, the Eraser uses the same **shape** but keeps its **own size** (separate from the brush size, also clamped to the brush's Min/Max). Resize it the same way — `[` / `]` or Alt+scroll while the Eraser tool is active. An "Eraser N×N" hint flashes. The tile pool is ignored — erasing always clears to empty. (Custom mask shapes have no scalar size, so resizing is a no-op for them.)
- **Fill**: flood-fill matches the clicked region (same tile / autotile) but writes tiles from the brush's weighted pool into each filled cell.
- **Rectangle**: each cell in the dragged rectangle takes a tile from the brush's weighted pool. A seeded preview ghosts the pool tiles across the rect while dragging.

### Saving and sharing

Click **Presets…** in the editor to save the current brush as a named preset, apply a saved one, or **Export** / **Import** brushes as files to share them or move them between projects. The brush's size range travels with it, so an imported brush keeps its own Min/Max. (This works just like the Tile Properties presets — see [Presets](#presets) above.)

## Multi-Tile Stamps

To paint more than one tile at a time, click and drag in the Tile Palette to select a rectangular group of tiles. Press Q or W to rotate the stamp counter-clockwise or clockwise — a stamp that contains any autotile is left as-is, since autotiles cannot be rotated. Dragging near the top or bottom edge of the palette auto-scrolls so you can select tiles outside the visible area.

The whole stamp follows your cursor, exactly as the preview shows it. **Clicking places it in one go** — a house, a tree or a doorway. **Holding the button and dragging keeps painting the pattern as you move**: the pattern goes on repeating from where you first clicked, so moving one tile to the right adds one more column of it rather than jumping a whole stamp-width at a time. A floor, a fence or a striped path fills in continuously. Shift+click draws a line the same way.

**Fill** uses the pattern too: flood-fill an area with a multi-tile selection and the pattern repeats across it, anchored on the tile you clicked. Gaps in the stamp are left untouched.

A stamp does not have to be rectangular: **Ctrl+click** a tile to add it to the current
stamp and **Shift+click** one to take it out, exactly like building a selection on the
map. Tiles you leave out become gaps — painting skips them instead of writing anything
there, so you can stamp an L, a ring, or scattered detail in one stroke. The palette
outlines each chosen tile individually once a stamp has gaps.

The magnifier button in the **Tile Palette** header scrolls the palette to your
selected tile and centres it — handy in tall tilesets after picking a tile with the
eyedropper.

## Switching Tilesets in the Palette

The search box at the top of the Tile Palette filters every tileset by name, graphic file, or id. Type to filter, use the arrow keys and Enter (or click) to pick one, and the palette switches to show that tileset's tiles. Picking a tileset closes the dropdown and removes focus from the search box, so the next keypress goes to your map rather than the search field.

## Autotiles in the Palette

Below the tileset grid, the **Autotiles** section lists every named autotile from your `Graphics/Autotiles/` folder. Click the header to expand or collapse it.

- **Search**: type in the search box above the autotiles grid to filter the list by name (case-insensitive, matches any part of the name). Click the **×** button to clear the search and show every autotile again.
- **Names on hover**: hover over any autotile in the grid and a small tooltip shows its name.
- **Select to paint**: click an autotile to select it for the Brush, Fill, and Rectangle tools.
- **Open detail**: double-click an autotile (or right-click it and choose **Open Autotile**) to open its detail panel, where you can pick an individual piece of the autotile to stamp as a fixed part.
- **Resize the list**: drag the bottom edge of the autotiles grid to make the section taller or shorter. The height you pick is remembered, like your panel layout.
- **Follows your selection**: the section opens on its own whenever an autotile becomes selected — including picking one off the map with the Eyedropper or ALT+click — and collapses again as soon as you select a plain tile.
- **Picked autotiles travel between maps**: the Eyedropper picks an autotile *by name*, so an autotile taken from one map still paints on a map whose tileset holds that graphic in a different slot — or does not hold it at all, in which case it paints as a named autotile. Tileset autotiles go back into their native slot whenever the map's tileset has them.

If your filter matches nothing, the section shows **"No autotiles match."**; if the project has no autotiles at all, it shows **"No autotiles found."**

## Live Tileset Graphic Updates

If you edit a tileset's graphic file in `Graphics/Tilesets/` while the project is open — repaint it in an external editor, replace it, or drop in a new version — the Tile Palette picks up the change and redraws with the new image automatically, no reload needed. (This matches how autotile graphics in `Graphics/Autotiles/` refresh.)

## Selection Tool

- **Click and drag**: Select a rectangular area.
- **Ctrl + click/drag**: Add tiles to the current selection (union).
- **Shift + click/drag**: Remove tiles from the current selection (difference).
- **Click on a selected tile + drag**: Move the selection to a new position.
- **Ctrl+A**: Select all tiles on the current layer.

Selections can be non-rectangular when using Ctrl/Shift. The highlight overlay makes selected cells visible with a gold fill and cell borders.

### Turning a Selection Into Your Brush

Anything already on the map can become your brush. Select it with the Select tool, then **right-click →
Use Selection as Brush** (also **Edit → Use Selection as Brush**, or **Ctrl+B**). The selected tiles
become the current stamp and the Brush tool takes over, so you can immediately paint copies of that
patch anywhere — no hunting for each tile in the palette.

- Non-rectangular selections keep their shape: the cells you left out become gaps the brush skips.
- Tiles from another tileset keep painting from that tileset.
- Named autotiles cannot be carried into a stamp, so those cells come through as gaps. Ordinary
  tileset autotiles are fine — they re-border themselves when you paint them.
- The map selection is released as soon as the brush is made, so you can paint straight away instead
  of being stencilled into the area you copied from.
- The Tile Palette shows no highlight for a brush taken from the map — the tiles are scattered around
  the tileset, and marking them there would point at cells you never chose.

To go back to nothing selected in the palette, use **Ctrl+Shift+D** (**Edit → Clear Tile Selection**).
That drops the stamp and any selected autotile; it does not touch a selection on the map, which is
still **Ctrl+D**.

### Painting Inside a Selection

A selection now **stays** when you switch to another tool and start painting, and it acts as a stencil:
Brush, Eraser, Fill and Rectangle only write inside the selected cells, so you can paint freely over the
edges without touching anything outside. Fill stops at the selection border too — it fills the part of
the matching region that falls inside it. Press **Esc** (or Edit → Deselect) when you want to paint
outside again.

### Dragging Off the Map

For the Rectangle and Select tools, you can start or finish a drag in the empty area beside the map — the selection / rectangle clamps to the nearest border tile instead of being cancelled. The drag also keeps going if your cursor leaves the canvas entirely (e.g. wanders into another panel); release the mouse button anywhere to finish. Moving a selection is unaffected: clicking outside the map always begins a fresh selection rather than triggering a move, even if the clamped border tile happens to fall inside your current selection.

## Undo / Redo with Moved Selections

When you move a selection with the Select tool, the selection marquee now follows the move on Undo / Redo — undoing puts both the tiles and the selection back where they were before the move, and redoing reapplies both. Previously, undoing a move left the selection in its post-move position even though the tiles snapped back.

## Copy and Paste

- Ctrl+C copies the selected area with full tile data (including per-tile properties on extended layers).
- Ctrl+Shift+C copies the selection across all layers at once.
- Ctrl+V enters paste preview mode. Move your cursor to position the paste, then click to commit.
- Ctrl+Shift+V (Paste All Layers) pastes onto the original source layers each tile was copied from, instead of the active layer — same preview-then-click flow.
- Press Escape to cancel the paste preview.
- **Between two open projects:** enable **Edit → Advanced Clipboard → Cross-Project Clipboard** in both windows, then a tile (or all-layer) copy can be pasted into another project's window. Off by default.

## Quick Reference

- Alt + click acts as an eyedropper without switching away from your current tool.
- Right-click opens a context menu.
- Ctrl + B turns the current map selection into your brush.
- Q and W rotate the brush or stamp counter-clockwise and clockwise.
- Ctrl + drag with the Brush or Eraser locks painting to a single axis.

## Audio Browser

**Tools → Audio Browser…**, or the **Audio** button on the toolbar, opens your project's audio
folders for listening — no event needed. Switch between BGM, BGS, ME and SE, search by name, and
play / pause / stop with volume and pitch. Pitch resamples like the game does: raising it plays the
clip higher *and* faster.
