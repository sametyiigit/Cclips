#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="$ROOT_DIR/build/DerivedData"
ARCHIVE_DIR="$ROOT_DIR/build/Release"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="Cclips.app"
VOLUME_NAME="Cclips"
SIGNING_IDENTITY="${APP_SIGNING_IDENTITY:-}"

rm -rf "$DERIVED_DATA" "$ARCHIVE_DIR" "$DIST_DIR"
mkdir -p "$ARCHIVE_DIR" "$DIST_DIR"

xcodebuild \
  -project "$ROOT_DIR/Cclips.xcodeproj" \
  -scheme Cclips \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA" \
  build \
  CODE_SIGNING_ALLOWED=NO

APP_PATH="$DERIVED_DATA/Build/Products/Release/$APP_NAME"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing app bundle at $APP_PATH" >&2
  exit 1
fi

cp -R "$APP_PATH" "$ARCHIVE_DIR/"
APP_RELEASE_PATH="$ARCHIVE_DIR/$APP_NAME"

if [[ -n "$SIGNING_IDENTITY" ]]; then
  codesign --force --deep --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP_RELEASE_PATH"
else
  codesign --force --deep --sign - "$APP_RELEASE_PATH"
fi

ZIP_PATH="$DIST_DIR/Cclips-macOS.zip"
DMG_PATH="$DIST_DIR/Cclips-macOS.dmg"
STAGING_DIR="$DIST_DIR/dmg-root"

ditto -c -k --sequesterRsrc --keepParent "$APP_RELEASE_PATH" "$ZIP_PATH"

mkdir -p "$STAGING_DIR"
cp -R "$APP_RELEASE_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

rm -rf "$STAGING_DIR"

echo "Created release artifacts:"
echo "  $ZIP_PATH"
echo "  $DMG_PATH"
