---
name: update-wiki
description: Update this wiki's own machinery to the latest published wiki-generator release. Fetches the released CLAUDE.md, raw-compile, audit-wiki and update-wiki files from GitHub, compares them with this wiki's copies and with the release it installed, shows local edits and what changed, and asks before writing anything. Use when the user says "update", "update the wiki", "update the skills", "check for updates", "upgrade the wiki", "am I on the latest version", "repair the skills", "reinstall the skills", or runs /update-wiki. Only the managed template files are rewritten; wiki/, raw/ and output/ are never touched.
---

# Update Wiki

This wiki was scaffolded from the `wiki-generator` templates, and those templates keep moving
upstream. This skill pulls the current versions down and applies them here, leaving every
compiled article, raw source and audit report exactly as it is.

## When to invoke
- User says "update", "update the wiki", "update the skills", or "upgrade the wiki"
- User says "repair", "reinstall the skills", or "force update". Every run compares the files
  themselves, so `repair` adds one thing: it also offers to restore skill files that carry
  local edits the new release doesn't touch (step 9)
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
| `templates/VERSION` | `<skills>/.wiki-version` (stamp, written by step 12) |

`<skills>` is always `<wiki>/.claude/skills/`. Everything else is off limits: `wiki/`, `raw/`,
`output/` and `.git/` are read-only to this skill, and `wiki/_master-index.md` most of all. The
scaffold seeds that file once; by the time anyone runs an update it holds the wiki's real
navigation map.

Upstream: `https://raw.githubusercontent.com/davron-design/wiki-generator`, read at two refs:
- `main/templates/VERSION` names the latest release. It is the only file read from `main`.
- `refs/tags/v<VERSION>/` holds that release: the four templates and `CHANGELOG.md`. A tag
  never moves, so every file fetched from it belongs to the same release. The pristine copies
  of the release this wiki installed come from that release's own tag.

`raw.githubusercontent.com` caches each file for 5 minutes, separately. Right after a push,
`main` can serve a new file next to an old one, which is why templates never come from `main`.

## Before updating, ask yourself
- **Right root**: Is the working directory the wiki root, or a folder inside it? A `CLAUDE.md`
  written one level off becomes a second conventions file loaded alongside the real one, and
  the two will disagree.
- **Which copies run**: Claude Code runs a skill in `~/.claude/skills/` ahead of a project
  skill with the same name. If global copies of `raw-compile`, `audit-wiki` or `update-wiki`
  exist, this wiki has been running those, and refreshing its own copies changes nothing until
  the global ones move out of the way.
- **Local edits**: Does a managed file differ from the release it was installed from? The
  pristine copy from that release's tag answers this exactly. `CLAUDE.md` is the one people
  extend with project conventions, and a silent overwrite deletes that work with no trace.
- **Fetch integrity**: Did every file download cleanly? A truncated `SKILL.md` breaks compile
  in ways that only surface on the next ingest, so the fetch is all-or-nothing.
- **Undo path**: Is this vault a git repo with a clean tree? If it is, the whole update is one
  `git checkout` away from being reverted, which is worth telling the user before they decide.

## The stamp

`<skills>/.wiki-version` records which release each managed file came from:

```
# Managed by wiki-generator. Do not edit by hand.
source: https://github.com/davron-design/wiki-generator
version: 2026-10-02
updated: 2026-10-02
held-back: CLAUDE.md@2026-09-09.2
```

- `version:` is the release every managed file came from, except the files listed in
  `held-back:`.
- `held-back:` is optional. It lists files that sit at a different release, comma-separated,
  as `<name>@<version>` or `<name>@unknown`. The names are `CLAUDE.md`, `raw-compile`,
  `audit-wiki` and `update-wiki`.
- A file's **base version** is its `held-back:` version when it is listed there, and
  `version:` otherwise.
- A `version:` value that isn't a date (`YYYY-MM-DD` or `YYYY-MM-DD.N`), such as the
  `unknown (pre-versioning)` an older updater could write, counts as `unknown`.
- A `held-back:` line whose entries have no `@` was written by an older updater. That updater
  left `version:` at the release the listed files came from and wrote the other files from a
  newer release it didn't record. So for this run a listed file's base is `version:`, and
  every other file's base is `unknown`.
