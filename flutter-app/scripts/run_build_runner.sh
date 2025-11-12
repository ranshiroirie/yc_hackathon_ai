#!/bin/sh

set -e

if command -v fvm >/dev/null 2>&1; then
  fvm dart run build_runner build --delete-conflicting-outputs
else
  flutter pub run build_runner build --delete-conflicting-outputs
fi
