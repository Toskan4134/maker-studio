/**
 * Custom Starlight docs loader — the "no-clones" model.
 *
 * Instead of port-docs.mjs writing generated markdown into src/content/docs,
 * this loader sources every page directly and feeds Astro's content collection
 * IN MEMORY at build/dev time. No generated files are ever written to disk, and
 * there are no hand-authored pages on disk either — even the splash/home pages
 * are synthesized here from src/data/splash.json. The loader produces:
 *
 *   1. Guide + mod pages (EN + ES + any future locale), read from the two source
 *      repos (local sibling files in dev, GitHub raw in versioned CI builds) and
 *      rendered via the context's markdown pipeline.
 *   2. The per-locale splash/home pages: hero frontmatter + a hand-built HTML
 *      body, both sourced from splash.json. This is what lets a new language be
 *      added by editing splash.json + creating docs/<lang>/ folders only.
 *
 * Locale set is single-sourced from splash.json (`locales`); the locale flagged
 * `root: true` is the default, path-less locale. astro.config.mjs derives its
 * `locales` + sidebar translations from the same file.
 *
 * Source selection + per-version refs come from env (set by CI per version):
 *   DOCS_SOURCE     "local" (default; read sibling repos on disk) | "remote"
 *   DOCS_APP_REF    git ref for maker-studio docs (default "main")
 *   DOCS_MODS_REF   git ref for maker-studio-mods docs (default "main")
 */

import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import type { Loader, LoaderContext } from "astro/loaders";
import splashJson from "../data/splash.json";

const SOURCE = process.env.DOCS_SOURCE || "local";
const APP_REF = process.env.DOCS_APP_REF || "main";
const MODS_REF = process.env.DOCS_MODS_REF || "main";
const RAW_BASE = "https://raw.githubusercontent.com/Toskan4134";
const MODS_REPO = "https://github.com/Toskan4134/maker-studio-mods";

const REPO_REF: Record<string, string> = {
	"maker-studio": APP_REF,
	"maker-studio-mods": MODS_REF,
};

type I18nText = Record<string, string>;
interface LinkItem {
	href: string;
	title: I18nText;
	desc: I18nText;
}
interface SplashData {
	locales: Record<string, { label: string; lang: string; root?: boolean }>;
	sidebarGroups: Record<string, Record<string, string>>;
	downloadUrl: string;
	hero: {
		pageTitle: I18nText;
		metaDescription: I18nText;
		title: I18nText;
		tagline: I18nText;
		image: { alt: string };
		actions: { icon: string; variant: string; link: string; text: I18nText }[];
	};
	intro: I18nText;
	available: I18nText;
	downloadText: I18nText;
	sections: Record<string, { heading: I18nText }>;
	features: { icon: string; title: I18nText; desc: I18nText }[];
	links: { startHere: LinkItem[]; buildMod: LinkItem[] };
}
const splash = splashJson as unknown as SplashData;

/** Locale set, single-sourced from splash.json. `path` is undefined for root. */
interface Locale {
	key: string; // splash.json text key (also the lang) — e.g. "en", "es"
	path?: string; // URL/source-folder segment — undefined for root, else === key
}
const LOCALES: Locale[] = Object.entries(splash.locales).map(([key, meta]) => ({
	key,
	path: meta.root ? undefined : key,
}));

const GUIDE_ORDER = [
	"getting-started",
	"interface-guide",
	"tools",
	"layers",
	"shadows",
	"tileset-editor",
	"events-editor",
	"database",
	"scripts",
	"game-simulator",
	"map-management",
	"map-versions",
	"marketplace",
	"keyboard-shortcuts",
];
const MOD_ORDER = [
	"overview", // from README.md
	"getting-started",
	"quick-reference",
	"api-reference",
	"events-reference",
	"troubleshooting",
	"api-changelog",
];
// English sidebar labels for mod pages whose H1 isn't a good short label (e.g.
// the README's H1). Only applied to the root locale — every other locale uses
// its own translated H1 as the sidebar label, so no per-language map is needed.
const MOD_LABELS: Record<string, string> = {
	"api-changelog": "Changelog",
	"api-reference": "API Reference",
	"events-reference": "Events Reference",
	"quick-reference": "Quick Reference",
	overview: "Overview",
};

interface RepoDoc {
	repo: "maker-studio" | "maker-studio-mods";
	docRelPath: string; // relative to the repo's docs/ dir, locale-aware (e.g. "es/foo.md")
	id: string; // content collection id (e.g. "es/guides/foo")
	section: "guides" | "mods";
	slug: string;
	order: number;
	label?: string;
	locale?: string; // URL/source segment for non-root locales (e.g. "es")
}

