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

## Scope question first
Before starting, confirm scope if it isn't clear:
- **Whole wiki** → report file is `output/_audits/YYYY-MM-DD_wiki_audit-round-N.md`
- **Single topic branch** (e.g. `wiki/<topic>/`) → report file is `output/_audits/YYYY-MM-DD_<topic>_audit-round-N.md`

Round numbering is **per topic, not global**. The whole-wiki audit has its own round sequence too. Determine `N` by scanning past reports in `output/_audits/` for the same scope.

## Procedure

1. **Read past audits.** List `output/_audits/`. Read recent reports for the same scope so you don't re-flag resolved items and so you can carry forward unresolved "Known Open Items".
2. **Read the index layer.** Start with `wiki/_master-index.md`, then each in-scope topic's `_index.md`.
3. **Read in-scope articles.** Cover every article in the scope.
4. **Look for:**
   - **Inconsistencies / contradictions** — claims that conflict across articles, or within one article. Note file:line. `raw-compile` defers every overwrite/supersede decision to audit, so compile-flagged conflicts and any `⚠️` source-conflict callouts are first-class findings here — reconcile them, don't merely re-note them.
   - **Missing cross-links** — concepts mentioned in prose that have (or should have) their own article but aren't linked with `[[wiki links]]`.
   - **Gaps in coverage** — topics referenced but never articled; obvious sibling concepts missing from a topic folder.
   - **Stale or structural issues** — outdated indexes, orphaned articles, broken `[[links]]`.
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
**Scope:** articles reviewed (include the topic branch path, e.g. `wiki/<topic>/`)
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

### 5. New Articles Created (if any)
- Table: Article | Purpose | Highest Leverage For

## Other Changes
- Index reorganizations, structural changes

## State of the Wiki After Round N
- Total articles, link edges, regions covered

## Wiki Integrity Score

Before → After: <before> → <after>   (write `(no change)` after it when no fixes were applied)

## Known Open Items
- Unresolved flags, external actions (e.g., "confirm with X"), WIP items
```

## Wiki Integrity Score

Each report carries a 0–100 integrity score so the wiki's health is legible at a glance and the round-over-round change is real. The score must be **computed from a fixed rubric, not eyeballed** — the same wiki state always yields the same number, otherwise the before→after delta means nothing.

Compute it as `score = max(0, 100 − Σ penalties)`, one penalty per *open* issue (count only issues that appear in your own Findings):

| Issue type | Penalty (each) |
|---|---|
| Inconsistency / contradiction | −8 |
| Broken or orphaned link | −5 |
| Index format drift (a non-table `_index.md` / `_master-index.md`) | −4 |
| Missing cross-link | −2 |
| Coverage gap (a concept referenced in prose but never articled) | −2 |
| Convention nit (missing `## Key Takeaways`, threadbare index description, off-convention filename) | −1 |

You record two numbers:
- **Before:** anchor on the prior round's *After* for this scope — its still-open issues carry forward and stay counted. Re-verify each carried-forward issue (drop any the user fixed out-of-band since last round), then add every new issue this round surfaces. A scope's first-ever round has no prior After, so Before is simply what you found. If a carried-forward count disagrees with last round's, reconcile it under Known Open Items and say why — an unexplained jump means the trend is fiction, not progress.
- **After:** recomputed once the user's chosen fixes land — drop the penalty for each *resolved* issue; anything deferred or declined stays counted. If no fixes are applied, after == before.

**Keep the report side dead simple.** The rubric above is *your* working method, not something the reader needs — so the report shows only one line: `Before → After: <before> → <after>`, with `(no change)` appended when nothing was applied (e.g. a report-only pass). No breakdown table, no per-dimension penalties, no formula in the report — just the number and how it moved.

## Conventions
- **Report-only pass first** — never change article contents without user confirmation.
- **Always include the one-line Wiki Integrity Score** — `Before → After: X → Y` — since it's what makes the wiki's health legible round to round.
- After the user confirms fixes, the report documents both what was fixed AND what remains open.
- Use `⚠️` inline callouts in articles for unresolved source conflicts and reference them under "Known Open Items".
- Numbering is sequential per topic so progression is visible across reports.
- Use today's date for the filename and the `**Date:**` field.

## Anti-patterns

- **NEVER auto-create the "suggested new articles".** They are proposals for the user to approve, defer, or reject — not actions to execute. Creating them silently destroys the triage step.
- **NEVER inflate findings to make the audit "feel productive".** If a round genuinely finds nothing, write that. A short honest report beats a padded one that trains the user to ignore future audits.
- **NEVER skip the past-audits read.** Re-flagging items resolved last round wastes the user's attention and signals you didn't do the homework.
- **NEVER add `⚠️` callouts to articles before the user has approved them.** The report-only pass is binding — inline edits during audit defeat the whole point.
- **NEVER claim an inconsistency without `file:line` evidence.** A finding the user can't navigate to is unactionable.
- **NEVER tune the integrity weights or skip issues to make a round look better.** The rubric is fixed precisely so rounds are comparable; a flattered score is worse than no score.
- **NEVER recompute the Before score from a blank slate when a prior round exists.** Anchor it to the last round's After and carry the still-open issues forward — a Before that ignores history isn't a baseline, it's an unrelated number, and the round-over-round delta becomes meaningless.
- **NEVER report an after-score that assumes fixes you didn't actually apply.** The after-score must reflect the wiki as it stands once you've stopped editing — deferred and declined issues stay counted.
- **NEVER dump the scoring rubric, penalty breakdown, or per-dimension table into the report.** The score is one line — `Before → After: X → Y` — the rubric is your internal method, not reader-facing clutter.

## Output to the user

After writing the report, surface:
- The audit report path
- The headline counts (findings per category, including the count of suggested new articles)
- The **Wiki Integrity Score** as `Before → After: X → Y`
- A short list of the highest-leverage proposed fixes, so the user can approve, reject, or reorder before any edits are made
- The High-impact suggested articles (just titles + one-line purpose), so the user can green-light, defer, or replace them

## Ask how to proceed

After surfacing the summary above, **always** ask the user how they want to proceed before making any changes. Use the `AskUserQuestion` tool with options scoped to what the report actually contains. Typical choices:

- **Apply all fixes** — resolve every inconsistency, wire every recommended cross-link, and create all High-impact suggested articles
- **Fixes only** — resolve inconsistencies and wire cross-links, but skip creating new articles
- **New articles only** — create the High-impact suggested articles, leave inconsistencies untouched for now
- **Pick à la carte** — let the user select specific items from the report to act on
- **Report-only / do nothing** — leave the wiki as-is; the report stands as the record

Adapt the option set to what was actually found (e.g. if there are no inconsistencies, drop "Fixes only"). Do not begin any edits until the user has answered.

## After the user chooses

Once the user picks what to apply:
1. Apply exactly the approved fixes and create exactly the approved articles — nothing they deferred or declined.
2. **Recompute the integrity score** over what's left open (resolved issues drop out; deferred/declined ones stay), and **update the report in place**: set the Wiki Integrity Score line to `Before → After: <before> → <after>`, and update "State of the Wiki After Round N" and "Known Open Items" to match reality.
3. Tell the user the score moved from `<before>` to `<after>` and what's still open, so the round closes with a clear, recorded measure of progress.

If the user chooses report-only / do nothing, the as-found score stands as the round's closing score (before == after) — still record it so the next round has a baseline to trend from.
