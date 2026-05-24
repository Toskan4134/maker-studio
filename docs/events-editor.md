# Events Editor

## Viewing Events

Toggle event markers from the **Events** button in the toolbar (or **View → Show Events**). Events appear as colored markers on the canvas. When you hover your cursor over an event, the status bar at the bottom shows the event's name. (Pressing **V** selects the Events *layer* for editing — it does not toggle marker visibility.)

## Creating Events

- Click the + button in the Events panel.
- Or double-click an empty space on the map.

Either action creates a new event at that position with default settings.

## Copying Events

With the **Events layer** active, you can duplicate whole events (all pages and settings) on the map:

- **Right-click** an event for **Cut**, **Copy**, and **Paste** (pastes at the cell you clicked).
- Or use **Ctrl+C** (copy) and **Ctrl+X** (cut) on the selected event, then **Ctrl+V** to paste — no need for the menu.

**Pasting with Ctrl+V** shows a *preview*: a ghost of the copied event follows your cursor. **Click** where you want it to drop the copy; press **Escape** to cancel. Cut copies the event and then removes it. The pasted event keeps every page, condition, graphic, and command from the original; only its ID and position change.

## Event Editor Dialog

Double-click an existing event (or select it and click Edit) to open the Event Editor.

### General

- **Name**: The event's display name.
- **Position**: X and Y coordinates, both editable.

### Pages

Events can have multiple pages, each with its own conditions, graphic, and command list.

- Click + to add a page.
- Click x to remove a page. At least one page is always required.

### Conditions

Control when a page becomes active:

- **Switch 1 / Switch 2**: Require specific switches to be ON.
- **Variable**: Compare a game variable against a value.
- **Self Switch**: Check a self switch (A through Z — A–D are the RPG Maker XP standard; E–Z work at runtime in Pokémon Essentials).

### Graphic

Set the event's visual appearance:

- Character graphic or tile graphic.
- Direction and pattern.
- Opacity and blend mode.

### Autonomous Movement

- **Type**: Fixed, Random, Approach, or Custom route.
- **Speed** and **Frequency** sliders to control movement behavior.

### Options

Toggle individual flags: Walk Animation, Step Animation, Direction Fix, Through (walk through walls), and Always on Top.

### Trigger

Choose what activates the event: Action Button, Player Touch, Event Touch, Autorun, or Parallel Process.

## Command List

The command list is where you build the event's logic. You can add, edit, delete, and reorder commands.

### Adding Commands

Click Insert (or press Insert / Enter) to open the Command Picker. The picker organizes commands into three categories:

1. Message / Flow Control
2. Scene Control
3. Actor / Party

A search box at the top filters across all categories.

If you have mods installed that add their own event commands, extra tabs marked with a puzzle icon (**🧩1**, **🧩2**, and so on) appear after the numbered category tabs. Each holds up to 24 mod commands. Pick one just like a built-in command; it edits through its own form (or a script box if the mod didn't define fields). Under the hood the form just writes a normal Script command, so it runs in-game like any other event script. Mod commands can be added to Favourites just like built-in ones.

### Editing Commands

Double-click a command to edit its parameters. Many commands have dedicated typed forms (Show Text, Control Switches, Conditional Branch, and so on). Commands that do not yet have a typed form show a raw JSON editor instead.

### Set Move Route

Editing a **Set Move Route** command opens a route editor: pick the target (This Event, Player, or another event), toggle Repeat / Skip If Cannot Move, and build the list of move actions. Add actions from the dropdown; reorder, delete, undo/redo within the route.

Actions that take parameters open their own form, using the same pickers as the rest of the editor instead of raw text:

- **Change Graphic** — character graphic file picker (with preview + hue) plus Direction and Pattern.
- **Play SE** — SE file picker with volume/pitch and a play-test button.
- **Script** — multi-line Ruby code box.
- **Change Speed / Change Freq** — labelled dropdowns (Slowest…Fastest, Lowest…Highest), matching RPG Maker XP.
- **Switch ON/OFF**, **Jump**, **Wait**, **Change Opacity**, **Change Blending** — dedicated fields.

Each move action also appears as its own colored row beneath the Set Move Route command in the main list. To re-edit one, double-click it — or select it and use Edit (Edit button / Space / right-click → Edit). Either jumps straight to that action's form.

### Block Commands

Some commands create paired blocks:

- **Conditional Branch** adds a matching Branch End.
- **Loop** adds a matching Repeat Above.
- **Show Choices** adds a matching Choices End.

Deleting the opening command also removes its matching closer.

### Keyboard Shortcuts in the Command List

| Key | Action |
|-----|--------|
| Space | Edit the selected command |
| Delete / Backspace | Delete the selected command |
| Insert / Enter | Open the Command Picker |
| Ctrl+C / Ctrl+V / Ctrl+X | Copy, Paste, or Cut commands |
| Up / Down arrows | Move the selection |
| Alt + Up / Down | Reorder the selected command |

### Drag Reorder

You can drag command rows to reorder them. Block openers drag together with their matching closer, keeping indentation balanced automatically.

### Color Coding

Command rows are colored by category so the list reads like syntax-highlighted code. Categories at a glance:

| Color | Category | Codes |
|-------|----------|-------|
| Green (italic) | Comments | Comment, Comment (cont.) |
| Cream / off-white | Text & Input | Show Text, Input Number, Change Text Options, Button Input |
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

## Known Limitations

- Multi-line text and scripts do not auto-split into continuation codes. Use multiple Show Text commands for longer text.
- Show Choices only inserts the closing marker. Add "When" branches manually.
- Some commands currently use a raw JSON editor because a typed form is not yet available.
