# Theeb Stream v2.1.0 release recovery

## Evidence

- The original `[release]` merge for `2.1.0+16` reached main but its release workflow failed in Android TV SDK setup because the runner attempted to install the removed legacy Android SDK `tools` package.
- PR #42 fixed that infrastructure drift by requesting `platform-tools` and preserving the Mobile, TV, and unsigned iOS build contracts.
- The exact PR head passed branch CI and the three platform build gates; the merged fix also passed the main build.

## Recovery strategy

This branch intentionally makes no runtime or version change. Its merge commit must contain `[release]` so the existing fail-closed release job rebuilds all three deliverables from the current healthy main lineage instead of reusing stale Actions artifacts.

Required release assets remain:

1. `Theeb-Stream-Android-Mobile-arm64-v8a.apk`
2. `Theeb-Stream-Android-TV.apk`
3. `Theeb-Stream-iOS-UNSIGNED-no-codesign.ipa`
4. `SHA256SUMS.txt`
5. `BUILD_PROVENANCE.txt`

The iOS package remains explicitly unsigned/no-codesign. Do not publish if version parity, any platform build, required asset verification, checksums, or provenance generation fails.

## Failure classification

Original failure: `INFRA_FAILURE` / GitHub runner Android SDK package drift.

Recovery: rebuild from the fixed lineage; do not rerun the known-bad release SHA and do not treat workflow artifacts as a GitHub Release.
