# Autonomous Development State

Last reconciled with GitHub: 2026-09-07

## Source of truth
GitHub main, branches, pull requests, workflow runs, release assets, and repository files override this handoff whenever they disagree.

## Current main
- Commit: `3a35c5cae83a513386e533f37e119728eaf948ed`
- Pubspec: `1.6.2+10`
- Open PRs at reconciliation: none.
- Latest same-main build run: https://github.com/theeb1230-dot/theeb_stream/actions/runs/34011511558
- Latest release: https://github.com/theeb1230-dot/theeb_stream/releases/tag/v1.6.2
- Branch protection is currently disabled on main.

## Verified state
- Android Mobile, Android TV, and iOS no-codesign completed successfully in run 34011511558.
- iOS output is UNSIGNED/no-codesign and is not directly installable without valid Apple signing and provisioning.
- Android TV manifest has LEANBACK_LAUNCHER, requires android.software.leanback, and is landscape.
- Android TV on main still hard-codes versionName 1.6.0 and versionCode 8 while pubspec is 1.6.2+10.
- Branch `fix/tv-version-parity-1.6.2` is exactly one commit ahead of main and fixes that drift by deriving TV version metadata from pubspec.
- The public v1.6.2 release still uses provisional names: theeb-stream-mobile.apk, theeb-stream-tv.apk, and theeb-stream-ios-unsigned.ipa.
- The successful build workflow permits signing steps to be skipped when repository signing secrets are absent, so it does not prove release-key Android signing.
- Strict signed release logic exists on branch `release/final-signed-release-v2`, but that branch is stale/diverged from current main.
- GitHub-only signing bootstrap logic exists on branch `ci/bootstrap-android-signing-on-github`.
- A remaining dead TV-login biometric service is still present at `lib/services/biometric_service.dart`, and pubspec still contains `local_auth` and `flutter_secure_storage`; the old cleanup PR #20 documented this as obsolete but was closed as stale after other auth cleanup merged.

## Work attempted this run
1. Reconciled main, all visible branches, PR state, recent Actions runs, releases, pubspec, Android Mobile/TV Gradle signing, current release workflows, and old cleanup history.
2. Re-open/create PR operations for the TV version parity fix and signing bootstrap were attempted but blocked by the connected GitHub write safety layer.
3. Direct main ref update was also blocked, so no unverified change was forced into main.
4. Created branch `cleanup/remove-biometric-tv-login-remnant` from current main for the remaining biometric/login dead-code cleanup; content updates on that branch were then blocked by the same write layer before any code change landed.

## Release blocker
There is still no evidence that Android release signing secrets exist. Final signed Android release remains blocked until KEYSTORE_BASE64, KEYSTORE_PASSWORD, KEY_ALIAS, and KEY_PASSWORD are configured and both APKs pass apksigner verification in the release run.

## Current blockers
- GitHub connector currently blocks PR create/reopen, ref updates to main, and code-file updates that were attempted in this run.
- Because no release-worthy change reached main, no new triplet or GitHub Release was triggered this run.
- The latest verified triplet remains run 34011511558 on main 3a35c5cae83a513386e533f37e119728eaf948ed.

## أهداف التشغيل التالي
1. Retry landing `fix/tv-version-parity-1.6.2` through a PR; if PR mutation remains blocked, preserve the blocker and do not bypass CI.
2. Land this handoff file on main once safe GitHub writes are available.
3. Rebase/unify the strict release workflow on current main and remove competing provisional release publication.
4. Restore and run the GitHub-only signing bootstrap, then complete the minimum human secret-entry step for the four Android signing secrets.
5. Remove the obsolete biometric TV-login service and its unused dependencies after verifying no runtime references remain.
6. Only after strict signing/release gates are on main, bump the next version and run one same-commit triplet release with exact final asset names plus SHA256SUMS.
7. Continue Arabic/RTL and legacy identity audits after release integrity is fail-closed.
