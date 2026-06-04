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
| 1--9 | Select layer by number |
| V | Select Events layer |
| ↑ | Previous layer (skips shadows) |
| ↓ | Next layer (skips shadows) |
| Alt+1--9 | Toggle layer visibility |
| Alt+V | Toggle Events layer visibility |

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

## Selection

| Default Key | Action |
|-------------|--------|
| Ctrl+A | Select all |
| Ctrl+D | Deselect (tiles, any selected shadow, and selected event[s]) |
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
| Alt + ↑ | Move command up |
| Alt + ↓ | Move command down |
| ↑ | Previous command |
| ↓ | Next command |

## Event Editor (Move Route)

| Default Key | Action |
|-------------|--------|
| Ctrl+Z | Undo move route edit |
| Ctrl+Y | Redo move route edit |
| Delete | Delete move command |

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
