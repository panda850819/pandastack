#!/usr/bin/env bun
// curate-feeds: pull unprocessed items from feed-server, enrich web articles
// via defuddle, write obsidian-clipper-style markdown to Inbox/feeds/raw/<date>/.
//
// Replaces the AI-instruction-driven flow in pandastack:curate-feeds skill.
// SKILL.md becomes a thin wrapper that just calls this script.
//
// Usage:
//   bun run scripts/curate-feeds.ts                  # process up to 100 items
//   bun run scripts/curate-feeds.ts --limit 20       # cap items per run
//   bun run scripts/curate-feeds.ts --dry            # don't write files / mark processed
//   bun run scripts/curate-feeds.ts --no-defuddle    # skip defuddle (use RSS description only)

import { execSync, spawnSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  readdirSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";

// Vault is the cwd. Run from vault root: cd <vault> && bun run <this-script>.
// Sanity-check by looking for an Obsidian vault marker (.obsidian/) or Inbox/.
const VAULT = process.cwd();
if (!existsSync(join(VAULT, ".obsidian")) && !existsSync(join(VAULT, "Inbox"))) {
  console.error(
    `cwd does not look like an Obsidian vault: ${VAULT}\n` +
      "Run from your vault root (the directory containing .obsidian/ or Inbox/).",
  );
  process.exit(1);
}
const RAW_ROOT = join(VAULT, "Inbox/feeds/raw");
const FEED_SERVER = process.env.PANDASTACK_FEED_SERVER ?? "http://localhost:3456";
const DEFUDDLE = `${process.env.HOME}/.bun/bin/defuddle`;

const args = process.argv.slice(2);
const LIMIT_IDX = args.indexOf("--limit");
const LIMIT = LIMIT_IDX >= 0 ? parseInt(args[LIMIT_IDX + 1] ?? "100", 10) : 100;
const DRY = args.includes("--dry");
const NO_DEFUDDLE = args.includes("--no-defuddle");

// Source types where defuddle is appropriate (web articles with full body)
const ARTICLE_TYPES = new Set(["rss", "website", "threads"]);

interface FeedItem {
  id: string;
  title: string;
  url: string;
  description: string;
  source_type: string;
  source_name: string;
  pub_date: string;
}

interface SourceMeta {
  name: string;
  tags?: string[];
}

interface DefuddleResult {
  title?: string;
  description?: string;
  author?: string;
  published?: string;
  domain?: string;
  image?: string;
  site?: string;
  language?: string;
  wordCount?: number;
  contentMarkdown?: string;
}

const NOISE_PATTERNS = [
  /\b(coupon|promo code|discount code)\b/i,
  /\d+%\s*off\b/i,
  /\bdeal\b/i,
];

function isNoise(item: FeedItem): boolean {
  if (item.title.split(/\s+/).length <= 1 && item.title.length < 20) return true;
  return NOISE_PATTERNS.some(
    (re) => re.test(item.title) || re.test(item.description),
  );
}

function slugify(s: string, max = 60): string {
  return s
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, "-")
    .replace(/^-|-$/g, "")
    .slice(0, max) || "untitled";
}

function defuddleFetch(url: string): DefuddleResult | null {
  try {
    const res = spawnSync(DEFUDDLE, ["parse", url, "--json"], {
      encoding: "utf-8",
      timeout: 30_000,
    });
    if (res.status !== 0 || !res.stdout) return null;
    return JSON.parse(res.stdout) as DefuddleResult;
  } catch {
    return null;
  }
}

function yamlString(s: string): string {
  return `"${s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, " ")}"`;
}

function yamlTagList(tags: string[]): string {
  return tags
    .map((t) => (/^[a-zA-Z0-9_-]+$/.test(t) ? t : yamlString(t)))
    .join(", ");
}

function buildMarkdown(
  item: FeedItem,
  defuddle: DefuddleResult | null,
  sourceTags: string[],
): string {
  const today = new Date().toISOString().slice(0, 10);
  const fetchedAt = new Date().toISOString();
  const title = (defuddle?.title || item.title).trim();
  const description = (defuddle?.description || item.description || "")
    .trim()
    .slice(0, 500);
  const author = defuddle?.author?.trim() || "";
  const published =
    defuddle?.published?.slice(0, 10) ||
    (item.pub_date ? item.pub_date.slice(0, 10) : "");
  const site = defuddle?.site?.trim() || "";
  const image = defuddle?.image || "";
  const wordCount = defuddle?.wordCount || 0;
  const language = defuddle?.language || "";
  const body = (defuddle?.contentMarkdown || item.description || "").trim();

  const fm: string[] = [
    `title: ${yamlString(title)}`,
    `source: ${yamlString(item.url)}`,
    `source_name: ${yamlString(item.source_name)}`,
    `source_type: ${item.source_type}`,
    `created: "${today}"`,
    `fetched_at: "${fetchedAt}"`,
    `type: feed-raw`,
    `origin: ai-fetched`,
  ];
  if (author) fm.push(`author: ${yamlString(author)}`);
  if (published) fm.push(`published: "${published}"`);
  if (site && site !== item.source_name) fm.push(`site: ${yamlString(site)}`);
  if (description) fm.push(`description: ${yamlString(description)}`);
  if (image) fm.push(`image: ${yamlString(image)}`);
  if (wordCount) fm.push(`word_count: ${wordCount}`);
  if (language) fm.push(`language: ${language}`);

  const allTags = Array.from(
    new Set(["clippings", item.source_type, ...sourceTags]),
  );
  fm.push(`tags: [${yamlTagList(allTags)}]`);

  return `---
${fm.join("\n")}
---

# ${title}

${body}

[Source](${item.url})
`;
}

