# Maker Studio — La Base de Sky integration

Maker Studio plugin build for **La Base de Sky (LBDS)** — a Spanish fork of Pokémon Essentials v21.1.

> **Requires:** La Base de Sky **v1.2.0** or newer.

## What's in this package

```
MakerStudio/                 <- copy THIS folder into your game's Plugins/
  meta.txt
  000_Settings.rb
  001_Core/
  002_Integration/
  003_Editor/
    Mods/                    bundled project mods
    README.txt               editor download + launch notes
```

The desktop editor application is **not bundled** — you install it separately (see below). The
in-game menu then launches it from its default install location, and it auto-updates itself.

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
