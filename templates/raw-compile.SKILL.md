---
name: raw-compile
description: Compile new source material from raw/ into the wiki/ knowledge base. Use when the user says "compile", drops new files into raw/, or asks to ingest research into the wiki. Reads each raw file, classifies it by topic, writes concise wiki articles (or appends to existing ones) with [[wiki links]], updates indexes, and archives compiled sources into a dated _compiled folder.
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
- **Naming & dedup**: Does this entity/topic already have a slug? Before creating one, scan `_master-index.md` and the target `_index.md` — reuse the canonical form, and append to the existing article rather than forking a near-duplicate under a variant slug.
- **Append, create, or queue?**: Complementary facts about an already-articled entity are an **append**; genuinely new ground is a **new article**; anything that contradicts or supersedes existing text is a **queue row** — never an in-place edit.

## Procedure

First, list `raw/`. If it holds nothing but archive folders — `_<date>-compiled/` folders and/or the `_archive/` folder — there's nothing to compile; tell the user and stop; do not create an empty dated archive folder.

For each remaining file in `raw/` (skip any `_<date>-compiled/` archive folders and the `_archive/` folder — neither is source material; recurse into topic subfolders like `raw/<topic>/` if the user has pre-bucketed material):

1. **Read the raw file.** Extract the key claims, definitions, and named entities. PDFs and images can be read directly; for formats you can't parse (e.g. `.docx`, `.pptx`, `.xlsx`), extract the text first, or — if you can't — leave the file in `raw/`, skip it, and flag it in the run report. Never compile from a filename or a guess at unreadable contents.
2. **Classify the material.** Read `wiki/_master-index.md` to see existing topic folders, then the target topic's `_index.md`. Decide the destination:
   - **Append to an existing article** — the material adds complementary facts to an entity that is already articled. Plan an append (step 4), not a new file.
   - **New article in an existing topic** — genuinely new ground that fits an existing folder.
   - **New topic folder** (with its own `_index.md`) — if no existing topic fits.
   - **Spans multiple topics** — pick the single best-fit topic as the article's **canonical home** and write it once there. In each *other* relevant topic's `_index.md`, add a cross-listing row using the piped form `[[canonical-topic/article-slug|article-slug]]`, with a description noting where it lives. (A raw file with several distinct sub-topics is still several articles — one per sub-topic, each in its own best-fit home.)
3. **Read the neighbors before writing.** Read every existing article the new material will cross-link to, plus any article in the target topic whose `_index.md` description shares the material's key entities. This bounded read — linked and same-entity articles, never the whole wiki — is what makes conflict detection possible: you cannot notice a contradiction in an article you never opened. Compare the new material's claims against what those articles say:
   - **Complementary** — the existing text stands; the new facts extend it → append (step 4).
   - **Contradicting or superseding** — leave the existing text untouched and log a queue row (see *Logging deferred conflicts*). Any non-conflicting remainder of the raw file still gets appended or articled normally.
