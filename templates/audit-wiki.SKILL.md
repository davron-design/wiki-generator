---
name: audit-wiki
description: Audit or lint the wiki/ knowledge base for inconsistencies, missing cross-links, and coverage gaps, then produce a numbered audit report in output/_audits that includes a 0–100 wiki integrity score and how it changed this round. Use when the user says "audit", "lint", "audit the wiki", or asks for a wiki review. Defaults to a report-only pass — does not change article contents without explicit user confirmation.
---

# Wiki Audit

You are the librarian of the `wiki/` folder. This skill reviews the wiki for quality issues and produces a structured audit report.

## When to invoke
- User says "audit", "lint", or "audit the wiki"
- User asks for a review of wiki quality, consistency, or coverage
- User asks you to check for stale or contradictory wiki content

## Before auditing, ask yourself
- **Scope honesty**: Am I auditing what the user asked, or drifting into adjacent topics that "look interesting"? Stay in the scope they named.
- **Round positioning**: What did the last round leave open? An audit that re-flags Round N-1's resolved items is noise. Read past audits first.
- **Findings vs. proposals**: Is this a real inconsistency to flag (Findings) or a new article idea (Suggested New Articles)? They go in different sections — the user reads them with different intent.
- **Evidence strength**: Can I cite file:line for every claimed inconsistency? If not, it's a hunch, not a finding.
- **Sweep mode**: Is this a full sweep or an incremental round? A scope's first-ever round is always full; after that, incremental is the default unless the user asks for full or an escalation trigger recommends one (see *Scope & sweep mode*).

## Scope & sweep mode first
Before starting, confirm scope if it isn't clear:
- **Whole wiki** → report file is `output/_audits/YYYY-MM-DD_wiki_audit-round-N.md`
- **Single topic branch** (e.g. `wiki/<topic>/`) → report file is `output/_audits/YYYY-MM-DD_<topic>_audit-round-N.md`

Round numbering is **per topic, not global**. The whole-wiki audit has its own round sequence too. Determine `N` by scanning past reports in `output/_audits/` for the same scope.

**Queue rows follow the scope.** A single-topic audit counts and resolves only the `wiki/_pending-reconciliation.md` rows whose existing article sits in `wiki/<topic>/`. Rows for other topics stay in the queue untouched, for their own topic's audit or a whole-wiki audit. A whole-wiki audit takes every row. "The queue" in the rest of this skill means the in-scope rows.

Then pick the sweep mode:
- **Full sweep** — read every in-scope article. Mandatory for a scope's first-ever round (there is no baseline to be incremental against), and whenever the user asks for a deep audit.
- **Incremental** (the default once a prior same-scope round exists): read the index layer, the in-scope rows of `wiki/_pending-reconciliation.md`, every article named in the prior report's Known Open Items ledger (re-verifying each carried-forward issue), and every article **new or changed since the prior same-scope report's date**. In a git repo, take that list from `git log` since that date plus `git status --porcelain wiki/`: compile never commits, so the articles it wrote since the last commit show up only in `git status`. Outside git, use file modification times. Unchanged, unflagged articles are skipped, and their previously-verified state carries forward through the ledger.

The report's `**Scope:**` line must state which mode ran. Incremental keeps audit cost proportional to what changed rather than to wiki size; the escalation triggers below decide when a full sweep is due again.

### Full-sweep escalation
Recommend a full sweep — in the report summary and as an option in the closing "how to proceed" question, never by silently expanding scope — when any of these fire:
- **~5 incremental rounds** have passed since this scope's last full sweep
- this round surfaced **3 or more new inconsistencies** — a signal that unchanged articles likely harbor latent conflicts too
- re-verifying carried-forward items revealed **out-of-band edits** since last round — the wiki changed in ways the audit trail didn't see

## Procedure

