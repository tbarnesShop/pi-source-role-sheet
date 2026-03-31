#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PI_DIR="$HOME/.pi/agent"
SKILLS_DIR="$PI_DIR/skills/source-role-sheet"
AGENTS_DIR="$PI_DIR/agents"

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR"

cp "$REPO_DIR/skills/source-role-sheet/SKILL.md" "$SKILLS_DIR/SKILL.md"
cp "$REPO_DIR/agents/recruiting-researcher.md" "$AGENTS_DIR/recruiting-researcher.md"
cp "$REPO_DIR/agents/candidate-enricher.md" "$AGENTS_DIR/candidate-enricher.md"
cp "$REPO_DIR/agents/workspace-executor.md" "$AGENTS_DIR/workspace-executor.md"

cat <<'EOF'
Installed source-role-sheet skill pack.

Files installed:
- ~/.pi/agent/skills/source-role-sheet/SKILL.md
- ~/.pi/agent/agents/recruiting-researcher.md
- ~/.pi/agent/agents/candidate-enricher.md
- ~/.pi/agent/agents/workspace-executor.md

Next steps:
1. Make sure Pi has Google Workspace / Sheets access.
2. Make sure Perplexity access is available for LinkedIn URL lookup.
3. Optionally configure Gumloop env vars for deep enrichment:
   - GUMLOOP_API_KEY
   - GUMLOOP_USER_ID
   - GUMLOOP_SAVED_ITEM_ID
4. Restart Pi if it was already running before installation.
EOF
