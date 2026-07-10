# Maker Studio — La Base de Sky v1.1.x integration

Maker Studio plugin build for **La Base de Sky (LBDS) v1.1.x** — a Spanish fork of Pokémon
Essentials v21.1.

> **Requires:** La Base de Sky **v1.1.0** or newer (the 1.1.x line).

This is the 1.1.x sibling of the `[LBDS1.2.0] Maker Studio` build. Both LBDS releases share the same
Essentials v21.1 engine base — `TilemapRenderer`, `Debug_Passability`,
`$PokemonSystem.autotile_animations`, `Plugins/` auto-loader, and a bundled Ruby stdlib (so
`require 'json'` works). The two builds carry the same fixes and are split only so the download
matches your installed LBDS line — the engine base is the same on both, so either build runs on
either version; the folder name just marks which line it is named for.

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
in-game menu then launches it from its default install location, and it auto-updates itself. The
editor stores its project mods, config and stats under `Plugins/MakerStudio/003_Editor/`.

## Install

1. Copy the **`MakerStudio`** folder from this package into your game's **`Plugins/`** directory
   (final path: `<game>/Plugins/MakerStudio/`).
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