1. **Read past audits and the reconciliation queue.** List `output/_audits/` and read recent reports for the same scope, so you don't re-flag resolved items and so you can carry forward unresolved "Known Open Items". Past reports are also where *already-resolved* conflicts are recorded (under "Resolved Reconciliations"); that history lives in the reports. Then read `wiki/_pending-reconciliation.md` if it exists. Every row is a still-open conflict that `raw-compile` deliberately deferred to you, and each in-scope row (see *Scope & sweep mode*) is a first-class Inconsistency finding for this round. The queue holds only open debt: it carries no resolved rows, because resolved conflicts are logged to the audit report and their rows deleted. If the file is missing, there's simply no deferred debt to clear.
2. **Read the index layer.** Start with `wiki/_master-index.md`, then each in-scope topic's `_index.md`.
3. **Read what the sweep mode calls for.** Full sweep: every article in the scope. Incremental: the new/changed articles plus every article carried forward via the ledger or the queue (see *Scope & sweep mode*).
4. **Look for:**
   - **Inconsistencies / contradictions**: claims that conflict across articles, or within one article. Note file:line. `raw-compile` defers every overwrite/supersede decision to audit, so each in-scope row in `wiki/_pending-reconciliation.md` (plus any `⚠️` source-conflict callouts) is a first-class finding here: reconcile it against the live article and decide which claim wins. When deciding, weigh each side's provenance from the articles' `Sources:` footers against the raw source named in the queue row; recency of ingest alone is no evidence. A row marked `same-run` came from two sources in one compile run, and the article holds the claim from the later-dated document unless the row also says `order unknown`. A numeric suffix on an archived filename (`deck-2.pptx`) only records a same-day name clash in the archive and carries no version order. When you open a raw source to judge it, read it the way the *Reading source files* section of `.claude/skills/raw-compile/SKILL.md` describes, because a text-only read of an Office file misses its pictures, chart values and speaker notes.
   - **Missing cross-links** — concepts mentioned in prose that have (or should have) their own article but aren't linked with `[[wiki links]]`.
   - **Gaps in coverage**: topics referenced but never articled, including `[[links]]` to articles that were never written (compile adds those on purpose to flag a future write); obvious sibling concepts missing from a topic folder.
   - **Stale or structural issues**: outdated indexes, orphaned articles, broken `[[links]]`, and `Sources:` items that resolve to no file. A link is broken when it is mistyped or its target was renamed or deleted: the target closely resembles an existing slug, or git history or an earlier report shows the article existed. A link to an article that was never written belongs under Gaps in coverage. A footer's compile date names the folder its source was archived into, so check both `raw/_<date>-compiled/<path>` and `raw/_archive/_<date>-compiled/<path>` before calling a citation dangling. A `- [[slug]] (synthesized YYYY-MM-DD)` item resolves to the article it names. Older footers that put each source on a plain line (`Sources: <path> (compiled …)`) are valid and need no finding.
   - **Needs consolidation** — articles that append-only ingest has made incoherent: redundant bullets saying the same thing twice, appended sections sitting awkwardly against older text, takeaways buried mid-list, or a structure that reads as a chronological log rather than a synthesis. Propose a supervised rewrite in the report — never perform it during this pass.
   - **Index format drift**: `_master-index.md` and every topic `_index.md` must be markdown tables (`| Topic | Description |` / `| Article | Description |`), with `##` section groupings once a topic exceeds ~5 articles. Flag any index still in bullet-list form, missing descriptions, or with a description so thin it doesn't help navigation. Also flag an index whose rows write a piped link with a bare `|` (`[[topic-slug/_index|topic-slug]]`): the row splits into an extra column and the link breaks. Inside a table it must be `\|`. Count this once per index file, however many rows it affects, and not again under broken links. The fix inserts a `\` before each such pipe and changes nothing else in the row.
