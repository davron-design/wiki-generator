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
- **Cross-link surface**: What will the new article link to? List the existing articles and the concepts that deserve their own article. If the wiki already holds related articles and the new one links to none of them, the topic placement is probably wrong, so reconsider it before writing. Inbound links from existing articles are the audit's missing-cross-links work.
- **Naming & dedup**: Does this entity/topic already have a slug? Before creating one, scan `_master-index.md` and the target `_index.md` — reuse the canonical form, and append to the existing article rather than forking a near-duplicate under a variant slug.
- **Append, create, or queue?**: Complementary facts about an already-articled entity are an **append**; genuinely new ground is a **new article**; anything that contradicts or supersedes existing text is a **queue row** — never an in-place edit.

## Procedure

First, list `raw/` recursively and set aside everything that isn't source material: the archive folders (`_<date>-compiled/` and `_archive/`), dotfiles such as `.gitkeep` and `.DS_Store`, Office lock files whose names start with `~$`, and empty folders. If nothing is left, there's nothing to compile: tell the user and stop, and create no dated archive folder.

For each remaining file in `raw/` (skip any `_<date>-compiled/` archive folders and the `_archive/` folder — neither is source material; recurse into topic subfolders like `raw/<topic>/` if the user has pre-bucketed material):

1. **Read the raw file in full.** Extract the key claims, definitions, and named entities from everything the file holds: text, tables, pictures, charts, and speaker notes. *Reading source files* below says how to read each format. Text extraction alone misses pictures and chart values in Office files, so follow that section for every `.pptx`, `.docx` and `.xlsx`. If you could read only part of a file, compile what you read and list the unread items in the run report. If you can't read it at all, leave it in `raw/`, skip it, and flag it in the run report. Never compile from a filename or a guess at unreadable contents.
2. **Classify the material.** Read `wiki/_master-index.md` to see existing topic folders, then the target topic's `_index.md`. Decide the destination:
   - **Append to an existing article** — the material adds complementary facts to an entity that is already articled. Plan an append (step 4), not a new file.
   - **New article in an existing topic** — genuinely new ground that fits an existing folder.
   - **New topic folder** (with its own `_index.md`) — if no existing topic fits.
   - **Spans multiple topics**: pick the single best-fit topic as the article's **canonical home** and write it once there. In each *other* relevant topic's `_index.md`, add a cross-listing row using the piped form `[[canonical-topic/article-slug\|article-slug]]`, with a description noting where it lives. Inside a table row the pipe is always written `\|`, because a bare `|` ends the cell and breaks the link. (A raw file with several distinct sub-topics is still several articles: one per sub-topic, each in its own best-fit home.)
3. **Read the neighbors before writing.** Read every existing article the new material will cross-link to, plus any article in the target topic whose `_index.md` description shares the material's key entities. This bounded read — linked and same-entity articles, never the whole wiki — is what makes conflict detection possible: you cannot notice a contradiction in an article you never opened. Compare the new material's claims against what those articles say:
   - **Complementary** — the existing text stands; the new facts extend it → append (step 4).
   - **Contradicting or superseding** — leave the existing text untouched and log a queue row (see *Logging deferred conflicts*). Any non-conflicting remainder of the raw file still gets appended or articled normally.
   - **Two sources in this run disagree**: "existing text" means text that was in the wiki before this run started. This rule covers only claims that are new to the wiki in this run. If the wiki already held the claim before the run, that text stays untouched, and each source that contradicts it gets its own queue row. When two sources compiled in the same run contradict each other, the article gets the claim from the document with the later stated date, meaning a date printed in the document itself (a cover date, an "as of" line, a revision date). File timestamps and the file's metadata (`docProps/core.xml`) don't count, since copying a file or reusing a template changes them. If neither document states a date, a version in the filename decides (`deck-v2` over `deck-v1`). If the winning claim is read second, replace the text this run wrote with it. If neither rule settles it, the claim read first stays. Either way, log the losing claim as a queue row with `same-run` added to its Flagged cell, or `same-run, order unknown` when neither rule applied, so the audit sees both claims.
