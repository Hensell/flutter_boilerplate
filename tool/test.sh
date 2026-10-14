#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

dart_command=(dart)
if command -v fvm >/dev/null 2>&1; then
  dart_command=(fvm dart)
fi

# Only generated translations and declaration-only contracts are excluded.
coverage_excludes="lib/l10n/gen/** lib/core/storage/local_store.dart lib/features/**/domain/repositories/*_repository.dart lib/core/logging/error_reporter.dart"

"${dart_command[@]}" pub global run very_good_cli:very_good test \
  --coverage \
  --collect-coverage-from all \
  --min-coverage 100 \
  --exclude-coverage "$coverage_excludes" \
  --show-uncovered \
  --test-randomize-ordering-seed random \
  "$@"

# Enforce the same coverage threshold for the independent design system.
(cd packages/app_ui && "${dart_command[@]}" pub global run very_good_cli:very_good test \
  --coverage --collect-coverage-from all --min-coverage 100 --show-uncovered \
  --exclude-coverage "lib/app_ui.dart lib/src/tokens/**" \
  --test-randomize-ordering-seed random)
