# Scripts Editor

The **Scripts** editor lets you view, reorder, rename, add, delete, and edit your project's Ruby
scripts directly from Maker Studio — the same scripts RPG Maker XP keeps in `Data/Scripts.rxdata`.
It is handy on bases that don't ship a `scripts_extract.rb`, so you can work with the code without
leaving the editor.

Open it from the **Scripts** button on the toolbar (next to **Database**) or **Tools → Scripts…**.

## The window

- **Left:** the list of scripts, in the order RPG Maker XP runs them. Section dividers (titles made of
  `=` signs) appear dimmed.
- **Right:** the selected script's code, with Ruby syntax highlighting, line numbers, and find &
  replace (`Ctrl+F` — see [Finding things](#finding-things)). Edit it like any code editor; standard
  `Ctrl+Z` / `Ctrl+Y` undo/redo work inside it.

## Managing scripts

Use the small buttons above the list:

- **＋** — add a new script below the selected one (type its name, then start editing on the right).
- **🗑** — delete the selected script.
- **▲ / ▼** — move the selected script up or down. Order matters: scripts run top to bottom.
- **Drag** a script up or down the list to reorder it — a line shows where it will drop.
- **Double-click** a script's name to rename it.

A dot (•) in the title bar means you have unsaved changes.

## Finding things

- **Find in the current script** — press `Ctrl+F` to open a find & replace bar at the top of the code
  editor. It supports match case, regular expressions, whole-word matching, and replace / replace all,
  and it follows the editor's language and theme.
- **Search all scripts** — press `Ctrl+Shift+F` to open a search panel that looks through **every**
  script's title and code at once. Results appear grouped by script with line numbers and the match
  highlighted; click a result to jump straight to that line, even in a different script. Toggle **Aa**
  for case-sensitive matching or **.*** for regular expressions (an invalid pattern simply shows no
  results). Very broad searches stop at 500 results — narrow the query to see the rest.

Both shortcuts are rebindable under **Help → Keyboard Shortcuts...** (the "Scripts" section).

## Where the code comes from

The picker at the top of the script list chooses **what this window is editing**:

- **Scripts.rxdata** — the packed scripts, exactly as RPG Maker XP stores them. This is the default.
- **Data/Scripts** — your extracted `.rb` files, offered whenever that folder exists. If your project
  is extracted (its `Scripts.rxdata` is just the one-line loader), the window opens here by itself
  instead of showing you the stub.
- **Plugins** — one entry per folder inside your project's `Plugins/`, so you can read and fix a
  plugin without leaving the editor.

The picker only lists what your project actually has, so it never sends you to an empty folder. The
window title tells you where you are (`Scripts · MakerStudio`), and **Open in VSC** opens whichever
folder you are browsing.

Drag the line between the list and the code to make the list wider — long script names have room, and the width is remembered next time. For a folder source the list shows its `.rb` files grouped by subfolder — click a folder to fold it,
and it stays folded next time you come back. Files are edited and saved exactly like packed scripts;
**Save** writes back only the files you actually changed.

You can manage the folder from here too:

- **+** creates a **new file** or **new folder** — next to whatever file is open, or at the top level.
- **Right-click a folder** to create a file or folder *inside it*, rename it, or delete it (deleting
  tells you how many files go with it first).
- **Right-click a file** to rename or delete it. Double-clicking its name renames it too.
- A left click on a folder simply opens or closes it.
- **Pick several at once**: Ctrl+click files (or folders) to add them, Shift+click for a range of
  files, then delete the lot in one go.
- **Drag things around**: drop a file or folder onto another folder to move it inside, or **anywhere outside the
  list** to take it back out to the top level — the list is outlined while that is where it would
  land. To move something up *one* level instead, drop it on the parent folder's header, or
  right-click it and pick *Move to "<folder>"*. The folder you are about to drop into is outlined, and
  dragging one of several selected items moves them all.

Only the **order** stays with `Scripts.rxdata` — on disk, files sort themselves.

## Snippets

The toolbar's **Snippets…** button opens the same saved snippet library the Event Editor's script
boxes use, so a helper you saved while writing an event is one click away here — and anything you
save here shows up there. A new snippet is cut from whatever you have **selected** in the code (or
from the whole script when nothing is selected), and using one asks whether to **Insert at cursor**
— dropping it where the caret is, over the selection if there is one — or **Replace** the whole
script. Folders, import and export work exactly as described in the
[Events Editor guide](events-editor.md#script-snippets).

## Saving

Click **Save** (or press `Ctrl+S`) to write everything back to `Data/Scripts.rxdata`. Your previous file is backed up to
`Data/Scripts.rxdata.bak` first, so you can always roll back. Closing the window with unsaved changes
asks you to confirm.

> **Tip:** After saving, run your game to make sure your edits compile — a syntax error in a script
> will stop the game from starting, just like in RPG Maker XP.

## Open in VS Code

If you prefer a full external editor, click **Open in VSC**. This opens whichever folder you are
browsing — a plugin's own folder when one is picked, else `Data/Scripts` — in
[Visual Studio Code](https://code.visualstudio.com/).

This button is for projects that have **extracted** their scripts into separate `.rb` files in
`Data/Scripts/` (for example with a `scripts_extract.rb` script). If that folder doesn't exist yet,
Maker Studio tells you to extract first. VS Code must be installed with its `code` command available
on your PATH (in VS Code: **Command Palette → "Shell Command: Install 'code' command in PATH"**).

> If a project's scripts are already extracted, `Scripts.rxdata` only contains a small loader, so
> there is nothing useful to edit there. Maker Studio notices and opens **Data/Scripts** for you —
> you only need this button if you would rather work in VS Code.
