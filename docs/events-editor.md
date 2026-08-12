# Events Editor

## Viewing Events

Toggle event markers from the **Events** button in the toolbar (or **View → Show Events**). Events appear as colored markers on the canvas. When you hover your cursor over an event, the status bar at the bottom shows the event's name. (Pressing **V** selects the Events *layer* for editing — it does not toggle marker visibility.)

## Creating Events

- Click the + button in the Events panel.
- Or, with the **Paint (Brush)** tool on the Events layer, **click an empty cell** — a new event is created there with default settings and selected. Double-click it (or any event) to open the editor.

A single-cell preview follows the cursor showing where the event will land.

## Tools on the Events Layer

With the **Events layer** active, only four tools do anything; the rest are greyed out in the toolbar:

- **Paint (Brush)** — **click an empty cell to create an event**; click an existing event to select it, then drag to move it.
- **Erase** — click an event to delete it, or **drag across the map to delete every event you pass over** (removed together in a single undo step).
- **Select** — box-select events (see below).
- **Pan** — move the view.

Double-clicking an event opens the editor; double-clicking does **not** create events (use the Brush). **Fill**, **Rectangle**, and **Eyedropper** are disabled here — you place one event per cell, not tiles. Switching to the Events layer while one of them is active falls back to the Brush automatically. **Brush size** has no effect on this layer, and the cursor preview shows a **single tile** (the first one selected), never a multi-tile group — you create one event at a time. The created event uses default settings regardless of the previewed tile.

## Selecting and Moving Events

Pick the **Select** tool, then on the Events layer:

- **Drag a box** to select every event inside it.
- **Ctrl+drag** adds events to the selection; **Shift+drag** removes them.
- **Drag** a selected event to **move the whole selection** together (one undo step). Moves that would leave the map or land on another event are blocked with a notice.
- **Delete** removes every selected event at once.
- **Ctrl+D** (or **Esc**) deselects.

## Copying Events

With the **Events layer** active, you can duplicate whole events (all pages and settings) on the map:

- **Right-click** an event for **Cut**, **Copy**, and **Paste** (pastes at the cell you clicked).
- Or use **Ctrl+C** (copy) and **Ctrl+X** (cut) on the selected event, then **Ctrl+V** to paste — no need for the menu.

**Pasting with Ctrl+V** shows a *preview*: a ghost of the copied event follows your cursor. **Click** where you want it to drop the copy; press **Escape** to cancel. Cut copies the event and then removes it. The pasted event keeps every page, condition, graphic, and command from the original; only its ID and position change.

> **One event per tile.** Two events cannot share a cell — the game treats overlapping events as a single occupant. Pasting onto a tile that already has an event, or dragging an event onto another event, is blocked with a *"Tile already has an event"* notice. Pick an empty tile (or delete/move the existing event first).

## Event Editor Dialog

Double-click an existing event (or select it and click Edit) to open the Event Editor.

The dialog window is resizable — drag its bottom-right corner to make it bigger, which helps when an event has many pages or a long command list.

At the bottom: **OK** saves your changes and closes the editor, **Apply** saves them and leaves it open (handy for testing a long event in steps), and **Cancel** discards them — if there is anything unsaved, you are asked first.

### General

- **Name**: The event's display name.
- **Position**: X and Y coordinates, both editable.

### Pages

Events can have multiple pages, each with its own conditions, graphic, and command list.

- Click + to add a page.
- Click x to remove a page. At least one page is always required.

### Conditions

Control when a page becomes active. Every check you tick must pass — they are ANDed together, and the topmost page whose conditions all pass is the one that runs.

- **Switch 1 / Switch 2**: Require specific switches to be **ON** or **OFF** — the dropdown after the switch name picks which.
- **Variable**: Compare a game variable against a value (≥).
- **Self Switch**: Check a self switch (A through Z — A–D are the RPG Maker XP standard; E–Z work at runtime in Pokémon Essentials), again **ON** or **OFF**.