5. **Suggest 3–5 new articles** that would strengthen the knowledge base. These are forward-looking proposals (not gap-fills for things already mentioned in prose — those go under Gaps in Coverage). Rank each by value-add impact:
   - **High** — closes a load-bearing gap; multiple existing articles would link inward; directly supports a current goal/decision in the wiki
   - **Mid** — useful consolidation or sibling coverage; would be referenced occasionally; nice-to-have rather than load-bearing
   - **Low** — completeness or glossary-style; rarely linked but improves navigability
   
   For each suggestion, include: proposed title, one-line purpose, impact score, a brief justification (what existing articles it would connect, what decision/use case it serves), and whether the wiki's existing articles already hold the facts it needs. A suggestion that needs facts the wiki lacks also goes on the report's Needs Source Material list. Do **not** create the articles in this pass. Surface them in the report so the user can approve, reorder, or defer.
6. **Default to report-only.** Do NOT edit article contents. Suggest changes in the report and wait for the user to confirm before applying fixes. For unresolved source conflicts you want flagged in-place, propose a `⚠️` callout — but only add it after the user agrees.
7. **Score the wiki's integrity.** From the issues you just found, compute the 0–100 integrity score (see [Wiki Integrity Score](#wiki-integrity-score)). This is the *as-found* score — the state before any fixes.
8. **Write the audit report** at `output/_audits/<filename-from-scope-section>` using the template below.

## Audit Report Template

```markdown
# Wiki Audit — <topic or "wiki">, Round N

**Date:** YYYY-MM-DD
**Scope:** articles reviewed (include the topic branch path, e.g. `wiki/<topic>/`) and the sweep mode — full or incremental
**Outcome:** one-line summary

## Findings

### 1. Inconsistencies / Contradictions
- List each issue with file:line references and the resolution taken (or "not fixed, awaiting confirmation")

### 2. Missing Cross-Links
- Summarize link edges added or recommended

### 3. Gaps in Coverage
- Bullets for topics mentioned-but-not-articled
- Split between "addressed this round" (closed with facts already in the wiki) and "remaining smaller gaps"; a gap that needs facts the wiki lacks goes under Needs Source Material

### 4. Suggested New Articles
- Table: Proposed Title | Purpose | Impact (High/Mid/Low) | Justification (what it connects, what it serves)
- 3–5 entries, ordered by impact (High first)

### 5. Needs Consolidation
- Articles whose appended content has outgrown their structure — for each: article path, what's incoherent (redundant bullets, awkward appends, buried takeaways), and a one-line proposed rewrite shape
- Proposals only — consolidation happens in the apply phase, per approved article

### 6. New Articles Created (if any)
- Table: Article | Purpose | Highest Leverage For | Built from (the wiki articles it draws on)

### 7. Needs Source Material
- Suggested articles and coverage gaps that need facts the wiki doesn't hold yet, each with the kind of source that would close it, so the user knows what to drop into `raw/`
- Omit this section when there are none

## Resolved Reconciliations
- The durable record of `_pending-reconciliation.md` rows cleared this round. Once a row is logged here, it is deleted from the queue — so this section, across all audit reports, is the permanent provenance trail of every deferred conflict ever resolved. Include only rows whose underlying conflict you actually fixed this round.
- Table: Flagged (date) | Existing article (file:line) | Existing claim (quoted) | Conflicting claim (source) | Resolution (which claim won + what changed) | Round
- Omit this section only if no reconciliation rows were cleared this round.

## Other Changes
- Index reorganizations, structural changes

## State of the Wiki After Round N
- Total articles, link edges, regions covered

## Wiki Integrity Score

Before → After: <before> → <after>   (write `(no change)` after it when no fixes were applied)

## Known Open Items
The open-issues ledger: every issue from this round's Findings that is still open at round close, one row each, so the next round can recompute its Before score mechanically. Category must match a rubric category exactly. Do NOT copy open `_pending-reconciliation.md` rows here — the queue is their durable home, and duplicating them double-counts the score.

| # | Category | Issue | Evidence (file:line) | Since round |
|---|---|---|---|---|

Below the table, note external actions (e.g., "confirm with X") and WIP items.
```

## Wiki Integrity Score

