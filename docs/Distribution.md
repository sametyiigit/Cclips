# Distribution Guide

This project supports two release modes:

## 1. Unsigned GitHub Release

Good for:
- fast public testing
- internal sharing
- first public releases before Apple signing is configured

Command:

```bash
zsh scripts/build-release.sh
```

Output:
- `dist/Cclips-macOS.zip`
- `dist/Cclips-macOS.dmg`

Note:
- macOS may warn on first launch because the app is not notarized

## 2. Signed + Notarized Release

Good for:
- smoother first-launch experience
- distribution to broader non-technical users

Required locally or in CI:
- Developer ID Application certificate installed in Keychain
- `APP_SIGNING_IDENTITY`
- `APPLE_ID`
- `APPLE_APP_PASSWORD`
- `APPLE_TEAM_ID`

Command:

```bash
APP_SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
APPLE_ID="you@example.com" \
APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
APPLE_TEAM_ID="TEAMID" \
zsh scripts/notarize-release.sh
```

What the script does:
- builds the Release app
- signs the app bundle
- submits the ZIP to Apple notarization
- staples the notarization ticket to the app
- rebuilds the final ZIP and DMG

## GitHub Actions Secrets

To upgrade the workflow from ad-hoc to signed/notarized builds, configure these secrets:
- `APP_SIGNING_IDENTITY`
- `APPLE_ID`
- `APPLE_APP_PASSWORD`
- `APPLE_TEAM_ID`
- optional certificate import secrets if you want CI-side certificate installation

## Suggested Release Process

1. Merge changes into `main`
2. Tag a version like `v1.0.0`
3. Push the tag
4. Confirm the GitHub Actions run finishes
5. Check the Release page assets
