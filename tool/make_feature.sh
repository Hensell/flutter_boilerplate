#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

feature_name="${1:-}"
if [[ $# -ne 1 || ! "$feature_name" =~ ^[a-z][a-z0-9]*(_[a-z0-9]+)*$ ]]; then
  echo "Usage: ./tool/make_feature.sh feature_name (lowercase snake_case)" >&2
  exit 2
fi
if [[ -e "lib/features/$feature_name" || -e "test/features/$feature_name" ]]; then
  echo "Feature already exists: $feature_name" >&2
  exit 2
fi
package_name=$(sed -n 's/^name: *//p' pubspec.yaml | head -n 1)
dart_command=(dart)
if command -v fvm >/dev/null 2>&1; then dart_command=(fvm dart); fi

"${dart_command[@]}" pub global run mason_cli:mason get
"${dart_command[@]}" pub global run mason_cli:mason make feature \
  --name "$feature_name" --package_name "$package_name" \
  --output-dir . --on-conflict skip --no-hooks
"${dart_command[@]}" format "lib/features/$feature_name" "test/features/$feature_name"
