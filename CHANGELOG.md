# Changelog

Released versions of the canonical templates in `templates/`. Every scaffolded wiki records
the version it runs in `.claude/skills/.wiki-version`, and the `update-wiki` skill reads that
stamp to tell the user exactly what they are missing.

Versions are dates (`YYYY-MM-DD`). A second release on the same day gets a `.2` suffix.

Bumping is manual and belongs in the same commit as the template edit: change the template,
add an entry here, set `templates/VERSION`. See [MAINTAINER.md](MAINTAINER.md).

## 2026-10-02

- **Before you update: this update still runs your current `update`**, which shows changes to
  skill files only as a one-line summary. If you edited a skill file by hand, choose per file
  and keep it, or copy your edit somewhere first. From the next update on, `update` shows your
  edits in full and asks before replacing them.
- **PowerPoint, Word and Excel files are read in full.** Compile used to extract only their
  text, so pictures pasted into slides, the values in charts, and speaker notes never reached
  the wiki. It now renders decks and documents with LibreOffice when that is installed (free
  and optional), and reads chart values, speaker notes and hidden slides from the file itself.
  The run report states, per file, how many pictures and charts were read, and lists anything
  it couldn't open. Decks compiled before this release may lack those parts: compare them with
  their archived copies in `raw/_<date>-compiled/`.
- **Same-day compiles keep every archived source.** A file whose name is taken in today's
  archive folder is stored as `deck-2.pptx` and cited under that name. A file whose content
  only contradicted the wiki is archived with the rest of the run, and its rows in
  `_pending-reconciliation.md` cite it the way a `Sources:` footer does. Files an earlier
  compile left in `raw/` for that reason are compiled and archived on the next run.
- **When two sources in one compile disagree, the later-dated document wins** (the date printed
  in the document, then a version in the filename). The other claim goes to the reconciliation
  queue marked `same-run`.
- **Answers flag open conflicts.** When a question touches an article with an open row in
  `_pending-reconciliation.md`, the answer says which claim is disputed.
- **Formats.** Links in index rows escape the pipe as `\|`, so a link stays inside its table
  cell. `Sources:` footers list one source per line. Article filenames are unique across the
  whole wiki. Existing articles keep their old formats until compile appends to them, and the
  audit accepts old footers. **Run `audit` after updating:** its index check now flags
  unescaped pipes (once per index file), while links to never-written articles and other
  topics' queue rows weigh less or not at all. The first score after this update can't be
  compared with earlier rounds.
- **Audit.** A topic audit counts only that topic's queue rows. Incremental audits include
  articles that are not yet committed to git. A link to an article that was never written counts
  as a coverage gap. Resolving a conflict adds the winning source to the article's footer and
  removes its ⚠️ callout. Articles the audit writes use only facts already in the wiki, and
  gaps that need new facts go on a "Needs source material" list.
- **`update` installs each release from its own tag** and compares every file with the copy
  this wiki installed, so your own edits to a skill now show as a full diff with a question
  before anything replaces them. Skill files take effect in the running session; start a new
  session when the update rewrote `CLAUDE.md`.
- **Global installs are retired.** Skills installed once for every project, in `~/.claude/skills/`
  in your home folder, run ahead of each wiki's own copies, so updates made inside a wiki never
  reached them. If this wiki used them, say `update` once more after this update. The new
  `update` installs this wiki's own copies and offers to move the global ones into a backup
  folder. If it reports "up to date" and the global copies are still there, fix it by hand:
  1. In every other wiki without its own `.claude/skills/` folder, say `update`, twice if
     needed, until that wiki has its own copies.
  2. Create a backup folder such as `~/.claude/wiki-skills-backup-2026-10-02` and move
     `raw-compile`, `audit-wiki`, `update-wiki` and `.wiki-version` from `~/.claude/skills/`
     into it. Renaming them inside `skills/` leaves them active.
  3. In any wiki still without its own copies, paste the bootstrap prompt from the README,
     start a new session there, and say `update`.

## 2026-09-09.2

- **`update` now points at `repair` when it reports "up to date".** The version fast path
  trusts the stamp, so a managed file edited by hand after install stayed invisible: the wiki
  read as current while running someone's local copy. Saying `repair` skips the version check
  and re-diffs all four files against upstream.

## 2026-09-09

- **New `update-wiki` companion skill.** Every scaffold now installs a third skill next to
  `raw-compile` and `audit-wiki`. Saying `update` inside a wiki fetches the current templates
  from GitHub, reports what changed since the wiki's recorded version, and rewrites only
  `CLAUDE.md` and the three `SKILL.md` files. Compiled content in `wiki/`, `raw/`, and
  `output/` is never read or written by it.
- **Version stamping.** Scaffolding and updating both write `.claude/skills/.wiki-version`, so
  a wiki can answer "which templates am I running?" without guessing from file contents.
- **Re-scaffolding no longer overwrites `wiki/_master-index.md`.** The seed index is written
  once, at creation. Choosing `overwrite` on an upgrade previously replaced a populated master
  index with the empty placeholder, erasing the wiki's navigation map.
- **`Sources:` footers survive archiving.** Compile stamps the compile date into every source
  line, and the audit checks both `raw/_<date>-compiled/<path>` and
  `raw/_archive/_<date>-compiled/<path>` before calling a citation dangling.

## Before 2026-09-09

Versioning starts above. A wiki whose `.wiki-version` is missing was scaffolded before this
point and is behind by everything on this list. Updating it is the fastest way to catch up.

- **2026-07-01** Compile became strictly append-only: it creates and appends, never rewrites
  or deletes. Conflicts are deferred to `wiki/_pending-reconciliation.md` instead of being
  resolved at ingest time. Audits gained incremental sweeps, full-sweep escalation triggers,
  and a fixed 0 to 100 integrity rubric with a Known Open Items ledger.
- **2026-06-19** Archiving rules clarified: dated `_<date>-compiled/` folders keep each
  source's path relative to `raw/`, and stale folders sweep into `raw/_archive/` whole.
- **2026-06-14** The reconciliation queue was introduced as the durable handoff between
  additive ingest and periodic audit.
- **2026-06-09** Deep audit of both companion skills: sharper trigger descriptions, explicit
  anti-patterns, and provenance requirements on every article.
- **2026-05-16** Indexes became markdown tables with `##` section grouping, replacing bullet
  lists.
- **2026-05-15** First release of the wiki convention.
