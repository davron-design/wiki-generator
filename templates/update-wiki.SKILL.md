---
name: update-wiki
description: Update this wiki's own machinery to the latest published wiki-generator templates. Fetches the current CLAUDE.md, raw-compile, audit-wiki and update-wiki files from GitHub, reports what changed since the version this wiki records, and asks before writing anything. Use when the user says "update", "update the wiki", "update the skills", "check for updates", "upgrade the wiki", "am I on the latest version", "repair the skills", "reinstall the skills", or runs /update-wiki. Only the managed template files are rewritten; wiki/, raw/ and output/ are never touched.
---

# Update Wiki

This wiki was scaffolded from the `wiki-generator` templates, and those templates keep moving
upstream. This skill pulls the current versions down and applies them here, leaving every
compiled article, raw source and audit report exactly as it is.

## When to invoke
- User says "update", "update the wiki", "update the skills", or "upgrade the wiki"
- User says "repair", "reinstall the skills", or "force update", which skips the version fast
  path in step 5 and re-diffs every managed file against upstream
- User asks which version this wiki is on, or whether it is behind
- User says the compile or audit rules changed and this wiki should pick them up
- User runs `/update-wiki`

Do **not** invoke this for wiki content. "Update the index" and "update that article" are
compile and audit work, not template work.

## What this skill owns

Five paths, and nothing else in the vault.

| Upstream file | Local path |
|---|---|
| `templates/CLAUDE.md` | `<wiki>/CLAUDE.md` |
| `templates/raw-compile.SKILL.md` | `<skills>/raw-compile/SKILL.md` |
| `templates/audit-wiki.SKILL.md` | `<skills>/audit-wiki/SKILL.md` |
| `templates/update-wiki.SKILL.md` | `<skills>/update-wiki/SKILL.md` (this file) |
| `templates/VERSION` | `<skills>/.wiki-version` (stamp, rewritten from the fetched version) |

`<skills>` is resolved in step 2. Everything else is off limits: `wiki/`, `raw/`, `output/`
and `.git/` are read-only to this skill, and `wiki/_master-index.md` most of all. The scaffold
seeds that file once; by the time anyone runs an update it holds the wiki's real navigation
map.

Upstream base URL: `https://raw.githubusercontent.com/davron-design/wiki-generator/main`

## Before updating, ask yourself
- **Right root**: Is the working directory the wiki root, or a folder inside it? A `CLAUDE.md`
  written one level off becomes a second conventions file loaded alongside the real one, and
  the two will disagree.
- **Which skills directory**: Are the companion skills project-scoped (`<wiki>/.claude/skills/`)
  or global (`~/.claude/skills/`)? A global install is shared by every wiki on the machine, so
  writing there updates all of them at once. Say so before touching it.
- **Local edits**: Does a managed file differ from the template it was installed from?
  `CLAUDE.md` is the one people extend with project conventions, and a silent overwrite deletes
  that work with no trace.
- **Fetch integrity**: Did every file download cleanly? A truncated `SKILL.md` breaks compile
  in ways that only surface on the next ingest, so the fetch is all-or-nothing.
- **Undo path**: Is this vault a git repo with a clean tree? If it is, the whole update is one
  `git checkout` away from being reverted, which is worth telling the user before they decide.

## Procedure

1. **Locate the wiki root.** A wiki root holds both `CLAUDE.md` and `wiki/_master-index.md`.
   Check the working directory, then walk up at most three levels. If no root is found, tell
   the user where you looked and stop. Do not scaffold anything.

2. **Resolve the skills directory.** Look for `raw-compile/SKILL.md` under, in order:
   - `<wiki>/.claude/skills/` (project-scoped, preferred when present)
   - `~/.claude/skills/` (global)

   If both exist, use the project-scoped one and mention the global copy so the user knows it
   stays stale. If neither exists, this wiki predates the companion-skill layout: use
   `<wiki>/.claude/skills/`, create it, and treat the run as a repair install.

3. **Read the local version.** `<skills>/.wiki-version` looks like this:

   ```
   # Managed by wiki-generator. Do not edit by hand.
   source: https://github.com/davron-design/wiki-generator
   version: 2026-09-09
   updated: 2026-09-09
   ```

   A missing file means the wiki was scaffolded before versioning existed. Record the version
   as `unknown (pre-versioning)` and continue. A `held-back:` line, if present, lists files the
   user declined on a previous run.

4. **Fetch the version and changelog.** Work in a temporary directory so a failed download can
   never land in the vault:

   ```bash
   TMP=$(mktemp -d)
   BASE=https://raw.githubusercontent.com/davron-design/wiki-generator/main
   curl -fsSL "$BASE/templates/VERSION" -o "$TMP/VERSION"
   curl -fsSL "$BASE/CHANGELOG.md"      -o "$TMP/CHANGELOG.md"
   ```

   If either fetch fails, report the cause (no network, or the repo moved) and stop. Nothing in
   the vault has been touched at this point, so there is nothing to roll back.

5. **Decide whether there is anything to do.** If the local version equals the upstream version
   and `.wiki-version` carries no `held-back:` line, report "up to date" with the version
   number and stop. Continue anyway if the user asked to force, reinstall, or repair.

   This fast path trusts the stamp, so it cannot see a managed file that was edited locally
   after it was installed: the wiki reports current while `raw-compile` quietly runs someone's
   hand-tweaked copy. **Say so in the up-to-date report**, and tell the user that `repair`
   re-fetches and diffs all four files regardless of the version match.

