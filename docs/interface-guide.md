# Interface Guide

## Menu Bar

Every menu item now shows a small icon next to its label so you can spot commands faster. The menus, left to right, are **File, Edit, View, Map, Tools, Mods, Help**.

- **File**: Open Project, **Open Recent** (recently opened projects, plus Clear Recent Projects), Save, Save All, Run Game
- **Edit**: Undo, Redo, Cut, Copy, Paste, **Advanced Clipboard** (Copy All Layers, Cut All Layers, Paste to Original Layers, **Cross-Project Clipboard** toggle — see below), Select All, Deselect, **Shadows** (Generate from Selection, Delete All Shadows)
  - **Cross-Project Clipboard** is off by default. When ticked, copying tiles, events, or event commands also places them on your system clipboard so a **second open Maker Studio window** can paste them. Turn it on in *each* window you want to share between. (Deleting a tile selection still works with the **Delete** key; only the old menu entry was replaced by this toggle.)
- **View**: **Panels** submenu (Maps, Tile Palette, Layers, Tile Properties, Tile Info, Events, Minimap), Show Grid, Show Collision, Show Events, Dim Inactive Layers, **Show MS-Exclusive Indicators** (see below), Zoom In/Out/100%, Dark Mode, **Language** submenu (see below), **Layout** submenu (Reset Layout, Import/Export Configuration)
- **Map**: New Map, Resize / Shift Map, Change Tileset, Import Map from JSON, **Export Map** submenu (Export as JSON / PNG / GIF / WebP)
- **Tools**: Tool selection (Brush/Eraser/Fill/Rectangle/Eyedropper/Select/Pan), Rotate CW/CCW, Flip Horizontal/Vertical, Database, Scripts
- **Mods**: Mod Manager (+ any mod-contributed menu items and panels)
- **Help**: Keyboard Shortcuts, Check for Updates, Stats, About Maker Studio, Toggle DevTools

## Language

The interface is available in **English** and **Español**. Switch under **View → Language** — the change applies immediately and is remembered across sessions. On first launch the editor picks your system language (Spanish systems start in Español; everything else defaults to English). Translation is still rolling out across the interface: the menus, welcome screen, and notifications are translated first, and any text without a translation yet simply shows in English.

## MS-Exclusive Feature Indicators

Some editor features go beyond what stock RPG Maker XP supports — they only work in the running game if your project has the **MakerStudio plugin** installed (the integration that ships with the editor). A tiny **MS** badge marks those features throughout the interface so you always know which ones depend on the plugin. Hover a badge for a reminder of why — most say *"Maker Studio exclusive — requires the MakerStudio plugin in-game"*, while some explain their specific reason.

You will see the badge on, for example:

- Menu items such as **Edit → Shadows** and **Map → Map Versions…** (also on the matching Map Tree right-click entries).
- **Map → Change Battleback…** — but **only while you are editing a [map version](map-versions.md)**. On the base map it changes the tileset exactly like RPG Maker XP does, so no plugin is needed and no badge is shown; only per-version overrides need the plugin (the version submenu's "(this version)" entry always carries the badge). (Panoramas are no longer changed from a menu — they are edited as the **Panorama Layers** group in the Layer panel; see the [Layers Guide](layers.md#fog-panorama-and-custom-layer-groups).)
- Layer panel rows for the fog/panorama layer groups (and any mod-added groups), shadow groups, and extra (non-native) tile layers.
- The **Autotiles** section of the Tile Palette — Maker Studio uses its own autotile system that is not tied to a map's tileset, so **all** painted autotiles need the plugin in-game (the badge's tooltip says so). Also a small badge over the tileset search box while you are browsing a tileset other than the map's own (cross-tileset painting).
- The **Tile Properties** panel header, and plugin-dependent event command forms (Change Map Settings when its type is set to **Fog**, fog color/opacity, the move-route **Set Frame** section). In tight spots — like the Sheet Cols/Rows fields in the graphic picker — the badge appears as a small dot instead.

If you use these features in a game that does not have the plugin, the game simply ignores them (or they are unavailable) at runtime — your maps still load fine in stock RPG Maker XP.

