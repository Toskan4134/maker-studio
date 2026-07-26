# Integrations

Engine/kit-specific builds of the Maker Studio game-side plugin. Each integration adapts the plugin
to a particular RPG Maker XP base (a specific Pokémon Essentials version, a kit/fork, or a
non-Essentials project). Download the one matching your project, copy its `MakerStudio/` folder into
your game's `Plugins/`, then install the editor app from the
[Releases](https://github.com/Toskan4134/maker-studio/releases/latest) page.

The editor application itself is the same across integrations and is **not bundled** — each
integration only ships the engine-side plugin code plus download links. Most integrations install by
copying their `MakerStudio/` folder into `Plugins/`; older engines without a `Plugins/` auto-loader
(e.g. the BES build) ship a single merged `.rb` you paste into the Script Editor — see each
integration's own `README.md`.

## Available integrations

| Integration | Target | Requires |
|-------------|--------|----------|
| [`[LBDS1.1.0] Maker Studio`](<[LBDS1.1.0] Maker Studio>) | La Base de Sky 1.1.x (fork of Essentials v21.1) | La Base de Sky v1.1.0+ (1.1.x line) |
| [`[LBDS1.2.0] Maker Studio`](<[LBDS1.2.0] Maker Studio>) | La Base de Sky 1.2.0+ (fork of Essentials v21.1) | La Base de Sky v1.2.0+ |
| [`[PE21.1] Maker Studio`](<[PE21.1] Maker Studio>) | Vanilla Pokémon Essentials v21.1 | Essentials v21.1 |
| [`[PE20.1] Maker Studio`](<[PE20.1] Maker Studio>) | Vanilla Pokémon Essentials v20.1 | Essentials v20.1 |
| [`[PE19.1] Maker Studio`](<[PE19.1] Maker Studio>) | Vanilla Pokémon Essentials v19.1 | Essentials v19.1 |
| [`[PE17.1] Maker Studio`](<[PE17.1] Maker Studio>) | Vanilla Pokémon Essentials v17.1 | Essentials v17.1 (RGSS `Game.exe`); paste-in install |
| [`[BES5] Maker Studio`](<[BES5] Maker Studio>) | Pokémon Essentials BES v5 (fork of Essentials v16.2) | BES v5 (runs on RGSS `Game.exe` or mkxp); paste-in install |

## Adding a new integration

1. Create `Integrations/<[TAG] Name>/` with a `README.md` (target + requirements + install steps).
2. Inside it, add the `MakerStudio/` plugin folder (start from an existing integration and adapt the
   Ruby in `001_Core/` + `002_Integration/` to the target engine).
3. Keep `003_Editor/` as download links only — **never** commit the editor binary.
4. On the next release, CI zips every folder here into the separate "Maker Studio Integrations"
   release and syncs this folder to the public `maker-studio` repo.
