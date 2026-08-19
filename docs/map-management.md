# Map Management

## Creating a New Map

Choose Map then New Map from the menu, or click the **+** button in the **Maps panel header** (next to the map list, mirroring the add-layer **+** in the Layers panel). Fill in the details:

- **ID**: Prefilled with the **lowest free ID starting at 1**, so IDs left free by deleted maps get reused instead of the numbering climbing forever. You can type a different one — any ID from 1 to 999 that no existing map uses. If it is taken, the field says so and Create stays disabled.
- **Name**: The map's display name.
- **Width / Height**: Dimensions in tiles.
- **Tileset**: Which tileset the map uses for its native layers.
- **Parent**: Where the map sits in the hierarchy tree. The list is ordered and indented exactly like the Map Tree, and you can filter it by **name or ID** — type `cave` or `042`. Pick **(root)** for a top-level map.

Click Create to add the map to your project.

### Creating a map inside another map

To nest the new map under an existing one, **right-click that map** in the Map Tree and choose **New Map Here…**. The New Map dialog opens with that map already filled in as the **Parent**, and the new map is created as its child. (You can still change the parent before clicking Create.)

## Changing a Map's ID

Right-click the map in the Map Tree and choose **Change ID…**, then type a free ID from 1 to 999. Maker Studio renames `Map###.rxdata`, moves the map's entry in `MapInfos.rxdata` (its child maps stay attached), rewrites **every Transfer Player command in the project** that pointed at the old ID, follows the **player start position** if it was on that map, and renames the map's baked shadow images. The toast tells you how many Transfer Player commands were updated.

Map IDs written inside **Ruby scripts** are not touched — nothing can find them reliably, so check those by hand. Unsaved maps are saved first, since the rewrite happens on disk.

## Opening Maps

Double-click any map in the Map Tree to open it in a new editor tab.

When you reopen a project, Maker Studio brings back the **exact set of map tabs you had open**, in the same left-to-right order, and makes the map you were last editing the active one — so a session picks up where you left off rather than starting on the first map in the list. (Opening a map file directly — by double-clicking it in your file manager — still wins over this and opens just that one map.) You can also **drag map tabs to reorder them**; the new order is what gets restored next time. Your folded map-tree folders come back the way you left them too. All of this is remembered per project, on this computer only, and nothing is written into the project itself.

## Duplicating a Map

To make a full copy of a map as a **brand-new map** (a separate `map_id`, not a version):

- Right-click a map in the Map Tree and choose **Duplicate Map**, or
- Open the map and choose **Map → Duplicate Map** from the menu.

The copy is named *"<original> (copy)"*, placed under the same parent, and opened automatically. It is a faithful clone — tiles, events, layers, shadows/fog, **and any map versions** come along. If the source map has unsaved edits, they're saved first so the copy is current. This is different from a **map version** (same map, swapped in-game); use Duplicate Map when you want an independent map you can change without affecting the original.

## Copying a Map Between Projects

You can copy a whole map from one project to another with **Ctrl+C / Ctrl+V** in the map list, the same way RPG Maker XP does:

