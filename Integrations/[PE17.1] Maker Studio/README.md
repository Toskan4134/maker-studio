# Maker Studio — Essentials v17.1 integration

Maker Studio plugin build for **vanilla Pokémon Essentials v17.1**.

> **Requires:** Pokémon Essentials v17.1. Runs on the original RGSS runtime (`Game.exe`,
> Ruby 1.8). The build is written in Ruby-1.8-safe syntax and bundles its own JSON parser
> (`MakerStudio::JSON`), so it needs no `json` library and no modern Ruby features (it also
> loads unchanged on modern-Ruby mkxp ports).

v17.1 is architecturally far from v21.1 — it renders maps with the classic Ruby `CustomTilemap`
(or the hardware `SynchronizedTilemap`, depending on the in-game tilemap view mode; both are
bitmap compositing, no per-tile sprites), uses the integer `PBTerrain` terrain system instead of
`GameData::TerrainTag`, has no `Plugins/` auto-loader, and fires the old `Events.*` hooks. This
build is therefore the same ground-up port as the BES v5 (v16.2) integration, adapted to v17.1:
it draws all Maker Studio content (extended layers, per-tile effects, native-layer "extra" tiles,
shadows, fog) as an **independent overlay sprite system** layered onto the map viewport, and
reimplements collision/terrain against `PBTerrain`.

## Install (different from the v19+ integrations!)

v17.1 has **no `Plugins/` folder auto-loader**, so you cannot just drop a folder in. Instead:

1. Open your project in **RPG Maker XP** → **Tools ▸ Script Editor** (F11).
2. Select the empty slot just **above `Main`**, right-click ▸ *Insert*, and name it `Maker Studio`.
3. Paste the entire contents of **`MakerStudio_PE17.rb`** (in this folder) into that slot.
4. Save. Run the game normally (`Game.exe`).
5. Download + install the editor app:
   **https://github.com/Toskan4134/maker-studio/releases/latest**
6. (Optional, for the editor's project mods/config) create the folder
   `Plugins/MakerStudio/003_Editor/` in your project by hand and copy the `003_Editor/` contents
   from this package into it.
7. In Debug mode press **F9** → choose **“Maker Studio…”** (the default selection is the normal
   debug menu, so pressing C still opens it as before) → **Open Maker Studio** / **Reload Map Data**.

> The `MakerStudio/` folder beside `MakerStudio_PE17.rb` is the maintainable split source. v17.1
> only uses the single concatenated `MakerStudio_PE17.rb`; if you edit the split files, regenerate
> the merged file before shipping.

## What works

- Extended layers (all of them) with per-tile **opacity / rotation / hue / saturation / lighting /
  flip H+V**.
- **Extra autotiles** and **cross-tileset** tiles on both extended and native layers.
- **Shadows** (runtime-generated, animated, 3D mode, editor-baked PNGs).
- **Fog** layers (scroll, hue, opacity, blend, follow-camera), clipped per map.
- Collision / terrain / bush / counter on extended + native-extra tiles, mapped onto `PBTerrain`
  (surf, bridges, tall-grass deep bush, cycling restrictions).
- Connected maps (`$MapFactory`), Continue-from-save, and a **Reload Map Data** hot-reload.
- Debug map previews (map-connections editor, warp-to-map picker) composited via the
  `createMinimap` override.

## Compatibility & limitations (v17.1-specific)

Because v17.1 composites the native layers into shared bitmaps (no per-tile native sprites), a few
v21.1 behaviours can only be approximated — the same set as the BES build:

- **Pure per-tile *passage / priority / terrain* overrides painted on the NATIVE layers (0–2)** —
  i.e. an override on a normal map tile that has *no* autotile_name and *no* cross-tileset reference —
  are **not applied**; the engine's own native collision is used for those cells. Overrides on
  **extended layers, extra autotiles and cross-tileset tiles work fully.**
- **Pure visual effects on a same-tileset NATIVE tile** (e.g. rotating an ordinary map tile in place):
  the effect is drawn as an overlay on top of the original, which is *not* blanked (blanking it would
  drop its native collision). For opaque, full-footprint effects (hue/saturation/lighting/flipH) this
  looks correct; **rotation can reveal the original tile at the corners and opacity < 255 lets it show
  through.** Cross-tileset native tiles *are* blanked and redrawn cleanly. Effects on extended-layer
  tiles are always exact.
- **Shadows use a single fixed z band** (above the floor, below objects/characters). v17.1 has no
  per-native-tile sprites, so the v21.1 per-tile shadow z-splitting over passable vs. solid ground
  isn't reproduced — shadows may sit slightly differently relative to tall native objects.
- **No passability debug overlay** integration (v17.1 has no `Debug_Passability`).
- **Autotile animation** is driven by `Graphics.frame_count / Animated_Autotiles_Frames`, the same
  clock the native tilemap uses, so overlay/shadow autotiles stay in step with the map.
- **Day/night tint**: in tilemap view modes 1/2 the overlay mirrors the tilemap's tone; in mode 0
  the engine tints the whole screen via a viewport post-effect that already covers the overlay —
  both paths keep Maker Studio tiles in step with native tiles.
- **Save data is never modified on disk.** Native cells are blanked only in memory and reloaded fresh
  from `.rxdata` on every map setup.

## Docs

User guides: https://github.com/Toskan4134/maker-studio (docs/) ·
Mods: https://github.com/Toskan4134/maker-studio-mods
