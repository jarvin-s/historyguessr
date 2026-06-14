#!/bin/sh
set -e

# Vercel doesn't ship Flutter, so install the SDK, then build the web app.
FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"

if [ ! -d "$HOME/flutter" ]; then
  git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

flutter config --enable-web
flutter --version

# Flutter bundles `.env` as an asset (see pubspec.yaml), so it must exist before
# the build. CI has no gitignored `.env`, so write it from Vercel env vars.
sh scripts/ensure_env.sh

flutter pub get
flutter build web --release
