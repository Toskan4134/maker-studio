# Map Versions

**Map Versions** let one map hold several different states of itself — for example a
**normal** town, a **cinematic** variant, and a **destroyed** version after a story event — without
creating separate maps. In‑game you switch between versions with a single **switch or variable**, and
the whole map (tiles, events, fog, shadows) changes **in place**: the player stays exactly where they
are, and the world transforms around them. No Transfer Player, no loading a parallel map.

Everything is stored **inside the same map file** (`MapXXX.rxdata`), as pure additions, so the map still
opens in stock RPG Maker XP and the base version is never modified.

## When to use it

- A location that changes after a story beat (intact → ruined, day → festival, sealed → opened).
- A cinematic / cutscene dressing of a normal map.
- Seasonal or time‑of‑day re‑dressings of the same place.

Versions share the map's **width and height** (they're the same map), and they share the same
`map_id`, so Transfer Player commands, quests, and connections that point at this map keep working
across every version.

## Where to manage versions

You can reach map versions from several places — they all drive the same actions:

- **Versions** button in the **toolbar** — shows the current version as a badge (e.g. `V2/3`) and opens
  the **Version Manager**.
- **Map → Map Versions…** in the menu bar.
- The **Version** control at the right end of the **status bar** (quick switch + menu).
- **Right-click a map** in the Maps tree → **Versions** (quick switch) or **Manage Versions…**.

### The Version Manager

The Version Manager lists every version — **Version 1 (Base)** plus your extra versions — with the
switch/variable that activates each one. From here you can **Switch to**, **Set Selector (⚙)**,
**Rename (✎)**, **Delete (🗑)**, and create a **New Version**. The version you're currently editing is
marked *editing*, and any selector overlaps are flagged with a **⚠** warning.

### Creating a version

1. Open the map you want to version.
2. Click **＋ New Version**. A dialog asks two things:
   - **Name** for the version.
   - **Start from** — either **Duplicate an existing version** (pick **Version 1 (Base)** or any other
     version to copy its tiles, events and layers) or **Blank (empty map)** to start from scratch at the
     base map's size.
3. The canvas switches to the new version — paint tiles, place events, add fog/shadows, then **Ctrl+S**
   to save. Edits to a version only affect that version; the base map is untouched.
4. Switch between **Version 1 (Base)** and your versions at any time from any of the controls above.
   Unsaved edits are saved automatically before switching.

> **Numbering stays tidy:** versions are numbered **Version 1 (Base), Version 2, Version 3 …**. If you
> delete a version in the middle, the ones after it are **renumbered down** so there's never a gap.

## Choosing what activates a version

Click **⚙** (Selector) to bind the active version to game state:

- **Variable equals value** — the version is active while the chosen variable equals the value you set
  (e.g. *Variable 0027 = 4*).
- **Switch is ON** — the version is active while the chosen switch is ON (e.g. *Switch 0088*).

In‑game, set that switch/variable however you like (a Control Switches / Control Variables event
command, a script, etc.). The moment its value matches, the map swaps to that version on the spot.

**Resolution order:** versions are checked by number (v1, v2, v3 …) and the **first one whose selector
matches wins**. If none match, the **base map (v0)** is shown. If two versions can be active at once,
the switcher shows a **⚠ selector overlap** warning so you can fix the ambiguity.

State lives in the variable/switch, so it's saved with the player's save file automatically — load a
save that was in the "destroyed" version and the map comes back destroyed.

## Things to know

- **Same size:** all versions share the base map's dimensions. Resize the base map before adding many
  versions.
- **Self‑switches are shared:** because every version is the same `map_id`, an event's self‑switch
  (A/B/C/D) is shared across versions. Handy for persistent door/chest state, but keep it in mind.
- **Running events stop on swap:** when the map changes version, any autorun/parallel event from the old
  version is stopped so it can't keep running on an event that no longer exists.
- **Getting stuck:** if a new version adds a wall where the player is standing, they could be trapped —
  design transitions so the player's tile stays walkable, or move them with the event that triggers the
  change.
- **File size:** each version stores a full copy of the map inside the file, so a map with many large
  versions makes a bigger `.rxdata`. This is normal.

## Requirements

Map Versions need the **Maker Studio game plugin** installed (it ships with the integration). The
runtime swap is supported on the v21.1‑family builds (LBDS 1.1/1.2 and vanilla Pokémon Essentials
v21.1). Editing versions in the editor works regardless of which build you ship.