4. **Write or append.**
   - **New article** at `wiki/<topic>/<article-slug>.md`:
     - Filename: lowercase, hyphenated (e.g., `ai-agent-overview.md`), and unique across all of `wiki/`. A short `[[article-slug]]` link resolves by filename alone, so two `overview.md` files in different topics make every `[[overview]]` ambiguous. Before creating the file, search every topic folder for the name (`find wiki -name '<slug>.md'`). If an article on the same subject has it, append to that article instead. If an article on a different subject has it, pick a more specific slug (`<topic>-overview.md`).
     - Bullet points over paragraphs — keep it concise.
     - Use `[[wiki links]]` whenever you mention another concept that has (or should have) its own article — linking to an article that doesn't exist yet is fine; it flags a future write.
     - **Always** include a `## Key Takeaways` section.
     - **End with a `Sources:` footer**: a blank line, a `---` line, a `Sources:` line, and then one list item per source, `- <path relative to raw/> (compiled YYYY-MM-DD)`. The blank line keeps the `---` from turning the line above it into a heading, and the list items keep each source on its own line when the article renders. Before a source's first citation, fix its archive name: if `raw/_<today>-compiled/<path>` already exists from an earlier run today, cite the next free suffix before the extension (`deck.pptx` becomes `deck-2.pptx`, then `deck-3.pptx`), and step 7 archives the file under that name. The date is what keeps the citation resolvable after archiving: a source cited `(compiled 2026-09-09)` lives at `raw/_2026-09-09-compiled/<path>`, or at `raw/_archive/_2026-09-09-compiled/<path>` once step 9 has swept that folder. Check both roots before concluding a source is gone. Provenance is the evidence the audit uses later to decide which claim wins.
   - **Append to an existing article**: add new bullets at the end of the relevant sections, or a new section placed above the footer's `---` line, so the footer stays last; new takeaways go as bullets at the end of `## Key Takeaways`; add the source as a new `- <path> (compiled YYYY-MM-DD)` item at the end of the `Sources:` list. An older footer that puts each source on a plain line (`Sources: <path> (compiled …)`) may be converted to the list form while you append to it. That changes only the footer's layout, so it is allowed. **Never modify or delete existing text.** Merging, rewording, and pruning are audit-time work (the audit's "needs consolidation" pass exists precisely to compact accreted articles under user supervision).
5. **Update the topic's `_index.md`** — entries live in a markdown table (`| Article | Description |`), not a bullet list. Add a row with `[[article-slug]]` and a description rich enough to navigate by. If you appended to an existing article, refresh its row's description if it has gone stale — index rows are navigation metadata, not article text, so updating them is always allowed. If the topic folder is new, create `_index.md` first with:
   - A `# <Topic> — Index` heading and a one- or two-line topic summary.
   - At least one section heading (e.g. `## Core`) above the table. Once a topic exceeds ~5 articles, split into multiple sections (e.g. `## People`, `## Programmes & Events`) — each section gets its own table. Section grouping is what makes a large topic browsable.
6. **Update `wiki/_master-index.md`**: also a markdown table (`| Topic | Description |`), one row per topic. Use the piped wiki-link form, escaped for the table as `[[topic-slug/_index\|topic-slug]]`, so the row links to the topic's index while showing a clean label. Add or update the row when you create a new topic or when the existing description has gone stale. When you add the first topic row, delete the seed's `_No topics yet…_` placeholder line. Descriptions should be navigable: pack in signature sub-areas and key entities.
7. **Archive the sources.** Once every raw file for this run is processed, move each one into `raw/_<YYYY-MM-DD>-compiled/` (today's date, which must match the date in every `Sources:` item and queue row you wrote this run), **preserving each file's path relative to `raw/`**: a source at `raw/<topic>/notes.md` archives to `raw/_<date>-compiled/<topic>/notes.md`. Create the dated folder only when at least one file is being archived.
   - **Archive every processed file**, including one whose claims all went to the reconciliation queue. Its queue rows are its citation. Only files skipped as unreadable stay in `raw/`.
   - **Never overwrite an archived file.** A second compile on the same day finds the dated folder already there, and a plain `mv` replaces a file at the same path without asking. Move each file with `mv -n` to the archive name fixed in step 4, which carries a suffix (`deck-2.pptx`) when the plain name was taken. The suffix records a name clash and nothing else, so it says nothing about which document is newer; a queue row for that file names its original filename.
   - Files that pre-existed inside an older `_*-compiled/` folder stay where they are.
8. **Verify the trail before reporting.** For every `Sources:` item and queue-row citation you wrote this run, confirm a file exists at `raw/_<date>-compiled/<path>`, and confirm that no compiled source is still sitting in `raw/`: a skipped `mv -n` leaves it there, while an earlier file at the same archive path would still pass the first check. This checks only the sources this run touched, so its cost stays proportional to the ingest, and it catches the three ways the trail breaks at write time: a file the archive step missed, a footer whose date drifted from the folder's (a run resumed the next day), and a mistyped filename. Fix any line that doesn't resolve before you report.
9. **Sweep stale archives once `raw/` clutters up.** If more than 10 `_<date>-compiled/` folders sit *directly* in `raw/` (not counting anything inside `_archive/`), move all but the newest-dated one into `raw/_archive/` (create it if needed), each folder whole with its name intact. This is purely cosmetic — it keeps `raw/` showing the latest run plus the archive instead of a wall of dated folders, and changes nothing in `wiki/`.

## Reading source files

Step 1 reads every file in full. Extracted text from an Office file misses most of what a reader sees: pictures pasted into slides and pages sit in the zip's `media/` folder, native charts keep their values in separate `charts/` files, and speaker notes live in `ppt/notesSlides/`.

Work in a temporary folder outside the vault (`mktemp -d`), and use its literal path in every later command, because shell variables don't carry over between Bash calls. Run multi-line scripts through `bash <<'EOF'`, since the Bash tool may start zsh, which splits words and expands patterns differently. Nothing you render or unzip goes into `raw/`, `wiki/` or `output/`.

- **PDFs and images** (`.pdf`, `.png`, `.jpg`, `.gif`, `.webp`): read them directly. Read a long PDF in page ranges until every page is covered.
- **Office files with LibreOffice** (`.pptx`, `.docx`, and the older `.ppt`, `.doc`, `.xls`):
  - Find `soffice` with `command -v soffice`. The installers usually leave it off PATH, so also try `/Applications/LibreOffice.app/Contents/MacOS/soffice` on macOS and `C:\Program Files\LibreOffice\program\soffice.exe` on Windows (`/c/Program Files/LibreOffice/program/soffice.exe` in Git Bash).
  - Render with `soffice --headless --convert-to pdf --outdir <temp folder> <file>` and read the PDF, including every picture on its pages. Always pass `--outdir`: without it the PDF lands next to the source, and the next compile picks it up as new material. If no PDF appears, LibreOffice may already be open; add `-env:UserInstallation=file://<temp folder>/lo` to run it with a separate profile.
  - Unzip a copy into the temp folder and read what the PDF lacks or blurs: the exact chart values in `charts/chart*.xml` (the `<c:v>` values of each series; a rendered chart shows bars against axis ticks unless it has data labels), the speaker notes in `ppt/notesSlides/`, and every hidden slide, meaning a `ppt/slides/slideN.xml` whose root element carries `show="0"`. The PDF leaves hidden slides out, so read their text and pictures the way the *Office files without LibreOffice* bullet below describes. An older binary file can't be unzipped, so first convert a copy to the current format into the temp folder (`--convert-to pptx`, `docx` or `xlsx`) and unzip that.
- **Office files without LibreOffice:** unzip a copy into the temp folder and read:
  - every `<a:t>` text run in `ppt/slides/`, `ppt/notesSlides/`, `ppt/charts/` and `ppt/diagrams/` (SmartArt), or for `.docx` every `<w:t>` run in `word/document.xml` and its headers, footers and footnotes. Read the XML runs directly, since a loop over a library's text frames skips tables and grouped shapes.
  - every chart's values in `charts/chart*.xml`.
  - every image in `media/`, opened one by one. Match each image to its slide or page through `ppt/slides/_rels/slideN.xml.rels` or `word/_rels/document.xml.rels`. Slide order is set in `ppt/presentation.xml`, and the numbers in the slide file names can differ from it.
  - `.emf` and `.wmf` images (common for content pasted from Excel) can't be opened this way, so count them as unread. The older binary `.ppt`, `.doc` and `.xls` files can't be unzipped and are unreadable without LibreOffice.
- **Spreadsheets** (`.xlsx`): read the cell values of every sheet, hidden ones included (`state="hidden"` in `xl/workbook.xml`). Render the workbook only when it has `xl/media/` or `xl/charts/`, and take chart values from `xl/charts/chart*.xml`.

Then sort each file by what you managed to read:
- **Read in full:** compile it.
- **Partly read** (some images, charts or slides stayed unread): compile what you read, and list each unread item by slide or page in the run report, so the user can check it by hand.
- **Unreadable:** leave it in `raw/`, skip it, and flag it in the run report.

Keep count as you go. For each Office file the run report states how it was read and how many of its images and charts you read out of the number found.

## Logging deferred conflicts

Compile is additive — it creates articles and appends to them, but never rewrites or deletes existing text. Additive ingest only stays safe if the conflicts it *defers* are captured somewhere durable. A conflict mentioned only in your run report is gone by the next session, and the audit has no way to know it was ever raised — so it silently rots into "organized misinformation": a superseded claim sits in an article, newer articles link to it, and every page still reads fine. The reconciliation queue is what prevents that.

So whenever new raw material contradicts or supersedes an article already in the wiki, append a row to `wiki/_pending-reconciliation.md` (create the file with this header if it doesn't exist yet):

```markdown
# Pending Reconciliation

Open conflicts `raw-compile` deferred for `audit-wiki` to resolve. Compile appends rows here; audit resolves them, records the resolution under "Resolved Reconciliations" in its report, and removes the cleared rows — when no rows remain, audit deletes this file. Every row in this file is therefore live, open debt.

| Flagged | Existing article | Existing claim (quoted) | Conflicting claim (source) |
|---|---|---|---|
| YYYY-MM-DD | `wiki/<topic>/<article>.md:<line>` | the article's current claim, quoted verbatim | what the new source asserts, and which raw source said it, cited the way a `Sources:` item is: `<path relative to raw/> (compiled YYYY-MM-DD)` |
```

Before appending a row, check the queue for an open row on the same article and claim. If one exists, add this source's citation to that row's last cell and write no second row. A duplicate row counts twice against the audit score and splits one conflict into two records. Also check the *Resolved Reconciliations* sections of the reports in `output/_audits/`: if an audit already settled this article and claim against this same source, log no row, because that decision stands. Inside a table cell, write any `|` in a quoted claim as `\|`, or the row splits.

Keep each row specific enough that the audit can act on it without re-deriving the conflict from scratch — name the article path and line, **quote the article's existing claim verbatim** (line numbers drift as later appends land; quoted text stays findable), quote what the new source claims, and name the raw source. There is no status column: a row's presence *is* its "open" status. Resolving a conflict is an audit-time decision, never a compile-time one.

`_pending-reconciliation.md` is a meta file like `_master-index.md`, not an article, so it lives at the wiki root and is exempt from the "every article belongs to a topic folder" rule. It is the open-debt handoff between additive ingest and periodic reconciliation — without it, the whole compile-then-audit split leaks. The *durable* record of conflicts already resolved lives in the audit reports (under "Resolved Reconciliations"), so this file only ever carries what's still outstanding and disappears once the queue is empty.

## Output to the user

After compiling, report:
- Which articles were created and which were appended to, per topic (new vs. existing topics)
- Any new topic folders created
- The name of the dated archive folder, and any file archived under a suffixed name because its path was already taken
- For each Office file: how it was read (rendered with LibreOffice, or read from the zip), how many of its images and charts you read out of the number found, and any unread items by slide or page
- Files skipped as unreadable, which are still waiting in `raw/`
- How many source files have been compiled since the latest report in `output/_audits/`: count the files in `_<date>-compiled/` folders (directly in `raw/` and inside `raw/_archive/`) dated on or after the date in that report's filename, or all of them if no audit has run yet. `CLAUDE.md` suggests an audit after roughly 10 new sources, and this count shows when one is due
- Whether stale compiled folders were swept into `raw/_archive/` this run (and how many), so the declutter is visible rather than silent
- Any conflicts logged to `wiki/_pending-reconciliation.md` this run, and the total number of rows now waiting — so the user can see reconciliation debt accruing and judge when an audit is due (every row is open by definition; there is no resolved clutter in this file)
- Anything ambiguous you had to make a judgment call on (so the user can correct course)

## Anti-patterns

- **NEVER compile an Office file from its extracted text alone.** Pictures, chart values and speaker notes sit outside the text, so the article loses them without a trace, and archiving the file hides the loss. Follow *Reading source files*.
- **NEVER drop articles into `wiki/` root.** Every article belongs to a topic folder — `_master-index.md` is the only navigation entry point that lives at the root.
- **NEVER skip `[[wiki links]]` for cross-references.** Broken graphs are silent failures — the article reads correctly but the knowledge base loses its connective tissue.
- **NEVER fork a variant slug for an entity that already has an article.** "GenAI" and "generative AI" as two files silently fragment the link graph — the wiki's connective tissue rots while every page still reads fine.
- **NEVER move a raw file into `_<date>-compiled/` before everything it contributed has landed:** its article text, its index rows, and its queue rows. A file archived halfway severs the source-to-article provenance trail. A file whose claims all went to the queue is done once its rows are written.
- **NEVER overwrite a file that is already archived.** Two compiles on one day can meet at the same path in `raw/_<date>-compiled/`, and a plain `mv` silently replaces the earlier document. Every footer citing it then points at a different file, and the audit judges conflicts against the wrong evidence. Archive under the next free suffix (`deck-2.pptx`) and cite that name.
- **NEVER flatten topic subfolders when archiving into `_<date>-compiled/`.** Two files named `notes.md` under different `raw/<topic>/` buckets collapse onto one path, and the second move overwrites the first: a source file is destroyed outright, and both articles' footers now cite an ambiguous name. Mirror each file's raw-relative path into the dated folder instead.
- **NEVER treat `_archive/` or any `_<date>-compiled/` folder as source material.** They hold already-compiled inputs; recursing into them re-ingests old sources and spawns duplicate articles. Skip them on every pass — the `_archive/` sweep only *relocates* these folders, it never re-reads them.
- **NEVER flatten the dated folders when sweeping into `_archive/`.** Move each `_<date>-compiled/` folder in whole, name intact — merging their contents into one bucket destroys the per-run, dated provenance grouping that ties each source back to the run that compiled it.
- **NEVER modify or delete existing article text during compile.** Appending is allowed — that's how complementary facts land — but merging, rewording, and pruning are audit-time decisions. If new raw material conflicts with or supersedes existing text, leave that text untouched and log it to the reconciliation queue (see *Logging deferred conflicts* above) — as a row in `wiki/_pending-reconciliation.md`, not merely in the run report, or it evaporates before the next audit and the deferral becomes a quiet data loss.
- **NEVER duplicate an article's content across topic folders.** A multi-topic article gets one canonical home; every other relevant topic cross-lists it via an `_index.md` row. Content clones drift apart and resurface later as audit findings.
- **NEVER write or append without updating the `Sources:` footer.** Unattributed claims are impossible to reconcile later — when a conflict reaches the audit, provenance is the evidence that decides which claim wins.
- **NEVER skip the `## Key Takeaways` section.** It is the article's TL;DR — queries depend on it.
- **NEVER write `_master-index.md` or a topic `_index.md` as a bullet list.** Indexes are markdown tables — the extra structure is what makes the wiki navigable at a glance. If you find an existing index in bullet form, convert it to a table when you touch it.
