# Cclips

Cclips is a lightweight, native clipboard manager for macOS built with SwiftUI and SwiftData. It automatically saves what you copy, lets you search clipboard history instantly, and keeps important clips pinned and ready to reuse.

## Highlights

- Persistent clipboard history for text, links, colors, and images
- Instant search across titles, contents, and source apps
- Global shortcuts for opening history and advancing the paste stack
- Smart collections for Links, Images, Colors, and Pinned clips
- Menu bar access with recent-history actions
- Clean local link detection without extra web renderer noise
- Privacy controls to ignore password managers and custom apps
- Sequential paste stack for queued or pinned clips

## Requirements

- macOS 14 Sonoma or later
- Xcode 15 or later for building and running the app bundle

## Keyboard Shortcuts

- `Shift-Command-V`: Open or hide the main clipboard window
- `Shift-Command-C`: Paste the next item from the paste stack

## Install

1. Open the latest release from the GitHub `Releases` page.
2. Download `Cclips-macOS.dmg`.
3. Drag `Cclips.app` into `Applications`.
4. Launch Cclips like any other Mac app.

Note:
- GitHub builds are ad-hoc signed, not notarized.
- On first launch macOS may ask you to confirm opening the app.
- If needed, use `Right click > Open` once.

## Build From Source

1. Open [Cclips.xcodeproj](/Users/sametyigit/Desktop/Cclips/Cclips.xcodeproj/project.pbxproj) in Xcode.
2. Choose the `Cclips` app target.
3. Run the app on macOS.

You can also build from Terminal:

```bash
xcodebuild -project Cclips.xcodeproj -scheme Cclips -configuration Debug build
```

To create release artifacts locally:

```bash
chmod +x scripts/build-release.sh
scripts/build-release.sh
```

This generates:
- `dist/Cclips-macOS.dmg`
- `dist/Cclips-macOS.zip`

## Architecture

- `SwiftData` persists clipboard entries locally
- `PasteboardWatcher` polls `NSPasteboard` for changes
- `ClipboardStore` deduplicates clips, manages search/filtering, and handles paste actions
- `LinkMetadataService` keeps link metadata local and lightweight
- `HotKeyManager` registers global Carbon shortcuts for history and paste-stack access

## Privacy Notes

Cclips stores your clipboard history locally on-device. By default, it ignores several common password manager apps, and you can add more bundle identifiers from Settings.

## GitHub Releases

The repository includes a GitHub Actions workflow at [.github/workflows/release.yml](/Users/sametyigit/Desktop/Cclips/.github/workflows/release.yml).

How it works:
- Push a tag like `v1.0.0`
- GitHub Actions builds the app on macOS
- The workflow produces a `.dmg` and `.zip`
- Those files are attached to the GitHub release automatically

## Roadmap

- Better image metadata and file-copy support
- User-configurable hotkeys
- Export/import and iCloud sync
- Rich previews for more clipboard content types