6. **Fetch the four templates.** Into `$TMP`, then check every one of them before considering
   any write:

   ```bash
   for f in CLAUDE.md raw-compile.SKILL.md audit-wiki.SKILL.md update-wiki.SKILL.md; do
     curl -fsSL "$BASE/templates/$f" -o "$TMP/$f"
   done
   ```

   Each file must be non-empty, and the three `*.SKILL.md` files must begin with `---` followed
   by a `name:` line. If any file fails either check, discard the whole batch and stop. A
   partial update is worse than no update.

7. **Diff each managed file** against its local copy and sort them into three buckets: already
   current, will change, and missing locally (a repair install).

8. **Show the user what will change**, before asking anything:
   - `This wiki: <local version>` and `Latest: <upstream version>`
   - The changelog entries newer than the local version, quoted from `$TMP/CHANGELOG.md`. For a
     pre-versioning wiki, show the whole file.
   - One line per managed file: current, or a summary of the change (which sections moved, how
     many lines).
   - **The full diff for `CLAUDE.md` whenever it differs.** It is around 40 lines, so the cost
     of printing it is trivial next to the cost of silently deleting a team's local
     conventions. Call out any local line the update would drop.
   - If the vault is a git repo with a dirty tree, say so and suggest committing first, so the
     update lands as a reviewable, revertable change.

9. **Ask before writing.** Use `AskUserQuestion`. Scope the options to what actually differs:
   - **Update everything** (the default recommendation)
   - **Skills only** (keep the local `CLAUDE.md`; offer this whenever `CLAUDE.md` has local
     edits)
   - **Choose per file**
   - **Cancel** (change nothing)

10. **Write the approved files** in this order: `CLAUDE.md`, `raw-compile`, `audit-wiki`, and
    `update-wiki` last. Writing this file last means a failure earlier in the run leaves the
    updater matching the templates it was reasoning about. Rewriting it mid-run is safe: the
    instructions you are following are already loaded.

11. **Stamp the version.** Rewrite `<skills>/.wiki-version` with the header from step 3,
    `updated:` set to today, and:
    - `version:` set to the upstream version **only if every managed file now matches upstream**
    - otherwise `version:` stays at the old value, plus a `held-back: <file>, <file>` line
      naming what the user declined

    Under-claiming is the safe direction. A stamp that advances past declined files hides them
    from every future run, and the next update reports "up to date" on a wiki that is not.

12. **Verify.** Re-read every file written this run. Each must exist, be non-empty, and (for
    the skill files) still carry its frontmatter. Report any failure instead of a success line.

13. **Report.** Cover the version move, the files written, the files skipped and why, and the
    two things the user needs to know next:
    - **The updated skills load in a new Claude Code session.** The current session is still
      running the copies it read at startup, so `compile` and `audit` follow the old rules
      until the user restarts.
    - How to undo, if the vault is a git repo: `git checkout -- CLAUDE.md .claude/skills`.

## Bootstrapping a wiki that has no `update-wiki` yet

Wikis scaffolded before this skill existed cannot run it. Give the user this to paste into
Claude Code from inside the wiki folder, once:

> Download `templates/update-wiki.SKILL.md` from
> https://github.com/davron-design/wiki-generator and save it as
> `.claude/skills/update-wiki/SKILL.md` in this folder. Then restart the session and say
> `update`.

From then on the skill updates itself along with everything else.

## Output to the user

After the run, report:
- The version move (`<before>` to `<after>`), or "already on `<version>`", and on that
  already-current path, that `repair` re-checks the files themselves rather than the stamp
- Each managed file: written, already current, or skipped at the user's request
- Whether the companion skills are project-scoped or global, and if global, that every wiki on
  the machine just changed
- The reminder that a new session is needed before the updated skills take effect
- The `git checkout` undo line when the vault is a git repo

## Anti-patterns

- **NEVER use WebFetch to retrieve the templates.** It normalizes and can summarize markdown,
  and these files have to land byte for byte. A skill file that was quietly reflowed on the way
  in still parses and still loads, so the damage shows up much later as behaviour that drifts
  from the documented rules. Use `curl -fsSL`.
- **NEVER write anything under `wiki/`, `raw/`, or `output/`.** `wiki/_master-index.md` is the
  trap: it is one of the scaffold's files, so it looks managed, but the scaffold seeds it once
  and the user owns it from then on. Writing the empty placeholder over a populated index
  erases the map of the entire wiki, and no compile or audit will rebuild it.
- **NEVER apply a partial fetch.** If one of the four templates fails to download or fails its
  frontmatter check, write none of them. Half an update leaves a wiki whose skills disagree
  with its `CLAUDE.md`.
- **NEVER overwrite `CLAUDE.md` without printing the diff first.** It is the one managed file
  teams extend with their own conventions, and an overwrite is unrecoverable outside git.
- **NEVER stamp `.wiki-version` at the upstream version when the user declined a file.** The
  stamp is what the next run trusts; an optimistic stamp makes declined files invisible forever
  and turns "up to date" into a lie.
- **NEVER edit a template while installing it, and never copy a local file back upstream.**
  Templates flow one way, repo to wiki. A fix belongs in `wiki-generator/templates/` first, and
  reaches this wiki on the next update.
- **NEVER touch `~/.claude/skills/` without telling the user that every wiki on the machine
  shares those files.** A global update is a fleet-wide change made from inside one vault.
- **NEVER run compile or audit as part of an update.** They are separate skills with separate
  confirmation steps, and folding them in hides real content changes inside what the user
  approved as a template refresh.
- **NEVER report success without step 12.** A failed Write leaves a wiki that looks updated and
  is not, and the version stamp will then vouch for it.
