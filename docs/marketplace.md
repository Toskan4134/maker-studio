# Mod Marketplace

The Marketplace is where you discover, install, and update community mods without leaving the editor. Mods are JS extensions that add tools, panels, exporters, menu items, and more — see the [Mod Development docs](https://github.com/Toskan4134/maker-studio-mods) for what they can do, or [Publishing a Mod](https://github.com/Toskan4134/maker-studio-mods/blob/main/PUBLISHING.md) if you want to share one.

## Opening the Marketplace

Open the **Mods** menu and click **Mod Manager**. The window has two tabs at the top:

- **Installed** — the mods currently loaded in your editor.
- **Marketplace** — the catalog of available mods.

Switch to **Marketplace** to browse.

## Browsing

The Marketplace shows a card for each available mod with an icon, name, author, star count, short description, and tags. Use the search box to filter by name, author, or description. Click any tag chip to filter to that tag; click it again to clear.

Click **Changelog** on a card to expand the release notes for that mod's latest version.

## Verified vs Unverified Mods

Every card shows one of two chips next to the mod name:

- **Verified** (green) — the mod's release was signed with the author's minisign key and the registry has the public key. The signature was checked before install.
- **Unverified** (yellow) — no signature was available. The mod can still be installed, but you have to confirm a second time and tick "I understand this is unverified code from the internet".

Verified does not mean the mod is safe to run; it means the bytes you downloaded match what the signer published. Always read the description and check the author before installing.

## Installing a Mod

Click **Install** on a card. A consent dialog appears showing:

- The mod's name and verification status.
- The list of capabilities it requests (read/write inside its own folder, access project files, show dialogs, etc.).
- Cancel / Install buttons.

If you accept, the editor downloads the release, verifies the signature (when present), unzips the mod into your mods folder, and activates it immediately. A toast confirms the install. The mod now appears in the **Installed** tab.

### Where the mod is installed

Two destinations:

- **Global** (default) — `%APPDATA%/maker-studio/Mods/`. Available in every project.
- **Project** — `<your-project>/Plugins/MakerStudio/003_Editor/Mods/`. Only available when this project is open. Useful if a collaborator should automatically get the mod when they open the project.

Switch the default with the **Global / Project** toggle at the top of the Marketplace. Project install is disabled until you open a project.

## Updating Mods

The editor checks for mod updates:

- Every time you open a project (right after mods load).
- Once an hour while the app is open.
- When you click **Refresh** in the Marketplace header.

When an update is available you get a toast that says "N mod updates available" with an **Open Mods** button. Open the Mods window — the **Installed** tab shows an orange **Update** badge next to each affected mod. Click the **Update** button to install the new version. Your settings and any per-mod stored data stay intact.

## Uninstalling

In the **Installed** tab, expand any mod that was installed from the Marketplace and click **Uninstall**. The mod's folder is deleted and the editor reloads. The Marketplace card returns to the **Install** state.

You can also uninstall from the Marketplace tab — same button on the card.

## Reading the status badge

Each row in the **Installed** tab shows a coloured status:

- **active** (green) — loaded and running with no errors logged.
- **load error** (red) — the mod failed to load (syntax error, bad manifest, import threw). Expand the row to see the error message.
- **runtime errors** (red) — the mod loaded fine but logged errors after starting. Expand the row and open **Logs** to see what went wrong.
- **disabled** (grey) — turned off via the **Disable** button. Re-enable to load it.
- **blocked** (red) — install blocked by a required Pokémon Essentials plugin (missing or version mismatch). The reason explains which plugin.

You can select and copy any text inside an expanded row — id, folder path, error message, log lines — handy when reporting a mod bug. The same goes for Marketplace cards: select the description, author, or changelog to copy.

## What if there's no internet?

The Marketplace caches everything for 1 hour. If your connection is down, browsing falls back to the last known catalog and release info. Installing requires fresh downloads.

## Privacy and Network

Three hosts the Marketplace contacts:

- `raw.githubusercontent.com` — to fetch the registry index.
- `api.github.com` — for release metadata and star counts.
- `objects.githubusercontent.com` (and related GitHub CDN) — for downloading release assets.

No data is sent back. The editor identifies itself with a `Maker-Studio-Marketplace` user-agent.

## Troubleshooting

**"Could not load registry"** — GitHub is unreachable or rate-limited. Wait a minute and click Refresh.

**"signature did not verify"** — the release was modified after signing, or the registry's pubkey is wrong. Install is blocked. Do not bypass; report the mod.

**"manifest id mismatch"** — the zip's `manifest.json` declares a different id than the registry entry. Likely the wrong asset was uploaded. Report the mod.

**Install button greyed out** — usually means the install is in progress. Hover the button to see the current step (Downloading, Verifying, Installing).

**Project install disabled** — open a project first. The Project install path needs a `Plugins/MakerStudio/003_Editor/Mods/` folder, which only exists inside a real project.
