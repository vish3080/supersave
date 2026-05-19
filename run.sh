#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# SuperSave dev runner — loads Supabase credentials from .env and runs Flutter.
# Usage:
#   ./run.sh          →  runs on Chrome (web)
#   ./run.sh ios      →  runs on iOS simulator
#   ./run.sh android  →  runs on Android emulator
# ─────────────────────────────────────────────────────────────────────────────

set -e

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env file not found."
  echo "Copy .env.example to .env and fill in your Supabase credentials."
  exit 1
fi

# Load variables from .env
export $(grep -v '^#' "$ENV_FILE" | xargs)

if [ -z "$SUPABASE_URL" ] || [ "$SUPABASE_URL" = "YOUR_SUPABASE_PROJECT_URL" ]; then
  echo "ERROR: SUPABASE_URL is not set in .env"
  exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ] || [ "$SUPABASE_ANON_KEY" = "YOUR_SUPABASE_ANON_KEY" ]; then
  echo "ERROR: SUPABASE_ANON_KEY is not set in .env"
  exit 1
fi

DEVICE="${1:-chrome}"

echo "▶  Running SuperSave on: $DEVICE"
flutter run -d "$DEVICE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
