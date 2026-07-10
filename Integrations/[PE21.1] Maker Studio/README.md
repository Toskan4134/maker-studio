# Maker Studio — Pokémon Essentials v21.1 integration

Maker Studio plugin build for **vanilla Pokémon Essentials v21.1** (the 2023-07-30 release).

> **Requires:** Pokémon Essentials **v21.1**.

This is the vanilla-v21.1 sibling of the `[LBDS1.2.0] Maker Studio` build (La Base de Sky is itself a
fork of Essentials v21.1). It is functionally identical; the differences are adaptations for vanilla
v21.1 and its mkxp runtime:

- The `Debug_Passability` patch (a class LBDS adds but vanilla v21.1 lacks) is guarded with
  `if defined?(Debug_Passability)`, so it simply no-ops on vanilla. The debug passability overlay
  won't reflect extended layers — debug-only, harmless.
- `$PokemonSystem.autotile_animations` (an LBDS option absent from vanilla) is read through
  `respond_to?`, so shadow animation never `NoMethodError`s on vanilla.
- **No `json` stdlib**: mkxp ships a Ruby without the `json` library, so the build bundles its own
  parser (`MakerStudio::JSON`) instead of `require 'json'` (which raises `LoadError` on mkxp).
- **No `MenuHandlers.get`**: vanilla v21.1's `MenuHandlers` has no `get` method (added in a later
  release), so the debug-menu parent is registered with an unconditional, idempotent
  `MenuHandlers.add` rather than a `get` existence check (which `NoMethodError`s on vanilla).
- **F12 soft-reset survival**: mkxp re-evaluates every script on an F12 soft-reset (restoring the
  engine's original methods), so each monkeypatch aliases the original *once* but (re)defines its
  override *unconditionally*. Otherwise the override — notably `Game.load_map` — is lost after a
  reset and the map reloads with no Maker Studio content.

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
   (final path: `<game>/Plugins/MakerStudio/`). Essentials v21.1 auto-loads plugins from `Plugins/`.
2. Download and install the editor app:
   **https://github.com/Toskan4134/maker-studio/releases/latest**
   (Windows `-setup.exe`, macOS `.dmg`, Linux `.AppImage`/`.deb`).
3. Launch your game in **Debug mode** → Debug Menu (F9) → **Maker Studio... → Open Maker Studio**.
   If the app isn't installed, the menu shows the download link.

> The plugin folder must stay named `MakerStudio` — the editor reads its project mods, config and
> stats from `Plugins/MakerStudio/003_Editor/`.

## Compatibility notes

The core classes Maker Studio builds on are present in vanilla v21.1: `TilemapRenderer`,
`AutotileExpander`, `GameData::TerrainTag`, `Game_Map::X_SUBPIXELS`, `Game.load_map`,
`MenuHandlers`/`EventHandlers`, `Translator`/`Compiler`, `PluginManager` + `Plugins/` auto-load,
`RPG::Cache`. The adaptations needed for vanilla and its mkxp runtime are the five points listed
above: the two LBDS-class guards, the bundled JSON parser (no `json` stdlib), the unconditional
debug-menu `add` (no `MenuHandlers.get`), and the F12 soft-reset override-survival idiom.

## Docs

User guides: https://github.com/Toskan4134/maker-studio (docs/) ·
Mods: https://github.com/Toskan4134/maker-studio-mods
