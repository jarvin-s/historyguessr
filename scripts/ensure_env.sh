#!/bin/sh
set -e

# Flutter bundles env files as assets, so the file listed in pubspec.yaml must
# exist before `flutter build`. CI won't have a gitignored `.env`, so we sync
# from `.env` locally or write from platform environment variables in deploy.
if [ -f .env ]; then
  cp .env env.example
elif [ -n "${SUPABASE_URL:-}" ] && [ -n "${SUPABASE_ANON_KEY:-}" ]; then
  cat > env.example <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
GEMINI_API_KEY=${GEMINI_API_KEY:-}
EOF
fi

if [ ! -f env.example ]; then
  echo "Missing env.example. Create .env from env.example or set SUPABASE_URL in CI."
  exit 1
fi
