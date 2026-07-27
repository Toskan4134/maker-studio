# Getting Started

## Prerequisites

You need an RPG Maker XP project folder -- specifically, a directory that contains `Game.exe` and a `Data/` subdirectory with your map and tileset files. The editor reads and writes `.rxdata` files directly, so no export or conversion step is required.

## Installation

Maker Studio has two parts, and you want both:

1. **The editor app** — the desktop program (Windows / macOS / Linux) you make maps with.
2. **A game-side plugin ("integration")** — a small Ruby plugin you copy into your game project. It is what makes your *game* display the Maker Studio content that plain RPG Maker XP doesn't support (extended layers, shadows, extra autotiles…), and it adds a **Maker Studio** entry to the game's Debug menu to launch the editor. The editor itself runs fine without it, but the game will ignore the extended content until the plugin is installed.

### Step 1 — Install the editor app

Download the build for your system (these links always point to the latest version):

| Platform | Direct download |
|----------|-----------------|
| **Windows** | [`.exe` installer](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x64-setup.exe) (recommended) · [`.msi`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x64_en-US.msi) (alternative) |
| **macOS** | [`.dmg`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_aarch64.dmg) (Apple Silicon) |
| **Linux** | [`.AppImage`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x86_64.AppImage) (universal) · [`.deb`](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_amd64.deb) (Debian/Ubuntu) |

