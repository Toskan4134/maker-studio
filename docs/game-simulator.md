# Game Simulator

The Game Simulator lets you test events and move routes without leaving the editor. It interprets event commands, animates sprites, and shows dialogue/pictures in real-time.

## Opening the Simulator

There are three ways to open the simulator:

1. **Simulate Map** - Click the **Sim Map** button in the main toolbar to test the entire map with all events active.
2. **Simulate Event Page** - In the Event Editor, click the **▶ Simulate** button to test a single event page in isolation.
3. **Test Move Route** - In the Set Move Route command editor, click **▶ Test Move Route** to test a custom move route.

## Simulator Panel

The simulator panel contains:

- **Canvas** - Shows the map, events, player, and effects (dialogue, pictures, screen tone, weather). Drag with left-click to pan; right-click for the player-position menu.
- **Toolbar** - Play/Pause, Step, Restart, Speed controls, Fixed Camera toggle
- **Event Log** - Logs every executed event command and move-route step (info / warn / unsupported)
- **Dialogue Overlay** - Displays Show Text and Show Choices

## Scenario Types

### Map Simulation

- **Player input**: Enabled - use arrow keys to move, C to interact
- **Camera**: Follows player
- **Events**: All parallel and autorun events run normally
- **Loop**: Not available (use Restart to replay)

### Event Page Simulation

- **Player input**: Disabled - watch the event run
- **Camera**: Follows the event being tested
- **Events**: Only the tested event runs
- **Loop**: When enabled, auto-restarts when the event finishes

### Move Route Simulation

- **Player input**: Disabled - watch the route execute
- **Camera**: Follows the target event (or player if player is selected)
- **Events**: Only the move route runs
- **Loop**: When enabled, auto-restarts when the route finishes

## Controls

| Action | Key | Description |
|--------|-----|-------------|
| Play/Pause | Space | Toggle simulation playback |
| Step | . (period) | Advance one frame while paused |
| Restart | R | Reset to initial state |
| Close | Esc | Close the simulator |

### Player Controls (Map simulation only)

| Action | Key | Description |
|--------|-----|-------------|
| Walk | Hold Arrow Keys | Continuous fluid movement; tap a different arrow to turn first |
| Action Button | C | Interact with facing event |
| Cancel | X | Cancel / back (logged only) |

The player walks continuously while a direction key is held — no per-tile retap needed. Tapping a different direction briefly turns in place; holding it after turning starts moving. The walk animation runs through the full RMXP charset (frames 0→1→2→3→0), matching the in-game character animation.

### Camera Controls

| Action | Input | Description |
|--------|-------|-------------|
| Pan | Left-click drag on canvas | Pan the camera; detaches follow until you re-enable Fixed Camera |
| Toggle camera mode | Y key or 📷 Fixed Camera button | Default ON: camera follows the player/event. OFF: free camera, drag to pan |
| Pan | Mouse drag / Scroll wheel | Drag or scroll to pan. Shift+Scroll for horizontal |
| Set Player Position | Right-click on canvas | Opens context menu, click "Set Player Position Here" |

## Supported Features

The simulator supports many RPG Maker XP event commands:

- **Message**: Show Text, Show Choices, Input Number
- **Flow Control**: Conditional Branch, Loop, Break Loop, Label, Exit Event Processing
- **Game Data**: Control Switches, Control Variables, Control Self Switches, Control Timer
- **Movement**: Set Move Route (full 45-move commands), Wait for Move's Completion
- **Map**: Transfer Player, Set Event Location, Scroll Map
- **Screen**: Show/Move/Erase Pictures, Change Screen Color Tone, Screen Flash, Screen Shake, Set Weather Effects
- **Audio**: Play BGM / BGS / ME / SE, Fade Out BGM / BGS, Memorize & Restore BGM/BGS, Stop SE — files play straight from your project's `Audio/` folder (`.ogg`/`.mp3`/`.wav`; `.mid`/`.midi` via the built-in synth). Volume and pitch are applied. BGM/BGS loop and pause with the sim; restarting or closing the simulator stops all audio.
- **Character**: Change Transparent Flag, Change Graphic

## Unsupported Features

The following commands are logged but not executed (require Game.rxdata or PluginScripts.rxdata):

- **Battle Processing** (301) - Requires battle system
- **Shop Processing** (302) - Requires shop system
- **Name Input** (303) - Requires name entry system
- **Menu/Save/Game Over/Title** (351-354) - Requires system scripts
- **Script** (355/655) - The simulator can't run Ruby, so scripts are logged rather than executed — but the **full script text is now shown in the log** (first line on the command row, each remaining line as an indented `↳` row).

## Toolbar Options

- **Speed**: 0.25×, 0.5×, 1×, 2×, or 4× playback speed. Preserved across Restart so resets don't bounce you back to 1×.
- **Loop** (Event Page / Move Route only): Auto-restart when finished. Preserved across Restart.
- **Fixed Camera**: ON (default) follows the player/event. OFF detaches the camera so you can drag-to-pan with left-click or pan with WASD. The toggle is preserved across Restart.

The old "📍 Set Player" toolbar button has been replaced by the right-click context menu on the canvas. Right-click any tile and pick "Set Player Position Here".

## Event Log

Every executed event command and move-route step is logged on its own line so you can trace execution turn-by-turn. Each row shows the **frame**, the **source** that ran it (System / Player / event name), then the command **code**, **name**, and a parameter summary.

**Color coding** matches the Event Editor command list — the whole row is tinted by category (text, flow control, variables, pictures, audio, move route, …) so you can scan the log the same way you read an event page.

**The source name is shown once.** When a run of commands comes from the same event, only the first row shows the frame and event name; the rest line up underneath, so the list stays clean.

**Support level** is a separate cue — a colored left stripe plus a tag — so you see both *what kind* of command it is and *whether the simulator ran it*:

- **Info** (no tag): implemented commands run normally.
- **Unsupported** (red stripe + `unsupported` tag): commands that need `scripts.rxdata` / `PluginScripts.rxdata` (battles, shop, common events, scripts) — logged but not executed.
- **Warn** (amber stripe + `warn` tag): partially-supported edge cases (e.g. variable source kinds that aren't loaded).

**Show Text**, **Comment**, and **Script** show every line: the first line on the command row, each extra line as its own indented `↳` row below it.

Move-route entries are prefixed with `Move:` and colored as move sub-commands; the code shown is the underlying move code (1–45).

**The log stays put while you read.** The panel size is fixed, so streaming logs never resize the simulator window or change row heights. Auto-scroll only follows the newest entry while you're already at the bottom — scroll up to inspect an earlier row and new entries won't yank you down. A **↓ Latest** button appears to jump back to the bottom.

Repeated identical entries (common with parallel events) collapse into a single row with a `×N` counter.

## Settings

Click ⚙ Settings to configure:

- **Player Start Position**: X/Y coordinates for player spawn
- **Player Character**: Which character sprite to use
- **Canvas Size**: Simulator viewport size (presets: Default 512×384, Amplified 640×440)
