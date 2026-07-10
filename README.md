# Maker Studio

A modern, feature-rich tile map editor built as a **replacement for RPG Maker XP**'s game editor,
with upgraded features and quality-of-life improvements. It reads and writes `.rxdata` files directly,
so existing projects work without conversion — plus
dockable panels, multi-tile brushes, per-tile properties, unlimited extended layers, multi-tileset
support, unlimited autotiles, a built-in shadow system, a full event editor, an in-editor game
simulator, and a JavaScript mod system.

## Download

Get the latest installer from the [**Releases**](https://github.com/Toskan4134/maker-studio/releases/latest)
page — Windows, macOS (Apple Silicon), and Linux. The app auto-updates from these releases.

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
[`Integrations/`](Integrations/) (e.g. La Base de Sky), then download the editor app above. Each
integration is also published as a `.zip` in the separate **Maker Studio Integrations** release on
the [Releases](https://github.com/Toskan4134/maker-studio/releases) page.

## About this repository

This repository hosts **documentation, integrations, and releases** only. The application source
code is maintained in a private repository.