- No stamp at all means the wiki predates versioning: every base is `unknown`.
- A stamp that exists only in `~/.claude/skills/.wiki-version` comes from an old global
  install. Mention its version in the report, and use `unknown` for every base anyway: one
  stamp shared by every wiki on the machine says nothing about this wiki's `CLAUDE.md`.

## Procedure

1. **Locate the wiki root.** A wiki root holds both `CLAUDE.md` and `wiki/_master-index.md`.
   Check the working directory, then walk up at most three levels. If no root is found, tell
   the user where you looked and stop. Do not scaffold anything. If `<wiki>/.claude`,
   `<wiki>/.claude/skills/` or any managed destination is a symlink (`[ -L <path> ]`), stop
   and say so: `cp` would write through the link into whatever it points at, often a
   `templates/` folder. Also stop when `<wiki>/.claude/skills` is the global skills folder
   (compare `pwd -P` of it with that of `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills`), which
   happens when the wiki root is the home folder: a write there would change every wiki on
   the machine.

2. **Work out which copies run.** Record what you find; nothing is written in this step.
   - This copy of `update-wiki` was loaded from `${CLAUDE_SKILL_DIR}`. A path under the home
     folder's `.claude/skills/` means a global copy is running. If the path above is empty or
     still shows a placeholder, this Claude Code version doesn't fill it in; rely on the
     search below.
   - Note whether `<wiki>/.claude/skills/` exists. If this run creates it, the report has to
     mention `/reload-skills`.
   - Search for global copies by their frontmatter `name:`, since Claude Code takes a skill's
     name from that line and a renamed folder still runs:

     ```bash
     bash <<'EOF'
     for G in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" "${USERPROFILE:+$USERPROFILE/.claude/skills}"; do
       [ -d "$G" ] || continue
       grep -lE '^name: *(raw-compile|audit-wiki|update-wiki)[[:space:]]*$' "$G"/*/SKILL.md 2>/dev/null |
         while IFS= read -r f; do echo "GLOBAL-SKILL $(dirname "$f")"; done
       [ -f "$G/.wiki-version" ] && echo "GLOBAL-STAMP $G/.wiki-version $(grep '^version:' "$G/.wiki-version")"
     done
     EOF
     ```

     Each `GLOBAL-SKILL` line names a skill folder and each `GLOBAL-STAMP` line a stamp file.
     Those exact paths are what step 13 may move.

   - Check `.claude/skills/` in each parent folder of the wiki, up to the git repository root
     if there is one. Claude Code loads project skills from every parent up to that root, and
     on a name clash the root copy runs.

3. **Read the stamp** and work out each file's base version (see *The stamp*). Call the
   stamp's `version:` value `LOCAL`, or `unknown` when there is no stamp or the value isn't a
   date.

