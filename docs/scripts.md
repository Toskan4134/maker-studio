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

## Saving

Click **Save** to write everything back to `Data/Scripts.rxdata`. Your previous file is backed up to
`Data/Scripts.rxdata.bak` first, so you can always roll back. Closing the window with unsaved changes
asks you to confirm.

> **Tip:** After saving, run your game to make sure your edits compile — a syntax error in a script
> will stop the game from starting, just like in RPG Maker XP.

## Open in VS Code

If you prefer a full external editor, click **Open in VSC**. This opens the `Data/Scripts` folder in
[Visual Studio Code](https://code.visualstudio.com/).

This button is for projects that have **extracted** their scripts into separate `.rb` files in
`Data/Scripts/` (for example with a `scripts_extract.rb` script). If that folder doesn't exist yet,
Maker Studio tells you to extract first. VS Code must be installed with its `code` command available
on your PATH (in VS Code: **Command Palette → "Shell Command: Install 'code' command in PATH"**).

> If a project's scripts are already extracted, `Scripts.rxdata` only contains a small loader, so the
> in-editor list will show just one entry (`Main`). Edit the real files in `Data/Scripts/` via the
> VS Code button instead.
