#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

: "${APP_SIGNING_IDENTITY:?Set APP_SIGNING_IDENTITY to your Developer ID Application identity.}"
: "${APPLE_ID:?Set APPLE_ID to your Apple Developer account email.}"
: "${APPLE_APP_PASSWORD:?Set APPLE_APP_PASSWORD to an app-specific password.}"
: "${APPLE_TEAM_ID:?Set APPLE_TEAM_ID to your Apple Developer team ID.}"

APP_SIGNING_IDENTITY="$APP_SIGNING_IDENTITY" zsh "$ROOT_DIR/scripts/build-release.sh"

ZIP_PATH="$ROOT_DIR/dist/Cclips-macOS.zip"
APP_PATH="$ROOT_DIR/build/Release/Cclips.app"
DMG_PATH="$ROOT_DIR/dist/Cclips-macOS.dmg"
STAGING_DIR="$ROOT_DIR/dist/dmg-root"

xcrun notarytool submit \
  "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --password "$APPLE_APP_PASSWORD" \
  --team-id "$APPLE_TEAM_ID" \
  --wait

xcrun stapler staple "$APP_PATH"

rm -f "$ZIP_PATH" "$DMG_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

mkdir -p "$STAGING_DIR"
cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "Cclips" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

rm -rf "$STAGING_DIR"

echo "Notarized release artifacts:"
echo "  $ZIP_PATH"
echo "  $DMG_PATH"