const REPO_DOCS: RepoDoc[] = LOCALES.flatMap(({ path }): RepoDoc[] => {
	const pfx = path ? `${path}/` : "";
	const isRoot = !path;
	const guides = GUIDE_ORDER.map<RepoDoc>((slug, i) => ({
		repo: "maker-studio",
		docRelPath: `${pfx}${slug}.md`,
		id: `${pfx}guides/${slug}`,
		section: "guides",
		slug,
		order: i + 1,
		locale: path,
	}));
	const mods = MOD_ORDER.map<RepoDoc>((slug) => ({
		repo: "maker-studio-mods",
		// The root overview comes from the repo README; localized overviews from es/overview.md etc.
		docRelPath: slug === "overview" && isRoot ? "README.md" : `${pfx}${slug}.md`,
		id: `${pfx}mods/${slug}`,
		section: "mods",
		slug,
		order: MOD_ORDER.indexOf(slug) + 1,
		label: isRoot ? MOD_LABELS[slug] : undefined,
		locale: path,
	}));
	return [...guides, ...mods];
});

/** Resolve a repo's docs dir on disk (local mode only). */
function repoDocsDir(repo: string, root: string): string {
	const firstExisting = (cands: string[]) => cands.find((c) => existsSync(c)) || cands[0];
	if (repo === "maker-studio-mods") {
		return firstExisting([
			join(root, "..", "..", "maker-studio-mods", "docs"), // docs-site inside the maker-studio repo
			join(root, "..", "maker-studio-mods", "docs"), // docs-site at the workspace root
		]);
	}
	return firstExisting([
		join(root, "..", "docs"), // docs-site inside the maker-studio public repo
		join(root, "..", "maker-studio", "docs"), // docs-site at the workspace root
	]);
}

/** Read a repo doc. Returns text, or null when missing locally / 404 remotely. */
async function readDoc(repo: string, docRelPath: string, root: string): Promise<string | null> {
	if (SOURCE === "remote") {
		const url = `${RAW_BASE}/${repo}/${REPO_REF[repo]}/docs/${docRelPath}`;
		const res = await fetch(url, { headers: { "User-Agent": "maker-studio-docs-site" } });
		if (res.status === 404) return null;
		if (!res.ok) throw new Error(`fetch failed (${res.status}): ${url}`);
		return res.text();
	}
	const file = join(repoDocsDir(repo, root), docRelPath);
	return existsSync(file) ? readFileSync(file, "utf8") : null;
}

