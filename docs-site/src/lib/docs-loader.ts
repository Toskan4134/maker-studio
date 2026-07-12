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
interface DownloadFile {
	label: I18nText;
	file: string;
}
interface SplashData {
	locales: Record<string, { label: string; lang: string; root?: boolean }>;
	sidebarGroups: Record<string, Record<string, string>>;
	downloadUrl: string;
	download: {
		base: string;
		heading: I18nText;
		platforms: {
			os: string;
			icon: string;
			meta: I18nText;
			primary: DownloadFile;
			alt: DownloadFile[];
		}[];
		links: { href: string; text: I18nText }[];
	};
	hero: {
		pageTitle: I18nText;
		metaDescription: I18nText;
		title: I18nText;
		tagline: I18nText;
		image: { alt: string };
		actions: { icon: string; variant: string; link: string; text: I18nText }[];
	};
	intro: I18nText;
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
const DOWNLOAD_SVG =
	'<svg aria-hidden="true" width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>';
// Simple Icons (CC0).
const OS_ICONS: Record<string, string> = {
	windows:
		"M0 3.449 9.75 2.1v9.451H0m10.949-9.602L24 0v11.4H10.949M0 12.6h9.75v9.451L0 20.699m10.949-8.099H24V24l-12.9-1.801",
	apple:
		"M12.152 6.896c-.948 0-2.415-1.078-3.96-1.04-2.04.027-3.91 1.183-4.961 3.014-2.117 3.675-.546 9.103 1.519 12.09 1.013 1.454 2.208 3.09 3.792 3.039 1.52-.065 2.09-.987 3.935-.987 1.831 0 2.35.987 3.96.948 1.637-.026 2.676-1.48 3.676-2.948 1.156-1.688 1.636-3.325 1.662-3.415-.039-.013-3.182-1.221-3.22-4.857-.026-3.04 2.48-4.494 2.597-4.559-1.429-2.09-3.623-2.324-4.39-2.376-2-.156-3.675 1.09-4.61 1.09zM15.53 3.83c.843-1.012 1.4-2.427 1.245-3.83-1.207.052-2.662.805-3.532 1.818-.78.896-1.454 2.338-1.273 3.714 1.338.104 2.715-.688 3.559-1.701",
	linux:
		"M12.504 0c-.155 0-.315.008-.48.021-4.226.333-3.105 4.807-3.17 6.298-.076 1.092-.3 1.953-1.05 3.02-.885 1.051-2.127 2.75-2.716 4.521-.278.832-.41 1.684-.287 2.489a.424.424 0 00-.11.135c-.26.268-.45.6-.663.839-.199.199-.485.267-.797.4-.313.136-.658.269-.864.68-.09.189-.136.394-.132.602 0 .199.027.4.055.536.058.399.116.728.04.97-.249.68-.28 1.145-.106 1.484.174.334.535.47.94.601.81.2 1.91.135 2.774.6.926.466 1.866.67 2.616.47.526-.116.97-.464 1.208-.946.587-.003 1.23-.269 2.26-.334.699-.058 1.574.267 2.577.2.025.134.063.198.114.333l.003.003c.391.778 1.113 1.132 1.884 1.071.771-.06 1.592-.536 2.257-1.306.631-.765 1.683-1.084 2.378-1.503.348-.199.629-.469.649-.853.023-.4-.2-.811-.714-1.376v-.097l-.003-.003c-.17-.2-.25-.535-.338-.926-.085-.401-.182-.786-.492-1.046h-.003c-.059-.054-.123-.067-.188-.135a.357.357 0 00-.19-.064c.431-1.278.264-2.55-.173-3.694-.533-1.41-1.465-2.638-2.175-3.483-.796-1.005-1.576-1.957-1.56-3.368.026-2.152.236-6.133-3.544-6.139zm.529 3.405h.013c.213 0 .396.062.584.198.19.135.33.332.438.533.105.259.158.459.166.724 0-.02.006-.04.006-.06v.105a.086.086 0 01-.004-.021l-.004-.024a1.807 1.807 0 01-.15.706.953.953 0 01-.213.335.71.71 0 00-.088-.042c-.104-.045-.198-.064-.284-.133a1.312 1.312 0 00-.22-.066c.05-.06.146-.133.183-.198.053-.128.082-.264.088-.402v-.02a1.21 1.21 0 00-.061-.4c-.045-.134-.101-.2-.183-.333-.084-.066-.167-.132-.267-.132h-.016c-.093 0-.176.03-.262.132a.8.8 0 00-.205.334 1.18 1.18 0 00-.09.4v.019c.002.089.008.179.02.267-.193-.067-.438-.135-.607-.202a1.635 1.635 0 01-.018-.2v-.02a1.772 1.772 0 01.15-.768c.082-.22.232-.406.43-.533a.985.985 0 01.594-.2zm-2.962.059h.036c.142 0 .27.048.399.135.146.129.264.288.344.465.09.199.14.4.153.667v.004c.007.134.006.2-.002.266v.08c-.03.007-.056.018-.083.024-.152.055-.274.135-.393.2.012-.09.013-.18.003-.267v-.015c-.012-.133-.04-.2-.082-.333a.613.613 0 00-.166-.267.248.248 0 00-.183-.064h-.021c-.071.006-.13.04-.186.132a.552.552 0 00-.12.27.944.944 0 00-.023.33v.015c.012.135.037.2.08.334.046.134.098.2.166.268.01.009.02.018.034.024-.07.057-.117.07-.176.136a.304.304 0 01-.131.068 2.62 2.62 0 01-.275-.402 1.772 1.772 0 01-.155-.667 1.759 1.759 0 01.08-.668 1.43 1.43 0 01.283-.535c.128-.133.26-.2.418-.2zm1.37 1.706c.332 0 .733.065 1.216.399.293.2.523.269 1.052.468h.003c.255.136.405.266.478.399v-.131a.571.571 0 01.016.47c-.123.31-.516.643-1.063.842v.002c-.268.135-.501.333-.775.465-.276.135-.588.292-1.012.267a1.139 1.139 0 01-.448-.067 3.566 3.566 0 01-.322-.198c-.195-.135-.363-.332-.612-.465v-.005h-.005c-.4-.246-.616-.512-.686-.71-.07-.268-.005-.47.193-.6.224-.135.38-.271.483-.336.104-.074.143-.102.176-.131h.002v-.003c.169-.202.436-.47.839-.601.139-.036.294-.065.466-.065zm2.8 2.142c.358 1.417 1.196 3.475 1.735 4.473.286.534.855 1.659 1.102 3.024.156-.005.33.018.513.064.646-1.671-.546-3.467-1.089-3.966-.22-.2-.232-.335-.123-.335.59.534 1.365 1.572 1.646 2.757.13.535.16 1.104.021 1.67.067.028.135.06.205.067 1.032.534 1.413.938 1.23 1.537v-.043c-.06-.003-.12 0-.18 0h-.016c.151-.467-.182-.825-1.065-1.224-.915-.4-1.646-.336-1.77.465-.008.043-.013.066-.018.135-.068.023-.139.053-.209.064-.43.268-.662.669-.793 1.187-.13.533-.17 1.156-.205 1.869v.003c-.02.334-.17.838-.319 1.35-1.5 1.072-3.58 1.538-5.348.334a2.645 2.645 0 00-.402-.533 1.45 1.45 0 00-.275-.333c.182 0 .338-.03.465-.067a.615.615 0 00.314-.334c.108-.267 0-.697-.345-1.163-.345-.467-.931-.995-1.788-1.521-.63-.4-.986-.87-1.15-1.396-.165-.534-.143-1.085-.015-1.645.245-1.07.873-2.11 1.274-2.763.107-.065.037.135-.408.974-.396.751-1.14 2.497-.122 3.854a8.123 8.123 0 01.647-2.876c.564-1.278 1.743-3.504 1.836-5.268.048.036.217.135.289.202.218.133.38.333.59.465.21.201.477.335.876.335.039.003.075.006.11.006.412 0 .73-.134.997-.268.29-.134.52-.334.74-.4h.005c.467-.135.835-.402 1.044-.7zm2.185 8.958c.037.6.343 1.245.882 1.377.588.134 1.434-.333 1.791-.765l.211-.01c.315-.007.577.01.847.268l.003.003c.208.199.305.53.391.876.085.4.154.78.409 1.066.486.527.645.906.636 1.14l.003-.007v.018l-.003-.012c-.015.262-.185.396-.498.595-.63.401-1.746.712-2.457 1.57-.618.737-1.37 1.14-2.036 1.191-.664.053-1.237-.2-1.574-.898l-.005-.003c-.21-.4-.12-1.025.056-1.69.176-.668.428-1.344.463-1.897.037-.714.076-1.335.195-1.814.12-.465.308-.797.641-.984l.045-.022zm-10.814.049h.01c.053 0 .105.005.157.014.376.055.706.333 1.023.752l.91 1.664.003.003c.243.533.754 1.064 1.189 1.637.434.598.77 1.131.729 1.57v.006c-.057.744-.48 1.148-1.125 1.294-.645.135-1.52.002-2.395-.464-.968-.536-2.118-.469-2.857-.602-.369-.066-.61-.2-.723-.4-.11-.2-.113-.602.123-1.23v-.004l.002-.003c.117-.334.03-.752-.027-1.118-.055-.401-.083-.71.043-.94.16-.334.396-.4.69-.533.294-.135.64-.202.915-.47h.002v-.002c.256-.268.445-.601.668-.838.19-.201.38-.336.663-.336zm7.159-9.074c-.435.201-.945.535-1.488.535-.542 0-.97-.267-1.28-.466-.154-.134-.28-.268-.373-.335-.164-.134-.144-.333-.074-.333.109.016.129.134.199.2.096.066.215.2.36.333.292.2.68.467 1.167.467.485 0 1.053-.267 1.398-.466.195-.135.445-.334.648-.467.156-.136.149-.267.279-.267.128.016.034.134-.147.332a8.097 8.097 0 01-.69.468zm-1.082-1.583V5.64c-.006-.02.013-.042.029-.05.074-.043.18-.027.26.004.063 0 .16.067.15.135-.006.049-.085.066-.135.066-.055 0-.092-.043-.141-.068-.052-.018-.146-.008-.163-.065zm-.551 0c-.02.058-.113.049-.166.066-.047.025-.086.068-.14.068-.05 0-.13-.02-.136-.068-.01-.066.088-.133.15-.133.08-.031.184-.047.259-.005.019.009.036.03.03.05v.02h.003z",
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
	const dl = splash.download;
	const dlCard = (p: SplashData["download"]["platforms"][number]) =>
		`<article class="feature-card dl-card">` +
		`<span class="feature-card__icon" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"><path d="${OS_ICONS[p.icon]}"/></svg></span>` +
		`<p class="feature-card__title">${p.os}</p>` +
		`<p class="feature-card__body">${t(p.meta)}</p>` +
		`<a class="dl-card__btn" href="${dl.base}/${p.primary.file}" download>${DOWNLOAD_SVG}<span>${t(p.primary.label)}</span></a>` +
		(p.alt.length
			? `<p class="dl-card__alt">${p.alt.map((a) => `<a href="${dl.base}/${a.file}" download>${t(a.label)}</a>`).join(" · ")}</p>`
			: "") +
		`</article>`;
	return [
		`<h2 class="dl-heading">${t(dl.heading)}</h2>`,
		`<div class="card-grid dl-grid">${dl.platforms.map(dlCard).join("")}</div>`,
		`<p class="dl-links">${dl.links.map((l) => `<a href="${resolve(l.href)}">${t(l.text)}</a>`).join(" · ")}</p>`,
		`<h2>${t(splash.sections.whatIs.heading)}</h2>`,
		`<p>${t(splash.intro)}</p>`,
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