> **OFF** needs the **MakerStudio plugin** installed in your game (Tools -> Integration). Vanilla RPG
> Maker XP can only ask for ON, so without the plugin the game reads an OFF check as a plain ON check
> — the page turns on exactly when you meant it to turn off. The built-in
> [Game Simulator](game-simulator.md) always honours it.

#### Advanced Conditions

Those four checks are everything the vanilla editor offers: two switches, one variable, one self
switch, all ANDed. **Advanced Conditions** — the collapsible section at the bottom of Conditions —
lifts that ceiling with a condition *tree*: as many checks as you want, mixed AND / OR, nested in
groups. Boss defeated **or** cheat switch on. Any one of five NPCs talked to. Rival beaten **and**
not (badge 3 **or** debug mode).

Expand the section and add rows:

- **Switch** — a switch, **ON** or **OFF**.
- **Variable** — a variable, **≥** or **<** a value.
- **Self Switch** — a self switch letter, **ON** or **OFF**.
- **Group** — a nested block with its own joiner, up to 4 levels deep.

Every group carries its own joiner in a dropdown: **Match ALL of these** (AND) or **Match ANY of
these** (OR). Nesting groups is how you write mixed logic — put an ANY group inside the ALL group and
you have "this and that and (either of these)". The **x** on a row deletes it; delete the last row and
the tree is gone again.

The tree is **ANDed on top of** the four checks above. It narrows a page further, it never overrides
them — so a page can keep using plain Switch 1 for the obvious case and the tree for the awkward part.

While collapsed, the section header shows a plain-language summary of what you built
(`0005: Boss Defeated ON OR (0003: Door A ON AND 0004: Door B ON)`), so you can confirm the logic
without expanding anything.

A **Match ANY** group with nothing in it is always false and would silently kill the page, so the
editor flags it inline. An empty **Match ALL** group is harmless — nothing to fail.

