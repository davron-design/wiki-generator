---
name: wiki-generator
description: Scaffold a new LLM-maintained wiki knowledge base in any directory. Creates the raw/wiki/output vault layout, seeds CLAUDE.md with vault conventions, and installs the companion `raw-compile`, `audit-wiki` and `update-wiki` skills so the destination repo is immediately ready to ingest, audit, and keep itself current. Use when the user says "set up a wiki", "generate a wiki", "scaffold a knowledge base", "install the wiki skills", or runs /wiki-generator.
---

# Wiki Generator

Scaffolds a complete LLM-maintained wiki vault in a target directory: folder layout, CLAUDE.md conventions, and the three companion skills (`raw-compile`, `audit-wiki`, `update-wiki`) needed to operate it. After this skill runs, the destination is ready to accept raw material, be audited, and pull down later template changes on its own.

## When to invoke
- User says "set up a wiki", "scaffold a knowledge base", "generate a wiki", or "install the wiki skills"
- User runs `/wiki-generator`
- User wants to bootstrap the LLM wiki pattern in a new project

## Before scaffolding, ask yourself
- **Target sanity**: Is the target directory empty (or non-existent)? Scaffolding into an in-use folder risks colliding with the user's existing `CLAUDE.md`, `wiki/`, or `.claude/skills/`. Confirm before writing.
- **Nested target**: Walk up from the target. If any ancestor directory already contains *both* `CLAUDE.md` and `wiki/_master-index.md`, that's an existing wiki vault — placing a new one inside it is almost always a mistake. Surface this to the user and require explicit confirmation before proceeding. If they meant to pick up newer templates, that is `update-wiki`'s job, not a re-scaffold (see step 3).
- **Template integrity**: Before any writes, confirm all six files exist in `templates/` (`CLAUDE.md`, `master-index.md`, `raw-compile.SKILL.md`, `audit-wiki.SKILL.md`, `update-wiki.SKILL.md`, `VERSION`). If any is missing, abort — the skill package is broken and a partial scaffold would silently produce a non-functional wiki.
- **Skill scope**: Should the three companion skills live inside the wiki (project-scoped, only active when working in that folder) or in `~/.claude/skills/` (active everywhere)? Project-scoped keeps each wiki self-contained; global avoids duplication if the user runs many wikis. Ask.
- **Upgrade, not scaffold**: If the target already holds a populated `wiki/`, the user wants an update rather than a re-scaffold. Point them at `update-wiki` (step 3) instead of walking them through the collision prompt.

## What gets created

```
<target>/
├── CLAUDE.md                                  # vault conventions for the LLM librarian
├── raw/                                       # input zone — drop source material here
│   └── .gitkeep
├── wiki/                                      # the compiled knowledge base
│   └── _master-index.md                       # entry point listing every topic
├── output/                                    # query results and reports
│   └── _audits/                               # audit reports land here
│       └── .gitkeep
└── .claude/
    └── skills/
        ├── .wiki-version                      # which templates this wiki runs
        ├── raw-compile/SKILL.md               # (project-scoped install only)
        ├── audit-wiki/SKILL.md                # (project-scoped install only)
        └── update-wiki/SKILL.md               # (project-scoped install only)
```

Global install (`~/.claude/skills/`) writes the three skill files and `.wiki-version` there instead, and skips `<target>/.claude/` entirely.

## Procedure

