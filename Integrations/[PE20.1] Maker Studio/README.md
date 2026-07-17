# Maker Studio — Pokémon Essentials v20.1 integration

Maker Studio plugin build for **vanilla Pokémon Essentials v20.1**.

> **Requires:** Pokémon Essentials **v20.1**.

## What you get

The full Maker Studio feature set, rendered in-game:

- **Extended layers** (up to 16 total) with per-layer visibility and opacity.
- **Per-tile effects**: opacity, rotation, flip H/V, hue, saturation, lighting.
- **Cross-tileset painting** — tiles from any tileset on any map.
- **Extra autotiles** by name, beyond RMXP's 7 slots (animated ones included).
- **Shadows**: generated at runtime from the source tiles + config (no PNGs to ship).
- **Fog, panorama and custom layer groups** with parallax and scroll.
- **Map versioning**: a switch/variable swaps the whole map (tiles + events) in place.
- **Non-4×4 character sheets** for events.
- **Move Route frame actions** (`ms_frame_*`).
- Collision and terrain honour everything above (extended layers, extra autotiles,
  cross-tileset tiles, per-tile passage/priority/terrain overrides).
- Debug map previews (map connections editor, "Warp to Map") show the **full** map,
  not just the three native layers.

## What's in this package

```
MakerStudio/                 <- copy THIS folder into your game's Plugins/
  meta.txt
  000_Settings.rb
  001_Core/
  002_Integration/
  003_Editor/
    README.txt               editor download + launch notes
```

The desktop editor application is **not bundled** — you install it separately (see below). The
in-game menu then launches it from its default install location, and it auto-updates itself.

## Install

1. Copy the **`MakerStudio`** folder from this package into your game's **`Plugins/`** directory
   (final path: `<game>/Plugins/MakerStudio/`). Essentials v20.1 auto-loads plugins from `Plugins/`.
2. Download and install the editor app:
   **https://github.com/Toskan4134/maker-studio/releases/latest**
   (Windows `-setup.exe`, macOS `.dmg`, Linux `.AppImage`/`.deb`).
3. Launch your game in **Debug mode** → Debug Menu (F9) → **Maker Studio... → Open Maker Studio**.
   If the app isn't installed, the menu shows the download link.

> The plugin folder must stay named `MakerStudio` — the editor reads its project mods, config and
> stats from `Plugins/MakerStudio/003_Editor/`.

## Docs

User guides: https://github.com/Toskan4134/maker-studio (docs/) ·
Mods: https://github.com/Toskan4134/maker-studio-mods
