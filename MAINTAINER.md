# wiki-generator — Maintainer Notes

These notes are for whoever maintains the `wiki-generator` skill itself.
**Destination users (people running the skill) never need to read this file.**

## Template sync

The files in `templates/` are the **canonical source** for the wiki convention. Any deployed copies (the maintainer's own live `.claude/skills/`, and every scaffolded downstream wiki) are derivatives.

When updating `CLAUDE.md`, `raw-compile`, `audit-wiki`, or `update-wiki`:

1. Edit the file in `wiki-generator/templates/`.
2. **Bump the version in the same commit.** Set `templates/VERSION` to today's date (`YYYY-MM-DD`, plus `.2` for a second release the same day) and add a matching `## <VERSION>` entry at the top of [`CHANGELOG.md`](CHANGELOG.md). `update-wiki` installs a release from its tag, and the release-tag workflow refuses to create a tag for a version without its changelog entry, so an edit shipped without both is invisible to every existing wiki.
3. If you keep a live wiki of your own, you can run `bash scripts/deploy-to-live.sh` to try the templates there before you push. It refuses to run unless the generator sits inside `<wiki>/.claude/skills/`, and it doesn't stamp `.wiki-version`.
4. Push to `main`.
5. On the Actions tab, check the **Release tag** run. Its `release` job must be green, and the tag must exist: `git ls-remote --tags origin "v$(tr -d '[:space:]' < templates/VERSION)"`. Its `bootstrap-prompt` job runs separately and never blocks a tag; if it is red, the prompt differs between the skill, the README and the guide, and only the docs need a fix. The `release` job also refuses a VERSION older than the newest tag and runs only on `main`.
6. Run the post-push check below.
7. Announce the release no sooner than 10 minutes after the push. Until the tag exists and the 5-minute CDN cache has turned over, `update` can stop with `tag-missing` and tell users the release is still being published.
8. Never move or delete a `v*` tag. Every wiki on a release compares its files against that tag, so a moved tag shows up as false local edits everywhere. A wrong release gets a new version.

Write changelog entries for the person reading them inside a stale wiki. They will see the entry with no other context, so name what changed in their compile or audit behaviour, not which file you touched.

### Post-push check

Tag results must all read `ok` as soon as the tag exists. `main` results can read `DIFF` for up to 5 minutes after the push, and this only tests the CDN location nearest to you.

```bash
V=$(tr -d '[:space:]' < templates/VERSION); R=https://raw.githubusercontent.com/davron-design/wiki-generator
for ref in main "refs/tags/v$V"; do for f in templates/VERSION templates/CLAUDE.md templates/raw-compile.SKILL.md templates/audit-wiki.SKILL.md templates/update-wiki.SKILL.md CHANGELOG.md; do
  curl -fsSL "$R/$ref/$f" | cmp -s - "$f" && echo "ok    $ref $f" || echo "DIFF  $ref $f"; done; done
```

Wikis still on `2026-09-09.2` or older fetch every template from `main`, one file at a time. Don't fetch template files from `main` yourself in the 10 minutes before a push, so the CDN location you share with nearby users has no old copy cached when the new `VERSION` lands.

## How existing wikis update

Each scaffolded wiki carries an `update-wiki` skill. Saying **"update"** inside the wiki makes it:

1. read `.claude/skills/.wiki-version` for the release each managed file came from (a `held-back:` line lists files at another release, as `<name>@<version>`),
2. fetch `templates/VERSION` from `main`, then the four templates and `CHANGELOG.md` from the tag `v<VERSION>`, plus pristine copies of the release the wiki installed from that release's own tag,
3. compare every file three ways (local copy, installed release, new release), so it can tell a local edit from an upstream change, show full diffs for `CLAUDE.md` and for any file with local edits, and ask before writing,
4. copy only `CLAUDE.md` and the three `SKILL.md` files from the fetched release, verify each copy, then re-stamp `.wiki-version`,
5. offer to move global copies out of `~/.claude/skills/`, since Claude Code runs those ahead of the wiki's own.

Templates never come from `main`. raw.githubusercontent.com caches each file separately for 5 minutes, so right after a push `main` can serve a new `VERSION` next to an old template, and a tag never changes. A tag that doesn't exist yet makes `update` stop with `tag-missing` ("the release is still being published"), and that miss is cached for 5 minutes too.

Every released version needs its tag: a wiki on a version without one has no pristine copies, and every file it holds shows as "no pristine". The two releases from before the workflow were tagged by hand (`v2026-09-09` at `fe4b8fd`, `v2026-09-09.2` at `78dd8ae`).

`wiki/`, `raw/`, and `output/` are out of reach for that skill by construction. Updated skill files take effect in the running session. A rewritten `CLAUDE.md` takes effect in a new session, and a `.claude/skills/` folder created during a session needs `/reload-skills`.

This depends on the repo staying **public**, because the fetch is an unauthenticated `curl` against `raw.githubusercontent.com`. Making it private breaks updates in every wiki on every machine, with no warning until someone runs `update`.

Wikis scaffolded before `update-wiki` existed have no way to run it. The bootstrap paste-prompt lives in `templates/update-wiki.SKILL.md` under *Bootstrapping a wiki that has no `update-wiki` yet*, and is repeated word for word in the README and the guide; the release-tag workflow fails when the three copies differ. After that one paste, the skill keeps itself current along with everything else.

## Adding a new managed file

If you ever add a fifth template, these places have to learn about it in the same commit, or it will freeze at its install-time contents in every wiki ever scaffolded:

1. `SKILL.md`: the write list in the Procedure, the template-integrity check, and the `held-back:` names in step 7
2. `templates/update-wiki.SKILL.md`: the *What this skill owns* table, the stamp names, the `FILES` list in step 4, and a `classify` call in step 7. `AskUserQuestion` takes at most four questions per call, so step 9's one-question-per-file call needs a second call for a fifth file.
3. `.github/workflows/sync-ws-templates.yml`: the file list, so `master-wiki-generator` mirrors it
4. `.github/workflows/release-tag.yml`: the trigger paths and the `managed` list in the tag check

## Direction of truth

Templates → deployments. **Never the reverse.** If you debug a bug by editing a deployed copy directly, you must port the fix back into `templates/` (and bump the version) before considering the change durable, or the next scaffold, `deploy-to-live.sh` run, or `update` will overwrite it.
