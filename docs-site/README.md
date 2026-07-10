# Maker Studio — Documentation Site

A bilingual (English / Español), **multi-version** documentation website for **Maker Studio**, built
with [Astro Starlight](https://starlight.astro.build/). It lives inside the public `maker-studio` repo
(`docs-site/`) and bundles two doc sets into one searchable, themed site:

- **User Guide** — end-user guides for map makers (sourced live from this repo's `../docs`).
- **Mod Development** — the mod API reference (sourced live from `../../maker-studio-mods/docs`).

Each version (`latest` = `main`, plus every `vX.Y.Z` release tag) is built separately and served side by
side with a version switcher in the header.

The theme mirrors the editor's own palette (navy `#1e1e2e`, periwinkle `#7c8aff` accent, Segoe UI),
ships full-text search (Pagefind), and renders a Spanish locale at `/es/`.

## Quick start

```bash
npm install
npm run dev        # local dev server at http://localhost:4321
npm run build      # static build into dist/
npm run preview    # serve the built dist/ locally
```

`npm run dev` / `npm run build` just work — no separate "port" step.

## How content is sourced (no generated files)

**Nothing** is written to disk, and there are **no hand-authored pages on disk** either. A custom
Starlight content loader ([`src/lib/docs-loader.ts`](src/lib/docs-loader.ts)) — wired in via
[`src/content.config.ts`](src/content.config.ts) — feeds every page to Astro's content collection
**in memory** at build/dev time. `src/content/docs/` is empty.

The loader produces two kinds of entries:

1. **Guide + mod pages** (every locale) — read from the two source repos and rendered through Astro's
   markdown pipeline. For each it adds Starlight frontmatter (title, description, sidebar order/label)
   and rewrites internal links to be relative (Astro does not base-prefix links inside Markdown
   bodies, so relative links work under any base — root for `latest`, `/vX.Y.Z` for tagged builds).
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

### Versioning env (set per build by CI)

```
DOCS_SOURCE, DOCS_APP_REF, DOCS_MODS_REF   # local | remote  +  git refs (default "main")
DOCS_VERSION                               # version id ("latest" | "vX.Y.Z")
DOCS_VERSIONS_JSON                         # [{id,label}] list for the header switcher
SITE_PREFIX, SITE_BASE, OUT_DIR            # "" (custom-domain root) or /vX.Y.Z, per-version output dir
```

`mod-api.d.ts` is not hosted locally — its download link points straight at the mods repo on GitHub at
the build's mods ref.

> Do **not** hand-edit guide/mod pages — they aren't files. Fix the **source** docs (`../docs`,
> `../../maker-studio-mods/docs`, and their `es/` subfolders) and the next build picks them up.

## Translations (Español)

Spanish is a first-class source locale: its raw pages live as plain Markdown in `docs/es/` (this repo's
user guides) and `../../maker-studio-mods/docs/es/` (mod API), mirroring the English layout. The loader
reads them and prefixes internal links with `/es`, so editing Spanish is just editing those raw files.

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

The workflow at the **repo root** `.github/workflows/docs-pages.yml` builds every version and publishes
to GitHub Pages on each push to `main` that touches `docs/**` or `docs-site/**`, on a daily schedule,
and on manual dispatch. It queries the GitHub tags API, then builds one Starlight site per version
(`latest` at the site root, each tag under `/vX.Y.Z/`) and merges them into a single `dist/`.

One-time setup: in the repo's **Settings → Pages**, set **Source = GitHub Actions** and the custom
domain `makerstudio.toskan.es` (Cloudflare CNAME `makerstudio` → `toskan4134.github.io`, DNS only).
The site publishes at `https://makerstudio.toskan.es/` (latest at the root; older versions under
`/vX.Y.Z/`); the old `toskan4134.github.io/maker-studio` URLs 301-redirect there.

The output is a plain static `dist/` — it can also be hosted on Netlify, Cloudflare Pages, S3, etc.

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
    │   └── VersionSelect.astro   # version dropdown (latest + vX.Y.Z tags)
    ├── styles/theme.css          # editor-matching palette (dark + light) + splash card layout
    └── content/docs/             # empty — all pages are loaded in memory
```
