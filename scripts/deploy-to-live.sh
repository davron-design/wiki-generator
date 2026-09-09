#!/usr/bin/env bash
# Push the canonical templates from wiki-generator/templates/ into the live
# `.claude/skills/raw-compile/` and `.claude/skills/audit-wiki/` folders that
# sit next to this generator. Templates are the source of truth; this script
# is the deployment direction.
#
# Use this when you (the skill maintainer) keep a working wiki in the same
# `.claude/skills/` directory as wiki-generator itself, and want your live
# copies to match the latest templates after an edit.
#
# Usage: bash scripts/deploy-to-live.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SKILL_DIR/templates"
LIVE_SKILLS_DIR="$(cd "$SKILL_DIR/.." && pwd)"  # .claude/skills/

echo "Deploying templates from: $TEMPLATES_DIR"
echo "                      to: $LIVE_SKILLS_DIR"
echo ""

mkdir -p "$LIVE_SKILLS_DIR/raw-compile" "$LIVE_SKILLS_DIR/audit-wiki" "$LIVE_SKILLS_DIR/update-wiki"
cp -v "$TEMPLATES_DIR/raw-compile.SKILL.md" "$LIVE_SKILLS_DIR/raw-compile/SKILL.md"
cp -v "$TEMPLATES_DIR/audit-wiki.SKILL.md"  "$LIVE_SKILLS_DIR/audit-wiki/SKILL.md"
cp -v "$TEMPLATES_DIR/update-wiki.SKILL.md" "$LIVE_SKILLS_DIR/update-wiki/SKILL.md"

# Re-stamp the live version so `update-wiki` reports the right baseline here too.
VERSION="$(tr -d '[:space:]' < "$TEMPLATES_DIR/VERSION")"
cat > "$LIVE_SKILLS_DIR/.wiki-version" <<EOF
# Managed by wiki-generator. Do not edit by hand.
source: https://github.com/davron-design/wiki-generator
version: $VERSION
updated: $(date +%F)
EOF
echo "stamped: $LIVE_SKILLS_DIR/.wiki-version ($VERSION)"

echo ""
echo "Done. The CLAUDE.md template is not deployed: the live wiki's CLAUDE.md is"
echo "maintained independently. Update it by hand if conventions change, or run"
echo "\`update\` inside the wiki to pull it from GitHub with a diff first."
echo ""
echo "Skills are read at session start, so restart Claude Code to pick these up."
