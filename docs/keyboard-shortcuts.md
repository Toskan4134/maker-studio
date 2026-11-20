# Keyboard Shortcuts

All shortcuts are customizable via **Help → Keyboard Shortcuts...**. The defaults are listed below.
While a modal dialog is open, editor shortcuts for the workspace behind it are paused; dialog controls and shortcuts continue to work. **Ctrl+R** (Reset App) and **F12** (Toggle DevTools) remain global and reconfigurable, including in dialogs, text fields, and the simulator. **Escape** and **Ctrl+Enter** continue to close or confirm the topmost dialog. Changed event-command forms ask before closing — see [Events Editor](events-editor.md).

## Tools

| Default Key | Tool |
|-------------|------|
| B | Brush |
| E | Eraser |
| F | Fill |
| R | Rectangle |
| O | Ellipse |
| L | Line |
| I | Eyedropper |
| S | Select |
| Shift+S | Wand |
| Shift+E | Magic Eraser |
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
| Shift + paint | Paint without changing neighbouring autotiles |
| Shift + drag (Rectangle / Ellipse) | Keep width and height equal (square / circle) |
| Ctrl + drag | Lock painting to one axis |

## Eraser

| Default Key | Action |
|-------------|--------|
| [ | Decrease eraser size |
| ] | Increase eraser size |
| Ctrl + drag | Lock erasing to one axis |

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
| Ctrl+R | Reset App — reloads Maker Studio to the Welcome page (your panel layout is kept; choose a project there to reopen it; use **View → Layout → Refresh Layout** to restore the default layout) |
| F12 | Toggle DevTools |

If you press **Ctrl+R** while a dialog or the simulator is open, a native warning explains that unapplied dialog edits will be lost. If maps have unsaved changes, choose **Save All & Reset**, **Discard and Reset**, or **Cancel**. Cancel keeps the editor and drafts open; a failed save prevents the reset. With no unsaved maps, confirm Reset or Cancel.

## Selection

| Default Key | Action |
|-------------|--------|
| Ctrl+A | Select all |
| Ctrl+D | Deselect (tiles, any selected shadow, and selected event[s]) |
| Ctrl+Shift+D | Clear the Tile Palette selection — drops the current stamp and autotile, leaving nothing picked. Does not touch a selection on the map. |
| Ctrl+C | Copy selection (active layer) |
| Ctrl+V | Paste (preview mode -- click to commit) |
| Ctrl+X | Cut selection |
| Ctrl+J | Duplicate — copies the selection and immediately arms the paste preview, so the next click drops the copy. Same idea as Ctrl+C then Ctrl+V, one keypress. Also **Edit → Duplicate** |