/** strip markdown to a flat plain-text description, capped at ~160 chars */
function toDescription(md: string): string {
	const paras = md
		.replace(/^#{1,6}\s.*$/gm, "")
		.split(/\n\s*\n/)
		.map((p) => p.replace(/\n/g, " ").trim())
		.filter((p) => p && !/^[|\-*>]/.test(p));
	let p = paras[0] || "";
	p = p
		.replace(/`([^`]+)`/g, "$1")
		.replace(/\*\*([^*]+)\*\*/g, "$1")
		.replace(/\*([^*]+)\*/g, "$1")
		.replace(/\[([^\]]+)\]\([^)]+\)/g, "$1")
		.replace(/[#>|]/g, " ")
		.replace(/\s+/g, " ")
		.trim();
	if (p.length > 158) p = p.slice(0, 155).replace(/\s+\S*$/, "") + "…";
	return p;
}

/** Climb from a page's directory to the site root: [locale/]section/slug = (locale?3:2) levels. */
function relRoot(locale?: string): string {
	return "../".repeat((locale ? 1 : 0) + 2);
}

/** Rewrite a single link target for a doc section + optional locale. */
function rewriteTarget(target: string, section: "guides" | "mods", locale?: string): string {
	// Special repo files rewrite to an external URL regardless of how the doc
	// authored the link — including a leading "/" (e.g. the ES docs write
	// "/mod-api.d.ts"), which the absolute-path guard below would otherwise pass
	// through unchanged and 404 against the site root.
	if (/mod-api\.d\.ts$/.test(target)) return `${RAW_BASE}/maker-studio-mods/${MODS_REF}/docs/mod-api.d.ts`;
	if (/examples\/mods\/?$/.test(target)) return `${MODS_REPO}/tree/main/examples/mods`;
	if (/PUBLISHING\.md$/.test(target)) return `${MODS_REPO}/blob/main/PUBLISHING.md`;
	if (/^(https?:|mailto:|#|\/)/.test(target)) return target;
	const m = target.match(/^(?:\.\/|\.\.\/)*([\w.-]+)\.md(#.*)?$/);
	if (m) {
		let base = m[1];
		const anchor = m[2] || "";
		if (base.toLowerCase() === "readme") base = section === "mods" ? "overview" : "getting-started";
		return `${relRoot(locale)}${locale ? `${locale}/` : ""}${section}/${base}/${anchor}`;
	}
	return target;
}

function rewriteLinks(md: string, section: "guides" | "mods", locale?: string): string {
	return md.replace(/\]\(([^)\s]+)\)/g, (_full, t) => `](${rewriteTarget(t, section, locale)})`);
}

async function loadRepoDocs(context: LoaderContext): Promise<void> {
	const { store, parseData, renderMarkdown, generateDigest, logger, config } = context;
	const root = fileURLToPath(config.root);

	let count = 0;
	for (const doc of REPO_DOCS) {
		const raw = await readDoc(doc.repo, doc.docRelPath, root);
		if (raw == null) {
			logger.warn(`skip (missing/404): ${doc.repo}:${doc.docRelPath}`);
			continue;
		}
		const md = raw.replace(/\r\n/g, "\n");
		const h1 = md.match(/^#\s+(.+)$/m);
		const title = (h1 ? h1[1] : doc.slug).trim();
		const description = toDescription(md);

		let body = md.replace(/^#\s+.+$/m, "").replace(/^\n+/, "");
		body = rewriteLinks(body, doc.section, doc.locale);

		const sidebar: Record<string, unknown> = { order: doc.order };
		if (doc.label) sidebar.label = doc.label;
		const frontmatter: Record<string, unknown> = { title, sidebar };
		if (description) frontmatter.description = description;

		const data = await parseData({ id: doc.id, data: frontmatter });
		const rendered = await renderMarkdown(body);
		store.set({
			id: doc.id,
			data,
			body,
			rendered,
			filePath: `${doc.locale ? `${doc.locale}/` : ""}${doc.section}/${doc.slug}.md`,
			digest: generateDigest(md),
		});
		count++;
	}
	logger.info(`Loaded ${count} repo docs (source: ${SOURCE}, app@${APP_REF}, mods@${MODS_REF}).`);

	// In local dev, watch the sibling doc dirs so edits hot-reload.
	if (SOURCE === "local" && context.watcher) {
		for (const repo of ["maker-studio", "maker-studio-mods"]) {
			const dir = repoDocsDir(repo, root);
			if (existsSync(dir)) context.watcher.add(dir);
		}
	}

	// Local dev only: flag source .md files that aren't in GUIDE_ORDER/MOD_ORDER —
	// they'd be silently omitted from the build. (Remote mode can't list a dir
	// cheaply, and the build set is intentionally those lists, which also fix the
	// sidebar order; this just catches a forgotten list entry early.)
	if (SOURCE === "local") {
		// README.md in the guides dir is the docs index, not a page; in the mods dir
		// it IS the "overview" page. Either way it should never be flagged.
		const known: Record<string, Set<string>> = {
			"maker-studio": new Set([...GUIDE_ORDER.map((s) => `${s}.md`), "README.md"]),
			"maker-studio-mods": new Set(MOD_ORDER.map((s) => (s === "overview" ? "README.md" : `${s}.md`))),
		};
		const listName: Record<string, string> = {
			"maker-studio": "GUIDE_ORDER",
			"maker-studio-mods": "MOD_ORDER",
		};
		for (const repo of ["maker-studio", "maker-studio-mods"] as const) {
			const dir = repoDocsDir(repo, root);
			if (!existsSync(dir)) continue;
			for (const name of readdirSync(dir)) {
				if (name.endsWith(".md") && !known[repo].has(name)) {
					logger.warn(
						`unlisted doc (won't be built): ${repo}/docs/${name} — add "${name.replace(/\.md$/, "")}" to ${listName[repo]} in src/lib/docs-loader.ts`,
					);
				}
			}
		}
	}
}

// ── Splash / home pages (synthesized from splash.json) ───────────────────────
// We build the body HTML by hand rather than using Starlight's <CardGrid> /
// <LinkCard> / <FeatureCard> components, because a content loader renders
// Markdown, not Astro components. The matching layout CSS for these class names
// is ported into src/styles/theme.css (the components' scoped styles don't apply
// to loader-injected HTML). The hero itself stays data-driven: Starlight renders
// it from each entry's `data.hero`.

