#!/usr/bin/env bash
#
# Rebundle the live widget used by /playground from the sibling loveletter-web
# repo into public/playground/ll-widget.mjs. The bundle is a single self-contained
# browser ESM that re-exports mountFeedbackWidget + currentWebDeviceInfo (from
# @loveletter/widget) and formatIssueBody + labelsFor (from @loveletter/core),
# so the playground can both run the real widget and render the exact wire-format
# issue body on submit. Re-run when the widget or formatter changes.
set -euo pipefail

DOCS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_WIDGET="$(cd "$DOCS_DIR/../loveletter-web/packages/widget" && pwd)"
OUT="$DOCS_DIR/public/playground/ll-widget.mjs"

ENTRY="$WEB_WIDGET/.ll-pg-entry.ts"
cat > "$ENTRY" <<'TS'
export { mountFeedbackWidget, currentWebDeviceInfo } from './src/index'
export { formatIssueBody, labelsFor } from '@loveletter/core'
TS
trap 'rm -f "$ENTRY"' EXIT

( cd "$WEB_WIDGET" && pnpm dlx esbuild .ll-pg-entry.ts \
    --bundle --format=esm --platform=browser --outfile="$OUT" )

echo "==> Wrote $OUT"