Each report carries a 0–100 integrity score so the wiki's health is legible at a glance and the round-over-round change is real. The score must be **computed from a fixed rubric, not eyeballed** — the same wiki state always yields the same number, otherwise the before→after delta means nothing.

Compute it as `score = max(0, 100 − Σ penalties)`, one penalty per *open* issue (count only issues that appear in your own Findings):

| Issue type | Penalty (each) | Cap (per round) |
|---|---|---|
| Inconsistency / contradiction | −8 | uncapped |
| Broken or orphaned link | −5 | uncapped |
| Index format drift (a non-table `_index.md` / `_master-index.md`, or one whose piped links leave the pipe unescaped; once per index file) | −4 | uncapped |
| Article needs consolidation | −3 | −9 |
| Missing cross-link | −2 | −10 |
| Coverage gap (a concept referenced in prose or linked, but never articled) | −2 | −10 |
| Convention nit (missing `## Key Takeaways` or `Sources:` footer, a `Sources:` line that resolves to no archived file, threadbare index description, off-convention filename) | −1 | −5 |

The caps exist because the capped categories are judgment calls with no natural bound — an eager round finds thirty missing cross-links, a lazy one four, and without caps that detection variance would swamp the real trend. The objective, high-stakes categories stay uncapped: every contradiction and broken link genuinely weighs.

Rows in `wiki/_pending-reconciliation.md` are deferred contradictions, so each in-scope row counts as an inconsistency (−8) for as long as it sits in the queue. It weighs on the score until reconciled, then drops out the moment its conflict is fixed and its row is cleared (logged to "Resolved Reconciliations" and deleted from the queue). This is what stops batched ingest from quietly inflating the score: the more conflicts compile defers, the lower the as-found score sits until an audit actually clears them. A row deferred (left in the queue) this round still counts; only a genuinely resolved-and-cleared one drops. A queue row and its user-approved in-article `⚠️` callout are the *same* conflict, so count it once (−8).

You record two numbers:
- **Before:** recompute it from the two durable open-issue stores: the prior same-scope report's **Known Open Items ledger** (re-verify each row; drop any the user fixed out-of-band since last round) plus every open in-scope `wiki/_pending-reconciliation.md` row, then add every new issue this round surfaces. The two stores are disjoint by construction (queue rows never appear in the ledger), so nothing counts twice. Check the carried-forward part on its own: the ledger rows plus the queue rows flagged on or before the prior report's date should land on the prior round's *After*, less any out-of-band fixes you dropped. Queue rows flagged since then and this round's new findings come on top of that. If the carried-forward part misses the prior *After*, reconcile the difference under Known Open Items and say why, since an unexplained jump makes the trend meaningless. A scope's first-ever round has no prior ledger, so Before is simply what you found.
- **After:** recomputed once the user's chosen fixes land — drop the penalty for each *resolved* issue; anything deferred or declined stays counted. If no fixes are applied, after == before.

**Keep the score line dead simple.** The rubric above is *your* working method, not something the reader needs — the score appears as one line: `Before → After: <before> → <after>`, with `(no change)` appended when nothing was applied (e.g. a report-only pass). No penalty math, no formula, no per-dimension breakdown in the report. The one structured artifact the report *must* carry is the Known Open Items ledger table — not because the reader needs arithmetic, but because the next round's Before is recomputed from it; a report without the ledger orphans the trend.

## Conventions
- **Report-only pass first** — never change article contents without user confirmation.
- **Always include the one-line Wiki Integrity Score** — `Before → After: X → Y` — since it's what makes the wiki's health legible round to round.
- After the user confirms fixes, the report documents both what was fixed AND what remains open.
- Use `⚠️` inline callouts (user-approved) in articles for unresolved source conflicts. The conflict's durable record stays its `_pending-reconciliation.md` row — a callout marks it in-place, it does not earn a Known Open Items entry.
- Numbering is sequential per topic so progression is visible across reports.
- Use today's date for the filename and the `**Date:**` field.
- In report and queue tables, write any `|` inside a quoted claim as `\|`, or the row splits.

