# Maker Studio

<div align="center">

[![Latest release](https://img.shields.io/github/v/release/Toskan4134/maker-studio?style=for-the-badge&label=Latest%20release&color=2ea44f)](https://github.com/Toskan4134/maker-studio/releases/latest)

**Editor — direct download**

[![Windows .exe](https://img.shields.io/badge/Windows-.exe_%28installer%29-0078D4?style=for-the-badge)](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x64-setup.exe)
[![Windows .msi](https://img.shields.io/badge/Windows-.msi_%28alternative%29-0078D4?style=for-the-badge)](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x64_en-US.msi)
[![macOS .dmg](https://img.shields.io/badge/macOS-.dmg_%28Apple_Silicon%29-000000?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_aarch64.dmg)
[![Linux .AppImage](https://img.shields.io/badge/Linux-.AppImage_%28universal%29-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_x86_64.AppImage)
[![Linux .deb](https://img.shields.io/badge/Linux-.deb_%28Debian%2FUbuntu%29-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://github.com/Toskan4134/maker-studio/releases/latest/download/Maker.Studio_amd64.deb)

**Game-side plugin (integrations) — direct download**

[![PE21.1](https://img.shields.io/badge/Plugin-PE21.1-6f42c1?style=for-the-badge)](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.0.0/PE21.1.Maker.Studio.v1.0.0.zip)
[![LBDS 1.1.0](https://img.shields.io/badge/Plugin-LBDS1.1.0-6f42c1?style=for-the-badge)](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.0.0/LBDS1.1.0.Maker.Studio.v1.0.0.zip)
[![LBDS 1.2.0](https://img.shields.io/badge/Plugin-LBDS1.2.0-6f42c1?style=for-the-badge)](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.0.0/LBDS1.2.0.Maker.Studio.v1.0.0.zip)
[![BES5](https://img.shields.io/badge/Plugin-BES5-6f42c1?style=for-the-badge)](https://github.com/Toskan4134/maker-studio/releases/download/integrations-v1.0.0/BES5.Maker.Studio.v1.0.0.zip)

Not sure which files you need? Follow the [**installation guide**](docs/getting-started.md#installation).

</div>

A modern, feature-rich tile map editor built as a **replacement for RPG Maker XP**'s game editor,
with upgraded features and quality-of-life improvements. It reads and writes `.rxdata` files directly,
so existing projects work without conversion — plus
dockable panels, multi-tile brushes, per-tile properties, unlimited extended layers, multi-tileset
support, unlimited autotiles, a built-in shadow system, a full event editor, an in-editor game
simulator, and a JavaScript mod system.

## Download

Use the direct-download buttons at the top of this page, or get any build (current or previous)
from the [**Releases**](https://github.com/Toskan4134/maker-studio/releases/latest)
page — Windows, macOS (Apple Silicon), and Linux. The app auto-updates from these releases.
Step-by-step instructions: [installation guide](docs/getting-started.md#installation).

> [!NOTE]
> The installers are **not code-signed** yet, so your OS shows a one-time warning on install:
>
> - **Windows** — SmartScreen says "Windows protected your PC". Click **More info → Run anyway**.
> - **macOS** — Gatekeeper blocks the first launch. Right-click the app and choose **Open**, or on
>   macOS 15+ go to **System Settings → Privacy & Security** and click **Open Anyway**.
> - **Linux** — no warning, but the AppImage uses your system's WebKit: if the app doesn't start,
>   install `webkit2gtk-4.1` and `gtk3` (Arch) or `libwebkit2gtk-4.1-0` and `libgtk-3-0` (Debian/Ubuntu).

## Documentation

User guides live in [`docs/`](docs/):

- [Getting Started](docs/getting-started.md)
- [Interface Guide](docs/interface-guide.md)
- [Tools](docs/tools.md) · [Layers](docs/layers.md) · [Shadows](docs/shadows.md)
- [Events Editor](docs/events-editor.md) · [Game Simulator](docs/game-simulator.md)
- [Tileset Editor](docs/tileset-editor.md) · [Map Management](docs/map-management.md)
- [Keyboard Shortcuts](docs/keyboard-shortcuts.md)
- [Mod Marketplace](docs/marketplace.md)

## Mods

Maker Studio is extensible via JavaScript mods. Discover and install community mods from the
in-app **Marketplace**, or write your own — see the
[**maker-studio-mods**](https://github.com/Toskan4134/maker-studio-mods) registry for the mod API
reference, tutorials, and publishing guide.

## Integrations

To use Maker Studio with a game, install the matching engine-side plugin from
[`Integrations/`](Integrations/) (e.g. La Base de Sky), then download the editor app above. Every
integration is also published as a `.zip` in a
[**Maker Studio Integrations vX.Y.Z**](https://github.com/Toskan4134/maker-studio/releases?q=integrations&expanded=true)
release per app version — the plugin buttons at the top download the current one. See the
[installation guide](docs/getting-started.md#installation) for step-by-step instructions.

## About this repository

This repository hosts **documentation, integrations, and releases** only. The application source
code is maintained in a private repository.