4. **Fetch the release and the pristine copies in one Bash call.** Shell variables don't
   survive between Bash calls, so everything happens in this single call. Fill in the two
   values at the top from step 3, then run it as shown. Every script in this skill runs
   through `bash <<'EOF'`, because the Bash tool may start another shell (zsh on macOS),
   which splits word lists and handles unmatched globs differently. Copy each script without
   its list indentation, so the closing `EOF` starts its line.

   ```bash
   bash <<'EOF'
   LOCAL='2026-09-09.2'   # version: from the stamp, or unknown
   BASES='2026-09-09.2'   # distinct base versions from step 3, space-separated, unknown left out
   R=https://raw.githubusercontent.com/davron-design/wiki-generator
   FILES='CLAUDE.md raw-compile.SKILL.md audit-wiki.SKILL.md update-wiki.SKILL.md'
   D='[0-9]{4}-[0-9]{2}-[0-9]{2}(\.[0-9]+)?'
   printf '%s' "$LOCAL" | grep -Eqx "$D" || LOCAL=unknown
   T=$(mktemp -d) || { echo 'STOP no-tempdir'; exit 1; }
   echo "TMP $T"
   get() {   # get <ref> <path> <dest>: succeeds only on HTTP 200 with a non-empty body
     mkdir -p "$(dirname "$3")"
     c=$(curl -fsSL --retry 2 -w '%{http_code}' -o "$3" "$R/$1/$2")
     echo "$c $1/$2"
     [ "$c" = 200 ] && [ -s "$3" ]
   }
   # The latest version: the only file read from main.
   get main templates/VERSION "$T/VERSION" || { echo 'STOP no-version'; exit 1; }
   V=$(tr -d '[:space:]' < "$T/VERSION")
   printf '%s' "$V" | grep -Eqx "$D" || { echo 'STOP not-github'; exit 1; }
   echo "LATEST $V"
   if [ "$LOCAL" != unknown ] && [ "$(printf '%s\n' "$LOCAL" "$V" | sort -V | tail -n 1)" != "$V" ]; then
     echo 'STOP older-than-local'; exit 1
   fi
   # The release, from its tag.
   get "refs/tags/v$V" templates/VERSION "$T/new/VERSION" || { echo 'STOP tag-missing'; exit 1; }
   [ "$(tr -d '[:space:]' < "$T/new/VERSION")" = "$V" ] || { echo 'STOP tag-mismatch'; exit 1; }
   for f in $FILES; do
     get "refs/tags/v$V" "templates/$f" "$T/new/$f" || { echo 'STOP release-incomplete'; exit 1; }
   done
   get "refs/tags/v$V" CHANGELOG.md "$T/new/CHANGELOG.md" || { echo 'STOP release-incomplete'; exit 1; }
   for s in raw-compile audit-wiki update-wiki; do
     [ "$(sed -n 1p "$T/new/$s.SKILL.md" | tr -d '\r')" = '---' ] &&
     [ "$(sed -n 2p "$T/new/$s.SKILL.md" | tr -d '\r')" = "name: $s" ] || { echo "STOP bad-frontmatter $s"; exit 1; }
   done
   # The release before this one, read from its changelog, to recognize an older release's copy.
   PREV=$(tr -d '\r' < "$T/new/CHANGELOG.md" | sed -n 's/^## \([0-9][-0-9.]*\)[[:space:]]*$/\1/p' | awk -v v="$V" 'f { print; exit } $0 == v { f = 1 }')
   echo "PREVIOUS ${PREV:-none}"
   if [ -n "$PREV" ]; then
     for f in $FILES; do get "refs/tags/v$PREV" "templates/$f" "$T/prev/$f" || rm -f "$T/prev/$f"; done
   fi
   # Pristine copies of what this wiki installed. A 404 here is normal for untagged versions.
   for b in $BASES; do
     printf '%s' "$b" | grep -Eqx "$D" || continue
     if [ "$b" = "$V" ]; then cp -R "$T/new" "$T/base-$b"; continue; fi
     for f in $FILES; do get "refs/tags/v$b" "templates/$f" "$T/base-$b/$f" || rm -f "$T/base-$b/$f"; done
   done
   echo DONE
   EOF
   ```

   The first line of output is `TMP <path>`. Use that literal path in every later command.
   `DONE` on the last line means the fetch succeeded. A missing pristine copy is no failure:
   its files simply have no pristine copy (step 7). `PREVIOUS` names the release before this
   one, whose copies step 7 uses to recognize a file left at an older release.

