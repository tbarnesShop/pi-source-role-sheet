#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PI_DIR="$HOME/.pi/agent"
SKILLS_DIR="$PI_DIR/skills/source-role-sheet"
AGENTS_DIR="$PI_DIR/agents"

require_shopify_pi() {
  if ! command -v devx >/dev/null 2>&1; then
    cat >&2 <<'EOF'
Error: Shopify dev tooling is not installed or `devx` is not on your PATH.

This skill pack is intended to run with Shopify Pi, launched via:
  devx pi
EOF
    exit 1
  fi

  local pi_version
  if ! pi_version="$(devx pi --version 2>&1)"; then
    cat >&2 <<'EOF'
Error: `devx` is installed, but Shopify Pi is not available via `devx pi`.

Verify your setup with:
  devx pi --version
  devx pi --help
EOF
    exit 1
  fi

  echo "Detected Shopify Pi via 'devx pi' (version: ${pi_version})"
}

require_shopify_pi

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
1. Start Pi with Shopify's wrapper:
   - devx pi
2. Make sure Pi has Google Workspace / Sheets access.
3. Make sure Perplexity access is available for LinkedIn URL lookup.
4. Optionally configure Gumloop env vars for deep enrichment:
   - GUMLOOP_API_KEY
   - GUMLOOP_USER_ID
   - GUMLOOP_SAVED_ITEM_ID
5. Restart Pi if it was already running before installation.
EOF
