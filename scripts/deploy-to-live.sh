#!/usr/bin/env bash
# Push the canonical templates from wiki-generator/templates/ into the live
# `raw-compile/`, `audit-wiki/` and `update-wiki/` skill folders that sit next
# to this generator. Templates are the source of truth; this script is the
# deployment direction.
#
# Use this when you (the skill maintainer) keep a working wiki whose
# `.claude/skills/` folder also holds wiki-generator, and want your live copies
# to match the templates after an edit, before you push.
#
# It refuses to run anywhere else: the generator's parent folder has to be a
# `.claude/skills/` folder inside a wiki root (a folder holding CLAUDE.md and
# wiki/_master-index.md), and never the home folder's ~/.claude/skills/.
#
# It does not stamp .wiki-version. Deployed templates are unreleased until you
# push and the release tag exists, so `update` should judge them against the
# published release.
#
# Usage: bash scripts/deploy-to-live.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SKILL_DIR/templates"
LIVE_SKILLS_DIR="$(cd "$SKILL_DIR/.." && pwd)"  # .claude/skills/
WIKI_ROOT="$(cd "$LIVE_SKILLS_DIR/../.." && pwd)"
HOME_SKILLS_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"

fail() { echo "deploy-to-live: $*" >&2; exit 1; }

if [ "$(basename "$LIVE_SKILLS_DIR")" != skills ] || [ "$(basename "$(dirname "$LIVE_SKILLS_DIR")")" != .claude ]; then
  fail "the generator's parent folder is $LIVE_SKILLS_DIR, which is not a .claude/skills/ folder. Run this from a copy of wiki-generator inside <wiki>/.claude/skills/."
fi
if [ -d "$HOME_SKILLS_DIR" ] && [ "$(cd "$HOME_SKILLS_DIR" && pwd -P)" = "$(cd "$LIVE_SKILLS_DIR" && pwd -P)" ]; then
  fail "refusing to deploy into $HOME_SKILLS_DIR: skills there run ahead of every wiki's own copies."
fi
if [ ! -f "$WIKI_ROOT/CLAUDE.md" ] || [ ! -f "$WIKI_ROOT/wiki/_master-index.md" ]; then
  fail "$WIKI_ROOT is not a wiki root (it needs CLAUDE.md and wiki/_master-index.md)."
fi

for p in "$WIKI_ROOT/.claude" "$LIVE_SKILLS_DIR" "$LIVE_SKILLS_DIR"/{raw-compile,audit-wiki,update-wiki} "$LIVE_SKILLS_DIR"/{raw-compile,audit-wiki,update-wiki}/SKILL.md; do
  if [ -L "$p" ]; then
    fail "$p is a symlink; cp would write through it into whatever it points at."
  fi
done

VERSION="$(tr -d '[:space:]' < "$TEMPLATES_DIR/VERSION")"
STAMPED="$( { sed -n 's/^version:[[:space:]]*//p' "$LIVE_SKILLS_DIR/.wiki-version" 2>/dev/null || true; } | tr -d '[:space:]')"
if printf '%s' "$STAMPED" | grep -Eqx '[0-9]{4}-[0-9]{2}-[0-9]{2}(\.[0-9]+)?' \
   && [ "$(printf '%s\n' "$STAMPED" "$VERSION" | sort -V | tail -n 1)" != "$VERSION" ]; then
  fail "these templates ($VERSION) are older than the release this wiki runs ($STAMPED). Pull the generator first."
fi

for s in raw-compile audit-wiki update-wiki; do
  if grep -qsE "^name: *$s[[:space:]]*\$" "$HOME_SKILLS_DIR"/*/SKILL.md; then
    echo "warning: $HOME_SKILLS_DIR holds a $s skill, which runs instead of the copy deployed here." >&2
  fi
done

echo "Deploying templates from: $TEMPLATES_DIR"
echo "                      to: $LIVE_SKILLS_DIR"
echo ""

mkdir -p "$LIVE_SKILLS_DIR/raw-compile" "$LIVE_SKILLS_DIR/audit-wiki" "$LIVE_SKILLS_DIR/update-wiki"
cp -v "$TEMPLATES_DIR/raw-compile.SKILL.md" "$LIVE_SKILLS_DIR/raw-compile/SKILL.md"
cp -v "$TEMPLATES_DIR/audit-wiki.SKILL.md"  "$LIVE_SKILLS_DIR/audit-wiki/SKILL.md"
cp -v "$TEMPLATES_DIR/update-wiki.SKILL.md" "$LIVE_SKILLS_DIR/update-wiki/SKILL.md"

echo ""
echo "Done. .wiki-version is not stamped, and the CLAUDE.md template is not deployed."
echo "After you push and the tag v$VERSION exists, say \`update\` in this wiki: the"
echo "skills then show as current, and CLAUDE.md is offered with a diff."
echo ""
echo "Running Claude Code sessions pick up the SKILL.md changes. A CLAUDE.md change"
echo "takes effect in a new session."
