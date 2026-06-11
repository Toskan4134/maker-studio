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

The Layer Panel lists every layer -- native, extended, and shadow layers alike, plus the fog / panorama / custom layer groups described below.

- **MS badge**: Extended layer rows, the fog/panorama (and any mod-added) group rows, and the shadow group row carry a small **MS** badge — these features require the MakerStudio plugin in-game (see [MS-Exclusive Feature Indicators](interface-guide.md#ms-exclusive-feature-indicators)). Native layer rows have no badge because they work in stock RMXP. Hide the badges via **View → Show MS-Exclusive Indicators**.
- **Eye icon**: Toggle layer visibility on and off.
- **Opacity slider**: Adjust the overall transparency of the layer. Dragging the slider adjusts opacity only — it no longer reorders the layer.
- **Drag a layer row**: Drag an extended layer by its name to reorder it. (Dragging from the eye icon, opacity slider, or delete button does nothing, so you can use those controls freely.)
- **Right-click**: Rename a layer.
- **Click a shadow sub-row**: Select that shadow — its sub-row highlights, a cyan outline draws on the canvas, and (in Dim mode) only that shadow recovers full opacity while others stay dimmed. Press `Ctrl+D` to deselect.

## Fog, Panorama, and Custom Layer Groups

Besides tile layers, the Layer Panel hosts **image layer groups** — full-screen graphics drawn above or below your tiles. Two groups are always there:

- **Fog Layers** — drawn *above* all tiles, like RPG Maker XP's fog, but you can stack as many as you want. Images come from `Graphics/Fogs/`. New fog layers start at 20% opacity.
- **Panorama Layers** — drawn *beneath* all tiles, replacing the tileset's single panorama. Images come from `Graphics/Panoramas/`. New panorama layers start at full opacity. See [Map Management](map-management.md#panorama-layers-and-battleback) for how existing tileset panoramas are picked up automatically.

Both groups work the same way:

- **+** on the group row adds a layer; each layer gets its own sub-row with edit and delete buttons.
- The **group eye icon** shows/hides every layer in the group at once; opacity is set per layer in the edit popup.
- The **edit popup** picks the image with the standard image picker (live preview, favourites, Browse) and offers per-layer **hue**, **opacity**, **blend mode** (normal/add/subtract/multiply), **zoom**, **scroll X/Y** speeds, **Follow camera** (lock the image to the screen), and — for world-anchored layers — a **Parallax** slider (0–1): `1` moves with the map, `0.5` is the classic RMXP panorama half-speed, `0` stays fixed on screen.
- Everything is rendered live on the editor canvas (scrolling included) and in-game by the MakerStudio plugin, clipped per map so connected maps don't bleed into each other.

**Custom layer groups**: mods can register extra groups of the same kind, each with its own `Graphics/` subfolder and its own draw priority (below or above the tiles). They appear as additional group rows in the Layer Panel and are saved inside the map file, so they keep rendering in-game even when the mod isn't installed.

Above-tile groups (fog and custom groups with priority ≥ 0) are listed near the top of the panel; below-tile groups (panorama and negative-priority custom groups) sit at the bottom, mirroring their draw order.

## Collision Overlay

Press C to toggle the collision overlay. This displays passage flags directly on the canvas as directional arrows and blocked/open indicators. The overlay reads from the tileset's base values combined with any per-tile overrides on extended layers.

## Priority Rendering

Tiles with a priority of 1 or higher render above events and are shifted upward on screen, matching RPG Maker XP's standard behavior. Ground tiles (priority 0) render below events.
