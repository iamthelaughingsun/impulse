#!/usr/bin/env bash
# Install the impulse suite into Hermes Agent.
#
# Hermes uses its own plugin and skill schemas, so this is deliberately not a
# copy of any other harness's installer:
#   * the master layer is hermes-plugin/impulse-core (plugin.yaml +
#     pre_llm_call hook), not a rules file;
#   * skills must sit two levels deep, skills/<category>/<name>/SKILL.md;
#   * Hermes resolves a skill's linked files relative to that skill, while the
#     suite writes references as shared/<file>.md — so each skill gets its own
#     shared/ copy.
#
# Usage: scripts/install-hermes.sh
# Override the target with HERMES_HOME.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"

if [ ! -d "$HERMES_DIR" ]; then
  echo "no Hermes home at $HERMES_DIR — install Hermes Agent first" >&2
  exit 1
fi

PLUGIN_DIR="$HERMES_DIR/plugins/impulse-core"
SKILLS_DIR="$HERMES_DIR/skills/impulse"

rm -rf "$PLUGIN_DIR" "$SKILLS_DIR"
mkdir -p "$HERMES_DIR/plugins" "$SKILLS_DIR"

cp -r "$ROOT/hermes-plugin/impulse-core" "$PLUGIN_DIR"
cp -r "$ROOT"/skills/*/ "$SKILLS_DIR/"

for skill in "$SKILLS_DIR"/*/; do
  [ -f "$skill/SKILL.md" ] || continue
  cp -r "$ROOT/shared" "$skill/shared"
done
cp -r "$ROOT/shared" "$SKILLS_DIR/shared"

echo "plugin:  $PLUGIN_DIR"
echo "skills:  $SKILLS_DIR ($(find "$SKILLS_DIR" -mindepth 2 -name SKILL.md | wc -l | tr -d ' ') skills)"
echo
echo "next:"
echo "  hermes plugins enable impulse-core"
echo "  restart the gateway afterwards — a new session alone does not reload"
echo "  the plugin env or the full skill list"
