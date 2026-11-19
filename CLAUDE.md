# Agent guidance

## Project

OpenLaunchpad is a native macOS 26+ launcher built with SwiftUI and AppKit. Open `Xcode-project/OpenLaunchpad.xcodeproj` with Xcode 26 or later and use the shared `OpenLaunchpad` scheme. The repository has an Xcode project, not the upstream Swift package or Makefile. Sparkle is resolved through Xcode's Swift Package Manager.

- `Xcode-project/LauncherCore/`: layout models, search, backup invariants, and pinch recognition.
- `Xcode-project/OpenLaunchpad/`: application lifecycle, SwiftUI views, scanning, persistence, system services, and integration checks.
- `Xcode-project/TrackpadBridge/`: optional, runtime-loaded private multitouch bridge; `CSQLite/` provides SQLite access.
- `Xcode-project/Resources/{en,es}.lproj/`: localized app and Info.plist strings.
- `Xcode-project/Info.plist` and `appcast.xml`: Sparkle configuration and update feed.

## Build and checks

Build and run the shared scheme on macOS with the macOS 26+ SDK. For command-line builds from the repository root:

```sh
xcodebuild -project Xcode-project/OpenLaunchpad.xcodeproj -scheme OpenLaunchpad -configuration Debug build
```

The app's `--self-test` argument runs `IntegrationChecks.run()` and exits with a nonzero status on failure. Run it from the built app bundle, for example `path/to/OpenLaunchpad.app/Contents/MacOS/OpenLaunchpad --self-test`. The checks use temporary fixtures but also inspect installed applications. The shared scheme currently has no configured test target; do not assume `swift test` or upstream's `make test` exists here.

The icon build phase references `scripts/make-icon.swift`, while the tracked file is `Scripts/Make-icon.swift`; this can fail on a case-sensitive filesystem. Check build-phase paths when changing the project or diagnosing a build failure. UI, gesture, and system integration changes also need appropriate manual testing on macOS hardware.

## Conventions and safety

- Keep layout invariants and reusable models in `LauncherCore`; keep AppKit and system integrations in the app target. When adding files or localizations, update the Xcode project and target membership as needed.
- Localize user-facing text using existing SwiftUI and `String(localized:)` patterns. Update Spanish resources and preserve format placeholders; do not translate stored preference values or user-provided names.
- Preserve `~/Library/Application Support/OpenLaunchpad/library.json` compatibility and backup/import validation. Use temporary directories and synthetic apps for destructive-operation checks; never test uninstall against real user applications.
- Keep private trackpad integration opt-in and fail gracefully when unavailable. Preserve the existing permission and system-app protections.
- Treat Sparkle signing keys and release credentials as secrets. Do not commit private keys; keep the feed, public key, versioning, signing, and notarization consistent when preparing releases.
- `DIFFERENCES.md` records the upstream comparison at specific revisions; update its baseline when refreshing the comparison.