5. **Handle a stop.** A `STOP <code>` line means the run ends here, and nothing in the vault
   has changed, so there is nothing to roll back. The status printed just above the `STOP`
   line tells the network cases apart.

   | Output | What happened | What to tell the user |
   |---|---|---|
   | `no-version`, status `000` | No connection to GitHub: offline, a proxy, or TLS inspection on a corporate network (curl's error line names it) | Network problem. Check the connection or proxy and try again. |
   | `no-version`, status `404` | The repo moved or went private | The update source is gone. Tell the maintainer. |
   | any code, status `429` | GitHub's rate limit for this network | Try again in an hour. |
   | `no-version`, any other status | A GitHub outage | Try again later. |
   | `not-github` | Something other than GitHub answered, such as a proxy or captive portal page | Something between this computer and GitHub answered instead. Check the network. |
   | `older-than-local` | The cache served an older `VERSION` than this wiki already runs | Try again in about 10 minutes. Never downgrade. |
   | `tag-missing` | `VERSION` names a release whose tag doesn't exist yet. The tag appears about a minute after a push, and a miss stays cached for 5 minutes | The release is still being published. Wait 10 minutes and try again. If it still fails after an hour, tell the maintainer that tag `v<V>` is missing. |
   | `tag-mismatch`, `release-incomplete`, `bad-frontmatter` | The release itself is broken | Tell the maintainer which code appeared. |
   | `no-tempdir` | No temporary folder could be created | Report the error as printed. |

   Never retry from `main` after a stop. Mixing files from two releases is the failure the
   tags exist to prevent.

   If the script ran without its `bash <<'EOF'` wrapper, or with an indented closing `EOF`,
   its STOP codes can be wrong (zsh, for one, turns the file list into a single word). Rerun
   it as shown before telling the user anything.

6. **Read the changelog gap.** From `<TMP>/new/CHANGELOG.md`, take every entry newer than the
   oldest known base version. Order versions with `sort -V`. If every base is `unknown`, take
   the whole file.

7. **Classify each managed file in one Bash call.** Fill in the literal `TMP` path, the wiki
   root, and each file's base version from step 3 (`unknown` points at a folder that doesn't
   exist, which is intended). Inside the single quotes, write each `'` of a path as `'\''`:
   a folder named `Dana's Wiki` becomes `'/path/to/Dana'\''s Wiki'`.

   ```bash
   bash <<'EOF'
   T='<TMP path from step 4>'; W='<wiki root>'
   same() { diff -q --strip-trailing-cr "$1" "$2" >/dev/null 2>&1; }
   norm() { tr -d '\r' < "$1" | sed 's/[[:space:]]*$//' | grep -v '^$'; }
   ws()   { [ "$(norm "$1")" = "$(norm "$2")" ]; }   # equal apart from spacing and blank lines
   classify() {   # classify <file> <local path> <pristine folder>
     L=$2; U="$T/new/$1"; P="$3/$1"; Q="$T/prev/$1"
     if   [ ! -f "$L" ];  then b='missing locally'
     elif same "$L" "$U"; then b='current'
     elif [ -f "$P" ] && same "$L" "$P"; then b='upstream change only'
     elif same "$L" "$Q"; then b='older release copy'
     elif [ ! -f "$P" ];  then b='no pristine'
     elif ws "$L" "$P";   then b='whitespace only'
     elif same "$P" "$U"; then b='local edit only'
     else                      b='local edit + upstream change'
     fi
     printf '%-22s %s\n' "$1" "$b"
   }
   classify CLAUDE.md            "$W/CLAUDE.md"                           "$T/base-<CLAUDE.md base>"
   classify raw-compile.SKILL.md "$W/.claude/skills/raw-compile/SKILL.md" "$T/base-<raw-compile base>"
   classify audit-wiki.SKILL.md  "$W/.claude/skills/audit-wiki/SKILL.md"  "$T/base-<audit-wiki base>"
   classify update-wiki.SKILL.md "$W/.claude/skills/update-wiki/SKILL.md" "$T/base-<update-wiki base>"
   EOF
   ```

   `--strip-trailing-cr` keeps a Windows checkout's line endings from posing as local edits.
   In the table, L is the local file, P the pristine copy of its base version, U the release:

   | Bucket | Condition | What the user sees | Question (step 9) | Base if the file is kept |
   |---|---|---|---|---|
   | current | L = U | "current" | none | V |
   | missing locally | no L | "will be installed" | part of the batch question | n/a |
   | older release copy | L ≠ P, L = the previous release's copy (Q) | "Matches release `<PREVIOUS>` exactly, so it carries no local edits; this release changes it." Displayed like an upstream change | Update (recommended) / Keep | `<PREVIOUS>` |
   | upstream change only | L = P, P ≠ U | One line naming the changed `#` headings, with the lines added and removed. Always the full diff for `CLAUDE.md`; for a skill, the full diff on request | Update (recommended) / Keep | its old base |
   | whitespace only | L and P differ only in spacing, line endings or blank lines | "Differs from the installed copy only in whitespace; no real local edits." Displayed like an upstream change | Update (recommended) / Keep | its old base |
   | local edit only | L ≠ P, P = U | "Has local edits; this release leaves it unchanged; kept", plus the full P→L diff | none, except under `repair`: Keep (recommended) / Restore the release copy | V |
   | local edit + upstream change | all three differ | The local edits (full P→L diff), the release's change (P→U, in full for `CLAUDE.md`, summarized for a skill), and every local line the update would drop | Keep mine / Take the release (drops the edits shown) | its old base |
   | no pristine | L ≠ U, no P | "Can't separate local edits from older template text." The full L→U diff for `CLAUDE.md`; for a skill a summary, the number of local lines the update would drop, and the full diff on request | Take the release / Keep mine | `unknown` |

   A file written in step 10 gets base V.

