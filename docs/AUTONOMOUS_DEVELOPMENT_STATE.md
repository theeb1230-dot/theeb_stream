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


## تشغيل 2026-09-08 — فيدباك جهاز فعلي / 1.6.5

المستخدم اختبر النسخة على جهاز فعلي وقدم صورًا تثبت فجوة بين شاشة "حالة المصادر" والتشغيل الحقيقي:
- شاشة الصحة كانت تعتبر أي استجابة HTTP أقل من 500 نجاحًا، لذلك كانت الدومينات تظهر خضراء رغم فشل استخراج/تشغيل الفيديو.
- VidLink و2Embed كانا يتجاوزان `validateStream` في مسار Android/TV، ما يسمح لرابط منتهي/غير قابل للتشغيل بالفوز قبل ExoPlayer.
- Moflix/Community/Vidrock/Frembed كانت لها مستخرجات متخصصة موجودة في الكود لكن غير مسجلة في `extractorRegistry`.
- شاشة التوصيات كانت تخفي fallback الرائج عندما لا يوجد سجل مشاهدة، رغم أن `RecommendationService.getForYou()` يدعمه.
- cache التوصيات لم يكن يفصل الصفحات.
- زر الملف الشخصي/الأفاتار كان خطوة وسيطة غير لازمة في تطبيق بلا تسجيل دخول.
- شاشة المشغل كانت ما تزال تسرب `Status:` و`Failed to load stream` للمستخدم.

الفرع الحالي: `runtime/playback-recommendations-settings-1.6.5`
PR الحالي: `#39 [release] 1.6.5 runtime playback and recommendations reliability`

التغييرات المنفذة:
- زر ترس مباشر إلى الإعدادات بدل الأفاتار/القائمة الوسيطة.
- health check أصبح fail-closed: وصول الدومين وحده = "غير مؤكد"، والأخضر على Android يحتاج resolver فعلي ورابط بث صالح.
- تنظيف شاشة التشخيص من المستخرجات القديمة/غير المسجلة.
- تسجيل Moflix/Community/Vidrock/Frembed extractors على Android Mobile وAndroid TV.
- إلزام كل stream نهائي، بما في ذلك VidLink/2Embed، بفحص `validateStream`.
- إصلاح التوصيات كي تعرض trending fallback على التثبيت الجديد وتتحمل فشل TMDB جزئيًا وتفصل cache حسب الصفحة.
- تعريب رسائل فشل المشغل وعدم عرض raw exceptions للمستخدم.
- إضافة مولد هوية ذيب ستريم هندسية (ذئب + play/stream) وتوليد أصول الهاتف/TV/iOS أثناء CI.
- رفع النسخة إلى `1.6.5+13` ومزامنة Android TV.

### أهداف التشغيل التالي

1. انتظار CI/build لـ PR #39 على آخر head وإصلاح أي failure على نفس الفرع.
2. عند خضرة branch CI + Android Mobile + Android TV + iOS، دمج #39 بعنوان يحتوي `[release]`.
3. التحقق من triplet النهائي على main ونشر `v1.6.5` مع SHA256SUMS وBUILD_PROVENANCE.
4. اختبار فيدباك المستخدم التالي تحديدًا على محتوى كان يفشل: Health runtime result → resolver → player init → fallback server switching.
5. إذا بقي فشل تشغيل رغم أن health runtime أخضر، أضف playback-start confirmation/blacklist مؤقتة على مستوى media URL وليس domain فقط.
6. متابعة تحسين الشعار فقط إذا أثبتت معاينة المستخدم أن الهوية الجديدة تحتاج تعديل، دون لمس منطق التشغيل.


## اعتماد إصدار 2.0.0 — 2026-09-08

بناءً على اختبار الجهاز الفعلي وطلب المستخدم، تم تحويل دفعة runtime الحالية من 1.6.5 إلى الإصدار الرئيسي **2.0.0+14** بدل نشر 1.6.5.

الإضافات النهائية على نفس PR:
- version parity: Flutter `2.0.0+14` وAndroid TV `2.0.0 / 14`.
- اعتماد هوية ذئب/Play بلون Electric Cyan بدل الأحمر في مولد أصول الهاتف وTV وiOS.
- تعريب ما تبقى من رسائل تشغيل داخل المشغل وعدم تسريب أخطاء codec/server الخام للمستخدم.
- توصيات fresh-install أصبحت تملك fallback ثانوي من Trending إلى Popular عند تعطل عائلة endpoints الأولى.
- يبقى شرط الإصدار: branch CI + Mobile APK + TV APK + iOS UNSIGNED IPA كلها خضراء على آخر head، ثم الدمج برسالة [release] ونشر v2.0.0 من نفس commit.

### أهداف التشغيل التالي بعد دمج 2.0.0
1. التحقق من GitHub Release v2.0.0 والأصول الثلاثة وSHA256SUMS/BUILD_PROVENANCE.
2. إعادة اختبار المستخدم لمسار Health → resolver → player على نفس المحتوى الذي كان يفشل.
3. إذا استمر فشل runtime مع health أخضر، إضافة playback-start confirmation وblacklist مؤقتة على مستوى media URL.
4. اختبار التوصيات على تثبيت جديد وسجل مشاهدة فعلي.


### اكتشاف إضافي من اختبار iPhone — إصلاح قبل v2.0.0

تم اكتشاف أن `DirectM3u8Service` كان يرسل كل منصة غير Web إلى `NativeStreamExtractor`، بينما MethodChannel الخاص بالاستخراج موجود على Android فقط ولا يوجد له implementation في iOS. هذا يفسر حالة "فحص سليم ثم التشغيل يفشل" على iPhone.

تم الإصلاح:
- iOS يستخدم الآن `WebStreamService` عبر Cloudflare Worker بدل Android MethodChannel.
- iOS يقبل direct HLS فقط ويرفض embed-only URLs داخل native player.
- قائمة الخوادم على iOS تُبنى من محاولات resolver فعلية لكل server.
- شاشة حالة المصادر على iOS تستخدم نفس resolver الفعلي الذي يستخدمه التشغيل، لذلك الأخضر يعني بثًا مباشرًا قابلًا للاستخدام في مسار iOS وليس مجرد HTTP reachability.
