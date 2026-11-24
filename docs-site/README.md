# Maker Studio — Documentation Site

A bilingual (English / Español), **multi-version** documentation website for **Maker Studio**, built
with [Astro Starlight](https://starlight.astro.build/). It lives inside the public `maker-studio` repo
(`docs-site/`) and bundles two doc sets into one searchable, themed site:

- **User Guide** — end-user guides for map makers (sourced live from this repo's `../docs`).
- **Mod Development** — the mod API reference (sourced live from `../../maker-studio-mods/docs`).

The header shows the editor version on guide pages and the API version on mod pages.

| URL base | Guide source | Mod API source |
|---|---|---|
| `/` | App `main` | Mods `main` |
| `/vX.Y.Z/` | App tag | Mods `main` |
| `/mods-vX.Y.Z/` | App `main` | Mod API tag |

Each build includes Pagefind search and Spanish routes under its `es/` path.
When the selected version predates a page, the selector opens that version's home page in the same language.

## Quick start

```bash
npm ci
npm run dev        # local dev server at http://localhost:4321
npm run build      # static build into dist/
npm run preview    # serve the built dist/ locally
```

## How content is loaded

The Starlight loader feeds the source Markdown directly into Astro's content collection at build
and dev time. Edit the docs in their source repos. [Loader](src/lib/docs-loader.ts) · [Content configuration](src/content.config.ts)

The loader produces two kinds of entries:

1. **Guide + mod pages** (every locale) — read from the two source repos and rendered through Astro's
   markdown pipeline. For each it adds Starlight frontmatter (title, description, sidebar order/label)
   and rewrites internal links to be relative (Astro does not base-prefix links inside Markdown
   bodies, so relative links work under each build's base). Links to examples and downloads use
   the selected Mod API ref. Links to submission templates, listing terms, and the registry file
   use the current registry on `main`.
2. **The splash/home page per locale** — synthesized from [`src/data/splash.json`](src/data/splash.json):
   the hero is emitted as Starlight `hero` frontmatter (rendered by Starlight), and the body is built
   as raw HTML mirroring Starlight's CardGrid/LinkCard markup. The matching layout CSS lives in
   [`src/styles/theme.css`](src/styles/theme.css) (loader-injected HTML doesn't get the components'
   scoped styles). The hero logo is served from `public/logo.png`.

### Source modes (env-driven)

| `DOCS_SOURCE` | Reads from | Used by |
|---|---|---|
| `local` (default) | sibling repos on disk (`../docs`, `../../maker-studio-mods/docs`) — shows uncommitted changes | `npm run dev` / `build` locally |
| `remote` | `raw.githubusercontent.com/<repo>/<ref>/docs/` | CI versioned builds |

A 404 in remote mode (a page that didn't exist at an old tag) is skipped, not fatal.

Guide screenshots live in `public/guide-media/` as WebP files. Link to them relative to the
source guide so the image also opens on GitHub. Use `../docs-site/public/guide-media/` from
`docs/` and `../../docs-site/public/guide-media/` from `docs/es/`. The loader serves local images
under the build's base path and uses the app ref's GitHub Raw URL in remote builds.
Wrap each screenshot in a link to the same file to enable the site's image viewer.

### Versioning env (set per build by CI)

```
DOCS_SOURCE                          # local or remote
DOCS_APP_REF, DOCS_MODS_REF           # git refs (default: main)
DOCS_VERSION, DOCS_MODS_VERSION       # latest or vX.Y.Z
DOCS_VERSIONS_JSON, DOCS_MODS_VERSIONS_JSON  # [{id,label}] for the two selectors
SITE_URL, SITE_BASE, OUT_DIR          # canonical origin, URL base, output directory
```

`mod-api.d.ts` and `app-strings.json` are served from the mods repository at the build's mods ref.

## Translations (Español)

Spanish is a first-class source locale: its raw pages live as plain Markdown in `docs/es/` (this repo's
user guides) and `../../maker-studio-mods/docs/es/` (mod API), mirroring the English layout. The loader
rewrites relative Markdown links to the matching locale. Use the translated heading's anchor in
each translation and check both versions of the built page after changing a heading.

Pages without a Spanish version fall back to English at their `/es/…` URL via Starlight's built-in
"not translated" notice.

### Adding a language

The locale set is single-sourced from [`src/data/splash.json`](src/data/splash.json). To add one (say
French):

1. In `splash.json`, add a `"fr"` entry to `locales` (label + lang), add the `fr` key to each
   `sidebarGroups` group, and add the `fr` key to every translatable text field (hero, intro,
   features, links, …). Missing keys fall back to English, so partial translations are safe.
2. Create the source folders `docs/fr/…` (this repo) and `../../maker-studio-mods/docs/fr/…` with the
   translated Markdown.

That's it — `astro.config.mjs` (locales + sidebar translations) and `src/lib/docs-loader.ts` (page
list + splash pages) both derive from `splash.json`, so **no code changes** are needed. Source pages
that don't exist yet for a locale are simply skipped (the English page shows at that URL).

## Adding a doc page

The set (and sidebar order) of guide/mod pages is the explicit `GUIDE_ORDER` / `MOD_ORDER` lists in
[`src/lib/docs-loader.ts`](src/lib/docs-loader.ts) — not folder discovery, so ordering stays curated
and local/remote builds load the exact same set with no extra API calls. To add a page, create the
source `docs/<slug>.md` (in `../docs` for guides or `../../maker-studio-mods/docs` for mods) **and add
its `<slug>` to the matching list**. In local `npm run dev`/`build`, a source `.md` that isn't in the
list logs an `unlisted doc (won't be built)` warning so a forgotten entry is caught early.

## Deploying (GitHub Pages)

The [Pages workflow](../.github/workflows/docs-pages.yml) runs on pushes to `main` affecting the
docs, site, or workflow, on a daily schedule, and on manual dispatch. Scheduled runs skip publication
when the source trees and tag lists match the deployed build. CI merges its root, app-version, and
API-version builds into a single `dist/` for GitHub Pages.

One-time setup: in the repo's **Settings → Pages**, set **Source = GitHub Actions** and the custom
domain `makerstudio.toskan.es` (Cloudflare CNAME `makerstudio` → `toskan4134.github.io`, DNS only).
The site publishes at `https://makerstudio.toskan.es/` (latest at the root; older versions under
`/vX.Y.Z/`); the old `toskan4134.github.io/maker-studio` URLs 301-redirect there.

## Theme

The website maps the desktop editor's default light and dark palettes, typography, control radii,
and hover surfaces to Starlight tokens. The 4 px control radius and 6 px panel radius follow the
editor's shared UI. Text on accent-filled web buttons uses a contrasting foreground in each mode.
Check links, tables, and keyboard focus at desktop and mobile widths when updating the theme.
[`src/styles/theme.css`](src/styles/theme.css)

## Project layout

```
docs-site/
├── astro.config.mjs            # Starlight config; locales + sidebar translations derived from splash.json
├── public/
│   ├── favicon.png             # the editor's own app icon
│   └── logo.png                # brand logo, served for the splash hero
└── src/
    ├── assets/logo.png          # brand logo (the editor's app icon)
    ├── data/splash.json         # single source of truth: locale set + all splash/home copy
    ├── content.config.ts        # wires the custom docs loader into the docs collection
    ├── lib/docs-loader.ts       # custom loader: guide/mod pages + synthesized splash pages, in memory
    ├── components/
    │   ├── Search.astro          # search override: suggested links before typing
    │   ├── Header.astro          # override: adds the version switcher
    │   ├── VersionSelect.astro   # editor version dropdown
    │   └── ModVersionSelect.astro # Mod API version dropdown
    ├── styles/theme.css          # editor-matching palette (dark + light) + splash card layout
    └── content/docs/             # empty — all pages are loaded in memory
```