On the **Events layer**, Ctrl+C / Ctrl+V / Ctrl+X / Ctrl+J act on all selected events instead — copy, cut, or duplicate whole events. Ctrl+A selects every event on the map. Ctrl+V (and Ctrl+J's arm) shows a preview ghost of the whole group that follows the cursor (cursor = group's top-left); click to drop the copy (Escape to cancel). See [Events Editor](events-editor.md#copying-events).

| Ctrl+Shift+C | Copy all layers |
| Ctrl+Shift+V | Paste in selected layers |
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
| Alt + click | Eyedropper, then switches to Brush (Fill, Rectangle, Ellipse, and Line stay active) |

## Tileset Property Editor

In the editor and tile palette, hold the **Pan** shortcut (Space by default) or the middle mouse button and drag. It works when another control has focus.

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
| Ctrl+J | Duplicate the selected command(s) — pastes a copy right there without disturbing whatever you have copied |
| Ctrl+A | Select every command in the list (the page's final End row is left out) |
| Escape | Cancel the open Command Picker or parameter form — from a parameter form this returns to the picker, on the page you picked from |
| Alt + ↑ | Move command up |
| Alt + ↓ | Move command down |
| ↑ | Previous command (steps over the extra lines of a multi-line Show Text / Comment / Script) |
| ↓ | Next command (same) |

## Event Editor (Page Tabs)

Click a page tab to give the tab strip focus, then these act on the whole page — a separate undo
history from the command list below it.

| Default Key | Action |
|-------------|--------|
| Ctrl+C | Copy page |
| Ctrl+X | Cut page |
| Ctrl+V | Paste page (adds a new page after the tab you're on) |
| Ctrl+J | Clone the current page (same as the **+** tab button / right-click → Clone Page) |
| Ctrl+Z | Undo page edit — now also undoes adding, deleting, or cloning a page |
| Ctrl+Y | Redo page edit |

## Database

Use the configured **Save** shortcut, **Ctrl+S** by default, to apply changes in the active XP, Animations, Common Events, or Tileset editor.

With a tab focused, press **Alt+Shift+Left** or **Alt+Shift+Right** to move it one position.

In the Actors, Classes, Skills, Items, Weapons, Armors, Enemies, Troops, and States lists, focus a record and press **F4** or **F5** to select the previous or next record. The configured Copy, Cut, Paste, Duplicate, and Delete shortcuts work while the list has focus. The Undo and Redo shortcuts, **Ctrl+Z** and **Ctrl+Y** by default, also work in the form fields of the XP database tabs, including System. Search and the event command editor keep their own shortcuts.

In Tilesets, Common Events, Animations, Switches, and Variables, click a row to give it focus, then these act on the whole record — a separate
undo history per list. See [Database](database.md#copying-cutting-and-pasting-records).

| Default Key | Action |
|-------------|--------|
| Ctrl+C | Copy the selected record (or name, in Switches/Variables) |
| Ctrl+X | Cut — copies, then removes. Blanks the slot on Common Events/Animations instead of renumbering; opens the delete confirmation on Tilesets |
| Ctrl+V | Paste (Replace) over the selected record |
| Ctrl+J | Duplicate the selected record — appends a copy to a new slot at the end of the list |
| Ctrl+Z | Undo the last edit in that list — paste, cut, replace, duplicate, add, delete, and Change Maximum… all count, including on-disk Tileset writes |
| Ctrl+Y | Redo it |

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
| ← / → (sequence divider focused) | Resize the route sequence panel |

## Move Route Editor (Draw path…)

These only apply while the visual route editor is open, which is why they can use the bare arrow keys without clashing with anything else. They are all rebindable — see [Set Move Route](events-editor.md#draw-path--the-visual-route-editor).

| Default Key | Action |
|-------------|--------|
| ↑ / ↓ / ← / → | Add a step in that direction |
| Ctrl + ↑ / ↓ / ← / → | Add a Turn in that direction |
| Backspace | Remove the last step |
| Delete | Remove the selected steps |
| Ctrl+Z / Ctrl+Y | Undo / redo any edit in the path editor (a whole drag stroke is one undo step) |

The **Controls** button in the editor's toolbar lists every control.

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
| Ctrl+D | Deselect event(s) |
| Escape | Cancel an active operation; with the Events list focused, deselect events and clear their map highlight |
| F2 | Rename the one selected event |

F2 and Escape apply while the Events list has focus; F2 does nothing when several events are selected or an editable field has focus. Escape clears the event selection and its map highlight. The panel's **Deselect** button performs the same action.

On the **Events layer**, the **Select** tool box-selects events: drag a marquee (Ctrl+drag adds, Shift+drag removes), drag the selection to move the group, Delete removes them all. See [Events Editor](events-editor.md#selecting-and-moving-events).

## Maps Panel (Map List)

| Default Key | Action |
|-------------|--------|
| Ctrl+C | Copy the selected map |
| Ctrl+X | Cut the selected map (asks for confirmation) |
| Ctrl+V | Paste the last tiles or map you copied or cut |
| Ctrl+J | Duplicate the selected map (same as right-click → Duplicate Map) |
| Delete | Delete the selected map (asks for confirmation, same as right-click → Delete Map) |
| F2 | Rename the one selected map inline, or the active map when no map row is selected |

In the Maps panel, **Ctrl+click** toggles rows and **Shift+click** selects the visible range. Drag a selected row to move all selected roots together with their descendants. Delete opens choices to keep descendants in the deleted maps' positions or delete them too; the confirmation warns about unsaved open maps. F2 renames the only selected map, or the active map when no map row is selected. It does nothing with multiple maps selected, when there is no selection and no active map, or while the filter field is being edited. Ctrl+C and Ctrl+X act on the single selected map, or the active map when no row is selected. The context menu offers the same **Copy Map** and **Cut Map** actions. **Paste Map** in that menu always looks for a whole map, even after a more recent tile copy. See [Map Management](map-management.md#copying-a-map-between-projects).


## Layer Panel (Layer List)

Click a row in the Layer Panel to give it focus. **Ctrl/Meta+click** toggles rows and **Shift+click** selects the visible range without changing the active layer. The selected tile rows are edited together by the canvas tools; one stroke has one Undo.

| Default Key | Action |
|-------------|--------|
| Ctrl+C | Copy the active layer, tiles and per-tile settings included (same as right-click → Copy Layer) |
| Ctrl+X | Cut the active layer — copies it, then clears it (same as right-click → Cut Layer) |
| Ctrl+V | Paste the copied layer — always asks whether to replace the active layer or paste into a new layer (same as right-click → Paste Layer) |
| Ctrl+J | Duplicate the active layer, tiles included — works on native layers too, and the copy always lands as a new extended layer (same as right-click → Duplicate Layer) |
| Delete | Delete selected extended tile layers when every selected row is removable |
| F2 | Rename the one selected layer inline |

These fire only while the Layer Panel has focus, so they don't conflict with copying tiles on the
canvas. F2 does nothing with multiple rows selected or while an editable field has focus. Delete is
available only when all selected rows are removable extended tile layers. Works on any layer,
native included — a copy, cut, or duplicate that has nowhere else to go lands in a new extended
layer, since a native layer is a fixed slot. See [Layers](layers.md#layer-panel).

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
