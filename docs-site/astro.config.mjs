// @ts-check
import starlight from "@astrojs/starlight";
import sitemap from "@astrojs/sitemap";
import { defineConfig } from "astro/config";
import { readFileSync } from "node:fs";

// Override at build time for GitHub Pages under the maker-studio repo, e.g.:
//   SITE_URL=https://toskan4134.github.io SITE_BASE=/maker-studio npm run build
const SITE_URL = process.env.SITE_URL || "https://toskan4134.github.io";
const SITE_BASE = process.env.SITE_BASE || undefined;
// Multi-version builds set OUT_DIR per version so outputs don't clobber each
// other (Astro cleans outDir at the start of each build), then CI merges them.
const OUT_DIR = process.env.OUT_DIR || undefined;

// Single source of truth for the locale set: src/data/splash.json. Adding a
// language there (+ creating its docs/<lang>/ source folders) is all it takes —
// the loader, locales, and sidebar translations below all derive from this. The
// locale marked `root: true` is the default (path-less) locale.
const splash = JSON.parse(readFileSync(new URL("./src/data/splash.json", import.meta.url), "utf8"));
const localeEntries = Object.entries(splash.locales);
const rootCode = (localeEntries.find(([, m]) => m.root) || ["en"])[0];

/** @type {Record<string, { label: string; lang: string }>} */
const locales = {};
for (const [code, meta] of localeEntries) {
  locales[meta.root ? "root" : code] = { label: meta.label, lang: meta.lang };
}

// Per-group sidebar label translations for every non-root locale, pulled from
// splash.json's `sidebarGroups`. The default label uses the root locale's value.
/** @param {string} group */
const groupLabel = (group) => splash.sidebarGroups[group][rootCode];
/** @param {string} group */
const groupTranslations = (group) => {
  /** @type {Record<string, string>} */
  const out = {};
  for (const [code, meta] of localeEntries) {
    if (meta.root) continue;
    const v = splash.sidebarGroups[group]?.[code];
    if (v) out[code] = v;
  }
  return out;
};

export default defineConfig({
  site: SITE_URL,
  base: SITE_BASE,
  outDir: OUT_DIR,
  trailingSlash: "ignore",
  // The Astro dev toolbar's HMR hook can throw "Cannot read properties of
  // undefined (reading 'send')" when a browser devtools extension is active.
  devToolbar: { enabled: false },
  integrations: [
    starlight({
      title: "Maker Studio",
      description:
        "Documentation for Maker Studio — a modern tile map editor for RPG Maker XP projects, plus its mod API.",
      logo: {
        src: "./src/assets/logo.png",
        alt: "Maker Studio",
        replacesTitle: false,
      },
      favicon: "/favicon.png",
      components: {
        Search: "./src/components/Search.astro",
        Footer: "./src/components/Footer.astro",
        Header: "./src/components/Header.astro",
        // Appends OG / Twitter Card / theme-color / JSON-LD to Starlight's own head.
        Head: "./src/components/Head.astro",
      },
      defaultLocale: "root",
      locales,
      social: [
        {
          icon: "github",
          label: "App on GitHub",
          href: "https://github.com/Toskan4134/maker-studio",
        },
        {
          icon: "seti:json",
          label: "Mods on GitHub",
          href: "https://github.com/Toskan4134/maker-studio-mods",
        },
      ],
      // The generated guide files have no meaningful per-file git date, so the
      // footer's "Last updated" meta row is just dead space — turn it off.
      lastUpdated: false,
      customCss: ["./src/styles/theme.css"],
      sidebar: [
        {
          label: groupLabel("userGuide"),
          translations: groupTranslations("userGuide"),
          items: [{ autogenerate: { directory: "guides" } }],
        },
        {
          label: groupLabel("modDevelopment"),
          translations: groupTranslations("modDevelopment"),
          items: [{ autogenerate: { directory: "mods" } }],
        },
      ],
    }),
    // Sitemap: the `latest` (root) build emits the canonical sitemap-index.xml
    // robots.txt points at. Versioned builds emit their own under /vX.Y.Z/ and
    // there is no switching that off — Starlight registers this integration
    // itself, so dropping it here changes nothing. Harmless: those copies are
    // `noindex` (see src/components/Head.astro) and nothing links their sitemap.
    sitemap(),
  ],
});
