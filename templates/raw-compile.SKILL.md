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

First, list `raw/`. If it holds nothing but archive folders — `_<date>-compiled/` folders and/or the `_archive/` folder — there's nothing to compile; tell the user and stop; do not create an empty dated archive folder.

For each remaining file in `raw/` (skip any `_<date>-compiled/` archive folders and the `_archive/` folder — neither is source material; recurse into topic subfolders like `raw/<topic>/` if the user has pre-bucketed material):

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
7. **Sweep stale archives once `raw/` clutters up.** After archiving this run, count the `_<date>-compiled/` folders sitting *directly* in `raw/` — do not count anything already inside `_archive/`. If there are **more than 10** (11 or more), move all of them **except the newest-dated one** (normally the folder this run just created) into `raw/_archive/` (create it if it doesn't exist), each `_<date>-compiled/` folder moved whole with its name intact. This leaves the top level holding just that one most-recent run (count resets to 1); the next sweep fires once 10 more accumulate (11 again). The point is purely cosmetic — keep `raw/` showing the latest run plus the archive, not a wall of dated folders — so it changes nothing in `wiki/`.

## Logging deferred conflicts

Compile is additive — it never rewrites an existing article. But additive ingest only stays safe if the conflicts it *defers* are captured somewhere durable. A conflict mentioned only in your run report is gone by the next session, and the audit has no way to know it was ever raised — so it silently rots into "organized misinformation": a superseded claim sits in an article, newer articles link to it, and every page still reads fine. The reconciliation queue is what prevents that.

So whenever new raw material contradicts or supersedes an article already in the wiki, append a row to `wiki/_pending-reconciliation.md` (create the file with this header if it doesn't exist yet):

```markdown
# Pending Reconciliation

Open conflicts `raw-compile` deferred for `audit-wiki` to resolve. Compile appends rows here; audit resolves them, records the resolution under "Resolved Reconciliations" in its report, and removes the cleared rows — when no rows remain, audit deletes this file. Every row in this file is therefore live, open debt.

| Flagged | Existing article | Conflicting claim (source) |
|---|---|---|
| YYYY-MM-DD | `wiki/<topic>/<article>.md:<line>` | what the new source asserts and what it contradicts |
```

Keep each row specific enough that the audit can act on it without re-deriving the conflict from scratch — name the article path and line, quote what the new source claims, and name the raw source. There is no status column: a row's presence *is* its "open" status. Resolving a conflict is an audit-time decision, never a compile-time one.

`_pending-reconciliation.md` is a meta file like `_master-index.md`, not an article, so it lives at the wiki root and is exempt from the "every article belongs to a topic folder" rule. It is the open-debt handoff between additive ingest and periodic reconciliation — without it, the whole compile-then-audit split leaks. The *durable* record of conflicts already resolved lives in the audit reports (under "Resolved Reconciliations"), so this file only ever carries what's still outstanding and disappears once the queue is empty.

## Output to the user

After compiling, report:
- Which topics received articles (new vs. existing)
- Any new topic folders created
- The name of the dated archive folder
- Whether stale compiled folders were swept into `raw/_archive/` this run (and how many), so the declutter is visible rather than silent
- Any conflicts logged to `wiki/_pending-reconciliation.md` this run, and the total number of rows now waiting — so the user can see reconciliation debt accruing and judge when an audit is due (every row is open by definition; there is no resolved clutter in this file)
- Anything ambiguous you had to make a judgment call on (so the user can correct course)

## Anti-patterns

- **NEVER drop articles into `wiki/` root.** Every article belongs to a topic folder — `_master-index.md` is the only navigation entry point that lives at the root.
- **NEVER skip `[[wiki links]]` for cross-references.** Broken graphs are silent failures — the article reads correctly but the knowledge base loses its connective tissue.
- **NEVER fork a variant slug for an entity that already has an article.** "GenAI" and "generative AI" as two files silently fragment the link graph — the wiki's connective tissue rots while every page still reads fine.
- **NEVER move a raw file into `_<date>-compiled/` until its article is written AND the topic index is updated.** Partial archives sever the source-to-article provenance trail.
- **NEVER treat `_archive/` or any `_<date>-compiled/` folder as source material.** They hold already-compiled inputs; recursing into them re-ingests old sources and spawns duplicate articles. Skip them on every pass — the `_archive/` sweep only *relocates* these folders, it never re-reads them.
- **NEVER flatten the dated folders when sweeping into `_archive/`.** Move each `_<date>-compiled/` folder in whole, name intact — merging their contents into one bucket destroys the per-run, dated provenance grouping that ties each source back to the run that compiled it.
- **NEVER overwrite an existing wiki article during compile.** If new raw material conflicts with or supersedes an existing article, leave the article untouched and log it to the reconciliation queue (see *Logging deferred conflicts* above). Updating existing content is an audit-time decision, not an ingest-time one — but the conflict must land as a row in `wiki/_pending-reconciliation.md`, not merely in the run report, or it evaporates before the next audit and the deferral becomes a quiet data loss.
- **NEVER skip the `## Key Takeaways` section.** It is the article's TL;DR — queries depend on it.
- **NEVER write `_master-index.md` or a topic `_index.md` as a bullet list.** Indexes are markdown tables — the extra structure is what makes the wiki navigable at a glance. If you find an existing index in bullet form, convert it to a table when you touch it.
