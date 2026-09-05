# Changelog

User-facing changes to the Maker Studio app and its game-side plugin.

## v1.6.0

Every event command describes itself in the list now, in its own colour — battle commands included. The Scripts window edits any script source the project actually has, whole records copy and paste across the editor, and presets learn multi-selection and an import that asks before overwriting.

### Additions
- 🎨 **A colour per command** — every event command paints its row in its own colour now, and continuation rows (text lines, branch elses, move steps) follow the command they belong to. Settings → Appearance grows an **Individual commands** group with one row per command, and an **RPG Maker XP palette** button that fills the whole set at once, light and dark.
- ⚔️ **The battle commands join the editor** — **If Win / If Escape / If Lose / Battle End / Shop Goods** were unknown to the editor: raw JSON forms, no colour, no block structure. They are real commands now, **Battle Processing** builds and syncs its branch skeleton the way Show Choices does, shops saved in the old shape are adopted on open, and the Game Simulator skips the whole battle block instead of running the win, escape and lose bodies in a row.
- 📝 **Every command row describes itself** — the text after a command's name is written for every code now, not just a few: options by name ("Scroll Map: Down, 3 tiles, speed 4"), items, actors and skills by name, and the later picture rows name their file.
- 📜 **The Scripts window edits any script source** — the list was tied to Scripts.rxdata; it now edits whichever source the project has: Scripts.rxdata, Data/Scripts when the project extracted its scripts, and every Plugins/ folder. Folder sources show a real tree, and you manage the files right there: new file or folder, rename, delete (multi-select included), drag onto a folder to move. The sidebar is resizable, folds and width persist, and the window reopens where you left off. Snippets insert at the cursor now.
- 🗂️ **Copy, cut, paste and duplicate whole records** — every list that holds a record now shares one clipboard: an event page, a tileset, an animation, a common event, a switch or variable name, a whole map layer — copy out of one slot, paste into another, or into another Maker Studio window behind the cross-project toggle. **Ctrl+J** duplicates whatever is selected, and each list keeps its own Ctrl+Z history.
- 🧩 **Presets grow up** — select several presets or folders with Ctrl/Shift and move, export or delete them in one action; the detail pane edits a snippet's code in place; a new snippet can be cut from the editor selection; and importing asks before overwriting — a clash list shows yours against the imported, with a diff, and you tick what to replace.
- 👆 **Double-click the blank row at the end of the command list** to append a command — same as double-clicking the empty space below.
- 🧩 **For mod developers**: Mod API **1.0.2** — event command colours are public: a mod theme can recolour a single command without leaving its category behind, and `commandSchemas()` reports each command's colour category and owning code.

### Fixes
- 🌉 **Shadows no longer draw over an active bridge** — while you cross a bridge the engine forces its tiles to z=0, which sank the shadow's source tiles under the shadow itself.
- 💥 **The Screen Flash preview shows the configured colour** — the swatch was white whatever you picked; it now blends the colour by Strength.
- ⏱️ **Fixed Control Timer running one second per minute** — the editor stored frames where RPG Maker XP stores seconds, so a one-minute timer ran one second in game.
- 🔢 **Fixed the Change HP / SP / EXP / Level rows** reading every option after the actor one off — a missing parameter shifted the rest.
- 🔥 **Fixed a game crash (NoMethodError) in La Base de Sky and Pokémon Essentials projects** when a follower stepped onto a tile no layer decided — the plugin asked the engine for an API RPG Maker XP doesn't have.
- 💧 **Fixed the eyedropper / ALT+click not scrolling the palette** after a click on the palette itself.
- 🧱 **Fixed painting a native autotile over an extra one resurrecting the old name** — the cell kept the displaced autotile's name and drew the old graphic with the new pattern.
- 🖼️ **Fixed autotile previews in the Tileset Editor** showing the last animation frame instead of the first.
- 🗑️ **Fixed deleted maps leaving their render caches behind**, so the next map to take the freed ID rendered with the deleted map's tileset until it was re-picked. **Escape on the Events layer** drops the tile selection now too.
- 💾 **Fixed saving a tileset after painting past the end of a short terrain-tag / priority / passage table** — the save failed with an error.
- 🗺️ **Fixed the transfer-player map picker getting stuck on placeholder tiles.**
- ↩️ **Undo got honest** — cancelling a just-created event deletes it again instead of leaving an empty one on the map; creating one is a single Ctrl+Z; duplicating or pasting a layer is one undo, not two; and reordering layers, which was never undoable, now is.

