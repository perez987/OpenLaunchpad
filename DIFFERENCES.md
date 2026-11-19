# Differences from upstream

This is a snapshot comparison of upstream [`aadityaraaz/OpenLaunchpad`](https://github.com/aadityaraaz/OpenLaunchpad) `main` at `a06156103cfc9f277869e0d1b3ec265d85c65a84` and this fork at `d48bf7c017c2d273fb7a93455f78ff2fced3bbf0`. Either repository may have changed since then. This is a comparison of the trees, not a complete history or a claim that every launcher feature was added by the fork.

Both versions share the same native macOS launcher, core layout and search functionality, opt-in experimental trackpad gestures, and MIT license. The main differences are:

| Area | Upstream | This fork |
| --- | --- | --- |
| Build and layout | Swift package in `Sources/`, built with `make app` and shell scripts. | Xcode project at `Xcode-project/OpenLaunchpad.xcodeproj`; sources and native bridges live under `Xcode-project/`. |
| Updates | Manual checks against a configured HTTPS JSON release manifest; users review downloads. No third-party package dependencies. | Sparkle, resolved through Xcode's Swift Package Manager, uses the fork's `appcast.xml` and Ed25519 public key. Update checks are integrated into the app. |
| Languages | English UI. | English and Spanish resources, with English fallback. UI strings and related checks have been localized. |
| Validation | `make test` runs the standalone `CoreChecks` executable and the application's integration self-test. | The standalone core test target, `Package.swift`, Makefile, and test scripts are absent. `IntegrationChecks.swift` remains available through the app's `--self-test` argument and includes localization and Sparkle configuration checks. The shared Xcode scheme has no configured test target. |
| Preview distribution | README describes v0.1.0, Apple silicon only, ad-hoc signed and not notarized. | README describes v0.1.8 for Apple silicon and Intel, distributed as a notarized DMG. The fork contains an appcast entry for that release. These are release descriptions, not guarantees about future builds. |
| Documentation and assets | Changelog, feature/validation/audit documents, release notes, and screenshots under `docs/`. | Those upstream documents and packaging scripts are not in the current tree; screenshots are under `Images/`. |

Most of the existing launcher functionality is common to both snapshots; many Swift changes also reflect reformatting and localization rather than wholly new features. The fork's Sparkle configuration and appcast do not by themselves guarantee that future releases are correctly signed, notarized, or deliverable.
