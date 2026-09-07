# Autonomous Development State — Theeb Stream

آخر تحديث: 2026-09-07
المستودع: `theeb1230-dot/theeb_stream`

## الحالة الفعلية

- الفرع المرجعي: `main`
- آخر main/release commit: `342c09e66973e51a5bd2f2143ffc90969ea4377f`
- آخر PR منجز: `#38 Cleanup 1.6.4: remove obsolete auth runtime dependencies`
- الإصدار المنشور الحالي: `v1.6.4`
- رابط الإصدار: https://github.com/theeb1230-dot/theeb_stream/releases/tag/v1.6.4
- نسخة المشروع الموحدة: `1.6.4+12`
- Android TV: `versionName 1.6.4` و`versionCode 12`
- iOS IPA الحالية `UNSIGNED/no-codesign` وليست قابلة للتثبيت المباشر دون توقيع وprovisioning صالحين خارجيًا.

## ما فُحص في هذه الجولة

- main وجميع branches والـPRs وأحدث commits.
- GitHub Actions والـruns وحالة required checks.
- handoff السابق وأهداف التشغيل التالي.
- Search / Details / Playback fallback الحالية بحثًا عن regressions ظاهرة.
- بقايا auth/login runtime dependencies.
- `pubspec.yaml` وAndroid TV version parity.
- حالة GitHub Releases والأصول المنشورة.

## المشكلة المكتشفة والإصلاح

كانت هناك بقايا مصادقة ميتة بعد إلغاء تسجيل الدخول:
- `lib/services/biometric_service.dart` ما زال موجودًا ويستورد `local_auth`.
- `local_auth` و`flutter_secure_storage` و`encrypt` بقيت dependencies مباشرة بلا استخدام فعلي في الكود الحالي.

تم في PR #38:
- حذف `lib/services/biometric_service.dart`.
- إزالة `local_auth`.
- إزالة `flutter_secure_storage`.
- إزالة `encrypt`.
- رفع Flutter version إلى `1.6.4+12`.
- توحيد Android TV إلى `1.6.4 / 12`.

## CI / Build Evidence

PR #38:
- CI run: `34158896476` — success.
- Build run: `34158896463` — success.
- release-facing identity/login audit: success.
- flutter analyze: success.
- flutter tests: success.
- Android Mobile APK build: success.
- Android TV APK build: success.
- iOS unsigned/no-codesign IPA build: success.

دورة الإصدار على main:
- Release build run: `34159610978` — success.
- Commit/tag source: `342c09e66973e51a5bd2f2143ffc90969ea4377f` / `v1.6.4`.
- Version parity validation: success.
- Required release assets verification: success.
- GitHub Release publish: success.
- Published release asset verification: success.

ملاحظة توقيع:
- خطوات Android keystore/signing كانت skipped لأن Secrets التوقيع غير متوفرة في هذه الجولة؛ لذلك لا يُدّعى أن Android artifacts موقعة بتوقيع release مُثبت.
- iOS IPA غير موقعة صراحة.

## GitHub Release v1.6.4

الرابط: https://github.com/theeb1230-dot/theeb_stream/releases/tag/v1.6.4

الأصول:
- `Theeb-Stream-Android-Mobile-arm64-v8a.apk`
- `Theeb-Stream-Android-TV.apk`
- `Theeb-Stream-iOS-UNSIGNED-no-codesign.ipa`
- `SHA256SUMS.txt`
- `BUILD_PROVENANCE.txt`

## Release Readiness

الحالة: **Developer/Experimental متقدم، وليست Golden مثبتة بالكامل**.

المثبت:
- analyze/tests خضراء.
- Mobile/TV/iOS no-codesign builds ناجحة.
- version/build parity موحدة.
- triplet منشور من نفس release commit/tag.
- checksums + provenance منشورة ومتحقق من ظهورها.

غير مثبت بما يكفي لـ Golden:
- Android release signature موثق عبر apksigner أو ما يعادله.
- iOS signed/provisioned installable IPA.
- device E2E شامل على Android Mobile وAndroid TV وiPhone.
- soak/stress/recovery أوسع لمسارات البحث والمشاهدة.

## أهداف التشغيل التالي

1. فحص runtime لمسار Search → Details → Playback fallback وإضافة regression tests عند أي فجوة مثبتة، خصوصًا cancellation/timeouts وإعادة المحاولة.
2. فحص Android TV D-Pad/focus والعودة من Details/Player وحالات lifecycle/reconnect.
3. مراجعة بقية dependencies المباشرة غير المستخدمة بحذر، خصوصًا plugins الأصلية، دون حذف اعتماد مستخدم فعليًا.
4. تحسين تعريب رسائل التنزيل وحالات الخطأ الثانوية المتبقية.
5. التحقق من Android signing عندما تتوفر Secrets وعدم وصف APK بأنه signed دون apksigner evidence.
6. الحفاظ على triplet + GitHub Release لكل دفعة release-worthy لاحقة.


## تحديث الجولة الحالية
- فرع العمل: localization/arabic-native-cleanup-1.6.5
- تم تعريب بقايا شاشة التنزيل ونص التحميل الافتراضي، وضبط iOS developmentRegion إلى ar مع إضافة ar إلى knownRegions.
- الفرع أمام main باثنين commits وخلفه بصفر.
- فتح PR محجوب حاليًا، لذلك لم يبدأ PR CI ولم يحصل merge أو Release جديد.

## أهداف التشغيل التالي
1. فتح PR واحد للفرع الحالي.
2. تشغيل CI وفحص analyze/tests وMobile/TV/iOS.
3. توحيد version إلى 1.6.5+13 قبل الدمج.
4. بعد الدمج إنتاج triplet ونشر v1.6.5 فقط إذا نجحت الحزم الثلاث.
