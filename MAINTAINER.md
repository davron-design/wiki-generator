# wiki-generator — Maintainer Notes

These notes are for whoever maintains the `wiki-generator` skill itself.
**Destination users (people running the skill) never need to read this file.**

## Template sync

The four files in `templates/` are the **canonical source** for the wiki convention. Any deployed copies — the maintainer's own live `.claude/skills/`, and every scaffolded downstream wiki — are derivatives.

When updating `raw-compile` or `audit-wiki`:

1. Edit the file in `wiki-generator/templates/`.
2. If the maintainer keeps a live wiki of their own, run `bash scripts/deploy-to-live.sh` to push the updated templates into the sibling `.claude/skills/raw-compile/` and `.claude/skills/audit-wiki/` next to this generator.
3. New downstream wikis automatically get the latest version on next scaffold.

## Upgrading existing downstream wikis

Existing downstream wikis are not auto-upgraded. The supported upgrade path is to re-run `wiki-generator` against the existing target and choose **overwrite** at the collision prompt. The skill detects this case and surfaces it explicitly so the user doesn't accidentally pick the default (skip), which would leave them on stale templates.

## Direction of truth

Templates → deployments. **Never the reverse.** If you debug a bug by editing a deployed copy directly, you must port the fix back into `templates/` before considering the change durable — otherwise the next scaffold or `deploy-to-live.sh` run will overwrite it.
