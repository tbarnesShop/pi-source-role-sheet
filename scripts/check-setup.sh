#!/usr/bin/env bash
set -euo pipefail

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

pass() {
  printf 'PASS: %s\n' "$1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

warn() {
  printf 'WARN: %s\n' "$1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

fail() {
  printf 'FAIL: %s\n' "$1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_devx_pi() {
  if ! command -v devx >/dev/null 2>&1; then
    fail "devx is not installed or not on PATH"
    return
  fi

  local version
  if version="$(devx pi --version 2>&1)"; then
    pass "Shopify Pi available via devx pi (${version})"
  else
    fail "devx exists but devx pi is not working"
  fi
}

check_pi_extensions() {
  if ! command -v pi >/dev/null 2>&1; then
    warn "pi binary not found on PATH; cannot inspect installed extensions"
    return
  fi

  local extensions
  extensions="$(pi list 2>/dev/null || true)"
  if printf '%s' "$extensions" | grep -qi 'shop-pi-fy'; then
    pass "shop-pi-fy appears in pi list"
  else
    warn "shop-pi-fy not found in pi list; ensure your Pi session has Google Workspace + Perplexity tools"
  fi
}

check_installed_files() {
  local files=(
    "$HOME/.pi/agent/skills/source-role-sheet/SKILL.md"
    "$HOME/.pi/agent/agents/recruiting-researcher.md"
    "$HOME/.pi/agent/agents/candidate-enricher.md"
    "$HOME/.pi/agent/agents/workspace-executor.md"
    "$HOME/.pi/agent/agents/team-brief-researcher.md"
  )

  local missing=0
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      pass "Installed: ${file}"
    else
      fail "Missing installed file: ${file}"
      missing=1
    fi
  done

  return $missing
}

check_gumloop_env() {
  local missing=()

  [[ -n "${GUMLOOP_API_KEY:-}" ]] || missing+=("GUMLOOP_API_KEY")
  [[ -n "${GUMLOOP_USER_ID:-}" ]] || missing+=("GUMLOOP_USER_ID")
  [[ -n "${GUMLOOP_SAVED_ITEM_ID:-}" ]] || missing+=("GUMLOOP_SAVED_ITEM_ID")

  if [[ ${#missing[@]} -eq 0 ]]; then
    pass "Required Gumloop env vars are set"
  else
    fail "Missing Gumloop env vars: ${missing[*]}"
  fi
}

check_gws() {
  if ! command -v gws >/dev/null 2>&1; then
    warn "gws not found on PATH; Pi Google Workspace tools may still be enough, but gws is recommended for reliable sheet creation and batch writes"
    return
  fi

  pass "gws found on PATH ($(command -v gws))"

  if gws drive about get --params '{"fields":"user"}' >/dev/null 2>&1; then
    pass "gws appears authenticated for Google Drive"
  else
    warn "gws found, but Google Drive auth check failed; Pi Google Workspace tools may still work, but gws fallback is not ready"
  fi
}

print_next_steps() {
  cat <<'EOF'

Suggested smoke test after this script passes:
1. Start Pi with: devx pi
2. Ask Pi to create a tiny sourcing sheet, for example:
   Source 3 senior backend engineers in Toronto into a new Google Sheet and enrich verified LinkedIn URLs with Gumloop.
EOF
}

check_devx_pi
check_pi_extensions
check_installed_files || true
check_gumloop_env
check_gws
print_next_steps

printf '\nSummary: %d pass, %d warn, %d fail\n' "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
