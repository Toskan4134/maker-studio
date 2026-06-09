# Layers Guide

## Native Layers (0--2)

The editor provides three native layers that are fully compatible with RPG Maker XP. These layers use the map's assigned tileset and standard tile IDs. Native layers are exactly what RMXP reads and renders, so anything you paint here will appear correctly when the game runs in RMXP alone.

## Extended Layers (3+)

Beyond the three native layers, the editor supports unlimited extended layers. Extended layers offer several features not available in RMXP:

- **Cross-tileset tiles**: Paint tiles from any tileset, not just the map's default one.
- **Extra autotiles**: Use named autotiles beyond RMXP's eight-slot limit.
- **Per-tile effects**: Set individual opacity, rotation, hue, saturation, lighting, and flip for each tile.
- **Per-tile passage, priority, and terrain**: Override game properties on a per-tile basis.

Extended layer data is embedded inside the map's `.rxdata` file. It is invisible to RMXP itself, but the editor's runtime plugin reads and renders it in-game.

## Layer Panel

The Layer Panel lists every layer -- native, extended, and shadow layers alike.

- **MS badge**: Extended layer rows, fog group rows, and the shadow group row carry a small **MS** badge — these features require the MakerStudio plugin in-game (see [MS-Exclusive Feature Indicators](interface-guide.md#ms-exclusive-feature-indicators)). Native layer rows have no badge because they work in stock RMXP. Hide the badges via **View → Show MS-Exclusive Indicators**.
- **Eye icon**: Toggle layer visibility on and off.
- **Opacity slider**: Adjust the overall transparency of the layer. Dragging the slider adjusts opacity only — it no longer reorders the layer.
- **Drag a layer row**: Drag an extended layer by its name to reorder it. (Dragging from the eye icon, opacity slider, or delete button does nothing, so you can use those controls freely.)
- **Right-click**: Rename a layer.
- **Click a shadow sub-row**: Select that shadow — its sub-row highlights, a cyan outline draws on the canvas, and (in Dim mode) only that shadow recovers full opacity while others stay dimmed. Press `Ctrl+D` to deselect.

## Collision Overlay

Press C to toggle the collision overlay. This displays passage flags directly on the canvas as directional arrows and blocked/open indicators. The overlay reads from the tileset's base values combined with any per-tile overrides on extended layers.

## Priority Rendering

Tiles with a priority of 1 or higher render above events and are shifted upward on screen, matching RPG Maker XP's standard behavior. Ground tiles (priority 0) render below events.