> Advanced Conditions carry the **MS** badge: the tree only takes effect in-game with the MakerStudio
> plugin installed (see [MS-Exclusive Feature Indicators](interface-guide.md#ms-exclusive-feature-indicators)).
> Without the plugin the game ignores the tree and judges the page on the four ordinary checks alone —
> more pages turn on, not fewer. The [Game Simulator](game-simulator.md) evaluates the tree properly.

### Graphic

Set the event's visual appearance:

- Character graphic or tile graphic.
- **Row** and **Col** — which cell of the sheet to show. **Col** is the horizontal frame (1…number of columns). **Row** is the vertical frame (1…number of rows): rows 1–4 are the standard directions (**1 – Down, 2 – Left, 3 – Right, 4 – Up**) and any rows beyond that are plain numbers, so a sprite can start on *any* row of a tall sheet.
- **Sheet Cols / Sheet Rows** — the number of columns and rows in the character sheet grid (1 or more each, no upper limit; default 4). Standard RPG Maker XP character sheets are 4x4 (4 directions, 4 animation frames). Change these when using non-standard layouts: a 1x1 single-frame icon, a 3x2 sprite sheet, an 8x8 extended sheet, a long effect strip, and so on. The Col and Row dropdowns adapt to the grid automatically.
- Opacity and blend mode.

The preview works like the map: **Ctrl+scroll** to zoom toward the cursor, **scroll / Shift+scroll** to pan up-down / left-right, and **middle-drag** or **Space+drag** to pan (the image always stays in view). Click a cell to pick its Row/Col; the **Fit** button resets the view. Handy for lining up cells on large or dense sheets.

Very tall images — a full tileset is hundreds of rows — open **fitted to the width, starting at the top**, rather than squeezed onto one screen where nothing is readable. Scroll down to reach the rest.

#### Using tiles from a tileset as the graphic

Pick a graphic that lives in `Graphics/Tilesets` and the picker notices: the preview gets a tile
grid, and you choose tiles instead of a whole image. **Click** a tile to use just that one, or
**drag** across several to use a block. Everything outside your selection dims, and the **Tiles**
read-out shows which tiles you took (`column, row · width×height`). **Use whole image** clears it.

Use **…** (Browse) to reach `Graphics/Tilesets` from an event's Graphic field — any graphic under
your project's `Graphics/` folder can be picked, whichever field you're filling.

**Sheet Cols / Sheet Rows follow your selection**, so you don't have to think about them: one tile
becomes a 1x1 sheet (a still sprite), a 3x4 block becomes a 3x4 sheet that animates. You can still
change them afterwards if you want a different reading of the same tiles.

The same tile picking is on the Move Route **Change Graphic** action and on **Show Picture**, where
your selection also drives the picture's origin and zoom.

Ordinary character sheets are unaffected — the tile grid only appears for tilesets.

> Tiles-as-graphics need the **MakerStudio plugin** installed in your game (Tools -> Integration).
> Without it the game draws the whole tileset image — the map still opens and runs, it just ignores
> the selection.

### Autonomous Movement

- **Type**: Fixed, Random, Approach, or Custom route.
- **Speed** and **Frequency** sliders to control movement behavior.

### Options

Toggle individual flags: Move Animation, Stop Animation, Direction Fix, Through (walk through walls), Always on Top, Block, and Always on Bottom.

**Block** makes the event impassable: nothing — player or other events — can step onto its tile, whatever the tile underneath would allow. An ordinary event already blocks the player, so this is for the case that doesn't: an event whose graphic is a **tile** inherits that tile's passability, so one drawn with a walkable floor tile gets walked straight through. Check Block and it stops the player anyway — handy for a rug you can't cross, an invisible wall, or a cut-scene barrier. Block is the opposite of Through, so ticking one clears the other, and it is per page: a later page without Block makes the event walkable again. It carries the **MS** badge: the flag only takes effect in-game with the MakerStudio plugin installed (see [MS-Exclusive Feature Indicators](interface-guide.md#ms-exclusive-feature-indicators)). Without the plugin the event blocks (or doesn't) by its usual rules.

**Always on Bottom** is the mirror of Always on Top: the event is drawn *underneath* every character, so the player walks over it instead of behind it — useful for floor decals, rugs, puddles, or shadows built as events. It still draws above the map's ground tiles. If both flags are checked, Always on Top wins. It carries the **MS** badge: the flag only takes effect in-game with the MakerStudio plugin installed (see [MS-Exclusive Feature Indicators](interface-guide.md#ms-exclusive-feature-indicators)). Without the plugin the event simply stacks by its position, as it did before.

### Trigger

Choose what activates the event: Action Button, Player Touch, Event Touch, Autorun, or Parallel Process.

## Command List

The command list is where you build the event's logic. You can add, edit, delete, and reorder commands.

### Adding Commands

Click Insert (or press Insert / Enter) to open the Command Picker. The picker sorts commands into several specific named categories, each with a one-line description under the active tab:

- **Messages** — show text, choices, and other message commands.
- **Logic** — conditions, switches, variables, loops, labels, and flow control.
- **Party & Items** — gold, items, weapons, armor, and party members.
- **Movement** — transfer player, set/scroll, and move routes.
- **Screen & Pictures** — screen tones, flashes, shakes, weather, and pictures.
- **Audio** — background music, sound effects, and other audio.
- **Actors** — actor stats, skills, equipment, name, class, and graphics.
- **Battle** — battle processing, shop, and enemy commands.
- **System** — windowskin, menu/save/encounter access, scripts, and system settings.

A search box at the top filters across all categories. The command list keeps a **fixed height** — the tallest a category ever needs — so the dialog no longer grows and shrinks as you switch between tabs; a tab with more commands (such as Favourites) scrolls up and down inside that fixed area. If you have enough categories or mods that the tabs don't all fit, arrow buttons appear at the ends of the tab bar to page through them — you can also scroll it with the mouse wheel, and the active tab is always kept in view.

The picker **remembers the tab you were last on**, so if you were browsing Battle (or a mod tab), that's where it opens next time.

### Favourites

Click the star next to any command to add it to your **Favourites** tab, which appears before the category tabs once you have at least one. To rearrange them, open the Favourites tab and click the **pencil** in the description strip to enter reorder mode: drag a command and the others shift aside to show where it will land, then drop it and click the check mark to finish. While reordering is on, clicking a command moves it instead of inserting it; turn it off to pick commands normally again. Your order is remembered across sessions.

Press **Escape** at any point to back out one step: from a command's parameter form it cancels the insert and returns you to the Command Picker — **on the page you picked the command from** — and from the picker it closes the picker. Escape no longer closes the whole Event Editor from inside these forms, so a mis-pick costs you one keypress instead of your unsaved page edits.

If you have mods installed that add their own event commands, extra tabs marked with a puzzle icon appear after the category tabs. Each mod names its own tab (and can give it a description of its own), so related mod commands are grouped together. Pick one just like a built-in command; it edits through its own form (or a script box if the mod didn't define fields). Under the hood the form just writes a normal Script command, so it runs in-game like any other event script. Mod commands can be added to Favourites just like built-in ones.

### Editing Commands

Double-click a command to edit its parameters. Many commands have dedicated typed forms (Show Text, Control Switches, Conditional Branch, and so on). Commands that do not yet have a typed form show a raw JSON editor instead.

**Selecting several commands from the keyboard**: hold **Shift** and press ↑ / ↓ to
grow or shrink the selection from where you started, the same as Shift+clicking. Copy,
cut, paste, delete and Alt+↑/↓ reorder then act on the whole run.

### Multi-Line Commands (Show Text, Comment, Script)

**Show Text**, **Comment**, and **Script** can hold as many lines as you need — just type them in the command's text box, one per line. In the command list, **each line gets its own row**, exactly like RPG Maker XP: the command row shows the first line, and every extra line appears below it on a row starting with `:`.

```
@>Text: "Hello there!"
:       "Nice weather today."
:       "Are you heading to the gym?"
```

Each extra line is indented to sit exactly under the first one, so a long message reads as a single aligned block instead of a ragged staircase. The indent is measured from the command's own name, so it stays correct for every command and in every interface language.

Those extra rows are *lines of the command*, not commands of their own:

- **Double-click any of them** (or select one and press Space) — the command's form opens with the **whole** text, so you always edit it as one block. Press OK and the lines are written back.
- **Selecting, dragging, copying, cutting, or deleting** any of the rows acts on the **whole command**, all its lines included. Nothing can be dropped between a command and its own lines.
- The **arrow keys** step over the extra lines, so the selection always lands on a whole command.

To break a message into separate text boxes in-game, insert a *second* Show Text command rather than adding more lines to the first one.

### Script Snippets

Any script box in the Event Editor has a **Snippets…** button next to its **Script** title — use it to keep a library of Ruby code you reuse instead of retyping (or hunting for) the same lines every time.

Click **Snippets…** and the snippet manager opens: type a name into **Save current as new** at the bottom and click **Save** to store whatever is currently in the box, then pick a saved snippet later and click **Apply** (or double-click it) to drop the code back in. The list shows the highlighted snippet's code in a scrollable preview, so you can check you picked the right one before applying. Rename, overwrite with the current box contents, and delete all work from the same dialog, and **Export…** / **Import…** write and read snippet files so you can back them up or share them with someone else.

Three places share **one** snippet library, so anything you save in one shows up in the others:

- the **Script** command,
- the **Script** action inside Set Move Route,
- the script box of a mod command that doesn't define its own fields.

Applying a snippet **replaces the whole box**, it does not insert at the cursor. If the box already has code in it, a confirmation appears first telling you how many lines you are about to lose — so paste your snippet into an empty command, or copy out what you want to keep before applying. If the box is empty the snippet is applied straight away.

Snippets are stored per-install (shared across all your projects) and remembered across sessions.

### Choosing a Graphic (Favourites)

Every graphic picker has a live preview and favourites: the event page **Graphic** (character sheet), **Show Picture**, **Execute Transition**, **Change Map Settings** (panorama / fog / battleback), the Move Route **Change Graphic** action, the map Battleback picker, and the fog / panorama / custom layer edit popup in the Layer panel.

- **Folder tree** — the list is a file-explorer tree: subfolders (e.g. `Graphics/Characters/NPCs/`) show as collapsible folders that you click to expand or collapse, with their images nested and indented inside. Folders sort to the top and everything is sorted by name. The folder containing your current graphic is expanded automatically when you open the picker **and the list scrolls to it**, so a graphic buried far down a long folder is on screen straight away (it only does this once — scroll away and the list stays where you put it). The search box still finds any graphic anywhere in the tree — so you can pick and favourite nested graphics directly instead of hunting through **Browse**.
- **Browse never duplicates** — the **…** button can pick any image under your project's `Graphics/` folder. If it's in another subfolder, the editor stores a relative `../Folder/name` reference instead of copying the file in (only an image from *outside* `Graphics/` is copied). The preview updates instantly, and previews you've already viewed are cached so flipping between the list and the **★ Favourites** tab doesn't re-load them.
- **Star any graphic** — hover a name in the list and click its star to favourite it (filled star = favourited). Favourites are remembered across projects and sessions.
- **Current image always has a star** — if the selected image isn't in the current folder list (you reached it through **Browse**, or it lives in another folder), it shows up as its own row just under **(None)**, labelled with its folder path — star it from there.
- **Favourites on top** — graphics you've starred in the current folder jump to the top of the list.
- **★ Favourites tab** — once you have any favourite, a tab appears listing **every** favourite, no matter which folder it lives in. A favourite from a different folder shows its folder name beside it; pick it and the editor stores the right reference automatically, so you can reuse one favourite across different picker types (including as an event's character graphic).

The same star works everywhere, so a character you favourite on an event's page is also pinned the next time you pick a Move Route graphic.

### Fog Commands and Multiple Fog Layers

Because a Maker Studio map can have **several fog layers** (not just the single tileset fog of stock RPG Maker XP), the three fog-related event commands let you pick **which fog layer** to affect:

- **Change Map Settings** (when the type is set to **Fog**) — pick the fog layer; the form pre-fills with that layer's current properties (graphic, hue, blend type, zoom, scroll X/Y, follow-camera), which you can then edit. (Opacity is handled by Change Fog Opacity below.)
- **Change Fog Color Tone** — pick the fog layer, then set the tone. The **Frames** field fades the tone in gradually over that many frames (0 = instant).
- **Change Fog Opacity** — pick the fog layer, then set the opacity. The **Frames** field fades the opacity gradually (0 = instant).

The dropdown lists the current map's fog layers by name. In-game the command changes that specific layer; if it can't find the layer it falls back to the map's main fog. These commands only affect **fog** layers — there are no event commands for panorama or custom layer groups (panoramas are edited in the Layer panel, battlebacks from the Map menu — see [Map Management](map-management.md#panorama-layers-and-battleback)).

### Set Move Route

Editing a **Set Move Route** command opens a route editor: pick the target (This Event, Player, or another event), toggle Repeat / Skip If Cannot Move, and build the list of move actions.

The move-action list edits just like the main command list:

- **Select** with a click; **Shift+click** extends the selection and **Ctrl+click** adds or removes individual actions — everything below acts on the whole selection.
- **Copy / Cut / Paste** with `Ctrl+C` / `Ctrl+X` / `Ctrl+V` — move actions have their own clipboard, so copying them never overwrites copied event commands (and vice versa). Pasted actions land after the selection, always inside the route.
- **Undo / Redo** with `Ctrl+Z` / `Ctrl+Y`, scoped to the route you are editing.
- **Edit** the selected action with `Space` or `Enter` (opens its parameter form), **Delete** removes it, the **arrow keys** move the selection, and `Alt+↑` / `Alt+↓` reorder.
- **Drag and drop** one action — or a whole multi-selection — to reorder; a line shows where it will land.

The route editor is fully translated now, so with the editor in Spanish the action
buttons, the route options and the rows read in Spanish too. Each row is drawn with
an indent guide, so at a glance the actions read as belonging to the route rather
than as commands of their own.

#### Draw path… — the visual route editor

Building a walk by clicking **Move Up** twelve times gets old fast. **Draw path…** (next to Test Move Route) opens the map itself and lets you draw the route on it.

- **Drag across tiles** to walk — each tile you cross becomes a Move action, diagonals included.
- **Click a tile far away** to add a **Jump** straight there.
- **Right-click** cuts the route back to the step you clicked.
- **Turn** and **Add Wait…** buttons add the non-moving actions; double-click a Wait row to change its frame count (20 frames = 1 second).
- **Set Start** picks the tile the route starts from. It defaults to the event's own tile (or the player's start position), and whatever you choose is remembered the next time you open the editor for that route.
- **Undo / Redo** with `Ctrl+Z` / `Ctrl+Y`. Select rows in the step list to delete them: right-click removes everything after the marked step, `Delete` removes exactly the ones you selected — both ask first, and `Ctrl+Y` brings them back.
- The **keyboard** draws too: arrow keys step, `Ctrl`+arrows turn, `Backspace` (or `Shift+←`) undoes the last step and `Shift+→` redoes it. All of these are rebindable under **Move Route Editor** in the shortcut settings.
- Pan with middle-drag or `Shift`+drag, zoom with `Ctrl`+scroll — the same as the map canvas.

**Apply as Move Route** replaces the route's actions with the path you drew. If the command already had a route, the editor opens showing it, so you can extend or trim rather than start over.

Actions that take parameters open their own form, using the same pickers as the rest of the editor instead of raw text:

- **Change Graphic** — character graphic file picker (with preview + hue) plus Direction and Pattern, and the same **tile picking** as the event page graphic when you choose a tileset.
- **Play SE** — SE file picker with volume/pitch and a play-test button.
- **Script** — multi-line Ruby code box.
- **Change Speed / Change Freq** — labelled dropdowns (Slowest…Fastest, Lowest…Highest), matching RPG Maker XP.
- **Switch ON/OFF**, **Jump**, **Wait**, **Change Opacity**, **Change Blending** — dedicated fields.

#### Frame actions (Maker Studio)

Below the standard actions is a **Frame** group that steps or sets which cell of the character sheet the target shows, using the page's **Sheet Cols / Sheet Rows** grid (see [Graphic](#graphic)). The sheet's **columns are the horizontal frames** and its **rows are the vertical frames**.

- **Next Frame / Previous Frame** — move one frame across the row; at the end of a row it wraps to the start of the next row (and the whole sheet wraps around at the very end).
- **Next / Previous Horizontal Frame** — move one column, wrapping within the current row only.
- **Next / Previous Vertical Frame** — move one row, wrapping within the current column only.
- **Set Frame…** — set the column and/or row directly. Each axis has its own checkbox, so you can change just the column, just the row, or both, leaving the other unchanged. Frame numbers are 1-based.

These let you drive a sprite's animation by hand — e.g. a stepped torch flicker, a portrait that cycles expressions, or a wide pose sheet. Because the frame is set manually, turn the target's **Move Animation** and **Stop Animation** off (Move Animation OFF / Stop Animation OFF actions) so the engine's automatic walk cycle doesn't overwrite the frame you set.

> The in-editor **Test Move Route** simulator previews these approximately — only the first four rows render distinctly there. In-game, all rows of the sheet are reachable.

**Test Move Route** starts with **Loop** already on when the route has **Repeat
Action** ticked, so a looping route previews the way it will actually behave in-game
instead of stopping after one pass. Turning Loop off in the simulator still wins from
then on.

Each move action also appears as its own colored row beneath the Set Move Route command in the main list. To re-edit one, double-click it — or select it and use Edit (Edit button / Space / right-click → Edit). Either jumps straight to that action's form.

### Block Commands

Some commands create paired blocks:

- **Conditional Branch** adds a matching Branch End. Tick **Add Else Branch** in its form to insert an **Else** section (untick to remove it and its commands).
- **Loop** adds a matching Repeat Above.
- **Show Choices** builds a full block: a **When** branch for each choice plus a **Choices End**. Editing the choices (rename, add, or set the cancel behavior to *Branch*) updates the When / When Cancel branches automatically, keeping the commands you've already put inside each one.

Deleting a block command (or its closing marker) removes the **whole block**, including every command nested inside it.

### Nesting Commands

By default, **Insert and Paste land the new command ABOVE the selected row** — as a preceding sibling, not inside anything. So to put a command *inside* a block, do one of the following:

- Right-click the block's opening line (the Conditional Branch, a When branch, or the Loop) and choose **Insert below** — the new command lands indented one level inside.
- Or select a row that is already inside the block (its first child, or any command within it) and Insert — the new command lands above that row, staying inside the block.

There's no manual indent control; nesting follows where you insert or drop a command.

### Keyboard Shortcuts in the Command List

| Key | Action |
|-----|--------|
| Space | Edit the selected command |
| Delete / Backspace | Delete the selected command |
| Insert / Enter | Open the Command Picker |
| Ctrl+C / Ctrl+V / Ctrl+X | Copy, Paste, or Cut commands |
| Ctrl+A | Select every command in the list (the page's final End row stays out of the selection). Handy before a bulk copy or delete |
| Escape | Cancel the open picker or parameter form (see [Adding Commands](#adding-commands)) |
| Up / Down arrows | Move the selection |
| Alt + Up / Down | Reorder the selected command (or whole block) by one, staying at its current level. To move a command *into* or *out of* a branch, drag it (see below) or cut and paste. A whole block (Conditional, Loop, Show Choices, Set Move Route) moves as one unit. |

You can also **copy and paste between events**: copy commands in one event (a block copies with everything inside it), open another event, and paste — the pasted commands keep their nesting.

**Copy between two open projects:** turn on **Edit → Advanced Clipboard → Cross-Project Clipboard** in both windows. Copied event commands (and whole events) then ride your system clipboard, so you can copy in one project's window and paste into another's. It's off by default; non-Maker-Studio clipboard text is ignored.

### Drag Reorder

You can drag command rows to reorder them. A block (Conditional, Loop, Show Choices, Set Move Route) drags together with everything inside it. As you drag, a **blue line** snaps to the gap nearest your cursor and shows exactly where the command will land. The command takes the indentation of the line's position, so:

- Drop onto an **Else** (or a **When**) row → the command goes *into* that branch.
- Drop onto a **Branch End** (or Repeat Above / Choices End) row → the command goes *out, below the whole block*.
- Drop the line between two commands → it lands at their level.
- Drop in the empty space below the list → it goes to the end.

### Reading a Row Without Opening It

Each row shows a short summary of what the command does, so you rarely need to open a command
to check it:

- **Set Move Route** and **Wait for Move's Completion** name their target — `003: Guard`, not
  just an id — alongside the step count and the repeat/skip flags.
- **Change Screen Color Tone**, **Change Fog Color Tone**, **Screen Flash** and **Change Picture
  Color Tone** show their channel values and duration (`R-68 G-68 B0 Gy68, 60 frames`).
- Switch / variable rows show the switch or variable name, not only its number.

### Color Coding

Command rows are colored by category so the list reads like syntax-highlighted code. Categories at a glance:

| Color | Category | Codes |
|-------|----------|-------|
| Green (italic) | Comments | Comment, Comment (cont.) |
| Cream / off-white | Text & Input | Show Text, Show Text (cont.), Input Number, Change Text Options, Button Input |
| Dimmed text color | Conditionals | Conditional Branch, Else, Branch End, Show Choices, When [**], When Cancel, Choices End |
| Amber | Other Flow | Loop / Repeat Above, Break Loop, Wait, Label, Jump to Label, Exit Event, Erase Event, Call Common Event |
| Pink | Variables | Control Switches, Control Variables, Control Self Switch, Control Timer |
| Orange (deep) | Party / Inventory | Change Gold, Items, Weapons, Armor, Party Member |
| Steel blue | Map / Screen | Transfer Player, Set Event Location, Scroll Map, Map Settings, Fog Tone/Opacity, Animation, Transparent, Transitions, Screen Tone/Flash/Shake, Weather |
| Mint | Movement | Set Move Route, Wait for Move's Completion |
| Dim mint | Move sub-commands | Individual move steps under a Set Move Route |
| Periwinkle | Pictures | Show / Move / Rotate / Tone / Erase Picture |
| Cyan | Audio | BGM, BGS, ME, SE (play / fade / stop / memorize / restore) |
| Red | System | Battle / Shop / Name Input, Abort Battle, Menu / Save / Game Over / Title |
| Yellow | Actor changes | HP, SP, State, Recover, EXP, Level, Parameters, Skills, Equipment, Name, Class, Graphic |
| Terracotta | Enemy changes | Enemy HP, SP, State, Recover, Appear, Transform, Battle Animation, Damage, Force Action |
| Orchid magenta | Scripts | Script, Script (cont.) |
| Muted italic | End | Final terminator row of the page |

Colors follow the active editor theme — the same hue family in dark and light mode, shifted for readability against each background. Selected rows always render white-on-blue regardless of category.

**Long rows scroll instead of being cut off.** When a command's text is wider than the list, hovering it scrolls the text sideways so you can read all of it without widening the panel or opening the command.

**Transfer Player rows say where they go.** A fixed destination reads as the map number, its name and the coordinates — `007: Pewter City (12,8)` — and a variable-driven one lists which variable holds the map, the X and the Y.

## Known Limitations

- Removing a choice from the *middle* of a Show Choices list can shift the commands in the When branches below it (branches are matched by position). Renaming choices or adding new ones at the end is safe.
- Some commands currently use a raw JSON editor because a typed form is not yet available.

## Waiting for a Move Route to Finish

**Wait for Move's Completion** pauses the event until a forced move route has finished. RPG Maker
waits for *every* character on the map, which means an unrelated event's route can hold yours up.
Maker Studio lets you narrow it:

| Option | Waits for |
|--------|-----------|
| **Any Event (RPG Maker default)** | Every character — the original behaviour. Chosen for new commands, and what happens without the plugin |
| **This Event** | The Set Move Routes *this event* ran, whoever they moved — including one it set on the player |
| A specific event | Just the route this event set on that one |

"This Event" is the one you want after moving the player through a door: the event itself is standing
still, so what matters is the route it started, not its own movement.

Anything other than *Any Event* needs the **Maker Studio plugin** in your game (the badge on the
form says so). Without it the game falls back to waiting for every character — never a crash, just
the original behaviour.

One catch worth knowing: a move route started by a **script** (Essentials' `Followers.follow_into_door`,
for instance) was not started by the event, so only *Any Event* waits for it.

## Autonomous Movement · Custom

With **Type: Custom** in the Autonomous Movement box, a **Set Move Route…** button appears. It opens
the same route editor the event command uses, and the route is stored on the page itself — the route
the event walks on its own, with no command needed. There is no target picker: a page route always
moves its own event.
