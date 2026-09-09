# wiki-generator — Maintainer Notes

These notes are for whoever maintains the `wiki-generator` skill itself.
**Destination users (people running the skill) never need to read this file.**

## Template sync

The files in `templates/` are the **canonical source** for the wiki convention. Any deployed copies (the maintainer's own live `.claude/skills/`, and every scaffolded downstream wiki) are derivatives.

When updating `CLAUDE.md`, `raw-compile`, `audit-wiki`, or `update-wiki`:

1. Edit the file in `wiki-generator/templates/`.
2. **Bump the version in the same commit.** Set `templates/VERSION` to today's date (`YYYY-MM-DD`, plus `.2` for a second release the same day) and add a matching entry to [`CHANGELOG.md`](CHANGELOG.md). This is the one manual step the whole update path depends on: `update-wiki` compares a wiki's recorded version against `templates/VERSION` to decide whether there is anything to do, so an edit shipped without a bump is invisible to every existing wiki.
3. If you keep a live wiki of your own, run `bash scripts/deploy-to-live.sh` to push the updated templates into the sibling `.claude/skills/` next to this generator.
4. Push to `main`. New scaffolds get the latest version immediately, and existing wikis pick it up the next time anyone says `update`.

Write changelog entries for the person reading them inside a stale wiki. They will see the entry with no other context, so name what changed in their compile or audit behaviour, not which file you touched.

## How existing wikis update

Each scaffolded wiki carries an `update-wiki` skill. Saying **"update"** inside the wiki makes it:

1. read `.claude/skills/.wiki-version` for the version it is on,
2. fetch `templates/VERSION` and `CHANGELOG.md` from `main` over `raw.githubusercontent.com`,
3. stop right there if the versions match,
4. otherwise fetch the four templates, show the changelog gap and a full diff of `CLAUDE.md`, and ask before writing,
5. rewrite only `CLAUDE.md` and the three `SKILL.md` files, then re-stamp `.wiki-version`.

`wiki/`, `raw/`, and `output/` are out of reach for that skill by construction. The updated skills load in a **new** Claude Code session, since the running one already read the old copies at startup.

This depends on the repo staying **public**, because the fetch is an unauthenticated `curl` against `raw.githubusercontent.com`. Making it private breaks updates in every wiki on every machine, with no warning until someone runs `update`.

Wikis scaffolded before `update-wiki` existed have no way to run it. The bootstrap paste-prompt lives in `templates/update-wiki.SKILL.md` under *Bootstrapping a wiki that has no `update-wiki` yet*, and is repeated in the README and the guide. After that one paste, the skill keeps itself current along with everything else.

## Adding a new managed file

If you ever add a fifth template, three places have to learn about it in the same commit, or it will freeze at its install-time contents in every wiki ever scaffolded:

1. `SKILL.md`: the write list in the Procedure, and the template-integrity check
2. `templates/update-wiki.SKILL.md`: the *What this skill owns* table and the step 6 fetch loop
3. `.github/workflows/sync-ws-templates.yml`: the file list, so `master-wiki-generator` mirrors it

## Direction of truth

Templates → deployments. **Never the reverse.** If you debug a bug by editing a deployed copy directly, you must port the fix back into `templates/` (and bump the version) before considering the change durable, or the next scaffold, `deploy-to-live.sh` run, or `update` will overwrite it.
