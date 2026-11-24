# Database

The **Database** window gathers your project's data editors into one tabbed window, like RPG Maker XP. Open it from the **Database** button on the toolbar or **Tools → Database…**. Switches, Variables, and Tilesets each have their own tab inside the window.

Tabs:

- **Tilesets**, **Switches**, **Variables** — the existing managers, embedded right in the window.
- **Common Events** — reusable command scripts (see below).
- **Animations** — battle/overworld animations (see below).
- **Actors**, **Classes**, **Skills**, **Items**, **Weapons**, **Armors**, **Enemies**, **Troops**, **States**, and **System** edit the standard RPG Maker XP files directly.

Closing and reopening the window brings you back to the tab you were on, with the same entry selected in each tab (until you close the app). In the Tilesets tab, a tileset you changed and applied or saved also reopens scrolled to where it was when you applied or saved it; one you only looked at starts at the top.

> Use **Apply** or the configured **Save** shortcut (**Ctrl+S** by default) to apply changes in the standard XP tabs, Animations, Common Events, or the Tileset editor. Switching tabs or closing the window while you have unsaved changes asks you to confirm first — and in the Tilesets tab, so does switching to a different tileset. Every save backs up the original `.rxdata` to a `map-backups` folder beside it.

## Editing RPG Maker XP records

The current tab stays visible until the requested tab is ready.

The default order starts with **Tilesets**, **Switches**, **Variables**, **Animations**, and **Common Events**.

Drag any tab left or right to reorder it. Hold it near either edge to scroll the row during the drag. With a tab focused, press **Alt+Shift+Left** or **Alt+Shift+Right** to move it one position. Maker Studio remembers the order in your local profile across projects.

Right-click a tab and choose **Hide Tab** to remove it from the row. While any tab is hidden, an eye-off tab with the hidden count appears at the right end of the row; click it to show the hidden tabs dimmed in their usual places, and click again to put them away. You can still open a hidden tab from there. Right-click a hidden tab and choose **Show Tab** to restore it. Hidden tabs are remembered like the order.

Find records by name or ID in the sidebar. The list-based XP editors share the searchable record list with Common Events and Animations. Related panels appear alongside one another when there is room and stack when the window narrows. Change its fields, then click **Apply** to write that tab’s changes to the project. Open **Actions** next to the search field or right-click a row to copy, cut, paste, duplicate, copy multiple records, clear, or delete. **Clear** asks before restoring defaults. To copy a block, start at the first record, choose **Copy Records…**, and enter the number of records. Empty slots are skipped. Paste starts at the selected ID and fills the available slots. **Add** appends one slot. **Change Maximum…** adds slots at the end or removes slots above the new limit. Use **Undo** or **Redo** in the footer before applying your changes. The configured record shortcuts work while the list has focus. Undo and redo also work in the form fields. Search and the event command editor use their own shortcuts.

Open **System** to edit the starting party, elements, terms, graphics, music, and sound effects. Graphics keep their preview frames visible while empty or loading. **Terminology** sets the labels the game uses for stats, currency, equipment slots, and menu and battle commands. These editors work on standard RPG Maker XP records, including those in Essentials projects with standard `.rxdata` files.

Choose **Delete** or press **Delete** with the record list focused. The confirmation opens while Maker Studio checks references to the record. Choose a replacement if any references use its ID. The deletion stays in your draft and can be undone or redone. Deleting a record immediately closes the gap in the list, and **Add** uses the next ID in that order. **Change Maximum…** is unavailable while deletions are pending. Save map edits and close event editors before clicking **Apply**. Applying saves the draft and its deletions together, closes ID gaps, and updates native references in the database, maps, common events, and troop events. References that already pointed at an empty or missing ID stay broken rather than landing on another record. Changed `.rxdata` files are backed up under `.maker-studio/database-backups`. Review hard-coded IDs in Ruby scripts manually.

