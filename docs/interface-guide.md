# Interface Guide

## Menu Bar

Every menu item now shows a small icon next to its label so you can spot commands faster. The menus, left to right, are **File, Edit, View, Map, Tools, Mods, Help**.

- **File**: Open Project, **Open Recent** (recently opened projects, plus Clear Recent Projects), Save, Save All, Run Game, **Clear Proton Preference** (Linux only — forgets your remembered Proton/Wine/native launch choice so the picker dialog shows again next time you press Run)
- **Edit**: Undo, Redo, Cut, Copy, Paste, **Advanced Clipboard** (Copy All Layers, Cut All Layers, Paste to Original Layers, **Cross-Project Clipboard** toggle — see below), Select All, Deselect, **Shadows** (Generate from Selection, Delete All Shadows)
  - **Cross-Project Clipboard** is off by default. When ticked, copying tiles, events, or event commands also places them on your system clipboard so a **second open Maker Studio window** can paste them. Turn it on in *each* window you want to share between. (Deleting a tile selection still works with the **Delete** key; only the old menu entry was replaced by this toggle.)
- **View**: **Panels** submenu (Maps, Tile Palette, Layers, Tile Properties, Tile Info, Events, Minimap — clicking an entry **focuses** that panel, bringing it to the front or reopening it as a floating window if closed; it never closes a panel, and the checkmark still shows which panels are open), Show Grid, Show Collision, Show Events, **Show Event Cells** (see below), Dim Inactive Layers, **Show MS-Exclusive Indicators** (see below), Zoom In/Out/100%, Dark Mode, **Language** submenu (see below), **Layout** submenu (Refresh Layout, Import/Export Configuration)
  - **Show Event Cells** is off by default. Events with no graphic always show a marker box on their tile; with this on, events that *do* have a graphic are outlined too — a thin border around their cell plus a small corner square — so you can tell exactly which tile every event sits on without hiding its sprite. It is greyed out while Show Events is off.
- **Map**: New Map, **Duplicate Map**, **Map Versions…**, Resize / Shift Map, Change Tileset, **Change Battleback…**, **Map Audio…**, Import Map from JSON, **Export Map** submenu (Export as JSON / PNG / GIF / WebP)
- **Tools**: Tool selection (Brush/Eraser/Fill/Rectangle/Eyedropper/Select/Pan), Rotate CW/CCW, Flip Horizontal/Vertical, **Brush Editor…**, Database, Scripts
- **Mods**: Mod Manager (+ any mod-contributed menu items and panels)
- **Help**: **Documentation** (opens this online documentation in your browser), Keyboard Shortcuts, **Reset App** (reload the editor — your panel layout is kept; `Ctrl+R`), Check for Updates, Stats, About Maker Studio, Toggle DevTools

## Language

The interface is available in **English** and **Español**, and installed [mods](marketplace.md) can add more languages — any language a mod provides appears in the same menu automatically (if the mod that provides your chosen language is disabled, the editor falls back to its default language and switches back when the mod returns). Switch under **View → Language** — the change applies immediately and is remembered across sessions. On first launch the editor picks your system language (Spanish systems start in Español; everything else defaults to English). The whole interface is translated — menus, panels, dialogs, the event editor and its command forms, the simulator, and notifications. A few technical terms stay in English on purpose (for example *tile*, *tileset*, *autotile*, *script*, *mod*, and audio kinds like *BGM*/*SE*) so they match RPG Maker and the modding API.

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

Left to right, the toolbar groups are:

`Save · Run · Saves · Sim Map` | `Brush · Eraser · Fill · Rectangle · Eyedropper · Select · Pan` | `Zoom` | `Database · Scripts` | `Versions` | `Grid · Col · Dim` | `Theme`

- **Save, Run** — **Save** writes the current map (Shift+Click saves every open map); **Run** launches the game (on Linux, Shift+Click lets you choose the Proton/Wine prefix or, if available, a native Linux build). (Creating a new map now lives in the Maps panel header — see Map Tree below.)
- **Saves** — appears after the first Run; opens the folder where the game stores its save files. On Windows/macOS this is the native saves folder; on Linux it is the folder inside the Proton/Wine prefix the game ran in, or — after a native-build run — the game's own Linux save folder. See [Running the Game](map-management.md#running-the-game).
- **Sim Map** — opens the [Game Simulator](game-simulator.md) on the current map with player input enabled.
- **Tools** — the seven drawing tools (Brush, Eraser, Fill, Rectangle, Eyedropper, Select, Pan), shown as icons. Hover any of them to see its name and keyboard shortcut.
- **Brush tool** — hover to reveal a popover with a size slider, a **quick brush switcher** (your saved Custom Shape Brush presets plus Default/Custom), and a **Brush Editor…** opener. When a custom brush is active, a compact indicator next to the tools shows the brush's name with a ✕ to clear it. See [Custom Shape Brush](tools.md#custom-shape-brush).
- **Zoom** — shows the current zoom percentage; hover to reveal zoom in/out controls.
- **Database / Scripts** — open the [Database](database.md) window and the [Scripts editor](scripts.md). (Also available under the **Tools** menu.) Switches, Variables, and Tilesets no longer have their own toolbar buttons — they are now tabs **inside the Database** (where you can still rename entries inline, add more slots, and edit tilesets).
- **Versions** — shows the current [map version](map-versions.md) as a badge (e.g. `V2/3`) and opens the Version Manager. Relevant once a map has extra versions.
- **Grid / Col / Dim** — icon + text toggle buttons for Show Grid, Show Collision, and Dim Inactive Layers.
- **Theme** — sun/moon toggle switch. Thumb left = light mode (☀ visible on the right); thumb right = dark mode (☾ visible on the left). Your choice is remembered across sessions.
- **Refresh Layout** — available under View then Layout (restores the default panel arrangement).

If the window is too narrow to show every toolbar group at once, the groups that don't fit collapse into a **"…" (More)** button at the right end of the toolbar. Click it to reveal the hidden groups in a dropdown. Widening the window brings them back into the toolbar automatically.

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

Every panel in the editor can be dragged, floated as a separate window, and rearranged to suit your workflow. If you ever want to start fresh, use **View → Layout → Refresh Layout** to restore the default arrangement. (To just reload the editor while *keeping* your layout, use **Help → Reset App** / `Ctrl+R`.)

- **Detach a panel**: right-click a tab or empty header area and pick **Detach to floating window**. The panel pops out as a draggable, resizable floating window inside the editor.
- **Floating windows stay on-screen**: if a floating panel is dragged or resized past the editor bounds, it auto-snaps back inside on release.
- **Reattach**: drag the floating window's tab back onto a dock zone, or close the panel.
- **Focus from the menu**: **View → Panels** brings a panel to the front (or reopens it floating if you closed it) — it never closes panels.

### Mod panels and layouts

Panels added by [mods](marketplace.md) keep their place in your layout. If a mod is disabled, uninstalled, or reloading, its panel slot stays where you docked it and shows a placeholder ("Panel provided by mod … — not loaded") until the mod is back; close the placeholder if you don't want to keep the slot. Exported layout configurations (**View → Layout → Export Configuration**) also record which mods provided which panels — importing a layout that uses panels from mods you don't have installed warns you with the list of missing mods and keeps those panels as placeholders. Older exported configurations still import fine.

## Minimap

Bottom-right panel. Shows a scaled view of the entire map (all native + extended layers + shadows) with a yellow viewport rectangle. Click or drag to recenter the main canvas.

- **Events display**: when **View → Events** is on, events render on the minimap with their active-page graphic (character or tile). Events with no graphic on any page are hidden so the minimap stays clean.
