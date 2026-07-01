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

Then pick the sweep mode:
- **Full sweep** — read every in-scope article. Mandatory for a scope's first-ever round (there is no baseline to be incremental against), and whenever the user asks for a deep audit.
- **Incremental** (the default once a prior same-scope round exists) — read the index layer, `wiki/_pending-reconciliation.md`, every article named in the prior report's Known Open Items ledger (re-verifying each carried-forward issue), and every article **new or changed since the prior same-scope report's date** (use `git log` if the vault is a git repo, file modification times otherwise). Unchanged, unflagged articles are skipped — their previously-verified state carries forward through the ledger.

The report's `**Scope:**` line must state which mode ran. Incremental keeps audit cost proportional to what changed rather than to wiki size; the escalation triggers below decide when a full sweep is due again.

### Full-sweep escalation
Recommend a full sweep — in the report summary and as an option in the closing "how to proceed" question, never by silently expanding scope — when any of these fire:
- **~5 incremental rounds** have passed since this scope's last full sweep
- this round surfaced **3 or more new inconsistencies** — a signal that unchanged articles likely harbor latent conflicts too
- re-verifying carried-forward items revealed **out-of-band edits** since last round — the wiki changed in ways the audit trail didn't see

## Procedure

1. **Read past audits and the reconciliation queue.** List `output/_audits/` and read recent reports for the same scope, so you don't re-flag resolved items and so you can carry forward unresolved "Known Open Items". Past reports are also where *already-resolved* conflicts are recorded (under "Resolved Reconciliations") — that history lives there, not in the queue. Then read `wiki/_pending-reconciliation.md` if it exists — every row is a still-open conflict that `raw-compile` deliberately deferred to you, and each one is a first-class Inconsistency finding for this round. The queue holds only open debt: it carries no resolved rows, because resolved conflicts are logged to the audit report and their rows deleted. If the file is missing, there's simply no deferred debt to clear.
2. **Read the index layer.** Start with `wiki/_master-index.md`, then each in-scope topic's `_index.md`.
3. **Read what the sweep mode calls for.** Full sweep: every article in the scope. Incremental: the new/changed articles plus every article carried forward via the ledger or the queue (see *Scope & sweep mode*).
4. **Look for:**
   - **Inconsistencies / contradictions** — claims that conflict across articles, or within one article. Note file:line. `raw-compile` defers every overwrite/supersede decision to audit, so each row in `wiki/_pending-reconciliation.md` (plus any `⚠️` source-conflict callouts) is a first-class finding here — reconcile it against the live article and decide which claim wins, don't merely re-note it. When deciding, weigh each side's provenance from the articles' `Sources:` footers against the raw source named in the queue row — recency of ingest alone is not evidence.
   - **Missing cross-links** — concepts mentioned in prose that have (or should have) their own article but aren't linked with `[[wiki links]]`.
   - **Gaps in coverage** — topics referenced but never articled; obvious sibling concepts missing from a topic folder.
   - **Stale or structural issues** — outdated indexes, orphaned articles, broken `[[links]]`.
   - **Needs consolidation** — articles that append-only ingest has made incoherent: redundant bullets saying the same thing twice, appended sections sitting awkwardly against older text, takeaways buried mid-list, or a structure that reads as a chronological log rather than a synthesis. Propose a supervised rewrite in the report — never perform it during this pass.
   - **Index format drift** — `_master-index.md` and every topic `_index.md` must be markdown tables (`| Topic | Description |` / `| Article | Description |`), with `##` section groupings once a topic exceeds ~5 articles. Flag any index still in bullet-list form, missing descriptions, or with a description so thin it doesn't help navigation.
5. **Suggest 3–5 new articles** that would strengthen the knowledge base. These are forward-looking proposals (not gap-fills for things already mentioned in prose — those go under Gaps in Coverage). Rank each by value-add impact:
   - **High** — closes a load-bearing gap; multiple existing articles would link inward; directly supports a current goal/decision in the wiki
   - **Mid** — useful consolidation or sibling coverage; would be referenced occasionally; nice-to-have rather than load-bearing
   - **Low** — completeness or glossary-style; rarely linked but improves navigability
   
   For each suggestion, include: proposed title, one-line purpose, impact score, and a brief justification (what existing articles it would connect, what decision/use case it serves). Do **not** create the articles in this pass — surface them in the report so the user can approve, reorder, or defer.
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
- Split between "addressed this round" and "remaining smaller gaps"

### 4. Suggested New Articles
- Table: Proposed Title | Purpose | Impact (High/Mid/Low) | Justification (what it connects, what it serves)
- 3–5 entries, ordered by impact (High first)

### 5. Needs Consolidation
- Articles whose appended content has outgrown their structure — for each: article path, what's incoherent (redundant bullets, awkward appends, buried takeaways), and a one-line proposed rewrite shape
- Proposals only — consolidation happens in the apply phase, per approved article

