#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

template_check_dir=$(mktemp -d)
trap 'rm -rf "$template_check_dir"' EXIT
cp -R lib test tool bricks mason.yaml pubspec.yaml pubspec.lock analysis_options.yaml \
  l10n.yaml .fvmrc "$template_check_dir/"
cd "$template_check_dir"
flutter_command=(flutter)
dart_command=(dart)
if command -v fvm >/dev/null 2>&1; then
  flutter_command=(fvm flutter)
  dart_command=(fvm dart)
fi
"${flutter_command[@]}" pub get
./tool/make_feature.sh template_probe
"${flutter_command[@]}" gen-l10n
"${dart_command[@]}" format --output=none --set-exit-if-changed lib test
"${flutter_command[@]}" analyze
"${dart_command[@]}" run bloc_tools:bloc lint .
./tool/test.sh
