---
name: wiki-generator
description: Scaffold a new LLM-maintained wiki knowledge base in any directory. Creates the raw/wiki/output vault layout, seeds CLAUDE.md with vault conventions, and installs the companion `raw-compile` and `audit-wiki` skills so the destination repo is immediately ready to ingest and audit material. Use when the user says "set up a wiki", "generate a wiki", "scaffold a knowledge base", "install the wiki skills", or runs /wiki-generator.
---

# Wiki Generator

Scaffolds a complete LLM-maintained wiki vault in a target directory: folder layout, CLAUDE.md conventions, and the two companion skills (`raw-compile`, `audit-wiki`) needed to operate it. After this skill runs, the destination is ready to accept raw material and be audited.

## When to invoke
- User says "set up a wiki", "scaffold a knowledge base", "generate a wiki", or "install the wiki skills"
- User runs `/wiki-generator`
- User wants to bootstrap the LLM wiki pattern in a new project

## Before scaffolding, ask yourself
- **Target sanity**: Is the target directory empty (or non-existent)? Scaffolding into an in-use folder risks colliding with the user's existing `CLAUDE.md`, `wiki/`, or `.claude/skills/`. Confirm before writing.
- **Nested target**: Walk up from the target. If any ancestor directory already contains *both* `CLAUDE.md` and `wiki/_master-index.md`, that's an existing wiki vault — placing a new one inside it is almost always a mistake. Surface this to the user and require explicit confirmation before proceeding. Exception: re-scaffolding the same path as an upgrade is fine.
- **Template integrity**: Before any writes, confirm all four files exist in `templates/` (`CLAUDE.md`, `master-index.md`, `raw-compile.SKILL.md`, `audit-wiki.SKILL.md`). If any is missing, abort — the skill package is broken and a partial scaffold would silently produce a non-functional wiki.
- **Skill scope**: Should the two companion skills live inside the wiki (project-scoped, only active when working in that folder) or in `~/.claude/skills/` (active everywhere)? Project-scoped keeps each wiki self-contained; global avoids duplication if the user runs many wikis. Ask.

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
└── .claude/                                   # (project-scoped install only)
    └── skills/
        ├── raw-compile/SKILL.md
        └── audit-wiki/SKILL.md
```

Global install (`~/.claude/skills/`) writes the two skill files there instead and skips `<target>/.claude/`.

## Procedure

1. **Resolve the target directory.** If the user didn't specify, ask with `AskUserQuestion`:
   - **Current directory** (default — the user's CWD)
   - **A subfolder** (prompt for a name, e.g. `./my-wiki`)
   - **An absolute path the user types in**
2. **Resolve install scope for the skills.** Ask with `AskUserQuestion`:
   - **Project-scoped** (default — skills land in `<target>/.claude/skills/`; only active inside this wiki)
   - **Global** (skills land in `~/.claude/skills/`; active everywhere — skip if either skill already exists there without confirmation)
3. **Confirm before writing.** Show the resolved file list. If any destination file already exists, list collisions and ask whether to **skip**, **overwrite**, or **abort**. Default to skip on collisions unless the user says otherwise — *except* if the collisions look like a prior scaffold of this same skill (e.g., a present `CLAUDE.md` plus `wiki/_master-index.md` plus the two companion `SKILL.md` files at their canonical paths). In that case, surface the prompt as **"this looks like an existing wiki being upgraded — choose `overwrite` to apply the latest templates, or `skip` to leave the current copies untouched"** so the user doesn't unintentionally accept the default and stay on stale templates.
4. **Create the folder structure** using the absolute target path:
   - `<target>/raw/`, `<target>/wiki/`, `<target>/output/_audits/`
   - Project install: `<target>/.claude/skills/raw-compile/`, `<target>/.claude/skills/audit-wiki/`
   - Global install: `~/.claude/skills/raw-compile/`, `~/.claude/skills/audit-wiki/` (only if missing)
5. **Write each template file** from `templates/` (this skill's sibling folder):
   - `templates/CLAUDE.md` → `<target>/CLAUDE.md`
   - `templates/master-index.md` → `<target>/wiki/_master-index.md`
   - `templates/raw-compile.SKILL.md` → `<scope>/raw-compile/SKILL.md`
   - `templates/audit-wiki.SKILL.md` → `<scope>/audit-wiki/SKILL.md`
6. **Drop `.gitkeep`** in `raw/` and `output/_audits/` so empty directories survive git.
7. **Verify every file landed.** For each path written in steps 5–6, confirm it exists and is non-empty. If any file is missing, report the failure to the user and stop — don't claim success on a half-broken scaffold.
8. **Report what was done.** Print the resolved target path, install scope, files created (or skipped), and the next steps below.

## Next steps to surface to the user

After scaffolding, tell the user:
- Drop source material into `<target>/raw/` and say **"compile"** — that triggers `raw-compile`.
- Say **"audit"** or **"lint the wiki"** to run `audit-wiki`; reports land in `output/_audits/`.
- The `wiki/_master-index.md` is the entry point for queries. It starts empty (no topics yet).
- If the user picked project scope and later wants the skills available everywhere, copy them to `~/.claude/skills/`.

## Maintainer notes

Template sync, the `deploy-to-live.sh` workflow, and the upgrade path for existing downstream wikis are documented in [`MAINTAINER.md`](MAINTAINER.md). Destination users running this skill do not need to read that file.

## Anti-patterns

- **NEVER scaffold into a non-empty directory without explicit confirmation.** Silent overwrites destroy the user's existing CLAUDE.md or wiki content.
- **NEVER scaffold a new wiki inside an existing wiki.** If an ancestor directory already contains `CLAUDE.md` + `wiki/_master-index.md`, the user almost certainly meant something else (an upgrade, a topic folder, or a sibling wiki). Confirm explicitly — wiki-inside-a-wiki creates two competing master indexes and breaks every cross-link.
- **NEVER accept the default `skip` on a collision prompt that looks like an upgrade.** If all four canonical files are present, the user is upgrading templates, not scaffolding; silently skipping leaves them on stale templates with no warning. Surface the upgrade framing in the prompt itself (see step 3).
- **NEVER inline template content into `SKILL.md`.** Templates live in `templates/` so a single edit flows to every downstream wiki and to the maintainer's own live skills.
- **NEVER copy from a deployed wiki back into `templates/`.** Direction of truth flows templates → deployments, never the reverse. A deployment edit is local debugging; promoting it requires reapplying the change in `templates/` first.
- **NEVER propagate `wiki-generator` itself into the scaffold.** Downstream wikis are consumers of the wiki pattern, not bootstrappers for new wikis. Including it would create a confusing recursion.
- **NEVER report "scaffold complete" without the verification step (step 7).** A silent Write failure on one file leaves the user with a broken wiki they won't notice until they try to compile.