### 6. New Articles Created (if any)
- Table: Article | Purpose | Highest Leverage For

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
| Index format drift (a non-table `_index.md` / `_master-index.md`) | −4 | uncapped |
| Article needs consolidation | −3 | −9 |
| Missing cross-link | −2 | −10 |
| Coverage gap (a concept referenced in prose but never articled) | −2 | −10 |
| Convention nit (missing `## Key Takeaways` or `Sources:` footer, threadbare index description, off-convention filename) | −1 | −5 |

The caps exist because the capped categories are judgment calls with no natural bound — an eager round finds thirty missing cross-links, a lazy one four, and without caps that detection variance would swamp the real trend. The objective, high-stakes categories stay uncapped: every contradiction and broken link genuinely weighs.

Rows in `wiki/_pending-reconciliation.md` are deferred contradictions, so each counts as an inconsistency (−8) for as long as it sits in the queue — it weighs on the score until reconciled, then drops out the moment its conflict is fixed and its row is cleared (logged to "Resolved Reconciliations" and deleted from the queue). This is what stops batched ingest from quietly inflating the score: the more conflicts compile defers, the lower the as-found score sits until an audit actually clears them. A row deferred (left in the queue) this round still counts; only a genuinely resolved-and-cleared one drops. A queue row and its user-approved in-article `⚠️` callout are the *same* conflict — count it once (−8), never twice.

You record two numbers:
- **Before:** recompute it from the two durable open-issue stores: the prior same-scope report's **Known Open Items ledger** (re-verify each row; drop any the user fixed out-of-band since last round) plus every open `wiki/_pending-reconciliation.md` row, then add every new issue this round surfaces. The two stores are disjoint by construction — queue rows never appear in the ledger — so nothing counts twice. The result should land on the prior round's *After*; if it doesn't, reconcile the difference under Known Open Items and say why — an unexplained jump means the trend is fiction, not progress. A scope's first-ever round has no prior ledger, so Before is simply what you found.
- **After:** recomputed once the user's chosen fixes land — drop the penalty for each *resolved* issue; anything deferred or declined stays counted. If no fixes are applied, after == before.

**Keep the score line dead simple.** The rubric above is *your* working method, not something the reader needs — the score appears as one line: `Before → After: <before> → <after>`, with `(no change)` appended when nothing was applied (e.g. a report-only pass). No penalty math, no formula, no per-dimension breakdown in the report. The one structured artifact the report *must* carry is the Known Open Items ledger table — not because the reader needs arithmetic, but because the next round's Before is recomputed from it; a report without the ledger orphans the trend.

## Conventions
- **Report-only pass first** — never change article contents without user confirmation.
- **Always include the one-line Wiki Integrity Score** — `Before → After: X → Y` — since it's what makes the wiki's health legible round to round.
- After the user confirms fixes, the report documents both what was fixed AND what remains open.
- Use `⚠️` inline callouts (user-approved) in articles for unresolved source conflicts. The conflict's durable record stays its `_pending-reconciliation.md` row — a callout marks it in-place, it does not earn a Known Open Items entry.
- Numbering is sequential per topic so progression is visible across reports.
- Use today's date for the filename and the `**Date:**` field.

## Anti-patterns

- **NEVER auto-create the "suggested new articles".** They are proposals for the user to approve, defer, or reject — not actions to execute. Creating them silently destroys the triage step.
- **NEVER inflate findings to make the audit "feel productive".** If a round genuinely finds nothing, write that. A short honest report beats a padded one that trains the user to ignore future audits.
- **NEVER skip the past-audits read.** Re-flagging items resolved last round wastes the user's attention and signals you didn't do the homework.
- **NEVER add `⚠️` callouts to articles before the user has approved them.** The report-only pass is binding — inline edits during audit defeat the whole point.
- **NEVER claim an inconsistency without `file:line` evidence.** A finding the user can't navigate to is unactionable.
- **NEVER tune the integrity weights or skip issues to make a round look better.** The rubric is fixed precisely so rounds are comparable; a flattered score is worse than no score.
- **NEVER log a `_pending-reconciliation.md` row under "Resolved Reconciliations" (and delete it from the queue) without actually fixing the underlying conflict in the article.** Deleting is unforgiving: once the row is gone there is no open row left for the next audit to catch, and the report's "resolved" claim becomes the only record. A row logged-and-deleted while the contradiction still lives in the wiki turns the conflict invisible to every future audit — a silent, permanent data loss. Fix the article first; log and delete only what you genuinely resolved.
- **NEVER leave resolved rows sitting in `_pending-reconciliation.md`, and NEVER keep an empty queue file around.** Resolved conflicts belong in the report's Resolved Reconciliations section, not the queue; the queue holds only open debt. When the last row clears, delete the file — an empty or resolved-cluttered queue forces every future audit to re-scan noise it should never see again.
- **NEVER recompute the Before score from a blank slate when a prior round exists.** Rebuild it from the prior report's Known Open Items ledger plus the open queue rows — a Before that ignores history isn't a baseline, it's an unrelated number, and the round-over-round delta becomes meaningless.
- **NEVER report an after-score that assumes fixes you didn't actually apply.** The after-score must reflect the wiki as it stands once you've stopped editing — deferred and declined issues stay counted.
- **NEVER dump the scoring rubric or penalty math into the report.** The score is one line — `Before → After: X → Y` — the rubric is your internal method, not reader-facing clutter. The one exception is the Known Open Items ledger table: it lists open issues (not penalties) and is mandatory, because the next round's Before is recomputed from it.
- **NEVER copy open `_pending-reconciliation.md` rows into the Known Open Items ledger.** The queue is their durable home; duplicating them double-counts the score and forks the record into two places that will disagree.
- **NEVER rewrite an article flagged "needs consolidation" during the audit pass.** Consolidation is the wiki's only lossy rewrite, so it happens exclusively in the apply phase, per article, after the user approves that specific article.

