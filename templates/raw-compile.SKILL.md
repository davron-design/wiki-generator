---
name: raw-compile
description: Compile new source material from raw/ into the wiki/ knowledge base. Use when the user says "compile", drops new files into raw/, or asks to ingest research into the wiki. Reads each raw file, classifies it by topic, writes concise wiki articles with [[wiki links]], updates indexes, and archives compiled sources into a dated _compiled folder.
---

# Raw → Wiki Compile

You are the librarian of the `wiki/` folder. This skill ingests new source material from `raw/` and turns it into well-linked wiki articles.

## When to invoke
- User says "compile" or "compile raw"
- New files have appeared in `raw/` and the user asks you to ingest them
- User asks you to add research/clipped articles to the knowledge base

## Before compiling, ask yourself
- **Topic fit**: Does this material extend an existing topic, or is it genuinely new ground? Defaulting to "new topic folder" fragments the wiki; defaulting to "existing folder" buries unrelated content under the wrong heading.
- **Article granularity**: Is this one article or several? A long raw file with three distinct sub-topics is three articles with cross-links, not one mega-article.
- **Cross-link surface**: What existing articles will reference this new one? If the answer is "none", the topic placement is probably wrong — reconsider before writing.
- **Naming & dedup**: Does this entity/topic already have a slug? Before creating one, scan `_master-index.md` and the target `_index.md` — reuse the canonical form, and extend an existing article via cross-link rather than forking a near-duplicate under a variant slug.

## Procedure

First, list `raw/`. If it holds nothing but `_<date>-compiled/` archive folders, there's nothing to compile — tell the user and stop; do not create an empty dated archive folder.

For each remaining file in `raw/` (skip any `_<date>-compiled/` archive folders; recurse into topic subfolders like `raw/<topic>/` if the user has pre-bucketed material):

1. **Read the raw file.** Extract the key claims, definitions, and named entities. PDFs and images can be read directly; for formats you can't parse (e.g. `.docx`, `.pptx`, `.xlsx`), extract the text first, or — if you can't — leave the file in `raw/`, skip it, and flag it in the run report. Never compile from a filename or a guess at unreadable contents.
2. **Classify the topic.** Read `wiki/_master-index.md` to see existing topic folders. Either:
   - Place the article inside an existing topic folder, or
   - Create a new topic folder (with its own `_index.md`) if no existing topic fits.
   - If the raw file genuinely spans multiple topics, create an article in **each** topic folder and cross-link them with `[[wiki links]]`.
3. **Write the wiki article** at `wiki/<topic>/<article-slug>.md`:
   - Filename: lowercase, hyphenated (e.g., `ai-agent-overview.md`).
   - Bullet points over paragraphs — keep it concise.
   - Use `[[wiki links]]` whenever you mention another concept that has (or should have) its own article — linking to an article that doesn't exist yet is fine; it flags a future write.
   - **Always** include a `## Key Takeaways` section.
4. **Update the topic's `_index.md`** — entries live in a markdown table (`| Article | Description |`), not a bullet list. Add a row with `[[article-slug]]` and a description rich enough to navigate by. If the topic folder is new, create `_index.md` first with:
   - A `# <Topic> — Index` heading and a one- or two-line topic summary.
   - At least one section heading (e.g. `## Core`) above the table. Once a topic exceeds ~5 articles, split into multiple sections (e.g. `## People`, `## Programmes & Events`) — each section gets its own table. Section grouping is what makes a large topic browsable.
5. **Update `wiki/_master-index.md`** — also a markdown table (`| Topic | Description |`), one row per topic. Use the piped wiki-link form `[[topic-slug/_index|topic-slug]]` so the row links to the topic's index while showing a clean label. Add or update the row when you create a new topic or when the existing description has gone stale. Descriptions should be navigable — pack in signature sub-areas and key entities, not just a category name.
6. **Archive the source.** Once all raw files for this run are compiled, create `raw/_<YYYY-MM-DD>-compiled/` (use today's date) and move every raw file you just compiled into it. Files that pre-existed inside an older `_*-compiled/` folder stay where they are.

## Output to the user

After compiling, report:
- Which topics received articles (new vs. existing)
- Any new topic folders created
- The name of the dated archive folder
- Anything ambiguous you had to make a judgment call on (so the user can correct course)

## Anti-patterns

- **NEVER drop articles into `wiki/` root.** Every article belongs to a topic folder — `_master-index.md` is the only navigation entry point that lives at the root.
- **NEVER skip `[[wiki links]]` for cross-references.** Broken graphs are silent failures — the article reads correctly but the knowledge base loses its connective tissue.
- **NEVER fork a variant slug for an entity that already has an article.** "GenAI" and "generative AI" as two files silently fragment the link graph — the wiki's connective tissue rots while every page still reads fine.
- **NEVER move a raw file into `_<date>-compiled/` until its article is written AND the topic index is updated.** Partial archives sever the source-to-article provenance trail.
- **NEVER overwrite an existing wiki article during compile.** If new raw material conflicts with or supersedes an existing article, leave the article untouched and flag it: name the existing article path, quote the conflicting raw claim, and recommend running `audit-wiki` to reconcile. Updating existing content is an audit-time decision, not an ingest-time one.
- **NEVER skip the `## Key Takeaways` section.** It is the article's TL;DR — queries depend on it.
- **NEVER write `_master-index.md` or a topic `_index.md` as a bullet list.** Indexes are markdown tables — the extra structure is what makes the wiki navigable at a glance. If you find an existing index in bullet form, convert it to a table when you touch it.
