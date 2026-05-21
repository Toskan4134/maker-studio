# Interface Guide

## Menu Bar

- **Project**: Open Project, New Map, **Import & Export Maps** (Import from JSON; Export as JSON / PNG / GIF / WebP), Save, Save All, Run Game, Export/Import Configuration, Reset Layout, Toggle DevTools
- **Edit**: Undo, Redo, Switches, Variables, Tilesets (manager), Resize/Shift Map, Change Tileset, Select All, Deselect, Copy/Cut/Paste (+ all-layers variants), Delete Selection, Generate Shadow from Selection, Delete All Shadows, Keyboard Shortcuts
- **View**: Panel toggles (Maps, Tile Palette, Layers, Tile Properties, Tile Info, Events, Minimap), Show Grid, Show Collision, Show Events, Dim Inactive Layers, Dark Mode, Zoom In/Out/100%, Reset Layout
- **Tools**: Tool selection (Brush/Eraser/Fill/Rectangle/Eyedropper/Select/Pan), Rotate CW/CCW, Flip Horizontal/Vertical
- **Mods**: Mod Manager (+ any mod-contributed menu items and panels)
- **Info**: Check for Updates, About Maker Studio, Stats

## Toolbar

The toolbar sits at the top of the window and provides quick access to common actions:

💾 Save | ▶ Run | ▶ Sim Map | ➕ New | 🖌️ 🧹 🪣 ⬜ 💧 ⬚ ✋ | 🔍 Zoom | Switches | Variables | Tilesets | Grid | Col | Dim | ☀/☾

- **Save, Run, New** — emoji + text for visibility.
- **Sim Map** — opens the [Game Simulator](game-simulator.md) on the current map with player input enabled.
- **Tools** — emoji only. Hover to see the tool name and keyboard shortcut.
- **Brush tool** — hover to reveal a size slider popup (1–5).
- **Zoom** — hover to reveal zoom in/out controls.
- **Switches / Variables** — open a searchable manager dialog where you can rename entries inline.
- **Tilesets** — opens the tileset manager for creating, editing, and deleting tilesets.
- **Grid / Col / Dim** — text-only toggle buttons.
- **Theme** — sun/moon toggle switch. Thumb left = light mode (☀ visible on the right); thumb right = dark mode (☾ visible on the left). Your choice is remembered across sessions.
- **Reset Layout** — available in the Project menu.

## Map Tree (left panel)

The Map Tree shows a hierarchical view of every map in your project. You can:

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

The status bar displays useful context at a glance: cursor coordinates (X, Y), the event name under your cursor, the current tool, brush size, active layer, zoom level, and whether undo history is available.

## Dockable Panels

Every panel in the editor can be dragged, floated as a separate window, and rearranged to suit your workflow. If you ever want to start fresh, use View then Reset Layout to restore the default arrangement.

- **Detach a panel**: right-click a tab or empty header area and pick **Detach to floating window**. The panel pops out as a draggable, resizable floating window inside the editor.
- **Floating windows stay on-screen**: if a floating panel is dragged or resized past the editor bounds, it auto-snaps back inside on release.
- **Reattach**: drag the floating window's tab back onto a dock zone, or close the panel.

## Minimap

Bottom-right panel. Shows a scaled view of the entire map (all native + extended layers + shadows) with a yellow viewport rectangle. Click or drag to recenter the main canvas.

- **Events display**: when **View → Events** is on, events render on the minimap with their active-page graphic (character or tile). Events with no graphic on any page are hidden so the minimap stays clean.
