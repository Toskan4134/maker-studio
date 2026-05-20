# Integrations

Engine/kit-specific builds of the Maker Studio game-side plugin. Each integration adapts the plugin
to a particular RPG Maker XP base (a specific Pokémon Essentials version, a kit/fork, or a
non-Essentials project). Download the one matching your project, copy its `MakerStudio/` folder into
your game's `Plugins/`, then install the editor app from the
[Releases](https://github.com/Toskan4134/maker-studio/releases/latest) page.

The editor application itself is the same across integrations and is **not bundled** — each
integration only ships the engine-side plugin code plus download links.

## Available integrations

| Integration | Target | Requires |
|-------------|--------|----------|
| [`[LBDS1.2.0] Maker Studio`](<[LBDS1.2.0] Maker Studio>) | La Base de Sky (fork of Essentials v21.1) | La Base de Sky v1.2.0+ |

## Adding a new integration

1. Create `Integrations/<[TAG] Name>/` with a `README.md` (target + requirements + install steps).
2. Inside it, add the `MakerStudio/` plugin folder (start from an existing integration and adapt the
   Ruby in `001_Core/` + `002_Integration/` to the target engine).
3. Keep `003_Editor/` as download links only — **never** commit the editor binary.
4. On the next release, CI zips every folder here as a release asset and syncs them to the public
   `maker-studio` repo.
