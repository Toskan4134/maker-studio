# Database

The **Database** window gathers your project's data editors into one tabbed window, like RPG Maker XP. Open it from the **Database** button on the toolbar or **Tools → Database…**. Switches, Variables, and Tilesets each have their own tab inside the window.

Tabs:

- **Tilesets**, **Switches**, **Variables** — the existing managers, embedded right in the window.
- **Common Events** — reusable command scripts (see below).
- **Animations** — battle/overworld animations (see below).
- The remaining RPG Maker XP tabs (Actors, Items, …) are shown but disabled for now.

> Each editor has its own **Apply** button. Switching tabs or closing the window while you have unsaved changes asks you to confirm first. Every save backs up the original `.rxdata` to a `map-backups` folder beside it.

## Common Events

Common events are command lists you can call from anywhere (via **Call Common Event**) or run automatically.

1. Pick an event from the list on the left. Use **Change Maximum…** to add or remove slots.
2. Set its **Name**.
3. Choose a **Trigger**:
   - **None** — only runs when another event calls it.
   - **Autorun** — runs on its own and pauses the game while it runs (until its condition switch turns off).
   - **Parallel** — runs in the background alongside the game.
4. For Autorun/Parallel, pick a **Condition Switch** — the event only runs while that switch is ON.
5. Build the **command list** using the same editor as map events (Insert / Edit / Delete / drag to reorder, copy & paste, undo/redo).
6. Click **Apply** to save.

## Animations

The Animations editor recreates the RPG Maker XP animation tool, with some extras.

**Set up the animation**

1. Select an animation on the left (or **Change Maximum…** to add slots) and give it a **Name**.
2. Click **Graphic** to choose the spritesheet from `Graphics/Animations/` (and an optional hue shift).
3. Pick a **Position** (Top / Middle / Bottom / Screen) and the number of **Frames**.

**Edit a frame's cells**

Each frame is made of *cells* — pieces of the spritesheet placed over the target.

- Click a cell in the **sheet** (lower right) to add it; click a cell on the **canvas** to select it, and drag to move it.
- With a cell selected, adjust **X / Y / Zoom / Angle / Opacity / Blend / Mirror** and its **Pattern** (which sheet image it shows). Use **Add / Dup / Del** for cells.
- Step through frames with **◀ / ▶** or the numbered frame strip. Turn on **Onion** to see the previous frame faintly behind the current one.
- **▶ Play** previews the animation (frames + screen flashes). **↶ / ↷** undo/redo your edits.
- Keyboard: **Ctrl+C / Ctrl+V / Ctrl+X** copy/paste/cut cells, **Delete** removes the selected cell, **Ctrl+Z / Ctrl+Y** undo/redo.

**Frame tools**

- **+ Frame** adds a frame; **Paste Last** copies the previous frame's cells into the current one.
- **Copy Frame / Paste Frame / Clear Frame** work on the whole current frame.
- **Tweening…** smoothly interpolates a range of cells between two frames (pick which frames, which cells, and whether to tween Pattern, Position/Zoom/Angle, and/or Opacity/Blending).
- **Cell Batch…** sets chosen values (X, Y, Zoom, Angle, Flip, Opacity, Blending, Pattern) on a range of cells across a range of frames.
- **Entire Slide…** slides every cell across a range of frames by a per-frame X/Y amount.

**SE and flash timing**

In the **SE and Flash Timing** list (right), **Add** a timing, then set:

- **Frame** it fires on.
- **SE** — a sound effect (pick name/volume/pitch).
- **Flash** — None / Target / Screen / Hide Target, plus color, alpha, and duration.
- **Condition** — None / Hit / Miss (when the timing applies).

Click **Apply** to save. Your changes are written straight back to `Animations.rxdata`, so they show up in the game.