1. Turn on **Edit → Cross-Project Clipboard** (it's off by default). With it off, copy/paste still works **within the same window**, but the copy is not mirrored to your OS clipboard, so a second window can't see it.
2. Open two Maker Studio windows on the two projects (File → Open Project… in a second window).
3. In the source project's map list, click the map you want to copy and press **Ctrl+C**. The whole map — tiles on every layer, events, shadows/fog/panorama layers, and any map versions — is serialized to your OS clipboard.
4. In the destination project's map list, click a map that will sit above the new one (this both focuses the panel and picks the landing spot) and press **Ctrl+V**. The map is imported as a **new map placed directly below the selected map** (at the root of the tree if no map is selected) and opened automatically.

Tips:

- Copying across windows needs **Cross-Project Clipboard** on. Within a single window the toggle doesn't matter — use **Duplicate Map** for a same-project clone.
- The copy goes through your OS clipboard (when the toggle is on), so it survives closing the source window. It is large, though — paste soon to avoid leaving a big payload on the clipboard.
- The pasted map lands right below the selected map; drag it elsewhere afterwards if you want it nested under a different parent (or use **New Map Here…** for a fresh nested map).
- The map's tileset is referenced by the tile graphics it uses; if the destination project lacks those tilesets/autotiles, the tiles still paste with their original ids but will render wrong until you add the missing graphics. Extended-layer tiles keep their original tileset reference.

## Resizing and Shifting Maps

Open the resize dialog from Map then Resize / Shift Map, or right-click a map in the Map Tree and choose Resize/Shift.

### Resizing

Enter the new width and height. A **9-way anchor pad** decides where the existing content lands in the new canvas — pick the center to keep the map centered as it grows or shrinks, or a corner/edge to anchor there. The dialog auto-computes the shift from your anchor choice.

### Wrap

A **Wrap** toggle (on by default) controls what happens to content that falls outside the new bounds:

- **Wrap on**: tiles, events, and shadows that move off one edge reappear on the opposite side (toroidal wrap).
- **Wrap off**: anything outside the new bounds is dropped.

You can also shift content manually by overriding the computed shift values.

### Preview & Undo

An SVG preview shows where your content will sit inside the new canvas before you commit. The resize is a single undo step — press Ctrl+Z afterward to restore the original size and content.

## Changing a Map's Tileset

Right-click a map in the Map Tree and choose Change Tileset, or use Map then Change Tileset from the menu. Pick from the searchable list and click Apply — the map repaints with the new tileset's graphics right away, no reload needed. Changing the tileset only affects the native layers, and does not remap tile IDs (existing tiles keep their numbers, so they may look different under the new tileset). Extended layers can continue to use tiles from any tileset.

## Panorama Layers and Battleback

In RPG Maker XP the **panorama** (the scrolling background image behind a map) and the **battleback** (the battle background) belong to the *tileset*, so every map sharing a tileset shares one of each. Maker Studio replaces the single panorama with **panorama layers** edited from the Layer panel, and still lets you change the battleback right from the map you're editing.

### Panoramas — the "Panorama Layers" group

Panoramas are edited in the **Layer panel**, in the **Panorama Layers** group — exactly like fog layers. (The old **Change Panorama…** menu items are gone; there is no separate panorama dialog anymore.)

- Click the group's **+** to add a panorama layer; use a layer's sub-row to edit or delete it. The group's eye icon shows/hides all panorama layers at once.
- The edit popup picks the image from `Graphics/Panoramas/` with the same image picker used everywhere else (live preview, favourites, Browse), and offers per-layer **hue**, **opacity**, **blend mode**, **zoom**, **scroll** speeds, **Follow camera**, and a **Parallax** slider (0–1): `1` moves 1:1 with the map, `0.5` matches RPG Maker XP's classic half-speed panorama scrolling, and `0` stays fixed on screen. The slider hides while **Follow camera** is checked (that already means fully screen-locked). New panorama layers default to full opacity and parallax `0.5`.
- You can stack **several panorama layers** on one map. They are drawn on the editor canvas beneath your tiles, so you see exactly how they look while mapping, and in-game each map's panoramas are clipped to that map (they don't bleed onto connected maps).
- Each [map version](map-versions.md) keeps its own panorama layers — a "destroyed" version can have a different sky than the normal one. Press **Ctrl+S** to save them with the map.

If a map already has a panorama from its tileset (or a version override saved with an older build), the editor shows it automatically as a single panorama layer. As long as you leave that layer untouched, nothing changes on disk — the map keeps using the stock tileset panorama, plugin or no plugin. The moment you edit the panorama layers (change, add, or delete one), they become part of the map: the MakerStudio plugin renders them in-game and quietly stops the tileset's own panorama from drawing twice (the tileset itself is never modified). Like fog layers, edited panorama layers need the plugin to show in-game, so the group carries the MS badge.

> Mods can also register their own **custom layer groups** — extra image-layer groups like Panorama Layers or Fog Layers, drawn beneath or above the tiles at a priority the mod chooses. They appear as additional groups in the Layer panel and are saved with the map, so they keep working in-game even without the mod installed.

### Battleback

There are three ways to change the battleback, all opening the same image picker:

- **Menu bar → Map → Change Battleback…** (next to Change Tileset…).
- **Right-click a map** in the Map Tree → **Change Battleback…**.
- When you're editing a [map version](map-versions.md), the version's right-click submenu has **Change Battleback (this version)…**.

Pick a battleback from `Graphics/Battlebacks/`. Battlebacks come in families of files that share one name: `<name>_bg`, `<name>_base0`, `<name>_base1`, `<name>_message` in Pokémon Essentials 19.1 and newer (and LBDS), or `battlebg<Name>`, `playerbase<Name>`, `enemybase<Name>` in Essentials 17.1 and BES. Either way the picker lists **one entry per family** and stores that shared name, not an individual file. Leave it blank to clear it.

