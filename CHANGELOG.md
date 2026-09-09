# Changelog

Released versions of the canonical templates in `templates/`. Every scaffolded wiki records
the version it runs in `.claude/skills/.wiki-version`, and the `update-wiki` skill reads that
stamp to tell the user exactly what they are missing.

Versions are dates (`YYYY-MM-DD`). A second release on the same day gets a `.2` suffix.

Bumping is manual and belongs in the same commit as the template edit: change the template,
add an entry here, set `templates/VERSION`. See [MAINTAINER.md](MAINTAINER.md).

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
