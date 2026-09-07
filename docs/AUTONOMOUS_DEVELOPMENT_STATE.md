# Autonomous Development State — Theeb Stream

آخر تحديث: 2026-09-07
المستودع: `theeb1230-dot/theeb_stream`

## الحالة الفعلية

- الفرع المرجعي: `main`
- آخر main: `2a6337c88b5b07ad4b47682fae388df7df2aabc5`
- آخر PR منجز: `#37 [release] Theeb Stream 1.6.3 parity and provenance`
- الإصدار المنشور الحالي: `v1.6.3`
- `v1.6.3` يشير إلى نفس commit `2a6337c...`.
- نسخة المشروع الموحدة: `1.6.3+11`.
- Android TV: `versionName 1.6.3` و`versionCode 11`.
- iOS IPA الحالية `UNSIGNED/no-codesign` وليست قابلة للتثبيت المباشر دون توقيع وprovisioning صالحين خارجيًا.

## ما اكتُشف وأُصلح في هذه الجولة

1. كان `pubspec.yaml` عند `1.6.2+10` بينما Android TV بقي عند `1.6.0 / 8`. تم توحيد version/build parity على `1.6.3+11`.
2. كان README يوثق إصدارًا قديمًا، وتمت مزامنته.
3. كان هناك ناشران آليان يمكن أن يتسابقا على نفس tag:
   - `.github/workflows/release.yml`
   - `.github/workflows/build.yml`
   تم جعل `release.yml` manual-dispatch فقط، واعتماد `build.yml` كالمسار الآلي الصارم للـrelease.
4. أضيف فحص version parity قبل النشر.
5. أضيف `BUILD_PROVENANCE.txt` مع `SHA256SUMS.txt` إلى Release والتحقق من ظهورهما.
6. أُعيد إنشاء ملف handoff على `main` بعد أن كان مفقودًا.

## CI / Build Evidence

PR #37:
- Theeb Stream branch CI: success.
- Android Mobile build: success.
- Android TV build: success.
- iOS unsigned/no-codesign build: success.
- Release publish job داخل PR: skipped كما هو متوقع لأنه ينشر فقط بعد push إلى main.

دورة main النهائية:
- Workflow run: `34157869465`
- Commit: `2a6337c88b5b07ad4b47682fae388df7df2aabc5`
- Android Mobile: success.
- Android TV: success.
- iOS unsigned IPA: success.
- Publish GitHub Release: success.

## GitHub Release v1.6.3

الرابط: https://github.com/theeb1230-dot/theeb_stream/releases/tag/v1.6.3

الأصول:
- `Theeb-Stream-Android-Mobile-arm64-v8a.apk`
  - SHA-256: `fe5840c5dd8e91802b4528075ad5b3fd6d88ffd9e56d627895ef56ed96085932`
- `Theeb-Stream-Android-TV.apk`
  - SHA-256: `ecf1057a76728604bcb86dcfac2fb69b26d719949846dc61b8b754b3a5b41379`
- `Theeb-Stream-iOS-UNSIGNED-no-codesign.ipa`
  - SHA-256: `2083c2d21cd16193ea5cb3829b43b387b024a9bf582713bd2a92542d96c73847`
- `SHA256SUMS.txt`
- `BUILD_PROVENANCE.txt`

## Release Readiness

الحالة: **Developer/Experimental متقدم، وليست Golden مثبتة بالكامل**.

المثبت:
- analyze/tests على PR أخضر.
- الحزم الثلاث من نفس commit/version.
- tag `v1.6.3` يطابق نفس commit.
- Android Mobile وTV وiOS no-codesign builds ناجحة.
- checksums + provenance منشورة.

غير مثبت بما يكفي لـ Golden:
- iOS signed/provisioned installable IPA.
- device E2E شامل على Android Mobile وAndroid TV وiPhone.
- تثبيت وتشغيل فعلي موثق للحزم النهائية على الأجهزة المستهدفة.
- soak/stress/recovery أوسع لمسارات البحث والمشاهدة.

## أهداف التشغيل التالي

1. فحص runtime للبحث والمشاهدة بعد hotfix 1.6.2/1.6.3 بحثًا عن regressions حقيقية بدل تغييرات تجميلية.
2. فحص Android TV focus/D-Pad والـplayer lifecycle مع العودة من التفاصيل والمشغل.
3. مراجعة TODO/FIXME/dead code والاعتماديات غير المستخدمة بعد إزالة login/auth remnants.
4. إضافة اختبارات regression لمسار Search → Details → Playback fallback حيث توجد فجوات مثبتة.
5. فحص التوقيع الفعلي لـAndroid artifacts إن توفرت secrets في run، وعدم ادعاء signed بدون دليل.
6. الحفاظ على دورة triplet + Release لكل دفعة release-worthy لاحقة، مع version/tag جديدين.