// Editor (Lucide-style) icon paths — kept in sync with the app's toolbar icons.
const FEATURE_ICONS: Record<string, string> = {
	brush:
		'<path d="M9.06 11.9 16.2 4.78a2.1 2.1 0 0 1 3 3l-7.13 7.13"/><path d="M7 14a4 4 0 0 0-4 4c0 1.5-.5 2.5-2 3 1 1 3 1.5 5 1.5 3 0 5-2 5-4.5A4 4 0 0 0 7 14z"/>',
	layers:
		'<polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/>',
	events: '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/>',
	mods:
		'<path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/>',
};
// Starlight's "right-arrow" glyph, for LinkCards.
const ARROW_SVG =
	'<svg aria-hidden="true" class="icon rtl:flip" width="1.333em" height="1.333em" viewBox="0 0 24 24" fill="currentColor"><path d="M17.92 11.62a1.001 1.001 0 0 0-.21-.33l-5-5a1.003 1.003 0 1 0-1.42 1.42l3.3 3.29H7a1 1 0 0 0 0 2h7.59l-3.3 3.29a1.002 1.002 0 0 0 .325 1.639 1 1 0 0 0 1.095-.219l5-5a1 1 0 0 0 .21-.33 1 1 0 0 0 0-.76Z"/></svg>';

/** pick a locale's text from an i18n field, falling back to English. */
const pick = (field: I18nText, key: string): string => field[key] ?? field.en;

/** Build the splash body HTML for one locale, mirroring Splash.astro's markup.
 *  `resolve` turns an internal href into an absolute, base+locale-prefixed URL so
 *  links never depend on the current page's trailing slash (a slash-less `/es`
 *  would otherwise resolve relative links against the root → English page). */
function buildSplashHtml(key: string, resolve: (href: string) => string): string {
	const t = (f: I18nText) => pick(f, key);
	const featureCard = (f: SplashData["features"][number]) =>
		`<article class="feature-card"><span class="feature-card__icon" aria-hidden="true">` +
		`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${FEATURE_ICONS[f.icon]}</svg>` +
		`</span><p class="feature-card__title">${t(f.title)}</p><p class="feature-card__body">${t(f.desc)}</p></article>`;
	const linkCard = (l: LinkItem) =>
		`<div class="sl-link-card"><span class="sl-flex stack">` +
		`<a href="${resolve(l.href)}"><span class="title">${t(l.title)}</span></a>` +
		`<span class="description">${t(l.desc)}</span></span>${ARROW_SVG}</div>`;
	return [
		`<h2>${t(splash.sections.whatIs.heading)}</h2>`,
		`<p>${t(splash.intro)}</p>`,
		`<p><strong>${t(splash.available)}</strong><br /><a href="${splash.downloadUrl}">${t(splash.downloadText)}</a></p>`,
		`<div class="card-grid">${splash.features.map(featureCard).join("")}</div>`,
		`<h2>${t(splash.sections.startHere.heading)}</h2>`,
		`<div class="card-grid">${splash.links.startHere.map(linkCard).join("")}</div>`,
		`<h2>${t(splash.sections.buildMod.heading)}</h2>`,
		`<div class="card-grid">${splash.links.buildMod.map(linkCard).join("")}</div>`,
	].join("\n");
}

async function loadSplashPages(context: LoaderContext): Promise<void> {
	const { store, parseData, generateDigest, config } = context;
	// public/logo.png is served at the build's base; resolve it for the hero <img>.
	const base = (config.base || "/").replace(/\/+$/, "");
	const logoSrc = `${base}/logo.png`;

	for (const { key, path } of LOCALES) {
		// A non-root locale index id must be the bare locale ("es") — what Astro's
		// loader yields for es/index.mdx. Starlight only normalizes the literal
		// "index" → "", so an "es/index" id would route to an English fallback at
		// /es/. Root stays "index" (Starlight maps it to "").
		const id = path || "index";
		const localePrefix = `${base}/${path ? `${path}/` : ""}`;
		const resolve = (href: string) =>
			/^(https?:|mailto:|#|\/)/.test(href) ? href : `${localePrefix}${href}`;
		const html = buildSplashHtml(key, resolve);
		const frontmatter = {
			title: pick(splash.hero.pageTitle, key),
			description: pick(splash.hero.metaDescription, key),
			template: "splash",
			hero: {
				title: pick(splash.hero.title, key),
				tagline: pick(splash.hero.tagline, key),
				image: {
					html: `<img src="${logoSrc}" alt="${splash.hero.image.alt}" width="200" height="200" style="width:100%;height:auto" />`,
				},
				actions: splash.hero.actions.map((a) => ({
					text: pick(a.text, key),
					link: resolve(a.link),
					icon: a.icon,
					variant: a.variant,
				})),
			},
		};
		const data = await parseData({ id, data: frontmatter });
		store.set({
			id,
			data,
			body: "",
			rendered: { html },
			filePath: `${path ? `${path}/` : ""}index.mdx`,
			digest: generateDigest(html),
		});
	}
}

export function makerStudioDocsLoader(): Loader {
	return {
		name: "maker-studio-docs",
		load: async (context: LoaderContext) => {
			await loadRepoDocs(context);
			await loadSplashPages(context);
		},
	};
}