## Output to the user

After writing the report, surface:
- The audit report path and the sweep mode that ran (full or incremental)
- The headline counts (findings per category — including articles flagged for consolidation and suggested new articles — and how many `_pending-reconciliation.md` rows were open coming in vs. cleared this round; whether the queue is now empty and the file deleted, or how many rows remain deferred)
- Whether a full-sweep escalation trigger fired, and if so the recommendation to run one next round
- The **Wiki Integrity Score** as `Before → After: X → Y`
- A short list of the highest-leverage proposed fixes, so the user can approve, reject, or reorder before any edits are made
- The High-impact suggested articles (just titles + one-line purpose), so the user can green-light, defer, or replace them

## Ask how to proceed

After surfacing the summary above, **always** ask the user how they want to proceed before making any changes. Use the `AskUserQuestion` tool with options scoped to what the report actually contains. Typical choices:

- **Apply all fixes** — resolve every inconsistency, wire every recommended cross-link, consolidate every flagged article, and create all High-impact suggested articles
- **Fixes only** — resolve inconsistencies and wire cross-links, but skip consolidations and new articles
- **Consolidate flagged articles** — perform the supervised rewrites for the articles flagged under Needs Consolidation
- **New articles only** — create the High-impact suggested articles, leave inconsistencies untouched for now
- **Pick à la carte** — let the user select specific items from the report to act on
- **Report-only / do nothing** — leave the wiki as-is; the report stands as the record

Adapt the option set to what was actually found (e.g. if there are no inconsistencies, drop "Fixes only"). If a full-sweep escalation trigger fired, say so alongside the question and note that the recommendation applies to the *next* round — the user can accept or ignore it. Do not begin any edits until the user has answered.

## After the user chooses

Once the user picks what to apply:
1. Apply exactly the approved fixes and create exactly the approved articles — nothing they deferred or declined.
2. **Perform approved consolidations with care — these are the wiki's only lossy rewrites.** For each approved article: merge redundant bullets, integrate appended sections into a coherent structure, rewrite `## Key Takeaways` to reflect the merged content, and preserve the `Sources:` footer with all source lines carried over. Where the cited raw sources are still available (in `raw/_*-compiled/` or `raw/_archive/`), re-verify claims against them rather than trusting your paraphrase — a consolidation that drops or distorts a fact is exactly the drift this supervised step exists to prevent. Touch nothing outside the approved articles.
3. **Clear the reconciliation queue (log, then delete).** For every `wiki/_pending-reconciliation.md` row whose conflict you actually resolved this round, do it in this order: (a) first record it as a row in the report's **Resolved Reconciliations** section — carrying its original Flagged date, article file:line, quoted existing claim, and conflicting claim, plus the resolution you took and the round; then (b) delete that row from the queue. Logging before deleting matters: once the row is gone, the report is its only trace, so the record must exist first. Leave any row the user deferred in the queue (untouched) so it carries into the next audit. When **no rows remain** in `wiki/_pending-reconciliation.md`, **delete the file** — an empty queue is no queue, and a deleted file spares every future audit from scanning it. The queue and the report must partition cleanly: every cleared conflict appears in Resolved Reconciliations and is *absent* from the queue; every deferred conflict stays in the queue and is *absent* from Resolved Reconciliations.
4. **Recompute the integrity score** over what's left open (cleared issues drop out; deferred/declined ones stay), and **update the report in place**: set the Wiki Integrity Score line to `Before → After: <before> → <after>`, update "State of the Wiki After Round N", and rebuild the Known Open Items ledger so it holds exactly the issues still open at round close — the next round's Before is computed from it.
5. Tell the user the score moved from `<before>` to `<after>` and what's still open, so the round closes with a clear, recorded measure of progress.

If the user chooses report-only / do nothing, the as-found score stands as the round's closing score (before == after) — still record it so the next round has a baseline to trend from.