In **Actors**, use the parameter chart to see how a stat changes across levels. Edit one level at a time or generate a growth curve for that stat. **EXP Curve** lists the total EXP and the EXP to the next level from the initial to the final level. The graphics controls preview project assets. **Classes** and **Enemies** use tables for skill learnings and actions. An enemy's action table shows only the conditions that apply, or **Always**; select an action to edit it and its conditions below, with the turn entered as `A + B × n`. Where an effect can add or remove states, both choices appear in the same state table.

Use the **Troops** toolbar to switch between **Formation** and **Battle Events**. In Formation, select an enemy in the members inspector to edit its settings or click the preview to place its battler. **Arrange** spaces all members evenly in a row, and **Auto-name** next to the name builds it from the members, such as `Ghost*2, Basilisk`. If a battle event targets that member or depends on its slot, review the target before removing the member. In Battle Events, select a numbered page. Use the arrows to scroll the page bar, **+** to add a page, or **×** to delete the selected page. Each troop keeps at least one page. **Battle Test** is available from both views and shares the background selected in Formation.

In **Troops**, open **Battle Test** to preview the troop and the battleback shared with Formation. The four party slots appear above the preview. Use the **+** in the next empty slot to add a member and the red **Remove** button to remove the selected member. Choose one to four distinct actors and select a slot to edit that actor’s level and equipment. Like RPG Maker XP, it writes the `BT_*.rxdata` battle files into the project's `Data` folder, using the current troop draft and the saved database, and runs the game from there. Battle Test requires the game’s scripts and executable to support XP battle-test mode. The launcher uses the project executable on Windows, Wine on macOS, and a native `Game_Linux` executable or Wine on Linux, with Proton available as a fallback.

In **Animations** and **Common Events**, **Actions** beside search opens the same menu as right-clicking a record. The footer arrows undo and redo changes to the record list, such as adding, cutting, or duplicating a record.

## Deleting and Renumbering Tilesets

In the Tilesets tab, **Delete** and **Cut** act on every tileset you've selected with Ctrl/Shift-click. Delete always asks first: the confirmation lists the maps that use the tilesets (those maps will show placeholder tiles afterwards) or tells you no map uses them. Undo restores them all. A map whose tileset is missing still opens, with placeholder tiles and a warning.

The **ID:** row has an edit button to change a tileset's ID, updating every map that uses it. It's refused if the ID is already taken, or if the database or any open map has unsaved changes. Open maps affected are reloaded, and the change can be undone.

## Copying, Cutting, and Pasting Records

**Right-click a row** in Tilesets, Common Events, or Animations to copy or cut the whole record and
paste it elsewhere — into another slot in the same project, or (with **Edit → Advanced Clipboard →
Cross-Project Clipboard** on) into another open Maker Studio window:

- **Copy** puts the record — every setting it has — on the clipboard.
- **Cut** copies it, then removes it. On **Common Events** and **Animations** it can't remove the
  slot outright (other commands point at these by number), so Cut instead **blanks the slot** and
  leaves the numbering untouched. On **Tilesets**, Cut opens the normal delete confirmation, since
  dropping a tileset can leave other maps pointing at nothing.
- **Paste (Replace)** overwrites the record under your cursor. You're asked to confirm before a
  tileset is replaced.
- **Paste as New** adds the copied record as a brand-new entry instead of overwriting anything.
- **Duplicate** copies the record straight into a fresh slot at the end of the list, in one step —
  no clipboard involved. Its shortcut is **Ctrl+J**, the same "Duplicate" key used across the editor
  (map selection, events, layers, maps, event pages and commands).

One copy can be pasted as many times as you like — copying again replaces what's on the clipboard.
Pasting a tileset carries everything: its graphic, autotile names, panorama/fog/battleback, and its
full passage/priority/terrain tag data (see [Tileset Editor](tileset-editor.md)).

**Switches** and **Variables** support the same idea for a single name: right-click an entry for
**Copy Name** / **Cut Name** / **Paste Name** / **Duplicate Name**. Since a switch's name and a
variable's name are the same kind of thing under the hood, a name copied (or cut, or duplicated) from
Switches can be pasted into Variables (and back).

