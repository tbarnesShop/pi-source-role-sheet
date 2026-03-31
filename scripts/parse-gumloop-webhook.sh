#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/parse-gumloop-webhook.sh '<gumloop-webhook-url>'

Example:
  ./scripts/parse-gumloop-webhook.sh 'https://api.gumloop.com/api/v1/start_pipeline?api_key=...&user_id=...&saved_item_id=...'

This prints shell export commands for:
  - GUMLOOP_API_KEY
  - GUMLOOP_USER_ID
  - GUMLOOP_SAVED_ITEM_ID
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" || $# -ne 1 ]]; then
  usage
  exit $([[ $# -eq 1 ]] && echo 0 || echo 1)
fi

WEBHOOK_URL="$1"

python3 - "$WEBHOOK_URL" <<'PY'
import sys
from urllib.parse import urlparse, parse_qs

url = sys.argv[1]
parsed = urlparse(url)
query = parse_qs(parsed.query)

required = {
    'GUMLOOP_API_KEY': 'api_key',
    'GUMLOOP_USER_ID': 'user_id',
    'GUMLOOP_SAVED_ITEM_ID': 'saved_item_id',
}

missing = [env for env, key in required.items() if not query.get(key) or not query[key][0]]
if missing:
    sys.stderr.write(
        'Error: webhook URL is missing required Gumloop parameters: ' + ', '.join(missing) + '\n'
    )
    sys.exit(1)

if 'gumloop.com' not in parsed.netloc:
    sys.stderr.write('Warning: URL host does not look like Gumloop: ' + parsed.netloc + '\n')

print('# Run these in your shell before starting Pi:')
for env_name, key in required.items():
    value = query[key][0]
    print(f"export {env_name}='{value}'")

print('\n# Security note: do not commit these values to git or paste them into README files.')
PY
