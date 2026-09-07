# Autonomous Development State — Theeb Stream

آخر تحديث: 2026-09-07
المستودع: `theeb1230-dot/theeb_stream`

## الحالة الفعلية

- الفرع المرجعي: `main`
- آخر main قبل هذه الجولة: `3a35c5cae83a513386e533f37e119728eaf948ed`
- الإصدار المنشور الحالي قبل هذه الجولة: `v1.6.2`
- `v1.6.2` يشير إلى نفس commit أعلاه ويحتوي Android Mobile APK وAndroid TV APK وiOS unsigned IPA.
- iOS IPA الحالية غير موقعة/no-codesign ولا تُعد قابلة للتثبيت المباشر دون توقيع وprovisioning صالحين خارجيًا.
- لم يكن ملف handoff موجودًا على `main` عند بداية الجولة، ولذلك أُعيد إنشاؤه هنا.

## ما اكتُشف في الجولة الحالية

1. `pubspec.yaml` كان عند `1.6.2+10` بينما Android TV بقي عند `1.6.0` و`versionCode 8`، وهو خرق لـ version/build parity.
2. `README.md` كان ما يزال يوثق `1.6.0+8`.
3. يوجد مساران أوتوماتيكيان للإصدار:
   - `.github/workflows/release.yml` ينشر عند تغيير `pubspec.yaml`.
   - `.github/workflows/build.yml` ينشر عند commit على main يحتوي `[release]`.
   هذا يسمح بسباق على نفس tag وإصدار ناقص أو فشل أحد الناشرين.
4. Release `v1.6.2` يحتوي الحزم الثلاث لكنه لا يحتوي `SHA256SUMS.txt` أو ملف provenance مستقل.

## التغييرات قيد التنفيذ

الفرع: `release/1.6.3-parity-and-provenance`

- رفع النسخة الموحدة إلى `1.6.3+11`.
- ضبط Android TV على `versionName 1.6.3` و`versionCode 11`.
- تحديث README إلى `1.6.3+11`.
- تحويل `release.yml` إلى manual dispatch فقط لمنع ازدواج النشر الآلي.
- تشديد `build.yml` لفحص version parity قبل النشر.
- إضافة `BUILD_PROVENANCE.txt` إلى GitHub Release والتحقق منه مع `SHA256SUMS.txt`.

## Release Readiness

الحالة: **Developer/Experimental متقدم، وليست Golden مثبتة بالكامل**.

المثبت بالأدلة حتى بداية هذه الجولة:
- `v1.6.2` منشور من commit `3a35c5c...`.
- Android Mobile/TV/iOS builds نجحت في GitHub Actions لذلك commit.
- iOS artifact unsigned/no-codesign.

غير مثبت بما يكفي لوصف Golden:
- توقيع/تثبيت iOS فعلي.
- device E2E شامل على الأجهزة المستهدفة.
- تحقق نهائي من الإصدار الجديد 1.6.3 بعد الدمج والنشر.

## أهداف التشغيل التالي

1. إكمال CI على PR الخاص بـ 1.6.3 وإصلاح أي failure على نفس الفرع.
2. دمج PR فقط بعد نجاح branch CI والبناء الثلاثي.
3. بعد الدمج التحقق من تشغيل دورة triplet على نفس commit الجديد.
4. التحقق من نشر `v1.6.3` مع:
   - Android Mobile APK
   - Android TV APK
   - iOS UNSIGNED/no-codesign IPA
   - `SHA256SUMS.txt`
   - `BUILD_PROVENANCE.txt`
5. التحقق أن tag يشير إلى نفس commit وأن version/build parity صحيحة.
6. بعد نجاح الإصدار، فحص أعلى فجوة runtime حقيقية في البحث/المشاهدة/TV focus بدل تغييرات تجميلية.
