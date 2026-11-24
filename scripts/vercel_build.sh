#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.4}"
FLUTTER_SDK_DIR="${FLUTTER_SDK_DIR:-$HOME/flutter-sdk}"

if [[ ! -x "$FLUTTER_SDK_DIR/bin/flutter" ]]; then
  echo "Installing Flutter SDK ${FLUTTER_VERSION} for Vercel Web build..."
  rm -rf "$FLUTTER_SDK_DIR"
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_SDK_DIR"
fi

git config --global --add safe.directory "$FLUTTER_SDK_DIR" || true
export PATH="$FLUTTER_SDK_DIR/bin:$PATH"

SUPABASE_URL="${SUPABASE_URL:-}"
PUBLIC_KEY="${SUPABASE_PUBLISHABLE_KEY:-${SUPABASE_ANON_KEY:-}}"

if [[ -z "$SUPABASE_URL" || -z "$PUBLIC_KEY" ]]; then
  echo "ERROR: SUPABASE_URL and SUPABASE_ANON_KEY (or SUPABASE_PUBLISHABLE_KEY) must be configured in Vercel project environment variables." >&2
  exit 1
fi

if [[ "$PUBLIC_KEY" == sb_secret_* || "$PUBLIC_KEY" == *service_role* ]]; then
  echo "ERROR: Refusing to embed a secret or service_role key into a Flutter Web client build." >&2
  exit 1
fi

APP_ENV="${APP_ENV:-dev}"
APP_NAME="${APP_NAME:-RITMA}"
ENABLE_DEBUG_LOGGING="${ENABLE_DEBUG_LOGGING:-false}"
ENABLE_DEMO_MODE="${ENABLE_DEMO_MODE:-false}"

flutter --version --suppress-analytics
flutter config --no-analytics --enable-web
flutter pub get --suppress-analytics

flutter build web --release \
  --base-href "/" \
  --suppress-analytics \
  --dart-define=APP_ENV="$APP_ENV" \
  --dart-define=APP_NAME="$APP_NAME" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$PUBLIC_KEY" \
  --dart-define=ENABLE_DEBUG_LOGGING="$ENABLE_DEBUG_LOGGING" \
  --dart-define=ENABLE_DEMO_MODE="$ENABLE_DEMO_MODE"

if [[ ! -f "build/web/index.html" ]] || ! grep -q '<base href="/">' "build/web/index.html"; then
  echo "ERROR: build/web/index.html missing or does not specify <base href=\"/\">." >&2
  exit 1
fi

if [[ ! -f "build/web/main.dart.js" ]]; then
  echo "ERROR: build/web/main.dart.js missing after release build." >&2
  exit 1
fi

echo "Verified Flutter Web release bundle at build/web (base-href /)."
