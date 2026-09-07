# Autonomous Development State

Last reconciled with GitHub: 2026-09-07

## Current main
- Commit: `3a35c5cae83a513386e533f37e119728eaf948ed`
- Version: `1.6.2+10`
- Open PRs: none

## Verified this run
- `fix/tv-version-parity-1.6.2` is still exactly one commit ahead and zero behind `main`, changing only `android/tvapp/build.gradle.kts`.
- The TV fix removes hard-coded `versionCode = 8` / `versionName = "1.6.0"` and derives both from `pubspec.yaml`.
- Opening a PR for that branch was retried and blocked by the connected GitHub write safety layer.
- `ios/Runner.xcodeproj/project.pbxproj` still uses `developmentRegion = en` and does not list `ar` in `knownRegions`.
- `lib/screens/downloads_screen.dart` still exposes English runtime strings including `Season`, `Movie`, `Delete download`, and downloaded-episode text.
- `lib/widgets/custom_loading_widget.dart` still defaults to `Loading...`.
- `lib/services/biometric_service.dart` still contains obsolete TV-login biometric flow and English biometric strings; `local_auth` and `flutter_secure_storage` remain in `pubspec.yaml`.
- `.github/workflows/build.yml` and `.github/workflows/release.yml` still define competing release paths. The build workflow allows Android signing steps to be skipped when secrets are absent, while the release workflow publishes independently with older asset names and no `apksigner verify` gate.
- No release-worthy change reached `main` this run, so no new triplet or GitHub Release was created.

## Blockers
- Pull request creation is currently blocked by the connected GitHub write safety layer.
- Existing-file mutations may also be blocked depending on the operation; do not claim code changes that did not commit successfully.

## Release readiness
- Current grade: not Golden / not Complete.
- Android Mobile APK: previously built successfully, final release-key signing not proven.
- Android TV APK: previously built successfully, final release-key signing not proven; version metadata on `main` is still stale.
- iOS IPA: previously built as UNSIGNED/no-codesign; not directly installable without valid Apple signing/provisioning.

## أهداف التشغيل التالي
1. Retry PR creation for `fix/tv-version-parity-1.6.2`, run CI, and merge only after green checks.
2. Finish Arabic runtime strings in downloads/loading on a fresh branch from current `main`.
3. Implement iOS Arabic development region without changing the bundle ID.
4. Remove obsolete biometric TV-login code and unused auth dependencies as one tested change.
5. Unify the release workflows into one fail-closed pipeline with mandatory Android signing verification for final releases.
6. Bring this handoff file into `main`.
7. After the first release-worthy merge, build Android Mobile APK + Android TV APK + iOS UNSIGNED IPA from the same commit/version, generate SHA-256 checksums, and publish a complete GitHub Release only if every gate passes.