You only pick the background: **the bases the battlers stand on come with it.** Pick `cave1` and battles on that map use `cave1_base0` / `cave1_base1`, narrowed to the environment you're standing in whenever that variant exists — `cave1_water_base0` on water, `cave1_ice_base0` on ice. If your battleback has no bases of its own, the game's usual bases for the environment are used instead, so nothing is ever left without one.

> **Needs the plugin.** Left to itself, Pokémon Essentials 19.1 and newer name the bases after the *environment*, not after your battleback — a cave battleback on a grassy map shows grass bases. The MakerStudio plugin is what puts your battleback first. Essentials 17.1 and BES already worked this way.

What the change does depends on what you're editing:

- **On the base map, you are editing the tileset** — exactly like RPG Maker XP. The new battleback is written to the tileset immediately and applies to **every map that uses that tileset** (other open maps update on the spot). In a stock RPG Maker XP game that's all it takes; Pokémon Essentials / LBDS games ignore the tileset field and read the backdrop from map metadata instead, so the MakerStudio plugin bridges the value onto that field in-game — on every supported base (Essentials 17.1, 19.1, 20.1, 21.1, LBDS and BES), each of which keeps that metadata in a different place. The base-map item carries no MS badge because the editor write itself is plain RMXP.
- **On a map version, you set a per-version override**, stored in the map file (press **Ctrl+S** to keep it) and applied in-game by the MakerStudio plugin — so those items carry the MS badge.

The **battleback is not shown on the map canvas** — it only appears in battles in-game — but it is stored and editable here.

