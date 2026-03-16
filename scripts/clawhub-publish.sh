#!/usr/bin/env bash
# Publishes all 10 OpenAlgernon skills to ClawHub.
# Run this after: clawhub login
set -e

CLAWHUB="${CLAWHUB:-clawhub}"
SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)/skills"

if ! "$CLAWHUB" whoami &> /dev/null; then
  echo "ERROR: Not logged in to ClawHub."
  echo "Run: clawhub login"
  exit 1
fi

SKILLS=(
  algernon-orchestrator
  algernon-texto
  algernon-review
  algernon-feynman
  algernon-interview
  algernon-debate
  algernon-sprint
  algernon-synthesis
  algernon-content
  algernon-progress
)

echo "Publishing ${#SKILLS[@]} skills to ClawHub..."
echo ""

for skill in "${SKILLS[@]}"; do
  echo "-> $skill"
  "$CLAWHUB" publish "${SKILLS_DIR}/${skill}"
  echo ""
done

echo "Done. All skills published."
echo "View at: https://clawhub.ai/u/$(${CLAWHUB} whoami --json 2>/dev/null | python3 -c 'import sys,json; print(json.load(sys.stdin).get("handle",""))' 2>/dev/null || echo 'your-handle')"