4. **Write or append.**
   - **New article** at `wiki/<topic>/<article-slug>.md`:
     - Filename: lowercase, hyphenated (e.g., `ai-agent-overview.md`).
     - Bullet points over paragraphs — keep it concise.
     - Use `[[wiki links]]` whenever you mention another concept that has (or should have) its own article — linking to an article that doesn't exist yet is fine; it flags a future write.
     - **Always** include a `## Key Takeaways` section.
     - **End with a `Sources:` footer** — a final `---` line followed by `Sources: <raw filename> (compiled YYYY-MM-DD)`. Provenance is the evidence the audit uses later to decide which claim wins.
   - **Append to an existing article** — add new bullets at the end of the relevant sections, or a new section; new takeaways go as bullets at the end of `## Key Takeaways`; add the raw filename + date as a new line in the `Sources:` footer. **Never modify or delete existing text** — merging, rewording, and pruning are audit-time work (the audit's "needs consolidation" pass exists precisely to compact accreted articles under user supervision).
5. **Update the topic's `_index.md`** — entries live in a markdown table (`| Article | Description |`), not a bullet list. Add a row with `[[article-slug]]` and a description rich enough to navigate by. If you appended to an existing article, refresh its row's description if it has gone stale — index rows are navigation metadata, not article text, so updating them is always allowed. If the topic folder is new, create `_index.md` first with:
   - A `# <Topic> — Index` heading and a one- or two-line topic summary.
   - At least one section heading (e.g. `## Core`) above the table. Once a topic exceeds ~5 articles, split into multiple sections (e.g. `## People`, `## Programmes & Events`) — each section gets its own table. Section grouping is what makes a large topic browsable.
6. **Update `wiki/_master-index.md`** — also a markdown table (`| Topic | Description |`), one row per topic. Use the piped wiki-link form `[[topic-slug/_index|topic-slug]]` so the row links to the topic's index while showing a clean label. Add or update the row when you create a new topic or when the existing description has gone stale. Descriptions should be navigable — pack in signature sub-areas and key entities, not just a category name.
7. **Archive the source.** Once all raw files for this run are compiled, create `raw/_<YYYY-MM-DD>-compiled/` (use today's date) and move every raw file you just compiled into it. Files that pre-existed inside an older `_*-compiled/` folder stay where they are.
8. **Sweep stale archives once `raw/` clutters up.** If more than 10 `_<date>-compiled/` folders sit *directly* in `raw/` (not counting anything inside `_archive/`), move all but the newest-dated one into `raw/_archive/` (create it if needed), each folder whole with its name intact. This is purely cosmetic — it keeps `raw/` showing the latest run plus the archive instead of a wall of dated folders, and changes nothing in `wiki/`.

## Logging deferred conflicts

Compile is additive — it creates articles and appends to them, but never rewrites or deletes existing text. Additive ingest only stays safe if the conflicts it *defers* are captured somewhere durable. A conflict mentioned only in your run report is gone by the next session, and the audit has no way to know it was ever raised — so it silently rots into "organized misinformation": a superseded claim sits in an article, newer articles link to it, and every page still reads fine. The reconciliation queue is what prevents that.

So whenever new raw material contradicts or supersedes an article already in the wiki, append a row to `wiki/_pending-reconciliation.md` (create the file with this header if it doesn't exist yet):

```markdown
# Pending Reconciliation

Open conflicts `raw-compile` deferred for `audit-wiki` to resolve. Compile appends rows here; audit resolves them, records the resolution under "Resolved Reconciliations" in its report, and removes the cleared rows — when no rows remain, audit deletes this file. Every row in this file is therefore live, open debt.

| Flagged | Existing article | Existing claim (quoted) | Conflicting claim (source) |
|---|---|---|---|
| YYYY-MM-DD | `wiki/<topic>/<article>.md:<line>` | the article's current claim, quoted verbatim | what the new source asserts, and which raw file said it |
```

Keep each row specific enough that the audit can act on it without re-deriving the conflict from scratch — name the article path and line, **quote the article's existing claim verbatim** (line numbers drift as later appends land; quoted text stays findable), quote what the new source claims, and name the raw source. There is no status column: a row's presence *is* its "open" status. Resolving a conflict is an audit-time decision, never a compile-time one.

`_pending-reconciliation.md` is a meta file like `_master-index.md`, not an article, so it lives at the wiki root and is exempt from the "every article belongs to a topic folder" rule. It is the open-debt handoff between additive ingest and periodic reconciliation — without it, the whole compile-then-audit split leaks. The *durable* record of conflicts already resolved lives in the audit reports (under "Resolved Reconciliations"), so this file only ever carries what's still outstanding and disappears once the queue is empty.

## Output to the user

After compiling, report:
- Which articles were created and which were appended to, per topic (new vs. existing topics)
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
- **NEVER modify or delete existing article text during compile.** Appending is allowed — that's how complementary facts land — but merging, rewording, and pruning are audit-time decisions. If new raw material conflicts with or supersedes existing text, leave that text untouched and log it to the reconciliation queue (see *Logging deferred conflicts* above) — as a row in `wiki/_pending-reconciliation.md`, not merely in the run report, or it evaporates before the next audit and the deferral becomes a quiet data loss.
- **NEVER duplicate an article's content across topic folders.** A multi-topic article gets one canonical home; every other relevant topic cross-lists it via an `_index.md` row. Content clones drift apart and resurface later as audit findings.
- **NEVER write or append without updating the `Sources:` footer.** Unattributed claims are impossible to reconcile later — when a conflict reaches the audit, provenance is the evidence that decides which claim wins.
- **NEVER skip the `## Key Takeaways` section.** It is the article's TL;DR — queries depend on it.
- **NEVER write `_master-index.md` or a topic `_index.md` as a bullet list.** Indexes are markdown tables — the extra structure is what makes the wiki navigable at a glance. If you find an existing index in bullet form, convert it to a table when you touch it.
