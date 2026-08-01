# Changelog

User-facing changes to the Maker Studio app and its game-side plugin.

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
