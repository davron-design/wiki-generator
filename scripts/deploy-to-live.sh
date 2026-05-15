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

mkdir -p "$LIVE_SKILLS_DIR/raw-compile" "$LIVE_SKILLS_DIR/audit-wiki"
cp -v "$TEMPLATES_DIR/raw-compile.SKILL.md" "$LIVE_SKILLS_DIR/raw-compile/SKILL.md"
cp -v "$TEMPLATES_DIR/audit-wiki.SKILL.md"  "$LIVE_SKILLS_DIR/audit-wiki/SKILL.md"

echo ""
echo "Done. The CLAUDE.md template is not deployed — the live wiki's CLAUDE.md"
echo "is maintained independently. Update it by hand if conventions change."