**Keyboard shortcuts and undo**: click a row to give its list keyboard focus, then **Ctrl+C** /
**Ctrl+X** / **Ctrl+V** / **Ctrl+J** copy, cut, paste, and duplicate the same way as the right-click
menu — the exact keys are whatever you've bound to Copy/Cut/Paste/Duplicate in **Help → Keyboard
Shortcuts...**. **Ctrl+Z** / **Ctrl+Y** undo and redo record-level edits on that list — not just
paste/cut/replace/duplicate anymore, but also **+ Add**, **Change Maximum…**, **New Tileset**, and
deleting a record, including the on-disk Tileset writes: undoing a pasted-in or newly-added tileset
writes the old data straight back (or removes the slot it created), and undoing a deleted tileset
writes it right back into its old slot. Each list's undo is independent of every other panel's —
undoing here never touches the map canvas or an open editor's own undo history.

## Common Events

Common events are command lists you can call from anywhere (via **Call Common Event**) or run automatically.

1. Pick an event from the list on the left. Use **Change Maximum…** to add or remove slots.
2. Set its **Name**.
3. Choose a **Trigger**:
   - **None** — only runs when another event calls it.
   - **Autorun** — runs on its own and pauses the game while it runs (until its condition switch turns off).
   - **Parallel** — runs in the background alongside the game.
4. For Autorun/Parallel, pick a **Condition Switch** — the event only runs while that switch is ON.
5. Build the **command list** using the same editor as map events (Insert / Edit / Delete / drag to reorder, copy & paste, undo/redo).
6. Click **Apply** to save.

You can also copy, cut, paste, and duplicate a whole common event — see [Copying, Cutting, and
Pasting Records](#copying-cutting-and-pasting-records) above.

## Animations

The Animations editor recreates the RPG Maker XP animation tool, with some extras.

**Set up the animation**

1. Select an animation on the left (or **Change Maximum…** to add slots) and give it a **Name**.
2. Click **Graphic** to choose the spritesheet from `Graphics/Animations/` (and an optional hue shift).
3. Pick a **Position** (Top / Middle / Bottom / Screen) and the number of **Frames**.

**Edit a frame's cells**

Each frame is made of *cells* — pieces of the spritesheet placed over the target.

- Click a cell in the **sheet** (lower right) to add it; click a cell on the **canvas** to select it, and drag to move it.
- With a cell selected, adjust **X / Y / Zoom / Angle / Opacity / Blend / Mirror** and its **Pattern** (which sheet image it shows). Use **Add / Dup / Del** for cells.
- Step through frames with **◀ / ▶** or the numbered frame strip. Turn on **Onion** to see the previous frame faintly behind the current one.
- **▶ Play** previews the animation (frames + screen flashes). **↶ / ↷** undo/redo your edits.
- Outside the animation record list, the shared Copy, Paste, Cut, Undo, and Redo shortcuts apply to cells and frames. Delete or Backspace removes the selected cell. See [Keyboard Shortcuts](keyboard-shortcuts.md#database).

**Frame tools**

- **+ Frame** adds a frame; **Paste Last** copies the previous frame's cells into the current one.
- **Copy Frame / Paste Frame / Clear Frame** work on the whole current frame.
- **Tweening…** smoothly interpolates a range of cells between two frames (pick which frames, which cells, and whether to tween Pattern, Position/Zoom/Angle, and/or Opacity/Blending).
- **Cell Batch…** sets chosen values (X, Y, Zoom, Angle, Flip, Opacity, Blending, Pattern) on a range of cells across a range of frames.
- **Entire Slide…** slides every cell across a range of frames by a per-frame X/Y amount.

**SE and flash timing**

In the **SE and Flash Timing** list (right), **Add** a timing, then set:

- **Frame** it fires on.
- **SE** — a sound effect (pick name/volume/pitch).
- **Flash** — None / Target / Screen / Hide Target, plus color, alpha, and duration.
- **Condition** — None / Hit / Miss (when the timing applies).

Click **Apply** to save. Your changes are written straight back to `Animations.rxdata`, so they show up in the game.

You can also copy, cut, paste, and duplicate a whole animation — see [Copying, Cutting, and Pasting
Records](#copying-cutting-and-pasting-records) above.