The badges are on by default. Hide or show them with **View → Show MS-Exclusive Indicators**; your choice is remembered across sessions.

## Toolbar

The toolbar sits at the top of the window and provides quick access to common actions:

💾 Save | ▶ Run | 📁 Saves | ▶ Sim Map | 🖌️ 🧹 🪣 ⬜ 💧 ⬚ ✋ | 🔍 Zoom | Switches | Variables | Tilesets | Database | Scripts | Grid | Col | Dim | ☀/☾

- **Save, Run** — emoji + text for visibility. (Creating a new map now lives in the Maps panel header — see Map Tree below.)
- **Saves** — appears after the first Run; opens the folder where the game stores its save files. On Windows/macOS this is the native saves folder; on Linux it is the folder inside the Proton/Wine prefix the game ran in. See [Running the Game](map-management.md#running-the-game).
- **Sim Map** — opens the [Game Simulator](game-simulator.md) on the current map with player input enabled.
- **Tools** — emoji only. Hover to see the tool name and keyboard shortcut.
- **Brush tool** — hover to reveal a size slider popup (1–5).
- **Zoom** — hover to reveal zoom in/out controls.
- **Switches / Variables** — open a searchable manager dialog where you can rename entries inline. Renames (and the **Add 50 more** button) are saved to your project immediately, so the new names survive a reload and are used by the running game — no separate save step needed.
- **Tilesets** — opens the tileset manager for creating, editing, and deleting tilesets.
- **Database / Scripts** — icon + text buttons that open the [Database](database.md) window and the [Scripts editor](scripts.md). (Also available under the **Tools** menu.)
- **Grid / Col / Dim** — icon + text toggle buttons for Show Grid, Show Collision, and Dim Inactive Layers.
- **Theme** — sun/moon toggle switch. Thumb left = light mode (☀ visible on the right); thumb right = dark mode (☾ visible on the left). Your choice is remembered across sessions.
- **Reset Layout** — available under View then Layout.

## Map Tree (left panel)

The Map Tree shows a hierarchical view of every map in your project. The panel header has a **+** button that creates a new blank map. You can:

- Double-click a map name to rename it.
- Right-click for a context menu: Open, Rename, Change Tileset, Resize/Shift, Delete.
- Drag and drop maps to reorganize the hierarchy.

## Tab Bar

Each open map gets its own tab along the top of the editor area.

- A dot indicator means the map has unsaved changes.
- Italic text means it is a preview tab that auto-closes when you open another map.
- Double-click a preview tab to make it permanent.
- Click the x button or middle-click a tab to close it.

## Status Bar (bottom)

The status bar displays useful context at a glance: cursor coordinates (X, Y), the event name under your cursor, the current tool, brush size, the active layer's name, zoom level, and whether undo history is available.

On very large or heavy maps it may also show **"⏸ Animations paused (performance)"**. When many tiles are visible at once, the editor keeps panning smooth by drawing from a cached image — and pauses autotile/fog animation when rebuilding that cache would take longer than 16ms (~60fps). Zoom back in (so fewer tiles are visible) and animation resumes automatically. (Animations also pause, without the indicator, while a dialog is open or the simulator is running.)

## Dockable Panels

Every panel in the editor can be dragged, floated as a separate window, and rearranged to suit your workflow. If you ever want to start fresh, use View then Layout then Reset Layout to restore the default arrangement.

- **Detach a panel**: right-click a tab or empty header area and pick **Detach to floating window**. The panel pops out as a draggable, resizable floating window inside the editor.
- **Floating windows stay on-screen**: if a floating panel is dragged or resized past the editor bounds, it auto-snaps back inside on release.
- **Reattach**: drag the floating window's tab back onto a dock zone, or close the panel.

## Minimap

Bottom-right panel. Shows a scaled view of the entire map (all native + extended layers + shadows) with a yellow viewport rectangle. Click or drag to recenter the main canvas.

- **Events display**: when **View → Events** is on, events render on the minimap with their active-page graphic (character or tile). Events with no graphic on any page are hidden so the minimap stays clean.
