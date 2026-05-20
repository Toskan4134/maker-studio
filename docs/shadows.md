# Shadows Guide

## Overview

The shadow system generates dynamic shadows from selected tiles. Shadows are computed at runtime when the game runs -- no shadow images are stored in the map data. You can create multiple independent shadows per map, each with its own settings.

## Creating a Shadow

1. Use the Select tool to highlight the tiles on the canvas that should cast shadows.
2. Open the shadow layer controls and choose "Generate Shadow."
3. A shadow is created from the silhouettes of the selected tiles.

## Shadow Configuration

Click a shadow's sub-row in the Layer Panel to select it, then open the configuration popup. Available settings:

- **Name**: Custom label for the shadow. Shown in the Layer Panel. Leave blank to keep the default `Shadow N`. When generating from a disconnected selection, the name is suffixed `(1)`, `(2)`, ... per piece.
- **Direction** (0--360°): Compass angle the shadow points away from the source. The popup shows an 8-button compass grid (N/NE/E/SE/S/SW/W/NW) plus a free-angle slider. `180°` (south, downward) is the default.
- **Height** (0--2): Length of the shadow as a multiplier of the source tile height. `0` lays the shadow flat, `1` matches source height, `2` doubles it.
- **Tint**: Colour the silhouette is filled with. Default black. Use a colder colour for dusk shadows, warmer for sunset, etc.
- **3D shadow**: When checked, a second copy of the shadow is generated anchored at the sprite's top edge (instead of the base) and merged into the same bitmap. Use **2nd Offset X / Y** to position it manually — there's no automatic placement because the editor can't tell from a sprite where its "top" cast should land. Set the second offset so the two shadows form the cast you want.
- **Opacity** (0--255): How dark the shadow appears. The default is 89 (~35%).
- **Offset X / Y**: Fine-tune position in 0.25-tile increments after the geometry from direction + height is applied.

Diagonal directions automatically shear (skew) the silhouette so the cast leans, not just translated. Pure east/west (90°/270°) collapse the drop to a thin line — that's expected; use 3D shadow + the second offset to add a top cast that combines into a fuller side-shadow shape.

## Disconnected Selections

If your selection has multiple separated groups of tiles (gaps between them), the editor automatically splits them into separate shadow layers — one per connected group. Each shadow gets its own bounds and entry in the Layer Panel.

## Migrating Old Shadows

Shadows saved before the direction/height update render blank on load. Open each one in the shadow editor, pick the new direction + height, and click Apply to migrate it. The old `stretch` value has no automatic conversion.

## Animated Shadows

When a shadow is generated from animated autotiles, the resulting shadow becomes an animated sprite sheet. Its frames cycle in sync with the source autotile, so animated water or lava tiles produce smoothly animated shadows.

## Presets

Click **Presets…** in the shadow configuration popup header to open the preset manager. Save the current direction / height / tint / opacity / offsets combination as a named preset and apply it later to any new shadow with one click. The dialog also supports rename, overwrite, and delete. Presets are stored per-install (shared across all your projects) and remembered across sessions.

## Managing Shadows

- You can have multiple shadows per map, each fully independent.
- Toggle any shadow's visibility from the Layer Panel.
- Adjust overall opacity per shadow.
- Click a shadow's sub-row to display a cyan selection outline on the canvas, making it easy to identify which shadow is which.
- Shadows never compound opacity where they overlap -- overlapping shadows maintain uniform density rather than stacking.

## Selection Outline

Clicking a shadow's sub-row in the Layer Panel displays a cyan outline around that shadow on the canvas, and highlights the row itself in the panel. This outline is visible only for the currently selected shadow and does not appear in-game. Press `Ctrl+D` to deselect.

## Dim Mode Interaction

When Dim mode is on (`D`) and the shadow layer is not the active layer, shadows render at reduced opacity so the underlying tiles stay visible. Selecting a shadow recovers full opacity for **just that one** — every other shadow stays dimmed. This makes it easy to identify and tweak a single shadow without losing the dimmed view of the rest. Toggle Dim off if you want every shadow at full opacity simultaneously.
