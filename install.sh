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

note_google_access() {
  if command -v gws >/dev/null 2>&1; then
    echo "Detected gws CLI fallback: $(command -v gws)"
  else
    cat <<'EOF'
Note: `gws` was not found on PATH.
That's okay if your Pi session already has Google Workspace tools configured.
For the most reliable spreadsheet creation and batch writes, `gws` is still recommended.
EOF
  fi
}

note_extensions() {
  if command -v pi >/dev/null 2>&1; then
    if pi list 2>/dev/null | grep -qi 'shop-pi-fy'; then
      echo "Detected Pi extension bundle: shop-pi-fy"
    else
      cat <<'EOF'
Note: `shop-pi-fy` was not found in `pi list`.
If your Pi session does not already have Google Workspace + Perplexity tools, install it with:
  pi install https://github.com/shopify-playground/shop-pi-fy
EOF
    fi
  fi
}

require_shopify_pi
note_google_access
note_extensions

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR"

cp "$REPO_DIR/skills/source-role-sheet/SKILL.md" "$SKILLS_DIR/SKILL.md"
cp "$REPO_DIR/agents/recruiting-researcher.md" "$AGENTS_DIR/recruiting-researcher.md"
cp "$REPO_DIR/agents/candidate-enricher.md" "$AGENTS_DIR/candidate-enricher.md"
cp "$REPO_DIR/agents/workspace-executor.md" "$AGENTS_DIR/workspace-executor.md"
cp "$REPO_DIR/agents/team-brief-researcher.md" "$AGENTS_DIR/team-brief-researcher.md"

cat <<'EOF'
Installed source-role-sheet skill pack.

Files installed:
- ~/.pi/agent/skills/source-role-sheet/SKILL.md
- ~/.pi/agent/agents/recruiting-researcher.md
- ~/.pi/agent/agents/candidate-enricher.md
- ~/.pi/agent/agents/workspace-executor.md
- ~/.pi/agent/agents/team-brief-researcher.md

Required before first sourcing run:
1. Start Pi with Shopify's wrapper:
   - devx pi
2. Make sure Pi has Google Workspace / Sheets access.
3. Make sure Perplexity access is available for LinkedIn URL lookup.
4. Configure the recruiter Gumloop pipeline:
   - https://www.gumloop.com/pipeline?workbook_id=3Pku5WWmdYaZ4nHUxjntJP
5. Copy your Gumloop webhook URL and run:
   - ./scripts/parse-gumloop-webhook.sh '<gumloop-webhook-url>'
6. Export these required env vars in your shell before launching Pi:
   - GUMLOOP_API_KEY
   - GUMLOOP_USER_ID
   - GUMLOOP_SAVED_ITEM_ID
7. Run the local preflight check:
   - ./scripts/check-setup.sh
8. Restart Pi if it was already running before installation.
EOF