## Anti-patterns

- **NEVER auto-create the "suggested new articles".** They are proposals for the user to approve, defer, or reject — not actions to execute. Creating them silently destroys the triage step.
- **NEVER inflate findings to make the audit "feel productive".** If a round genuinely finds nothing, write that. A short honest report beats a padded one that trains the user to ignore future audits.
- **NEVER skip the past-audits read.** Re-flagging items resolved last round wastes the user's attention and signals you didn't do the homework.
- **NEVER add `⚠️` callouts to articles before the user has approved them.** The report-only pass is binding — inline edits during audit defeat the whole point.
- **NEVER claim an inconsistency without `file:line` evidence.** A finding the user can't navigate to is unactionable.
- **NEVER tune the integrity weights or skip issues to make a round look better.** The rubric is fixed precisely so rounds are comparable; a flattered score is worse than no score.
- **NEVER log a `_pending-reconciliation.md` row under "Resolved Reconciliations" (and delete it from the queue) without actually fixing the underlying conflict in the article.** Deleting is unforgiving: once the row is gone there is no open row left for the next audit to catch, and the report's "resolved" claim becomes the only record. A row logged-and-deleted while the contradiction still lives in the wiki turns the conflict invisible to every future audit — a silent, permanent data loss. Fix the article first; log and delete only what you genuinely resolved.
- **NEVER leave resolved rows sitting in `_pending-reconciliation.md`, and NEVER keep an empty queue file around.** Resolved conflicts belong in the report's Resolved Reconciliations section; the queue holds only open debt. Delete the file only when it holds no rows at all, for any topic. A topic audit that clears its own rows usually leaves other topics' rows behind, and deleting the file then erases open conflicts that no report ever recorded.
- **NEVER recompute the Before score from a blank slate when a prior round exists.** Rebuild it from the prior report's Known Open Items ledger plus the open queue rows — a Before that ignores history isn't a baseline, it's an unrelated number, and the round-over-round delta becomes meaningless.
- **NEVER report an after-score that assumes fixes you didn't actually apply.** The after-score must reflect the wiki as it stands once you've stopped editing — deferred and declined issues stay counted.
- **NEVER dump the scoring rubric or penalty math into the report.** The score is one line — `Before → After: X → Y` — the rubric is your internal method, not reader-facing clutter. The one exception is the Known Open Items ledger table: it lists open issues (not penalties) and is mandatory, because the next round's Before is recomputed from it.
- **NEVER copy open `_pending-reconciliation.md` rows into the Known Open Items ledger.** The queue is their durable home; duplicating them double-counts the score and forks the record into two places that will disagree.
- **NEVER rewrite an article flagged "needs consolidation" during the audit pass.** Consolidation is the wiki's only lossy rewrite, so it happens exclusively in the apply phase, per article, after the user approves that specific article.

## Output to the user

After writing the report, surface:
- The audit report path and the sweep mode that ran (full or incremental)
- The headline counts (findings per category, including articles flagged for consolidation and suggested new articles, and how many `_pending-reconciliation.md` rows were open coming in vs. cleared this round; whether the file now holds no rows for any topic and was deleted, or how many rows remain, in this scope and in total)
- Whether a full-sweep escalation trigger fired, and if so the recommendation to run one next round
- The **Wiki Integrity Score** as `Before → After: X → Y`
- A short list of the highest-leverage proposed fixes, so the user can approve, reject, or reorder before any edits are made
- The High-impact suggested articles (just titles + one-line purpose), so the user can green-light, defer, or replace them

## Ask how to proceed

After surfacing the summary above, **always** ask the user how they want to proceed before making any changes. Use the `AskUserQuestion` tool with options scoped to what the report actually contains. The tool accepts at most four options per question and adds an "Other" choice of its own, where the user can type the specific items they want; that covers picking à la carte. Choose up to four of these:

