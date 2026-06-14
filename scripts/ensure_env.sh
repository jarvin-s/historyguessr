#!/bin/sh
set -e

# Flutter bundles env files as assets, so the `.env` file listed in pubspec.yaml
# must exist before `flutter build`. CI won't have a gitignored `.env`, so we
# write it from platform environment variables when it's missing.
if [ ! -f .env ]; then
  if [ -n "${SUPABASE_URL:-}" ] && [ -n "${SUPABASE_ANON_KEY:-}" ]; then
    cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
GEMINI_API_KEY=${GEMINI_API_KEY:-}
EOF
  elif [ -f env.example ]; then
    cp env.example .env
  fi
fi

if [ ! -f .env ]; then
  echo "Missing .env. Copy env.example to .env locally, or set SUPABASE_URL and SUPABASE_ANON_KEY in CI."
  exit 1
fi