8. **Show the user what will change**, before asking anything:
   - `This wiki: <LOCAL>` (plus any held-back bases) and `Latest: <V>`
   - The changelog entries from step 6, quoted as written
   - Each managed file with its bucket and the display from the table above. Produce every
     diff with `diff -u --strip-trailing-cr`.
   - If the vault is a git repo with a dirty tree, say so and suggest committing first, so the
     update lands as a reviewable, revertable change.
   - Any global or parent-folder copies found in step 2, and that Claude Code runs those
     instead of this wiki's copies

9. **Ask before writing.** Use `AskUserQuestion`, which takes at most four questions per call.
   - **Nothing to do:** every file is current or "local edit only", and this run isn't a
     `repair`. Write nothing except the stamp when its bases change (step 12), report
     "up to date on `<V>`" with any local edits kept, and go to step 13 if step 2 found global
     copies. Otherwise stop.
   - **No conflicts:** every changed file is "upstream change only", "older release copy",
     "whitespace only" or "missing locally". Ask one question: **Update all** (recommended) /
     **Choose per file** / **Cancel**.
   - **Anything else:** ask one question per non-current file in a single call, with the
     options from the table. There are at most four managed files, which fits the tool's
     limit. "Choose per file" leads to the same per-file questions.
   - **Cancel** means no writes and no stamp change.

10. **Write the approved files** with `mkdir -p` and `cp "<TMP>/new/<file>" "<destination>"`,
    every path quoted. Never use the Write or Edit tool for these files: they re-type the
    content, and these files have to land byte for byte. Write in this order: `CLAUDE.md`,
    `raw-compile`, `audit-wiki`, and `update-wiki` last. Writing this file last means a failure
    earlier in the run leaves the updater matching the templates it was reasoning about.
    Rewriting it mid-run is safe: the instructions you are following are already loaded.

11. **Verify before stamping.** For every file written this run, run
    `diff -q "<TMP>/new/<file>" "<destination>"`. A file that fails gets base `unknown` and is
    reported as a failure. The stamp vouches only for files that passed.

12. **Stamp the version.** Rewrite `<skills>/.wiki-version` with the header from *The stamp*,
    `version: <V>`, `updated:` set to today, and a `held-back:` line listing
    `<name>@<base>` for every file whose base after this run is not V. Leave the line out when
    every file is at V.

    Under-claiming is the safe direction. A stamp that vouches for a file it never wrote hides
    that file from every later run's pristine comparison, and the next update reports a local
    edit as current, or the reverse.

13. **Offer to move global copies aside** when step 2 found any. Ask after the update, in a
    separate question, so this wiki's own copies are already in place.
    - Tell the user: "Claude Code runs `<global skills folder>/<name>` instead of this wiki's copy,
      so `compile`, `audit` and `update` here have been running those (version `<X>` from the
      global stamp, if there is one)."
    - Other wikis on this computer without their own `.claude/skills/` use those copies too,
      and lose their skills when the copies move. If the copy running now is the global
      `update-wiki` (step 2), saying `update` in each of those wikis installs their own copies,
      so suggest doing that first. Otherwise each of them needs the bootstrap prompt (below)
      after the move.
    - Options: **Move them now** / **Leave them**.
    - On an explicit yes, move exactly the `GLOBAL-SKILL` folders and `GLOBAL-STAMP` files from
      step 2, each whole, into a new backup folder, and delete nothing. `mv -n` never
      overwrites, and the script reports anything it couldn't move:

      ```bash
      bash <<'EOF'
      B="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/wiki-skills-backup-$(date +%Y-%m-%d-%H%M%S)"
      mkdir "$B" || exit 1
      for p in '<GLOBAL-SKILL folder>' '<GLOBAL-SKILL folder>' '<GLOBAL-STAMP file>'; do
        if [ -e "$p" ] && mv -n "$p" "$B/" && [ ! -e "$p" ]; then echo "MOVED $p"; else echo "NOT MOVED $p"; fi
      done
      ls -la "$B"
      EOF
      ```

      Report every `NOT MOVED` line; those copies still run.
    - Renaming a folder inside the global skills folder doesn't disable it, so the folders
      have to leave that directory.
    - Copies in a parent folder's `.claude/skills/` belong to that project. Name their paths
      and leave the decision to the user.

