# Keyboard Shortcuts

All shortcuts are customizable via **Help → Keyboard Shortcuts...**. The defaults are listed below.

## Tools

| Default Key | Tool |
|-------------|------|
| B | Brush |
| E | Eraser |
| F | Fill |
| R | Rectangle |
| I | Eyedropper |
| S | Select |
| Space (hold) | Pan mode |

## View Toggles

| Default Key | Toggle |
|-------------|--------|
| G | Grid |
| C | Collision overlay |
| D | Dim mode |

## Brush

| Default Key | Action |
|-------------|--------|
| [ | Decrease brush/eraser size |
| ] | Increase brush/eraser size |
| Alt + scroll | Adjust brush/eraser size |
| Q | Rotate brush counter-clockwise |
| W | Rotate brush clockwise |
| A | Toggle custom brush — switch between your last-used [custom brush](tools.md#custom-shape-brush) and the default square brush |
| Ctrl + B | [Use the map selection as your brush](tools.md#turning-a-selection-into-your-brush) |
| Shift + click | Draw line from last painted position |

## Eraser

| Default Key | Action |
|-------------|--------|
| [ | Decrease eraser size |
| ] | Increase eraser size |
| Shift + click | Draw line from last erased position |

## Layers

| Default Key | Action |
|-------------|--------|
| 1--9 | Select the 1st–9th tile layer (counted top to bottom, skipping the Shadows/Fog/Panorama group rows — so **4** always selects the layer shown as "Layer 4") |
| V | Select Events layer |
| ↑ | Previous layer (skips shadows) |
| ↓ | Next layer (skips shadows) |
| Alt+1--9 | Toggle layer visibility |
| Alt+V | Toggle Events layer visibility |
| Alt + click a layer's eye icon | Show only that layer; Alt+click again restores the others (see [Layers](layers.md#layer-panel)) |

## Tileset Editor

Only while the Tileset Editor (Database → Tilesets) is open, and only in the **Priority** and
**Terrain Tag** modes.

| Default Key | Action |
|-------------|--------|
| 1--9, 0 | Pick the 1st–10th value in the list — **1** is priority / terrain tag **0**, **2** is 1, and so on, with **0** as the tenth |

These share the digits with the layer shortcuts on purpose: the two are never active at the same
time, and whichever surface is open owns them. A digit past the end of the list (a tileset has at
most six priorities) simply does nothing. All ten are rebindable in Help → Keyboard Shortcuts under
*Tileset Editor*.

## Zoom

| Default Key | Action |
|-------------|--------|
| + | Zoom in |
| - | Zoom out |
| Ctrl + scroll | Zoom |

## File

| Default Key | Action |
|-------------|--------|
| Ctrl+S | Save current map |
| Ctrl+Shift+S | Save all open maps |
| Ctrl+Alt+S | Create shadow from selection |
| Ctrl+Z | Undo |
| Ctrl+Y | Redo |
| Ctrl+Enter | Run game |
| Ctrl+R | Reset App — reloads the editor (your panel layout is kept; to restore the default layout use **View → Layout → Refresh Layout** instead) |

## Selection

| Default Key | Action |
|-------------|--------|
| Ctrl+A | Select all |
| Ctrl+D | Deselect (tiles, any selected shadow, and selected event[s]) |
| Ctrl+Shift+D | Clear the Tile Palette selection — drops the current stamp and autotile, leaving nothing picked. Does not touch a selection on the map. |
| Ctrl+C | Copy selection (active layer) |
| Ctrl+V | Paste (preview mode -- click to commit) |
| Ctrl+X | Cut selection |

On the **Events layer**, Ctrl+C / Ctrl+V / Ctrl+X act on the selected event instead — copy or cut a whole event. Ctrl+V shows a preview ghost that follows the cursor; click to drop the copy (Escape to cancel). See [Events Editor](events-editor.md#copying-events).

| Ctrl+Shift+C | Copy all layers |
| Ctrl+Shift+V | Paste to original layers |
| Ctrl+Shift+X | Cut all layers |
| Ctrl + click/drag | Add tiles to selection |
| Shift + click/drag | Remove tiles from selection |
| Delete | Delete selection |
| Escape | Cancel selection / cancel paste preview |

## Navigation

| Key | Action |
|-----|--------|
| Space (hold) + drag | Pan |
| Middle-click drag | Pan |
| Scroll wheel | Pan viewport |
| Shift + scroll | Pan horizontally |
| Ctrl + scroll | Zoom |
| Alt + click | Eyedropper (without switching tool) |

## Tileset Property Editor

| Default Key | Action |
|-------------|--------|
| Ctrl+S | Save tileset (keeps the editor open) |
| Ctrl+Z | Undo tileset edit |
| Ctrl+Y | Redo tileset edit |
| Ctrl+A | Select all tiles |
| Escape | Deselect tiles |

## Event Editor (Command List)

| Default Key | Action |
|-------------|--------|
| Space | Edit selected command |
| Delete | Delete command |
| Insert | Insert new command |
| Ctrl+C | Copy command |
| Ctrl+V | Paste command |
| Ctrl+X | Cut command |
| Ctrl+A | Select every command in the list (the page's final End row is left out) |
| Escape | Cancel the open Command Picker or parameter form — from a parameter form this returns to the picker, on the page you picked from |
| Alt + ↑ | Move command up |
| Alt + ↓ | Move command down |
| ↑ | Previous command (steps over the extra lines of a multi-line Show Text / Comment / Script) |
| ↓ | Next command (same) |

## Event Editor (Move Route)

The move-action list in **Set Move Route** supports the same editing keys as the main command list. Click selects a single action; **Shift+click** extends the selection and **Ctrl+click** toggles — copy, cut, delete, and drag all act on the whole selection.

| Default Key | Action |
|-------------|--------|
| Space / Enter | Edit the selected move action |
| Ctrl+C / Ctrl+V / Ctrl+X | Copy / Paste / Cut move actions (separate clipboard from event commands) |
| Ctrl+Z | Undo move route edit |
| Ctrl+Y | Redo move route edit |
| Delete | Delete move command |
| ↑ / ↓ | Previous / next move action |
| Alt + ↑ / ↓ | Move the selected action up / down |

## Move Route Editor (Draw path…)

These only apply while the visual route editor is open, which is why they can use the bare arrow keys without clashing with anything else. They are all rebindable — see [Set Move Route](events-editor.md#draw-path--the-visual-route-editor).

| Default Key | Action |
|-------------|--------|
| ↑ / ↓ / ← / → | Add a step in that direction |
| Ctrl + ↑ / ↓ / ← / → | Add a Turn in that direction |
| Backspace | Undo the last step |
| Shift + ← | Undo the last step (alternative) |
| Shift + → | Redo the last undone step |
| Delete | Remove the selected steps |
| Ctrl+Z / Ctrl+Y | Undo / redo any edit in the path editor |

## Scripts Editor

| Default Key | Action |
|-------------|--------|
| Ctrl+F | Find (and replace) in the current script |
| Ctrl+Shift+F | Search across all scripts |
| Ctrl+S | Save all scripts back to Scripts.rxdata |

See the [Scripts editor guide](scripts.md#finding-things) for details.

## Events Panel

| Default Key | Action |
|-------------|--------|
| Delete | Delete selected event (or all box-selected events) |
| Ctrl+D / Escape | Deselect event(s) |

On the **Events layer**, the **Select** tool box-selects events: drag a marquee (Ctrl+drag adds, Shift+drag removes), drag the selection to move the group, Delete removes them all. See [Events Editor](events-editor.md#selecting-and-moving-events).

## Game Simulator

| Default Key | Action |
|-------------|--------|
| Space | Play / Pause |
| . | Step one frame |
| R | Restart |
| Esc | Close simulator |
| C | OK / action button |
| X | Cancel |
| Y | Toggle camera mode |
| Arrow keys | Move player (map simulation) |

## Tabs

| Key | Action |
|-----|--------|
| Alt + click tab | Close tab |
| Middle-click tab | Close tab |
| Double-click preview tab | Promote to permanent tab |

## Customizing Shortcuts

Open **Help → Keyboard Shortcuts...** to rebind any action. Click a row, then press the new key combination. If the key is already in use, you can swap or cancel.

Context-specific shortcuts (Tileset, Event Editor) share some default keys with global shortcuts (e.g. Ctrl+Z for undo). These work based on which panel has focus. Rebinding a context-specific shortcut only affects that context.

## Mod Shortcuts

Installed mods can add their own menu items with keyboard shortcuts. These appear in the Keyboard Shortcuts dialog under a **Mods** section, and you can rebind them just like built-in shortcuts. Conflicts between a mod shortcut and a built-in (or another mod) are detected when you assign the key, so you can swap or cancel. Your custom mod-shortcut bindings persist across sessions, and **Reset All** restores them to the mod's defaults along with everything else.
