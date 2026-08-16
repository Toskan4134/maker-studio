# Mod Marketplace

The Marketplace is where you discover, install, and update community mods without leaving the editor. Mods are JS extensions that add tools, panels, exporters, menu items, and more — see the [Mod Development docs](https://github.com/Toskan4134/maker-studio-mods) for what they can do, or [Publishing a Mod](https://github.com/Toskan4134/maker-studio-mods/blob/main/PUBLISHING.md) if you want to share one.

## Opening the Marketplace

Open the **Mods** menu and click **Mod Manager**. The window has two tabs at the top:

- **Installed** — the mods currently loaded in your editor.
- **Marketplace** — the catalog of available mods.

Switch to **Marketplace** to browse.

## Browsing

The Marketplace shows a card for each available mod with an icon, name, author, star count, short description, and tags.

- **Search** matches name, author, description, mod id and tags. Press Escape (or the ✕) to clear it.
- **All / Installed / Updates** switches which mods are listed, each with its own count — the quickest way to see what you already have or what has a new version waiting.
- **Tags** opens a searchable list of every tag with the number of mods carrying it. Tick as many as you like and choose whether a mod has to match **any** of them or **all**. The tags you picked stay visible next to the button; click one to drop it. A tag on a card also filters by it.
- The count on the right (`12 of 340`) tells you how much the filters are hiding, and **Clear filters** puts everything back.
- The two small buttons next to the sort order switch between **cards** and a **compact list** that fits many more mods on screen. Your choice and the sort order are remembered.

Long lists load in batches — click **Show N more** at the bottom to reveal the next ones.

Click **Changelog** on a card to open the release notes for that mod's latest version in a dialog. The notes are shown as formatted Markdown (headings, lists, links, and code render the way they do on GitHub).

## Verified vs Tampered vs Unverified Mods

Every card shows a chip next to the mod name that reflects the SHA-256 integrity check against the registry's pinned hash:

- **Verified** (green) — the release asset's SHA-256 matches the hash pinned in the registry. The bytes you would download are exactly what was reviewed.
- **Tampered** (red) — the release bytes do not match the registry's pinned SHA-256. The **Install and Update buttons are disabled** and cannot be clicked. A tooltip on the greyed-out button explains why.
- **Unverified** (yellow) — the hash could not be checked yet (network error, asset not yet fetched). You can still install, but the consent dialog shows the unverified path with an extra confirmation step.
- **Checking...** — the asset is being downloaded and hashed. The button enables or disables once the result is known.

Verified does not mean the mod is safe to run; it means the bytes match what the registry maintainer pinned. Always read the description and check the author before installing.

## Mods That Need a Newer Editor

Every mod declares which version of the Mod API it needs. When a mod needs a newer one than your Maker Studio provides, its card shows an amber **Needs a newer editor** chip and the **Install / Update button is disabled** — the tooltip names the version required. Update Maker Studio (**Help → Check for Updates**) and the mod installs normally.

This also applies to updates of a mod you already have: if a new release of it starts requiring a newer API, the update is held back until you update the editor, and your installed version keeps working meanwhile. A mod that somehow got installed anyway shows up as **error** in the Mod Manager with the required version in its message, and stays inactive rather than half-running.

## Installing a Mod

Click **Install** on a card. A consent dialog appears showing:

- The mod's name and verification status.
- The list of capabilities it requests (read/write inside its own folder, access project files, show dialogs, etc.).
- Cancel / Install buttons.

If you accept, the editor downloads the release, verifies the SHA-256 hash against the registry's pinned value, unzips the mod into your mods folder, and activates it immediately. A toast confirms the install. The mod now appears in the **Installed** tab.

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

You can select and copy any text inside an expanded row — id, folder path, error message, log lines — handy when reporting a mod bug. The same goes for Marketplace cards and the Changelog dialog: select the description, author, or release notes to copy.

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

**"Tampered" chip (red)** — the release asset's SHA-256 does not match the hash pinned in the registry. Install and Update are blocked (buttons are disabled). This means the asset was replaced or corrupted after the registry entry was created. Report the mod so the registry maintainer can investigate.

**"manifest id mismatch"** — the zip's `manifest.json` declares a different id than the registry entry. Likely the wrong asset was uploaded. Report the mod.

**Install/Update button greyed out** — an install is already in progress (hover the button to see the current step: Downloading, Verifying, Installing), the card shows a red **Tampered** chip meaning the release failed its SHA-256 check and install is blocked, or the card shows an amber **Needs a newer editor** chip and you need to update Maker Studio first.

**Project install disabled** — open a project first. The Project install path needs a `Plugins/MakerStudio/003_Editor/Mods/` folder, which only exists inside a real project.