> Maps saved with an older Maker Studio build may still contain a per-map base override; the editor now ignores it (the base map always shows the tileset's settings) and removes it the next time you save that map. The same in-game plugin also stops the tileset's own fog from drawing twice when a map uses Maker Studio fog layers.

## Map Audio (Auto-Change BGM / BGS)

Each map can carry its own background music and background sound, played automatically when the player enters it — the same **Auto-Change BGM / BGS** fields RPG Maker XP puts in Map Properties. Open the dialog from:

- **Menu bar → Map → Map Audio…**, or
- **Right-click a map** in the Map Tree → **Map Audio…**

The dialog has one row per track:

- Tick **Auto-Change BGM** (or **Auto-Change BGS**) to turn that track on for this map. While the box is unticked the picker is greyed out and the map plays whatever was already playing.
- Click the **…** button to choose the file from your project's `Audio/BGM/` (or `Audio/BGS/`) folder, with the usual volume and pitch sliders and a play button to preview it.

Click **OK** to write the change **straight to the map file** — there is no separate save step and no unsaved-changes marker, so **Ctrl+S is not needed** (this works like changing a base map's battleback). **Cancel** discards it.

These are **native RPG Maker XP fields**, so the music plays in any game with no plugin installed — that's why the menu items carry no MS badge.

> **One setting per map, shared by every version.** Map audio is stored on the base map file, so all of a map's [versions](map-versions.md) play the same BGM/BGS — there is no per-version override (the same limitation as Change Tileset). To change the music for a specific situation, use the **Play BGM** / **Play BGS** event commands instead.

## Deleting a Map

Right-click a map in the Map Tree and choose Delete Map, then confirm the deletion. Any child maps are moved up to the deleted map's parent so they are not lost. The map's `.rxdata` file is removed from disk.

You can also **delete the selected map from the keyboard**: with the Maps panel focused, press **Delete**. The same confirmation prompt appears (child maps are moved up, the `.rxdata` file is removed).

## Exporting Maps

The editor supports four export formats. All exports stream their work in the background — the bottom status bar shows a progress bar while frames render and encode, and a toast pops up when the export finishes with an **Open folder** button that reveals the output file in your OS file explorer.

### Export as JSON

Map then Export Map then Export as JSON saves a complete dump of the map including extended layers and shadow data. This is useful for backups, sharing, or re-importing.

### Export as PNG

Map then Export Map then Export as PNG renders the entire map to a PNG image at full resolution.

### Export as GIF (Animated)

Map then Export Map then Export as GIF creates an animated GIF showing autotile and shadow animations in motion. GIF is limited to a 256-color palette, so heavily shaded maps may look posterized — prefer WebP for those.

### Export as WebP (Animated)

Map then Export Map then Export as WebP creates an animated WebP. WebP supports the full 24-bit color space, so it preserves shadow gradients and fog colors GIF cannot. Before saving, the editor asks whether the animation should loop forever or play once and stop — pick "Play once" if you intend to embed the file somewhere that should not repeat. Output is lossless by default.

## Importing Maps

Map then Import Map from JSON loads a previously exported JSON file as a new map in your project.

## Setting the Player Start Position

The player start position is where the player appears when a new game begins. To set it:

1. Right-click any tile on the map you want the game to start on.
2. Choose **Set as Player Start** from the menu.

A green **Start** marker appears on that tile, and the position is saved to your project immediately (no map save needed). There is only one start position per project — setting a new one moves it. The marker is only drawn on the map it belongs to. To move it, right-click a different tile (on any map) and choose Set as Player Start again.

## Running the Game

Click the green Run button in the toolbar (or use File then Run Game). The editor launches `Game.exe` in debug mode from your project folder.

If any open map has unsaved changes, you are asked first — the editor no longer saves them for you:

- **Save & Run** — saves every map with unsaved changes, then launches.
- **Run Without Saving** — launches the game as your files are on disk, leaving your unsaved edits open in the editor. Handy when you want to check how the map behaves *before* your latest changes.
- **Cancel** — nothing is saved and the game is not launched.

With nothing unsaved there is no prompt; Run launches straight away.

### If the Game Is Already Open

Press Run while a game the editor launched is still running and it asks what you want to do, with three choices:

- **Cancel** — leave things as they are.
- **Close and Reopen** — closes the running game and starts a fresh one. Use this after changing something a running game won't pick up (it only ever closes the game *the editor* started, never one you launched yourself).
- **Open Anyway** — starts a second copy alongside the first.

The question is asked every time. Both answers do something you can't take back — one closes the game you're playing, the other leaves two copies running against the same save files — so there is no "don't warn me again".

### Choosing Which Screen the Game Opens On

On **Windows**, the **Game** tab of **Help → Settings…** has a **Which monitor the game opens on** option. The default, **The same one as the editor**, opens the game on whichever screen you are working on — without it RPG Maker always centres the game on your primary screen. Or pin it to a specific screen with **Always this monitor**. It applies at your next Run, and the window may jump once or twice while the game boots before it settles. On macOS and Linux the option is there but greyed out — Wine/Proton owns the game window. See [Settings](interface-guide.md#settings-help--settings).

### Running on macOS (Wine)

`Game.exe` is a Windows executable, so on macOS the editor launches it through **Wine**. You need a working Wine install: plain Wine on Intel Macs, or **Game Porting Toolkit / Whisky** on Apple Silicon (both expose the `wine`/`wine64` command the editor looks for). The editor creates its own dedicated Wine prefix the first time you press Run, separate from any default `~/.wine`, and suppresses the usual first-run Mono/Gecko install prompts. If Wine isn't installed, Run stops with an error asking you to install it and try again.

### Running on Linux (Proton / Wine / Native)

`Game.exe` is a Windows executable, so on Linux the editor normally runs it through **Proton** or **Wine**. If your project also has a native Linux build (a `Game_Linux` folder next to `Game.exe`, from a native mkxp-z build), the editor detects it and offers that as an option too. The first time you press Run, a dialog lets you pick how to launch:

- **Proton**: choose an installed Proton version (and, if needed, the Steam app id to use). The editor sets up a dedicated Wine prefix for your game the first time.
- **Wine**: launch through your system Wine instead.
- **Native Linux build** (when available): runs `Game_Linux` directly, with no Proton/Wine involved. If it's already running, the editor just focuses its window instead of starting a second copy; otherwise it opens your terminal emulator and launches it there in debug mode.

Your choice is remembered per project, so later runs launch straight away without asking again. To make the dialog reappear later — for example to switch between Proton and the native build — use **File → Clear Proton Preference**. That item only appears when there is actually a Proton/Wine choice to forget: on Linux, with a project open, and only if you launched it through Proton or Wine (a project you run with the native Linux build has nothing to clear).

### Live Reload While the Game Is Running

With the Maker Studio plugin installed, you don't have to restart the game to see an edit. When you
save anything — map tiles, layers, events, tilesets, the database, the map tree — the editor leaves a
small marker in the plugin folder, and the running game notices it within a second and re-applies the
map you're standing on. Tiles, events, passability and the extended layers all come back fresh.

**Graphics count too.** Repaint a tileset, an autotile or a character sheet in Photoshop (or whatever
you draw in) and save it over the file: the palette and the map editor refresh on their own, and the
running game reloads those bitmaps on its next check — no restart, no re-entering the map.

It only ever fires while the editor is open on that project (the editor is what writes the marker),
and you can turn it off per project with `LIVE_RELOAD = false` in
`Plugins/MakerStudio/000_Settings.rb` — or, without leaving the game, from the debug menu under
**Maker Studio… → Live Reload (on save)**, which flips it for that session.

### Opening the Saves Folder

**File → Open Saves Folder** opens the folder where the game writes its save files. After your first Run, a **Saves** button in the toolbar does the same thing. Either way, where it lands depends on how the game was launched:

- **Windows**: opens the native saves folder, `%AppData%\<Game>`.
- **macOS**: opens the saves folder inside the Wine prefix the game ran in — macOS runs `Game.exe` through Wine, so the game writes to Wine's `AppData\Roaming`, not to `~/Library/Application Support`.
- **Linux, Proton/Wine**: opens the relevant folder inside the Proton/Wine prefix the game ran in.
- **Linux, native build**: opens `~/.local/share/<GameTitle>/`, where native Linux builds keep their save data.

This makes it easy to back up or clear save files while testing.

## Autosave and Crash Recovery

You still save with **Ctrl+S** as usual, but the editor quietly protects unsaved work in the background:

- Every **5 minutes**, any open map with unsaved changes is snapshotted to a private autosave folder in your user profile. Your real map files are **never** touched by an autosave — there is nothing to clean up and nothing changes in your project.
- Saving a map normally discards its snapshot (it is no longer needed).
- If the editor (or your PC) crashes with unsaved changes, the next time you open that project a notification lists the maps with autosaved work and offers two choices. The notification stays up until you pick one:
  - **Restore** — writes the autosaved changes into the map files and reloads any of those maps you have open. The pre-restore state is kept in the regular `Data/map-backups/` history, so you can still go back if you didn't want the restore.
  - **Discard** — throws the autosaved work away and removes the snapshot, so the notification won't come back for it.
- Closing the notification with the **✕** without choosing leaves the snapshot in place, so you'll be offered the recovery again next session. Use **Discard** to stop the prompt for good.
- Discarding a map's unsaved changes (when closing a tab, switching projects, or exiting) also drops that map's snapshot, so discarded work is never offered for recovery later.

Saves themselves are also crash-safe: the editor writes to a temporary file and swaps it in only once it is fully on disk, so a crash or power loss mid-save can never leave a half-written map file. On top of that, every save first copies the previous file into `Data/map-backups/` (the newest 10 backups per file are kept).

## Opening the Same Project in Two Windows

Running two Maker Studio windows on **different** projects is fully supported (it's how the [Cross-Project Clipboard](interface-guide.md) works). Opening the **same** project in two windows is risky, though: both windows write the same map files, and the last one to save silently wins. The editor detects this and shows a warning when a second window opens a project that is already open elsewhere. You can keep editing, but it's best to close one of the windows.

## Close Confirmation

When you close a tab that has unsaved changes, the editor asks you to confirm:

- **Save**: Saves the map, then closes the tab.
- **Discard**: Closes the tab without saving.
- **Cancel**: Returns to the editor without closing.

## Switching Projects with Unsaved Changes

If you choose **File → Open Project…** or pick a project from **File → Open Recent** while any open map has unsaved changes, the editor opens a Save All / Discard / Cancel dialog before swapping projects:

- **Save All**: Saves every dirty map, then switches to the new project.
- **Discard**: Switches without saving — unsaved edits are lost.
- **Cancel**: Stays on the current project.

This is the same prompt used by Help → Reset App and View → Layout → Refresh Layout, so unsaved work cannot be lost silently by opening a different project.

## "Not a Project Folder" Dialog

When you point the editor at a folder that does not look like an RPG Maker XP project (no `Data/MapInfos.rxdata` inside), it shows a **Not a Project Folder** dialog with two buttons:

- **Choose Another…**: Re-opens the folder picker so you can try a different folder.
- **Go Back**: Returns to your previous project (or to the welcome screen if this was the first launch).

This replaces the previous behaviour where picking a non-game folder left the editor in an empty / stuck state.