### Changes
- ✂️ **Show / Move Picture rows are trimmed to name + opacity** — origin, xy, zoom and blend are almost always the defaults and buried the two facts worth scanning for; Move Picture appends the tween duration.

## v1.5.0

Move routes are drawn on the map now instead of clicked together one **Move Up** at a time. The editor installs the game-side plugin by itself, whole maps travel between projects with Ctrl+C / Ctrl+V, any map can change its ID without breaking the transfers pointing at it, and the Show Text box finally tells you what all those `\c[…]` codes do.

### Additions
- 🚶 **Draw path… — the visual move-route editor** — a **Draw path…** button next to Test Move Route opens the map itself and lets you click the route onto it instead of stacking Move Up twelve times. Extend the path with the arrow keys, turn in place with Ctrl+arrows, undo with Backspace, delete several steps at once, and **Apply as Move Route** writes it back. If the command already had a route, it opens showing it, so you extend or trim instead of starting over — and a route that follows a **Wait for Move's Completion** starts from where the previous one ended. Every key in the editor is rebindable.
- 🧩 **The editor installs the game plugin for you** — when a project has no integration, the dialog now offers a **Build** dropdown with every supported engine: pick yours, press **Install**, and it downloads the right zip and sets up `Plugins/MakerStudio/` itself. The two paste-in builds (Essentials v17.1 and BES v5) turn the button into **Download** and then **Open Folder**, since those are one script you paste into the Script Editor by hand.
- 🔤 **Text codes, right in the Show Text box** — a **Text codes** button opens a reference of every message code your game understands, grouped into Substitution, Style and Flow; click one and it lands where your cursor was. Typing `\` filters the same list into an autocomplete you can pick from with the arrow keys. La Base de Sky projects also get that base's extra codes, including the **NameBox** ones, which are copied to your clipboard for a Script command.
- 📋 **Copy a whole map into another project** — **Ctrl+C** in the map list copies the map with all its layers, events and versions, and **Ctrl+V** pastes it into the tree, exactly as RPG Maker XP does. Turn on **Edit → Cross-Project Clipboard** to make it work between two Maker Studio windows. **Delete** removes the selected map from the keyboard too.
- 🗂️ **Reorderable map tabs, and a session that comes back whole** — drag tabs into the order you want, and reopening the project restores the whole set of tabs in that order with the map you were last editing active, not just the first map in the list.
- 🔢 **Change a map's ID** — **Change ID…** in the map tree moves a map to any free number and rewrites **every Transfer Player command in the project** that pointed at it, follows the player start position and renames its baked shadows; the toast says how many commands were updated. New maps also reuse the free IDs left by deleted ones instead of always taking the next number.
- ⚔️ **The battleback belongs to the map, not to the tileset** — a map you never set one on still shows the tileset's, so a fresh project looks like RPG Maker XP; the moment you pick one, that map keeps its own and other maps on the same tileset are left alone. Map versions each get theirs.
- 🏷️ **Game names in Settings** — rename the folder your game keeps its saves in (`Game.ini`'s title) and the caption of the game window (`mkxp.json`), without leaving the editor or touching anything else in those files.
- 🖼️ **Current tileset in the graphic picker** — an event's graphic list starts with a **Current tileset** row, so you can grab tiles from the map's own tileset without browsing for it.
- 👀 **Command rows say more without being opened** — summaries now carry real values instead of bare ids, Transfer Player rows name where they go (`007: Pewter City (12,8)`), long rows scroll sideways when you hover them instead of being cut off, and Text, Comment and Script lines are shown without the wrapping quotes.
- 🎚️ **Every slider takes a typed value** — double-click a slider's number and type the exact one you want, anywhere in the editor.
- 🔄 **Both update checks show two versions** — the one you have and the newest one available, for the editor and for the game-side plugin.
- 🖌️ **Brush strokes can start off the map** — begin a stroke above or to the left of the map edge and the part that lands on the map is painted, instead of nothing happening.
- 🧩 **For mod developers**: Mod API **1.0.1** — mods can restyle any built-in editor UI (`ui.decorate`), add their own content to editor surfaces through named slots, teach the **Game Simulator** to run Script commands and conditions, ask whether the project is an LBDS one, and read where their event command was placed. Mods that need a newer editor than yours are now held back with a **Needs a newer editor** chip instead of failing halfway.

### Fixes
- 🧱 **Fixed an eyedropped autotile turning into the wrong tile** on a map using a different tileset — the pick now travels by name, not by slot.
- 🖌️ **Fixed extra autotiles not connecting mid-stroke** — a stroke drawn with one of the game's own autotiles now joins up as you draw, instead of freezing on the first shape.
- 👻 **Fixed the paint preview of an eyedropped autotile** showing the wrong piece.
- 🎨 **Fixed the palette showing another map's tileset** when several maps came back at once on reopening a project.
- 🏃 **Fixed event Frequency having five levels instead of six** — the page dropdown, Change Freq and the simulator all stopped at *Higher*, silently downgrading events set to *Highest*.

### Changes
- ⬆️ **Insert and Paste now land above the selected row**, as a sibling, instead of inside whatever block was selected. To put a command inside a block, insert on the row that is already inside it.
- ▶️ **Run no longer saves your maps for you** — if anything is unsaved it asks first, and launches straight away when there is nothing pending.
- 🧩 **Check Game Integration has its own icon** in the Help menu.

## v1.4.0

Event pages stopped being a straitjacket: conditions can now be a tree of ANDs and ORs, a switch can be required OFF, and an event can block the tile it stands on. Graphics can be a slice of an image — pick tiles straight off a tileset and give them to an event. The tileset editor lets you write your own terrain tags, and battlebacks finally work in Pokémon Essentials, bases included.

### Additions
- 🌳 **Advanced Conditions on event pages** — a condition *tree* instead of the vanilla four checks: as many switches, variables and self switches as you want, mixed **AND / OR**, nested in groups, each one negatable. "Boss defeated **or** cheat switch on", "any one of five NPCs talked to", "rival beaten **and** not (badge 3 **or** debug mode)". Needs the MakerStudio plugin in-game; the built-in Game Simulator always honours it.
- 🔀 **Switch conditions can ask for OFF** — Switch 1, Switch 2 and Self Switch each get an ON / OFF dropdown, so a page can turn on precisely when a switch turns off.
- 🧱 **Block** — a new page option that makes the event impassable whatever the tile underneath allows. Made for events drawn with a walkable floor tile, which the player used to walk straight through.
- 🔻 **Always on Bottom** — the mirror of Always on Top: the event is drawn underneath every character, for floor decals, rugs, puddles and shadows built as events.
- 🖼️ **Use part of an image as a graphic** — pick a rectangle, or click and drag **tiles straight off a tileset**, and that slice becomes the event's graphic (also available for pictures and move routes). Everything downstream treats the slice as the whole image, so the sheet grid and the animation frames keep working.
- 🏷️ **Custom terrain tags and priorities in the Tileset Editor** — name your own terrain tags instead of living with 0–7, and extract the ones your game already defines from its own data.
- 🖌️ **Multi-tile stamps** — fill an area with a repeating pattern, drag to stamp continuously, and turn any map selection into a brush.
- 🗺️ **New Map, where you meant it** — the New Map dialog now lets you pick the parent map, and the map tree has **New Map Here**.
- ↩️ **Adding and deleting extended layers can be undone.**
- 👁️ **The event-cells view stays how you left it** between sessions, and a double-click confirms your pick in the graphic picker.
- 🐧 **Linux gets the already-running prompt too** — launching a second copy of the game asks first, as it does on Windows.
- 🧩 **For mod developers**: floating panels can set their own size, mods can read and react to events, toasts can carry up to two action buttons, and a mod can open the Keyboard Shortcuts dialog scrolled to a specific action.

### Fixes
- ⚔️ **Fixed the battleback being ignored in Pokémon Essentials and La Base de Sky** — those games read the backdrop from the map's metadata and never looked at the field the editor was writing. It now applies on every supported base (Essentials 17.1, 19.1, 20.1, 21.1, LBDS and BES), each of which keeps that metadata somewhere different.
- 🪨 **Fixed the bases not following the battleback** — picking `cave1` changed the background but left the battlers standing on grass, because Essentials names the bases after the environment. Your battleback now leads, and the environment only narrows it (`cave1_water_base0` on water, `cave1_ice_base0` on ice).
- 💥 **Fixed the plugin refusing to load on Essentials 17.1 and BES** — one line used Ruby syntax those engines are too old to parse, which took the whole plugin down at boot.
- 💾 **Fixed a crash on loading a save in Essentials 17.1 and BES** — the single-file version of the plugin had fallen behind the rest and still called a method those engines don't have.
- 🔄 **Fixed reordering extended layers not showing in the running game.**
- 🧭 **Fixed the location picker opening blank** and made its panning smooth, with a tile grid.
- 🖼️ **Fixed panoramas and battlebacks not hot-reloading** into the game you already had open.
- 👀 **Event indicators are clearer** on the map.
- 🌍 **Fixed untranslated text** in export, map versions, the tile right-click menu, and the ON/OFF labels.

### Changes
- 📄 **The per-project editor settings file is now `ms-editor-config.json`.** Existing projects are unaffected — it is created again on the next save.
- 📐 **The event editor's left panel can be resized**, and the window opens at a more sensible size.
- 🔍 **The tile info section moved to the bottom of the tileset editor's sidebar.**

## v1.3.0

The interface is yours now: pick a theme, recolour anything, and keep your place between sessions. Graphics you repaint in another program reload into the editor **and** into the game you already have running. The tileset editor moved into the Database and got a lot faster on big sheets.

### Additions
- 🎨 **Make the editor look how you want** — a new **Appearance** tab in **Help → Settings…** lets you pick a theme, switch dark/light, and recolour anything the editor draws: backgrounds, text, accents, the event command list, the Ruby syntax colours. Every colour is saved **per theme and per light/dark mode**, so your dark palette and your light one stay separate, and edits to a mod's theme are kept for the next time you turn it on. Colours update as you pick them and are stored when you press Save.
- 🖌️ **Themes from mods** — a mod can ship a full theme, including a wallpaper painted behind your map. A theme can offer both a light and a dark look and follow the Dark Mode toggle, or pin the editor to the one it was designed for. Pick one under **View → Theme** or in the new Appearance tab.
- ♻️ **Graphics reload into the running game** — repaint a tileset, autotile or character sheet in another program and it refreshes in the editor and in the playtest you already have open, without restarting either. Character sheets filed in subfolders are watched too. You can turn it off per project, or for one session from the game's debug menu.
- 🧱 **The tileset editor lives in the Database** — it is now the **Tilesets** tab: the list, the name, the graphic and the property grid on one screen. Each priority level has its **own colour** so a sheet mixing several can be read at a glance, and **Apply** saves without closing while **Save** saves and closes. Right-clicking a tile in the palette and choosing **Edit Properties…** opens it scrolled to that exact tile.
- 🎵 **Audio Browser** — a listening-only audio picker under **Tools** and in the toolbar, with a pitch slider that resamples the way the game does.
- ⚙️ **Editor settings** — a new **Help → Settings…** window: choose the size the editor opens at (default, remember the last one, maximized, fullscreen, or an exact size) and which monitor it opens on, picked by name so it survives unplugging a screen. On Windows you can also choose **which monitor the game opens on**; by default it follows whichever screen you are working on.
- 🪟 **Dialogs can be resized** — drag any edge or corner of a dialog to resize it, and when dialogs are stacked, Escape closes only the one on top.
- 🚶 **Autonomous Movement → Custom** now edits the event page's own route instead of a blank one, and **Wait for Move's Completion** can wait for one character instead of every character on the map.
- 👁️ **Alt+click a layer's eye** to show only that layer; Alt+click again puts back exactly what was visible before.
- 🗂️ **The editor remembers where you were** — reopening a project restores the map you were last editing and the map-tree folders you had folded.
- 📂 **File → Open Project Folder** and **Open Saves Folder** open those folders in your file manager.
- 🖊️ **Syntax highlighting in event script boxes**, and a **Snippets** library for the code you retype.
- 🌍 **Set Move Route is fully translated** — the route options, all 45 move actions and the Frame section.
- ⌨️ **Digit shortcuts in the tileset editor** — in Priority and Terrain Tag mode, 1–9 and 0 pick the value to paint. Rebindable.
- 🔍 **A Marketplace built for many mods** — tags in a searchable popover, All/Installed/Updates filters, a result count, and card or list views.
- 🎯 **Multi-tile stamps** — Ctrl+click adds a tile to the stamp and Shift+click removes it, on the palette and on the map.
- 🎮 **The simulator's Max FPS** is configurable, so it can match your game's own frame rate.
- 🔁 **Close and Reopen** — when the game is already running, Run can close it and start a fresh one.

### Fixes
- 🍎 **Fixed the Saves button doing nothing on macOS** — it pointed at a folder the game never writes to, and failed silently. It now opens the saves folder inside the Wine prefix the game actually ran in.
- 🎨 **Fixed parts of the interface ignoring the theme** — around 130 places were pinned to a fixed colour and never followed the theme you had chosen.
- ⌨️ **Fixed number fields you could not clear** — selecting the number and pressing Backspace snapped it straight back to the minimum. You can now empty a field; it fills in the minimum when you click away.
- 🧊 **Fixed the editor freezing when opening a very large tileset** — a 500-row sheet is no longer drawn all at once.
- ⏱️ **Fixed the simulator running every Wait 1.65× too fast**, and a move route re-issued while still running skipping its Waits.
- 🧍 **Fixed tall events flickering** over tiles set to priority 1.
- ↩️ **Fixed undoing a map resize leaving the events moved** in the saved file.
- ⌨️ **Fixed keyboard shortcuts firing while you were typing** in the event editor.
- 🖍️ **Fixed unreadable text selection** in the Scripts editor's dark theme.

### Changes
- 🖱️ **Events are created with a double-click** by default, matching RPG Maker — a single click selects the tile. Switch it back under **View → Create Events on Double-Click**.
- 🎚️ **Scrollbars are thicker and easier to grab**, and checkboxes, radios and sliders follow the theme instead of the system blue.
- 🗑️ **Deleting a layer asks first.**
- ⚠️ **"Don't warn me again" is gone from the already-running prompt** — launching a second copy of the game, or closing the one that is running, is worth confirming every time.
- 🐧 **Clear Proton Preference is only listed when there is a choice to forget.**

## v1.2.1

Hotfix for v1.2.0: the Integration stopped games from starting.

### Fixes
- 🚑 **Fixed the game refusing to start after installing the v1.2.0 Integration** — it failed at boot with a plugin error about an invalid registration key (`Invalid plugin registry key 'msintegration'` / `Clave de registro de plugin no válida 'msintegration'`). The line the editor uses to recognise which Integration you have is now hidden from the engine, so it identifies itself exactly as before without the engine ever seeing it. Affected every folder-installed Integration on every engine; if you installed v1.2.0, update to v1.2.1.

## v1.2.0

A big update to the event editor and the game-side plugin: a redesigned command picker, an editor that keeps your Integration up to date on its own, a reusable script library, per-map default music, and in-game tile colors that finally match what you see in the editor.

### Additions
- 🎛️ **Redesigned event command picker** — commands are now split across nine named tabs (Messages, Logic, Party & Items, Movement, Screen & Pictures, Audio, Actors, Battle, System) instead of three numbered pages, each with a one-line description of what it covers. The list keeps a fixed height, so the dialog no longer grows and shrinks as you switch tabs, and the picker reopens on the tab you were last using. If you have enough tabs to overflow, the tab bar scrolls with the mouse wheel and gets arrow buttons at its ends. **Favourites** can now be reordered: open the Favourites tab, click the pencil, and drag them into the order you want.
- 🔌 **The editor keeps your Integration up to date** — open a project and Maker Studio checks the plugin installed in your game. If it's older than the editor, it offers to download and install the right one for you (**Update Now**), point you at the download page, or remind you later. It works out which Integration your project uses on its own, keeps your project's mods and settings untouched, and handles the paste-in builds (BES v5, v17.1) by replacing just their script. You can run the check any time from **Help → Check Game Integration…**.
- ✂️ **Script snippets** — every script box in the event editor now has a **Snippets…** button: save the bits of code you retype, then drop them in with one click. One shared library across your whole project, with rename, overwrite, delete, and import/export to a file.
- 🎵 **Default music per map** — a new **Map Audio** dialog lets you set a map's Auto-Change BGM and BGS, so entering it starts the music you picked without needing an event to do it.
- 🧩 **One more supported engine** — vanilla Pokémon Essentials v17.1 now has its own Integration to install.
- ⌨️ **Command list touches** — multi-line commands now indent their continuation lines to line up under the command name, like the classic editor; **Ctrl+A** selects every command in the page; and cancelling an insert takes you back to the picker on the tab you were browsing.
- 🐧 **Linux polish** — `.makerstudio` project files now show the Maker Studio icon in your file manager, and the app icon shows correctly on the KDE Wayland dock.

### Fixes
- 🎨 **In-game tile colors now match the editor** — tiles with a hue or saturation change rendered far more vivid in-game than in the editor. The plugin now reproduces the editor's color math exactly, including tiles that combine hue with saturation or lighting.
- 🖌️ **Autotiles now take color and lighting in-game** — hue, saturation and lighting set on an autotile were shown in the editor but ignored by the game; they now render in-game too, animation intact, without affecting other tiles using the same autotile.
- 🧱 **Fixed tiles flickering in-game while walking** — a tile stacked on two extended layers could show one layer or the other depending on where you were standing, so parts of a map appeared and disappeared as you moved.
- 💾 Fixed Ctrl+S not saving while the Scripts window was open.

### Changes
- 🔄 **Autotiles are never rotated or flipped** — an autotile picks its pattern from the tiles around it, so a rotated or mirrored one no longer matched the edge it was chosen for (and could look upright in the editor but rotated in-game). The transform controls are now greyed out while an autotile is selected, and rotating a stamp that contains autotiles leaves them alone. Rotations saved on autotiles by older versions are ignored everywhere.

## v1.1.1

Small update: a faster way to open projects, plus editor and in-game preview performance fixes.

### Additions
- 📂 **Open a project by double-clicking it** — create a `.makerstudio` file for your project (**File → Create Project File…**) and double-click it in your file manager to launch Maker Studio straight into that project, just like RPG Maker XP's project file. (On the Linux AppImage, register it once with **Help → Install Linux File Association…**.)

### Fixes
- ⚡ **Editor performance** — the map canvas no longer lags when painting lots of tiles, tiles with color or rotation properties, or autotiles, or when working on very large maps.
- 🗺️ **Faster in-game map previews** — the debug "jump to map" and map-connection editor screens no longer freeze on maps with many styled tiles.

## v1.1.0

Update focused on stability: several in-game and editor bugs fixed, plus broader engine support.

### Additions
- 🍷 **Play/test on macOS** — the editor's "Run Game" button now launches your game through Wine on macOS (needs Wine, or Game Porting Toolkit/Whisky on Apple Silicon).
- 🧩 **Two more supported engines** — vanilla Pokémon Essentials v19.1 and v20.1 now have their own Integration to install.

### Fixes
- 🐢 **Big performance fix** — maps with lots of autotiles or extended-layer content used to run at single-digit FPS in-game; they now run at full speed regardless of map size.
- 🧱 Fixed several in-game collision bugs: tiles that should block movement could sometimes be walked through, and object hitboxes could land one tile off.
- 🎨 Fixed autotile passage/priority/terrain properties sometimes saving the wrong values to the wrong tileset, which could make a shared autotile graphic (e.g. sand, water) behave inconsistently across maps.
- 🖼️ Fixed a crash when placing tiles from another tileset onto very tall tilesets.
- 🌑 Fixed shadows occasionally drawing in front of or behind the wrong tiles.
- 👣 Fixed footprints (La Base de Sky 1.2.1) not appearing on sand painted with Maker Studio's autotiles or extended layers.
- 🔍 Fixed map search not finding maps nested several folders deep.
- 🖌️ Fixed autotile previews sometimes going blank after switching projects.
- 📐 Fixed map resize not saving events' new positions in-game.
- 💡 Fixed lighting/color effects looking different in the Game Simulator than in the actual game.
- 🧩 Fixed mods being unable to read or edit an event's list of commands.

### Changes
- 📝 The event editor now shows each line of a multi-line Show Text, Comment or Script command as its own row, matching the classic editor's look — while still selecting, moving and deleting as one command.
- 🪟 The event editor window no longer resizes itself when switching between pages.

## v1.0.0

First public release. See the [GitHub release notes](https://github.com/Toskan4134/maker-studio/releases/tag/v1.0.0) for details.