Every build (current and previous versions) is also on the [Releases](https://github.com/Toskan4134/maker-studio/releases) page. Once installed, the app keeps itself up to date automatically.

The installers are **not code-signed** yet, so your OS shows a one-time warning on install:

- **Windows** — run the `.exe` and when SmartScreen says "Windows protected your PC", click **More info → Run anyway**, then follow the installer.
- **macOS** — open the `.dmg` and drag Maker Studio into **Applications**. Gatekeeper blocks the first launch: right-click the app and choose **Open**, or on macOS 15+ go to **System Settings → Privacy & Security** and click **Open Anyway**.
- **Linux** — make the AppImage executable (`chmod +x Maker.Studio_x86_64.AppImage`) and run it. It uses your system's WebKit: if it doesn't start, install `webkit2gtk-4.1` and `gtk3` (Arch) or `libwebkit2gtk-4.1-0` and `libgtk-3-0` (Debian/Ubuntu). The `.deb` installs with `sudo apt install ./Maker.Studio_amd64.deb`. On Linux the AppImage does not self-update — use [**Gear Lever**](https://flathub.org/en/apps/it.mijorus.gearlever) to manage updates (it can auto-update AppImages from GitHub releases).

### Step 2 — Install the game-side plugin

Download the integration that matches your project:

| Your project | Direct download |
|--------------|-----------------|
| Pokémon Essentials **v21.1** (vanilla) | [`PE21.1.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.2.1/PE21.1.Maker.Studio.v1.2.1.zip) |
| Pokémon Essentials **v20.1** (vanilla) | [`PE20.1.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.2.1/PE20.1.Maker.Studio.v1.2.1.zip) |
| Pokémon Essentials **v19.1** (vanilla) | [`PE19.1.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.2.1/PE19.1.Maker.Studio.v1.2.1.zip) |
| Pokémon Essentials **v17.1** (vanilla) | [`PE17.1.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.2.1/PE17.1.Maker.Studio.v1.2.1.zip) |
| La Base de Sky **1.1.x** | [`LBDS1.1.0.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.2.1/LBDS1.1.0.Maker.Studio.v1.2.1.zip) |
| La Base de Sky **1.2.x** | [`LBDS1.2.0.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.2.1/LBDS1.2.0.Maker.Studio.v1.2.1.zip) |
| Pokémon Essentials **BES v5** | [`BES5.Maker.Studio.zip`](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.2.1/BES5.Maker.Studio.v1.2.1.zip) |

> **Note on v19.1, v17.1 and BES v5:** these engines' older tile renderers mean per-tile passage/priority/terrain overrides on a plain (non-extended) tile don't affect in-game collision. Extended layers, extra autotiles, and cross-tileset tiles all work normally.

Then:

1. Unzip the download.
2. Copy the **`MakerStudio`** folder from inside it into your game's **`Plugins/`** directory, so the final path is `<your game>/Plugins/MakerStudio/`. Don't rename the folder — the editor reads project mods, config, and stats from `Plugins/MakerStudio/003_Editor/`.
3. **BES v5 and Essentials v17.1 only:** those engines have no `Plugins/` auto-loader, so instead of copying a folder you paste a single merged `.rb` into the RPG Maker XP Script Editor (in the slot above `Main`) — follow the `README.md` inside the zip.

Each zip also ships its own `README.md` with engine-specific notes, in case anything differs on your setup.

To check it worked: start your game in **Debug mode**, open the Debug menu (F9), and look for **Maker Studio…** — from there you can launch the editor directly (if the app isn't installed yet, that menu shows the download link).

### Keeping the plugin up to date

The plugin ships alongside the editor, so a project can end up running an older one than the app — usually after you update the editor and forget to re-copy the folder. Symptoms are subtle: the game renders something differently from the editor, or a fix you read about in the changelog doesn't apply in-game.

The editor checks for you. When you open a project whose `Plugins/MakerStudio` is older than the app, it offers three choices:

- **Update Now** — downloads the matching integration and replaces the plugin files for you. Your `003_Editor/` folder (project mods, config, stats, and the portable editor if you keep one there) is left untouched. Restart the game afterwards.
- **Download Manually** — opens the release page so you can copy the folder in yourself.
- **Later** — dismisses it for this project until the next editor update.

You can run the check any time from **Help → Check Game Integration…**, which also tells you which build the project has (`PE21.1`, `LBDS1.2.0`, …) and its version.

**BES v5 and v17.1 projects are covered too.** Those builds are one pasted script rather than a folder, so they carry their version as a comment in the script itself. The editor finds it in `Data/Scripts/` or `Scripts.rxdata` and, on **Update Now**, replaces that single script in place — no other script is touched, and the script bank is backed up first.

If the editor finds no integration at all, it says so once per project and points you at the downloads — the editor works fine without one, but your game will ignore extended layers, shadows, extra autotiles and per-tile effects.

One caveat for existing projects: integrations installed before this check existed carry no version marker. A folder plugin is still recognised — the editor works out which build it is from the plugin's own files and shows it as *(detected)* — but a *pasted* script reads as "not installed" until you paste the current one over it once.

## Launching

Run the editor executable. On first launch you will see a welcome screen prompting you to select a game folder. Click **Browse** and navigate to your RPG Maker XP project root (the folder containing `Game.exe`).

The editor remembers your last-opened project, so subsequent launches go straight to the map tree.

## Opening a Map

The Map Tree panel on the left shows every map in your project, organized in the same hierarchy you set up in RPG Maker XP. Double-click any map to open it in a new editor tab. Maps with a dot indicator next to their name have unsaved changes.

When you open a project, a "Loading project..." card appears in the map editor area listing each load step (maps, tilesets, system data, opening the first map, and tileset graphics) with a progress count. The rest of the layout stays visible around it, and the card disappears once everything -- including all tileset graphics -- has loaded, leaving the first map ready to edit.

## Navigation

Moving around the canvas is straightforward:

- **Pan**: Hold Space and drag, or middle-click and drag, or Shift and drag.
- **Zoom**: Ctrl + scroll wheel, or use the + / - buttons in the toolbar. Zoom ranges from 5% to 400% — the low end lets you see a large map in full at once.
- **Status Bar**: Shows your cursor coordinates (X, Y) along the bottom edge of the window.

## Saving

Press Ctrl+S to save the current map. Changes are written directly to the corresponding `.rxdata` file. Every save first backs up the previous file into `Data/map-backups/` (the newest 10 backups per file are kept), so you can always revert if something goes wrong, and writes are crash-safe — a crash or power loss mid-save can never leave a half-written file. Unsaved work is also autosaved in the background every few minutes; see [Map Management → Autosave and Crash Recovery](map-management.md#autosave-and-crash-recovery).

## Building from Source

If you prefer to build the editor yourself:

```bash
npx tauri build              # Production build
npm run tauri:dev            # Dev mode with hot reload
```