14. **Report** (see *Output to the user*).

## Bootstrapping a wiki that has no `update-wiki` yet

Wikis scaffolded before this skill existed cannot run it. Give the user this to paste into
Claude Code from inside the wiki folder, once:

> Run this exact command with Bash in this folder, and do not use WebFetch: `curl -fsSL --create-dirs -o .claude/skills/update-wiki/SKILL.md https://raw.githubusercontent.com/davron-design/wiki-generator/main/templates/update-wiki.SKILL.md` Then tell me to start a new Claude Code session here and say `update`.

From then on the skill updates itself along with everything else.

## Output to the user

After the run, report:
- The version move (`<before>` to `<after>`), or "already on `<version>`"
- Each managed file: written, already current, kept with local edits, skipped at the user's
  request, or failed verification
- Global copies: moved to the backup folder, or still in place and still running instead of
  this wiki's copies
- When the changes take effect:
  - Claude Code picks up the new skill files within this session.
  - If this run created `.claude/skills/`, run `/reload-skills` or start a new session, since
    Claude Code isn't watching a folder that didn't exist at launch.
  - If `CLAUDE.md` was written, start a new Claude Code session in this folder before the next
    compile or audit. Claude Code reads `CLAUDE.md` only when a session starts.
- The undo line when the vault is a git repo: `git checkout -- CLAUDE.md .claude/skills`

## Anti-patterns

- **NEVER use WebFetch to retrieve the templates.** It normalizes and can summarize markdown,
  and these files have to land byte for byte. A skill file that was quietly reflowed on the way
  in still parses and still loads, so the damage shows up much later as behaviour that drifts
  from the documented rules. Use `curl -fsSL`.
- **NEVER fetch a template or the changelog from `main`.** Each file on `main` is cached
  separately, so a run shortly after a push can mix a new `VERSION` with an old skill and stamp
  the mix as current. Read only `VERSION` from `main`; everything else comes from the tag. If
  the tag is missing, stop and wait.
- **NEVER write anything under `wiki/`, `raw/`, or `output/`.** `wiki/_master-index.md` is the
  trap: it is one of the scaffold's files, so it looks managed, but the scaffold seeds it once
  and the user owns it from then on. Writing the empty placeholder over a populated index
  erases the map of the entire wiki, and no compile or audit will rebuild it.
- **NEVER apply a partial fetch.** If one of the four templates or the changelog fails to
  download or fails its checks, write none of them. Half an update leaves a wiki whose skills
  disagree with its `CLAUDE.md`.
- **NEVER treat a missing pristine copy as "unmodified".** Without the installed release's own
  file, local edits and older template text look the same. Classify the file as "no pristine"
  and show the diff.
- **NEVER overwrite `CLAUDE.md` without printing the diff first.** It is the one managed file
  teams extend with their own conventions, and an overwrite is unrecoverable outside git.
- **NEVER drop a `held-back:` entry for a file that isn't at the stamped version.** The stamp
  is what the next run trusts; an entry dropped too early points the next comparison at the
  wrong pristine copy.
- **NEVER edit a template while installing it, and never copy a local file back upstream.**
  Templates flow one way, repo to wiki. A fix belongs in `wiki-generator/templates/` first, and
  reaches this wiki on the next update.
- **NEVER write into `~/.claude/skills/`.** Global copies run ahead of every wiki's own, so a
  write there changes every wiki on the machine at once. The only allowed action is moving
  them out (step 13), after the user explicitly agrees, and nothing is ever deleted.
- **NEVER run compile or audit as part of an update.** They are separate skills with separate
  confirmation steps, and folding them in hides real content changes inside what the user
  approved as a template refresh.
- **NEVER report success without step 11.** A failed copy leaves a wiki that looks updated and
  is not, and the version stamp would then vouch for it.
