# Git Integration

The **Git** button in the menu bar opens project version control. Maker Studio uses the Git executable installed on your computer. If the project is not a repository yet, initialize it from this window.

## Changes

The Changes tab lists project files Git sees as changed. Select the files to include, enter a commit message, and commit them. Maker Studio commits files saved on disk, so save editor changes first; unsaved edits block Git actions that could overwrite them.

You can discard changes for a selected file. Tracked files return to their last commit; selected untracked files are deleted. The editor reloads affected data when possible. If it cannot reload a change safely, it asks you to reopen the project.

## Commit history

Open **Commit history** to see commits from the repository's branches and refs in a graph. Each row shows the commit subject, any branch or ref labels, author, date, and short hash. Commits appear newest first by displayed author date wherever their parent relationships allow. A spinner appears beside the heading while a page loads. The graph loads the first 100 commits, then automatically loads another page of 100 when you reach the end of the list, up to 1,000. At the limit, a notice says that the 1,000 most recent commits are shown.

When the tab opens, it selects the current branch's commit if it is in the loaded graph; otherwise, it selects the first loaded commit.

At a wide dialog size, the graph sits above the **Changed files** list and comparison preview, which appear side by side. Compact commit rows align the graph, subject and refs, author, date, and hash into columns, so more history fits in the graph. Drag a divider between columns to resize them, or focus it and press **← / →** (hold **Shift** for a larger step). The graph column can shrink to 40px; minimum widths keep the subject, author, date, and hash readable. As you make the dialog narrower, the graph, file list, and preview stack vertically; each panel scrolls independently without adding a scrollbar to the dialog. At the narrowest size, author and date give way to the commit subject, refs, and hash.

Commit dates use **DD/MM/YYYY**. Drag the horizontal divider between the graph and the lower panels to resize the graph from 20% to 80% of the flexible workspace area (50% by default); the lower file and preview panels share the remaining space and can occupy up to 80%. Both areas resize live as you drag. You can also focus the divider and press **↑ / ↓** to adjust it in 5% steps, or **Home / End** to jump to either limit.

Use **↑ / ↓** to move through commits and **Home / End** to jump to the first or last one. Tab focuses only the active commit in the graph.

Select a commit to list its **Changed files**, including each file's status. The list is scoped to your project folder, even when the Git repository also contains other files. Select a file to compare that commit with its first parent using the preview beside the list. The **Styled / Raw text** control appears only for JSON, XML, and Markdown. Styled Markdown renders as Markdown; JSON and XML use syntax highlighting. Other supported code languages always keep syntax highlighting and do not show this toggle. The language is inferred from the file extension (Scripts entries use Ruby); style changes do not affect change marks and reset when you select another file. When both versions exist, the header also offers **Side by side** and **Unified**. Side by side shows aligned before/after panes; Unified shows context and changes interleaved in one pane. Added or deleted text files and Scripts entries show only the version that exists; an existing empty file is shown as empty rather than treated as missing. Syntax styling covers Ruby, JavaScript/JSX, TypeScript/TSX, JSON, Markdown, CSS, HTML, XML, YAML, TOML, Python, shell, and SQL; other text uses plain styling. Scripts, database records, and maps retain structured previews. Maps also have a side-by-side visual comparison.

Image files (PNG, JPEG, BMP, GIF, WebP) show before/after previews. Click an image to open a larger viewer, where you can zoom and drag it. Ogg, MP3, and WAV use app-styled controls when the browser supports the codec: play/pause, elapsed and total time with a seek bar, and volume. MIDI has a matching Play/Stop action. Each side is limited to 16 MiB; larger media files cannot be previewed. Added or deleted media shows only the side that exists; modified media remains side by side.

## Branches and remotes

Choose a local branch and switch to it from the branch controls. Pull downloads remote changes; Push sends local commits to the configured remote. Pull and branch switching require the whole repository to be clean. Switching branches reloads the project, and a pull that changes files also reopens it so the editor reflects the new data. Configure a remote and upstream branch in Git before using Pull or Push.