// ----- main -----
console.log(`[curate] fetching unprocessed items from ${FEED_SERVER}`);
const itemsRaw = execSync(
  `curl -sf "${FEED_SERVER}/items?unprocessed=1"`,
  { encoding: "utf-8", maxBuffer: 100 * 1024 * 1024 },
);
const allItems: FeedItem[] = JSON.parse(itemsRaw);
console.log(`[curate] ${allItems.length} unprocessed items in DB`);

const items = allItems.slice(0, LIMIT);
if (items.length < allItems.length) {
  console.log(`[curate] processing first ${items.length} (--limit ${LIMIT})`);
}
if (items.length === 0) {
  console.log("[curate] nothing to do");
  process.exit(0);
}

// Source tag lookup
const sourcesRaw = execSync(`curl -sf "${FEED_SERVER}/sources"`, {
  encoding: "utf-8",
});
const sources: SourceMeta[] = JSON.parse(sourcesRaw);
const sourceTagsByName = new Map<string, string[]>();
for (const s of sources) sourceTagsByName.set(s.name, s.tags || []);

const today = new Date().toISOString().slice(0, 10);

// Cross-date dedup: scan ALL date folders for existing slugs
const existingSlugs = new Set<string>();
if (existsSync(RAW_ROOT)) {
  for (const dateDir of readdirSync(RAW_ROOT)) {
    const dirPath = join(RAW_ROOT, dateDir);
    let listing: string[];
    try {
      listing = readdirSync(dirPath);
    } catch {
      continue;
    }
    for (const f of listing) {
      if (f.endsWith(".md")) existingSlugs.add(f.slice(0, -3));
    }
  }
}

let written = 0;
let noise = 0;
let dedup = 0;
let defuddleFailed = 0;
const processedIds: string[] = [];

for (const item of items) {
  processedIds.push(item.id);

  if (isNoise(item)) {
    noise++;
    continue;
  }

  const slug = slugify(item.title);
  if (existingSlugs.has(slug)) {
    dedup++;
    continue;
  }

  let defuddle: DefuddleResult | null = null;
  const useDefuddle =
    !NO_DEFUDDLE && ARTICLE_TYPES.has(item.source_type) && !!item.url;

  if (useDefuddle) {
    process.stdout.write(`  ${slug}: defuddle... `);
    defuddle = defuddleFetch(item.url);
    if (defuddle?.contentMarkdown) {
      console.log(`OK (${defuddle.contentMarkdown.length} chars)`);
    } else {
      console.log("FAIL → fallback to RSS description");
      defuddleFailed++;
    }
  } else {
    console.log(`  ${slug}: ${item.source_type} (skip defuddle)`);
  }

  const sourceTags = sourceTagsByName.get(item.source_name) || [];
  const md = buildMarkdown(item, defuddle, sourceTags);
  // Dir = curate run date (fetch event). Article published date lives in
  // frontmatter. Matches Inbox/clippings/ convention; without this, items
  // scatter across decades by article pub date and break "today's run" view.
  const targetDir = join(RAW_ROOT, today);

  if (DRY) {
    console.log(`    [dry] would write ${today}/${slug}.md (${md.length} bytes)`);
  } else {
    if (!existsSync(targetDir)) mkdirSync(targetDir, { recursive: true });
    writeFileSync(join(targetDir, `${slug}.md`), md);
    existingSlugs.add(slug);
  }
  written++;
}

if (!DRY && processedIds.length > 0) {
  const body = JSON.stringify({ ids: processedIds });
  execSync(
    `curl -sf -X POST "${FEED_SERVER}/items/processed" -H "Content-Type: application/json" -d '${body.replace(/'/g, "'\\''")}'`,
    { encoding: "utf-8" },
  );
}

console.log("");
console.log(`[curate] summary:`);
console.log(`  written:        ${written}`);
console.log(`  noise skipped:  ${noise}`);
console.log(`  dedup skipped:  ${dedup}`);
console.log(`  defuddle fail:  ${defuddleFailed} (used RSS description)`);
console.log(`  marked processed in feed-server: ${processedIds.length}`);
