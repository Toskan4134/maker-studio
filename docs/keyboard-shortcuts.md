# Keyboard Shortcuts

Use the keyboard button in the workspace toolbar, panels, and dialogs to see the shortcuts for that surface and their current assignments. Available commands follow the active editor mode. The list opens next to the button and can extend beyond a narrow panel.

Open **Help → Keyboard Shortcuts…** to see and reassign the built-in actions. Search by action, category, or current shortcut. `Ctrl` in the tables also accepts `Command` on macOS for configurable actions. Fixed controls and mouse gestures are marked in the sections where they apply.

When a dialog is open, its shortcuts take over from the workspace. **Reset App** (Ctrl+R) and **Toggle DevTools** (F12) are available in dialogs, text fields, and the simulator. **Close Dialog** (Escape) is reassignable under **App** and closes the topmost dialog or overlay. **Ctrl/Command+Enter** is a fixed shortcut that confirms the topmost dialog when it offers a confirmation action. Plain Enter can submit a single-line input dialog and inserts a newline in a multiline field. Event command forms with unsaved edits ask before closing. See [Events Editor](events-editor.md).

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
| Shift+C | Toggle the cell overlay for events |

## Brush

| Default Key | Action |
|-------------|--------|
| [ | Decrease brush/eraser size |
| ] | Increase brush/eraser size |
| Alt + scroll | Adjust brush/eraser size (fixed gesture) |
| Q | Rotate brush counter-clockwise |
| W | Rotate brush clockwise |
| A | Toggle custom brush — switch between your last-used [custom brush](tools.md#custom-shape-brush) and the default square brush |
| Ctrl + B | [Use the map selection as your brush](tools.md#turning-a-selection-into-your-brush) |
| Shift + paint | Paint without changing neighbouring autotiles (fixed gesture) |
| Shift + drag (Rectangle / Ellipse) | Keep width and height equal (fixed gesture) |
| Ctrl + drag | Lock painting to one axis (fixed gesture) |

## Eraser

| Default Key | Action |
|-------------|--------|
| [ | Decrease eraser size |
| ] | Increase eraser size |
| Ctrl + drag | Lock erasing to one axis (fixed gesture) |

## Layers

| Default Key | Action |
|-------------|--------|
| 1–9 | Select the 1st–9th tile layer, counting from the bottom |
| V | Select Events layer |
| ↑ / ↓ | Select the previous / next tile layer, wrapping at either end |
| Alt+1–9 | Toggle visibility for the numbered layer indices (1 for index 0 through 9 for index 8) |
| Alt+V | Toggle Events layer visibility |
| Alt + click a layer's eye icon | Show only that layer. Alt+click again restores the others (fixed gesture). |

Tile layer navigation skips Events, Shadows, Fog, Panorama, and custom graphic groups. Extended layer indices can have gaps after deletion, so a number key selects by layer order while its Alt combination uses the layer index. See [Layers](layers.md#layer-panel).

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

## Creating and reopening

| Shortcut | Action |
|---|---|
| Ctrl+T | Open the New Map dialog at the project root |
| Ctrl+Shift+T | Reopen the most recently closed map in this project session. Repeat to reopen earlier maps. |
| Ctrl+W | Close the active map tab. Prompts if there are unsaved changes. |
| Ctrl+Tab / Ctrl+Shift+Tab | Switch to the next / previous open map tab, wrapping at either end. |
| Ctrl+N | Add an extended layer to the active map |

**Ctrl+Tab / Ctrl+Shift+Tab** cycle through event pages, displayed Database sections, or open tabs in a focused Autotile Detail panel. In the Database this includes revealed hidden tabs and works from focused fields. **Close Dialog** (default **Escape**) closes the Event Editor or Database. **Ctrl+W** closes the active autotile tab while the panel has focus.

## Zoom

| Default Key | Action |
|-------------|--------|
| + | Zoom in |
| - | Zoom out |
| Ctrl + scroll | Zoom (fixed gesture) |
| Ctrl+0 | Reset the active map zoom to 100% |

The default `+` shortcut matches a plus keypress without Shift. If your layout uses Shift to type `+`, use numpad `+`, Ctrl+scroll, or reassign **Zoom In**.

## File

| Default Key | Action |
|-------------|--------|
| Ctrl+S | Save current map |
| Ctrl+Shift+S | Save all open maps with unsaved changes |
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
| Ctrl+C | Copy selected cells from the selected tile layers |
| Ctrl+V | Preview paste on the active tile layer. Click to place it. |
| Ctrl+X | Cut selected cells from the selected tile layers |
| Ctrl+J | Duplicate the selection and start a paste preview. Click to place the copy. |
| Ctrl+Shift+C | Copy all layers |
| Ctrl+Shift+V | Paste in selected layers |
| Ctrl+Shift+X | Cut all layers |
| Ctrl + click/drag | Add tiles to selection (fixed gesture) |
| Shift + click/drag | Remove tiles from selection (fixed gesture) |
| Delete | Clear the selected cells on the selected tile layers |
| Escape | Cancel a shape or selection drag, cancel a paste preview, or clear the selection |

**Cancel** is reassignable. Escape also works as a fixed fallback during an active shape or selection drag. If the clipboard contains several source layers, Paste uses the one that matches the active layer’s index. See [Tools](tools.md#copy-and-paste).

On the **Events layer**, Copy, Paste, Cut, and Duplicate work on selected events. Select All selects every event on the map. Paste and Duplicate show a preview that follows the cursor from the group's upper-left corner. Click to place it or use Cancel to dismiss it. See [Events Editor](events-editor.md#copying-events).

## Navigation

The **Pan (Hold)** key is reassignable. The map canvas uses the base key of the assignment and ignores its modifiers. If you change it while a map canvas is already open, reopen that map to use the new key on its canvas. The Tile Palette and Tileset Editor use the full assignment. The other gestures in this table are fixed.

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
| Ctrl+D | Deselect tiles |

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
| Ctrl+Z / Ctrl+Y | Undo / redo command edits |
| Escape | Close the Command Picker or parameter form via **Close Dialog**. When inserting a new command, closing the form returns to the picker. |
| Alt + ↑ | Move command up |
| Alt + ↓ | Move command down |
| ↑ | Previous command (steps over the extra lines of a multi-line Show Text / Comment / Script) |
| ↓ | Next command (same) |
| Shift+↑ / Shift+↓ | Extend the selection to the previous / next command (fixed) |

## Event Editor (Page Tabs)

Click a page tab to give the tab strip focus, then these act on the whole page — a separate undo
history from the command list below it.

| Default Key | Action |
|-------------|--------|
| Ctrl+C | Copy page |
| Ctrl+X | Cut page |
| Ctrl+V | Paste page (adds a new page after the tab you're on) |
| Ctrl+J | Clone the current page (same as the **+** tab button / right-click → Clone Page) |
| Ctrl+Z | Undo a page edit, including adding, deleting, or cloning a page |
| Ctrl+Y | Redo page edit |

## Database

Use the configured **Save** shortcut, **Ctrl+S** by default, to apply changes in the active XP, Animations, Common Events, or Tileset editor.

With a tab focused, press **Alt+Shift+Left** or **Alt+Shift+Right** to move it one position. These controls are fixed.

In the Actors, Classes, Skills, Items, Weapons, Armors, Enemies, Troops, and States lists, **F4** and **F5** are fixed controls for the previous and next record while a record list has focus. On Windows, WebView2 can intercept F5 before it reaches the focused list. Click a record to select it if that happens. The configured Copy, Cut, Paste, Duplicate, and Delete shortcuts work while the list has focus. The Undo and Redo shortcuts, **Ctrl+Z** and **Ctrl+Y** by default, also work in the form fields of the XP database tabs, including System. Search and the event command editor keep their own shortcuts.

In Tilesets, Common Events, Animations, Switches, and Variables, click a row to give it focus, then these act on the whole record — a separate
undo history per list. See [Database](database.md#copying-cutting-and-pasting-records).

| Default Key | Action |
|-------------|--------|
| Ctrl+C | Copy the selected record (or name, in Switches/Variables) |
| Ctrl+X | Cut — copies, then removes. Blanks the slot on Common Events/Animations instead of renumbering; opens the delete confirmation on Tilesets |
| Ctrl+V | Paste (Replace) over the selected record |
| Ctrl+J | Duplicate the selected record — appends a copy to a new slot at the end of the list |
| Ctrl+Z | Undo the last edit in that list — paste, cut, replace, duplicate, add, delete, and Change Maximum… all count, including on-disk Tileset writes |
| Ctrl+Y | Redo the last edit in that list |

Outside the Animations record list, the animation editor uses Copy, Paste, Cut, Undo, and Redo for cells and frames. Use **Delete** or the fixed **Backspace** fallback to remove the selected cell. In the Switch/Variable picker, **↑ / ↓** select the previous or next visible entry.

## Event Editor (Move Route)

In **Set Move Route**, click to select one move action. **Shift+click** extends the selection and **Ctrl+click** toggles a row. Copy, Cut, Delete, and drag act on the selected actions.

| Default Key | Action |
|-------------|--------|
| Space / Enter | Edit the selected move action. Space is the default for **Edit Command**. Enter is a fixed alternative. |
| Ctrl+C / Ctrl+V / Ctrl+X | Copy / Paste / Cut move actions (separate clipboard from event commands) |
| Ctrl+Z | Undo move route edit |
| Ctrl+Y | Redo move route edit |
| Delete | Delete move command |
| ↑ / ↓ | Previous / next move action |
| Alt + ↑ / ↓ | Move the selected action up / down |
| ← / → (sequence divider focused) | Resize the route sequence panel (fixed) |

## Move Route Editor (Draw path…)

These only apply while the visual route editor is open, which is why they can use the bare arrow keys without clashing with anything else. They are all rebindable — see [Set Move Route](events-editor.md#draw-path--the-visual-route-editor).

| Default Key | Action |
|-------------|--------|
| ↑ / ↓ / ← / → | Add a step in that direction |
| Ctrl + ↑ / ↓ / ← / → | Add a Turn in that direction |
| Backspace | Remove the last step |
| Space (hold) + drag | Pan the map using **Pan (Hold)** |
| Delete | Remove the selected steps |
| Ctrl+Z / Ctrl+Y | Undo / redo any edit in the path editor (a whole drag stroke is one undo step) |

The **Controls** button in the editor's toolbar lists every control.

## Scripts Editor

| Default Key | Action |
|-------------|--------|
| Ctrl+F | Find (and replace) in the current script |
| Ctrl+Shift+F | Search across all scripts |
| Ctrl+S | Save the current script source. For an archive source, this writes to `Scripts.rxdata`. |
| Ctrl+Z / Ctrl+Y | Undo / redo inside the code editor |

Escape closes the cross-script search panel while it has focus. With in-script search open, CodeMirror uses fixed **F3 / Shift+F3** for the next or previous result and Escape to dismiss the search. **Tab / Shift+Tab** change indentation in the code editor. See the [Scripts editor guide](scripts.md#finding-things).

## Events Panel

| Default Key | Action |
|-------------|--------|
| Delete | Delete selected event (or all box-selected events) |
| Ctrl+D | Deselect event(s) |
| Escape | Clear the event selection and its map highlight with the Events list focused (fixed) |
| F2 | Rename the one selected event |

F2 requires a single selected event and focus on the list outside an editable field. Use the panel’s **Deselect** button to clear the selection with the mouse.

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

These actions use the Layer Panel’s selection or active layer while it has focus. Clipboard actions work on native and extended tile layers. F2 requires one selected tile layer and a noneditable focus target. Delete requires all selected rows to be removable extended tile layers. The focused list also handles Shift+↑ / Shift+↓ to extend a range of visible rows. See [Layers](layers.md#layer-panel).

## Game Simulator

| Default Key | Action |
|-------------|--------|
| Space | Play / Pause |
| . | Step one frame |
| R | Restart |
| Escape | Close the simulator via **Close Dialog**. If simulator settings are open, the first press closes settings. |
| C | OK / action button |
| X | Cancel |
| Y | Toggle camera mode |
| Arrow keys | Move the player in map simulation. Up and Down also navigate choices or adjust numeric input. |

## Tabs

In Snippets and Mods, **Next Tab** (Ctrl+Tab) and **Previous Tab** (Ctrl+Shift+Tab) use the same assignments as map tabs. In Snippets, fixed **← / →** also switch libraries when a library tab has focus. Map tab gestures are fixed.

| Key | Action |
|-----|--------|
| Alt + click tab | Close tab |
| Middle-click tab | Close tab |
| Double-click preview tab | Promote to permanent tab |

## Other fixed controls

| Surface | Keys and actions |
|---------|------------------|
| Welcome page | **← / →** switch focused tabs. **Alt+↑ / Alt+↓** reorder a focused project in a reorderable list. |
| App Settings | In the Supporter feature list, **↑ / ↓** move between features. **Home / End** jump to the first or last feature. |
| Tile Palette | In the tileset search, **↑ / ↓** move the highlight, **Enter** chooses it, and **Escape** closes the list. |
| Graphic picker | In the file list, **↑ / ↓** move between graphics. In the preview, **Space+drag** pans and **Ctrl+scroll** zooms. |
| Location picker | **Space+drag**, **Shift+drag**, and dragging with the middle button pan. **Ctrl+scroll** zooms. |
| Event text codes | With suggestions open, **↑ / ↓** choose a suggestion, **Enter / Tab** insert it, and **Escape** dismisses the list. |
| Inline fields | Where an inline editor supports these keys, **Enter** commits and **Escape** cancels the current edit. |
| Git dialog | On a graph column divider, **← / →** resize it and **Shift** makes a larger adjustment. The history divider uses **↑ / ↓ / Home / End**. **Shift+F10** or the Menu key opens the menu for a committed file. |
| Git image preview | **Home** resets the view, **+ / −** zoom, and the arrow keys pan. |
| Map canvas diagnostics | **Ctrl+Alt+Shift+P** toggles render diagnostics while the map canvas is visible and no modal is open. |

## Customizing Shortcuts

Click an action in **Help → Keyboard Shortcuts…** and press the new combination. A conflict offers **Keep** to share the new key, **Swap** to move the other assignments to your previous key, and **Cancel** to restore your previous assignment. If other actions still use the previous key, **Update All** moves those actions together and **Only This** leaves their assignments in place.

Separate actions can share a key when their contexts differ. For example, `1` selects a map layer or picks a tileset value. Shared actions such as **Undo** have one assignment reused by every editor that handles them. Use the reset button on a row to restore its default, or **Reset All** to restore all built-in and mod menu defaults. Assignments persist across sessions.

## Mod Shortcuts

Installed mods can add menu shortcuts. Reassign them under **Mods** in **Keyboard Shortcuts**, using the same conflict options as built-in actions. A mod can also define local controls for its panel or dialog. Look for those in the keyboard button’s contextual help.