- **Apply all fixes**: resolve every inconsistency, wire every recommended cross-link, consolidate every flagged article, and create the High-impact suggested articles that existing wiki content can support
- **Fixes only**: resolve inconsistencies and wire cross-links; skip consolidations and new articles
- **Consolidate flagged articles**: perform the supervised rewrites for the articles flagged under Needs Consolidation
- **New articles only**: create the High-impact suggested articles that existing wiki content can support, and leave inconsistencies untouched for now
- **Report-only / do nothing**: leave the wiki as-is; the report stands as the record

Adapt the option set to what was actually found (e.g. if there are no inconsistencies, drop "Fixes only"), and always keep **Report-only** among the four. If a full-sweep escalation trigger fired, say so alongside the question and note that the recommendation applies to the *next* round; the user can accept or ignore it. Do not begin any edits until the user has answered.

## After the user chooses

Once the user picks what to apply:
1. Apply exactly the approved fixes and create exactly the approved articles, and leave out everything the user deferred or declined.
   - **New articles come from the wiki only.** An article the audit creates, or a gap it closes, may only reorganize facts already stated in existing wiki articles, such as a timeline that collects dates from five articles. Its `Sources:` footer lists each article it draws on as `- [[article-slug]] (synthesized YYYY-MM-DD)`. If an approved article would need facts the wiki doesn't hold, write only the part the wiki supports (or skip it) and add the rest to the report's Needs Source Material section. General knowledge never enters an article, because a claim with no source gives later conflict resolution nothing to check.
2. **Perform approved consolidations with care. They are the wiki's only lossy rewrites.** For each approved article: merge redundant bullets, integrate appended sections into a coherent structure, rewrite `## Key Takeaways` to reflect the merged content, and preserve the `Sources:` footer with every source item carried over. Where the cited raw sources are still available (in `raw/_*-compiled/` or `raw/_archive/`), re-verify claims against them, reading Office files as raw-compile's *Reading source files* section describes; a fact that came from a slide picture or a chart is missing from a text-only read. A consolidation that drops or distorts a fact is exactly the drift this supervised step exists to prevent. Touch nothing outside the approved articles.
3. **Clear the reconciliation queue (fix, log, then delete).** For every in-scope `wiki/_pending-reconciliation.md` row whose conflict you actually resolved this round, do it in this order: (a) finish the article: when the queued claim wins, add its raw source to the article's `Sources:` footer as a `- <path> (compiled YYYY-MM-DD)` item, and in every case remove the `⚠️` callout for this conflict if the article has one, or the next round flags the settled conflict again; (b) record it as a row in the report's **Resolved Reconciliations** section, carrying its original Flagged date, article file:line, quoted existing claim, and conflicting claim, plus the resolution you took and the round; then (c) delete that row from the queue. Logging before deleting matters: once the row is gone, the report is its only trace, so the record must exist first. Leave any row the user deferred in the queue (untouched) so it carries into the next audit. When `wiki/_pending-reconciliation.md` holds **no rows at all, for any topic**, **delete the file**: a deleted file spares every future audit from scanning an empty queue. After a topic audit, other topics' rows usually remain, and then the file stays. The queue and the report must partition cleanly: every cleared conflict appears in Resolved Reconciliations and is *absent* from the queue; every deferred conflict stays in the queue and is *absent* from Resolved Reconciliations.
4. **Recompute the integrity score** over what's left open (cleared issues drop out; deferred/declined ones stay), and **update the report in place**: set the Wiki Integrity Score line to `Before → After: <before> → <after>`, update "State of the Wiki After Round N", and rebuild the Known Open Items ledger so it holds exactly the issues still open at round close — the next round's Before is computed from it.
5. Tell the user the score moved from `<before>` to `<after>` and what's still open, so the round closes with a clear, recorded measure of progress.

If the user chooses report-only / do nothing, the as-found score stands as the round's closing score (before == after) — still record it so the next round has a baseline to trend from.