1. **Resolve the target directory.** If the user didn't specify, ask with `AskUserQuestion`:
   - **Current directory** (default — the user's CWD)
   - **A subfolder** (prompt for a name, e.g. `./my-wiki`)
   - **An absolute path the user types in**
2. **Resolve install scope for the skills.** Ask with `AskUserQuestion`:
   - **Project-scoped** (default — skills land in `<target>/.claude/skills/`; only active inside this wiki)
   - **Global** (skills land in `~/.claude/skills/`; active everywhere — skip if any of the three skills already exists there without confirmation)
3. **Check for an existing wiki first.** If the target already holds `CLAUDE.md` plus `wiki/_master-index.md`, this is an existing vault, and scaffolding is the wrong tool. Tell the user to run `update-wiki` instead (say **"update"** inside that folder), which refreshes `CLAUDE.md` and the three skill files against the latest templates while leaving every article, source and audit report alone. Offer the bootstrap paste-prompt from `templates/update-wiki.SKILL.md` if the wiki has no `update-wiki` skill yet. Only continue scaffolding here if the user explicitly insists after hearing that.
4. **Confirm before writing.** Show the resolved file list. If any destination file already exists, list collisions and ask whether to **skip**, **overwrite**, or **abort**, defaulting to skip. `wiki/_master-index.md` is exempt from the choice: it is seeded once and never rewritten (see step 6).
5. **Create the folder structure** using the absolute target path:
   - `<target>/raw/`, `<target>/wiki/`, `<target>/output/_audits/`
   - Project install: `<target>/.claude/skills/{raw-compile,audit-wiki,update-wiki}/`
   - Global install: `~/.claude/skills/{raw-compile,audit-wiki,update-wiki}/` (only if missing)
6. **Write each template file** from `templates/` (this skill's sibling folder):
   - `templates/CLAUDE.md` → `<target>/CLAUDE.md`
   - `templates/master-index.md` → `<target>/wiki/_master-index.md`, **only if that file does not already exist.** It is a seed, and a populated master index is the wiki's entire navigation map. Overwriting it with the empty placeholder destroys that map, and nothing rebuilds it. Skip it on every re-run, whatever the user chose in step 4.
   - `templates/raw-compile.SKILL.md` → `<scope>/raw-compile/SKILL.md`
   - `templates/audit-wiki.SKILL.md` → `<scope>/audit-wiki/SKILL.md`
   - `templates/update-wiki.SKILL.md` → `<scope>/update-wiki/SKILL.md`
7. **Stamp the template version.** Read `templates/VERSION` and write `<scope>/.wiki-version`:

   ```
   # Managed by wiki-generator. Do not edit by hand.
   source: https://github.com/davron-design/wiki-generator
   version: <contents of templates/VERSION>
   updated: <today, YYYY-MM-DD>
   ```

   This stamp is what `update-wiki` reads later to tell the user what they are missing. A wiki without it reports as pre-versioning and gets offered the full changelog.
8. **Drop `.gitkeep`** in `raw/` and `output/_audits/` so empty directories survive git.
9. **Verify every file landed.** For each path written in steps 6–8, confirm it exists and is non-empty. If any file is missing, report the failure to the user and stop — don't claim success on a half-broken scaffold.
10. **Report what was done.** Print the resolved target path, install scope, template version, files created (or skipped), and the next steps below.

## Next steps to surface to the user

After scaffolding, tell the user:
- Drop source material into `<target>/raw/` and say **"compile"** — that triggers `raw-compile`.
- Say **"audit"** or **"lint the wiki"** to run `audit-wiki`; reports land in `output/_audits/`.
- Say **"update"** to run `update-wiki`, which pulls the latest templates from GitHub and refreshes `CLAUDE.md` and the three skill files. It never touches `wiki/`, `raw/`, or `output/`.
- The `wiki/_master-index.md` is the entry point for queries. It starts empty (no topics yet).
- If the user picked project scope and later wants the skills available everywhere, copy them to `~/.claude/skills/`.

## Maintainer notes

Template sync, the `deploy-to-live.sh` workflow, and the upgrade path for existing downstream wikis are documented in [`MAINTAINER.md`](MAINTAINER.md). Destination users running this skill do not need to read that file.

## Anti-patterns

- **NEVER scaffold into a non-empty directory without explicit confirmation.** Silent overwrites destroy the user's existing CLAUDE.md or wiki content.
- **NEVER scaffold a new wiki inside an existing wiki.** If an ancestor directory already contains `CLAUDE.md` + `wiki/_master-index.md`, the user almost certainly meant something else (an upgrade, a topic folder, or a sibling wiki). Confirm explicitly — wiki-inside-a-wiki creates two competing master indexes and breaks every cross-link.
- **NEVER overwrite an existing `wiki/_master-index.md`.** It is the only scaffold file the user takes ownership of, and after the first compile it holds the entire navigation map. Replacing it with the empty seed erases every topic row, and no later compile or audit rebuilds them. Write it once, when it is absent, and skip it forever after.
- **NEVER re-scaffold an existing wiki to pick up new templates.** That is what `update-wiki` is for: it refreshes exactly the managed files, shows the changelog since the wiki's recorded version, and cannot reach `wiki/`, `raw/`, or `output/` at all. Re-scaffolding puts the user one wrong collision answer away from losing content.
- **NEVER inline template content into `SKILL.md`.** Templates live in `templates/` so a single edit flows to every downstream wiki and to the maintainer's own live skills.
- **NEVER add a managed file without also adding it to `update-wiki`.** A file the scaffold writes but the updater does not know about freezes at its install-time version in every wiki ever created, and no one finds out until the behaviour diverges.
- **NEVER copy from a deployed wiki back into `templates/`.** Direction of truth flows templates → deployments, never the reverse. A deployment edit is local debugging; promoting it requires reapplying the change in `templates/` first.
- **NEVER propagate `wiki-generator` itself into the scaffold.** Downstream wikis are consumers of the wiki pattern, not bootstrappers for new wikis. Including it would create a confusing recursion.
- **NEVER report "scaffold complete" without the verification step (step 9).** A silent Write failure on one file leaves the user with a broken wiki they won't notice until they try to compile.
- **NEVER skip the `.wiki-version` stamp.** Without it every future `update-wiki` run has to offer the entire changelog and re-diff every file, because the wiki cannot say what it already has.
