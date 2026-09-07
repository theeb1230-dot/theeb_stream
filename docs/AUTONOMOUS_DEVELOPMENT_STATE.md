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

## Verified state
- Android Mobile, Android TV, and iOS no-codesign jobs completed successfully in run 34011511558.
- iOS output is UNSIGNED/no-codesign and is not directly installable without valid Apple signing and provisioning.
- Android TV manifest has LEANBACK_LAUNCHER, requires android.software.leanback, and is landscape.
- The public v1.6.2 release uses provisional asset names and does not prove release-key Android signing.
- Signing steps in the successful build were skipped because repository signing secrets were unavailable.

## Active high-value work
1. Make Android TV versionName/versionCode derive from pubspec.yaml to prevent version drift.
2. Replace duplicate/provisional release publishing with one strict fail-closed pipeline that requires Android signing secrets, verifies both APKs with apksigner, runs analyze/tests, builds all three platforms from one commit, computes SHA-256, and publishes exact final asset names.
3. Bootstrap a durable Android release key through GitHub, then add KEYSTORE_BASE64, KEYSTORE_PASSWORD, KEY_ALIAS, and KEY_PASSWORD as repository Actions secrets.
4. Continue Arabic/RTL and identity audits without changing package/application IDs unless necessary.

## Release blocker
There is no current evidence that Android release signing secrets exist. A final signed Android release must remain blocked until they are configured and apksigner verification succeeds.

## أهداف التشغيل التالي
1. Validate and land the TV version parity fix after CI is green.
2. Unify the strict release workflow and remove the competing publisher.
3. Restore the GitHub-only signing bootstrap workflow and complete the minimum human secret-entry step.
4. Bump the next version only after the strict release path is on main, then run one same-commit triplet release and verify exact assets plus SHA-256.
5. Resume visible Arabic/RTL and legacy identity scans after release integrity is fail-closed.
