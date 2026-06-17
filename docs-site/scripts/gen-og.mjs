// Generates public/og-image.png — the single site-wide social card used by the
// OG / Twitter Card tags emitted in src/components/Head.astro. Runs from the
// `prebuild` + `predev` npm hooks, so every local + CI build (latest + every
// version tag) regenerates it under the right base automatically.
//
// Composites src/assets/logo.png onto a branded 1200×630 SVG and rasterizes to
// PNG via Sharp (already a dependency — no extra install). Text uses a generic
// sans stack; Sharp's SVG renderer substitutes an available font, so the card
// renders on Windows (Segoe UI), macOS, and Linux CI alike.
import sharp from "sharp";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const splash = JSON.parse(readFileSync(resolve(root, "src/data/splash.json"), "utf8"));
const logoPath = resolve(root, "src/assets/logo.png");

// Brand wordmark from the single source of truth.
const wordmark = splash.hero.title.en; // "Maker Studio"
const tagline = "A modern tile map editor for RPG Maker XP projects.";
const platforms = "Windows · macOS · Linux";

const logoB64 = readFileSync(logoPath).toString("base64");
const logoDataUri = `data:image/png;base64,${logoB64}`;

const W = 1200;
const H = 630;
const NAVY = "#1e1e2e";
const NAVY_DEEP = "#181825";
const ACCENT = "#7c8aff";
const ACCENT_HI = "#c8cdff";
const TEXT = "#e0e0e8";
const MUTED = "#a0a0b0";

const svg = `
<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${NAVY}"/>
      <stop offset="1" stop-color="${NAVY_DEEP}"/>
    </linearGradient>
    <linearGradient id="accentbar" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="${ACCENT}"/>
      <stop offset="1" stop-color="${ACCENT_HI}"/>
    </linearGradient>
  </defs>

  <!-- Background -->
  <rect width="${W}" height="${H}" fill="url(#bg)"/>

  <!-- Subtle decorative grid in the accent hue, very low opacity -->
  <g stroke="${ACCENT}" stroke-opacity="0.06" stroke-width="1">
    ${Array.from({ length: 9 }, (_, i) => `<line x1="${i * 150}" y1="0" x2="${i * 150}" y2="${H}"/>`).join("")}
    ${Array.from({ length: 5 }, (_, i) => `<line x1="0" y1="${i * 150}" x2="${W}" y2="${i * 150}"/>`).join("")}
  </g>

  <!-- Top accent bar -->
  <rect x="0" y="0" width="${W}" height="10" fill="url(#accentbar)"/>

  <!-- Logo -->
  <image href="${logoDataUri}" x="96" y="120" width="160" height="160"/>

  <!-- Wordmark -->
  <text x="96" y="360" font-family="'Segoe UI', Arial, Helvetica, sans-serif" font-size="92" font-weight="700" fill="${TEXT}">${wordmark}</text>

  <!-- Accent underline beneath the wordmark -->
  <rect x="100" y="392" width="120" height="6" rx="3" fill="url(#accentbar)"/>

  <!-- Tagline -->
  <text x="96" y="452" font-family="'Segoe UI', Arial, Helvetica, sans-serif" font-size="36" fill="${ACCENT_HI}">${tagline}</text>

  <!-- Platforms -->
  <text x="96" y="520" font-family="'Segoe UI', Arial, Helvetica, sans-serif" font-size="28" fill="${MUTED}">${platforms}</text>

  <!-- Docs URL, bottom-right -->
  <text x="${W - 96}" y="${H - 60}" text-anchor="end" font-family="'Segoe UI', Arial, Helvetica, sans-serif" font-size="26" fill="${ACCENT}">toskan4134.github.io/maker-studio</text>
</svg>`;

const out = resolve(root, "public/og-image.png");
await sharp(Buffer.from(svg)).png().toFile(out);
console.log(`[gen-og] wrote ${out.replace(root, ".")} (${W}×${H})`);
