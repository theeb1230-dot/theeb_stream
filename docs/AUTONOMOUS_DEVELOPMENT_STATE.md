# Autonomous Development State — Theeb Stream

## تشغيل 2026-09-18 — متابعة PR #55: Back trap + source truth

- exact main ما زال `fac694aad540dbb231455a7fff851b05e2178271`; PR #55 هو المفتوح الوحيد، لذلك كل العمل بقي على `p0/player-server-truth-back-2.1.3`.
- أثناء انتظار بوابات head السابق ظهر route trap فعلي في player: `PopScope(canPop: false)` كان يعترض platform Back ويستدعي pop يدويًا، وهو غير مناسب لمطلب Android system Back / Android TV remote Back / iOS gesture. تم تحويله إلى `canPop: true` مع cleanup idempotent بعد pop، بينما `_exitPlayer()` المرئي ما زال يحفظ progress قبل الخروج.
- أضيف `test/player_back_navigation_contract_test.dart` لقفل platform Back وعدم رجوع `canPop:false`، وللتأكد أن modal server/quality/subtitle routes تغلق أولًا وأن explicit exit يبقى idempotent.
- أي خضرة للـhead السابق `45bc27c...` أصبحت غير قابلة للتوريث بعد تغيير head؛ يجب انتظار Branch CI + Mobile + TV + iOS على exact head الجديد فقط.
- صور المستخدم ما زالت baseline: 0 Server و0 Extractor مثبتان player-start فعليًا. Registry: 27 total / 5 runtime overlaps / 22 net-new pending.
- source picker في #55 يفصل `بدأ فعليًا` عن `رابط مستخرج`، وresolver retry يبقى fail-closed.
- direct search لم يتغير: TMDB `/search/multi` + `include_adult=false` + `language=ar-SA`; Theeb Engine غير مربوط بلا production HTTPS مثبت.
- buffering watchdog على main: ~12s + last stable position + failed server + failed media URL session guard.
- version/tag: `2.1.3+19` / `v2.1.3`; لا Release جديد قبل دمج دفعة مثبتة.

### أهداف التشغيل التالي

1. افحص exact head لـ#55 بعد تحديث السجل، ثم Branch CI وMobile/TV/iOS لهذا الـSHA وحده؛ أصلح failures من logs دون rerun أعمى.
2. إذا خضر exact head وأصبح PR mergeable بلا blocker، ادمج expected-head فورًا وأعد قراءة main.
3. بعد الدمج دقق source-health screen counters/groups والنصوص الخمس: بدأ فعليًا/رابط مستخرج/فشل/غير مؤكد-WebView/غير مدعوم.
4. وسع widget/runtime Back evidence للـloading/error/server picker/quality/subtitle وTV focus restoration.
5. لا ترق أيًا من 22 net-new إلى working دون resolver مسموح + player-start progress evidence.

---


## تشغيل 2026-09-18 — دمج PR #54 وبدء PR #55

- exact main بعد دمج #54: `fac694aad540dbb231455a7fff851b05e2178271`. تم دمج #54 باستخدام expected head `d67d4b8def4829a3c74619c72d2d33409c9f5650` بعد نجاح Branch CI #220 وBuild #218 على exact head نفسه؛ Mobile APK وTV APK وiOS UNSIGNED/no-codesign كلها success. Android signing steps بقيت skipped.
- PR الحالي الوحيد: #55 `fix: make player server status fail-closed` على `p0/player-server-truth-back-2.1.3`. head قبل تحديث هذا السجل: `8bcca9a4026245deccdc1030b19ee2d4ef40fc7d`.
- P0 جديد مقفل برمجيًا في player server picker: non-empty URL لم يعد يعني نجاحًا. الحالة `بدأ فعليًا` تتطلب selected player initialized مع position > 0؛ الرابط غير المشغل يظهر `رابط مستخرج · لم يبدأ التشغيل بعد`، والفشل/عدم التأكد يبقى واضحًا.
- retry resolver يبقى fail-closed: `available=false` و`playbackStatus=url_extracted` حتى إثبات player start، مع regression test `player_server_truthfulness_contract_test.dart`.
- صور المستخدم ما زالت الدليل الميداني: 0 Server و0 Extractor مثبتان كبث بدأ فعليًا. Canonical inventory: 27 total / 5 runtime overlaps / 22 net-new pending، ولا ترقية إلى working من URL/HTTP/resolver فقط.
- direct search: TMDB `/search/multi`, `include_adult=false`, `language=ar-SA`; Theeb Engine غير مربوط بلا production HTTPS endpoint مثبت ومصرح.
- navigation/back: Movie/Series/Player coverage البرمجية موجودة؛ device E2E وTV remote focus restoration ما زالا مطلوبين.
- buffering fallback: ~12s watchdog + last stable position + failed server identity + session failed-media-URL blacklist موجودة الآن على main عبر #54.
- version يبقى `2.1.3+19`; لا Release جديد لهذه الدفعة حتى اكتمال بوابات PR #55 وتحديد release-worthiness.

### أهداف التشغيل التالي

1. فحص exact head الجديد لـ#55 وقراءة Branch CI + Mobile/TV/iOS؛ إصلاح أي failure من logs على نفس الفرع فقط.
2. دمج #55 فقط عند خضرة exact-head الكاملة والـmergeability باستخدام expected head SHA، ثم إعادة قراءة main.
3. توسيع Back regression للـserver picker/quality/subtitle dialogs/fullscreen/loading/error وTV remote Back/focus restoration.
4. مراجعة شاشة حالة المصادر والعدادات لضمان أن displayed groups/counts تطابق العناصر ولا يوجد `0/35` أو نجاح مبني على URL فقط.
5. إبقاء 22 net-new pending حتى contract/resolver مسموح + player-start progress evidence.
6. الاستمرار في RTL/Arabic/dead-code/security cleanup بعد P0 دون تغيير package/bundle IDs تجميليًا.

---


## تشغيل 2026-09-18 — PR #54 / session media URL loop guard

- exact main عند بداية التشغيل: `35d54fa09a49d6ddbb5ad8077866e778eaabe288`.
- PR المفتوح الوحيد: `#54 fix: fail closed unresolved web and iOS stream health` على `reliability/session-media-url-loop-guard`.
- exact head بعد إصلاحات هذا التشغيل: `b820c3a7f55f6dbf20fdffc7df2bb0945b163529`.
- commits الجديدة: `0e9e91bb3ba1a872bcce964a85d167e216b94ab9` لمنع إعادة media URL الفاشل داخل الجلسة، ثم `b820c3a7f55f6dbf20fdffc7df2bb0945b163529` لاختبار regression.
- Branch CI على head السابق `70702ba409dee864288fd9963edd86b8bb41849d`: run `35389158807` success. Build run `35389158880`: TV APK success عند الفحص، Mobile APK وiOS UNSIGNED كانا ما زالا in-progress. لا تورث هذه الخضرة إلى head الجديد.
- صور اختبار المستخدم السابقة ما زالت الدليل الحاكم: 0 بث صالح فعليًا مثبت في Servers و0 في Extractors؛ لا يعتبر reachability/HTTP 200/extracted URL نجاح تشغيل.
- source-health يبقى fail-closed. PR #54 يمنع web/embed inventory من الظهور كـ playback-confirmed ويعقم Worker/iOS resolver results قبل runtime.
- Canonical registry: 27 total / 5 runtime overlaps (Videasy, VidFast, 2Embed, Frembed, VidLink) / 22 net-new pending. runtime-working المؤكد للـ22 الجديدة = 0 حتى resolver + URL + player-start progress evidence.
- direct search: TMDB `/search/multi` مع `include_adult=false` و`language=ar-SA`. Theeb Engine `/api/search` غير مربوط لعدم وجود production HTTPS base URL مثبت ومصرح.
- navigation/back: إصلاحات Movie Details وSeries Details وPlayer موجودة واختبارات regression البرمجية قائمة؛ device E2E على iPhone/Android/Android TV ما زال غير مثبت.
- buffering fallback: watchdog bounded قرابة 12 ثانية، يحفظ `_lastStablePosition` ويستبعد server identity الفاشلة. أضيف الآن session-scoped `_failedMediaUrls` حتى لا يعود نفس media URL عبر provider identity أخرى؛ URL والخادم الفاشلان يوسمان عند فشل fallback، والقائمة تصفى قبل المحاولة.
- version parity يبقى Flutter `2.1.3+19` ومرشح Android TV `2.1.3/19`. لا Release جديد في هذا التشغيل.
- signing blockers: Android release-key signing غير مثبت عند غياب secrets؛ iOS يبقى UNSIGNED/no-codesign ولا يدعى installable مباشرة.

### أهداف التشغيل التالي

1. فحص exact head `b820c3a7f55f6dbf20fdffc7df2bb0945b163529` وانتظار/قراءة Branch CI + Mobile/TV/iOS gates الجديدة؛ إصلاح أي CODE_DEFECT/TEST_DEFECT على نفس PR #54 فقط.
2. عدم الدمج إلا إذا كانت كل required checks خضراء على exact head نفسه والـPR mergeable بلا blocker، ثم الدمج باستخدام expected head SHA وإعادة قراءة main.
3. بعد الدمج، إن كانت الدفعة release-worthy، رفع version/build التالي بصورة متسقة وبناء Mobile APK + TV APK + iOS UNSIGNED من exact main نفسه ثم التحقق fail-closed من provenance/checksums/manifest/signing.
4. توسيع back regression للحالات loading/error/dialog/server-picker/fullscreen وTV remote focus restoration حيث يمكن اختباره آليًا.
5. إبقاء 22 net-new servers pending حتى يوجد contract موثق ومسموح لكل adapter؛ لا تحويل التسجيل أو URL template إلى working.
6. ربط Theeb Engine search فقط عند production HTTPS endpoint مثبت ومصرح.
7. متابعة تنظيف التعريب/RTL/dead code بعد إغلاق P0، دون تغيير package/bundle identifiers تجميليًا.

---

## الحالة الحالية — 2026-09-18 / v2.1.3

- exact release/main commit: `b701654db98c6990b2c42713a6c1eb3f16ca3e13`.
- PR المدمج: `#51 fix: P0 source truth, navigation, direct search and 2.1.3 reliability`.
- exact PR head قبل الدمج: `d13ba5dbedb62fe459d67ab5781734f15fc8348d`.
- النسخة الموحدة: Flutter `2.1.3+19` وAndroid TV `2.1.3 / 19`.
- Branch CI على exact PR head: run `35354104347` — success.
- Build على exact PR head: run `35354104500` — success.
- main release build: run `35358156473` — Mobile APK + TV APK + iOS UNSIGNED/no-codesign IPA + Publish GitHub Release كلها success.
- GitHub Release: `v2.1.3`، target `b701654db98c6990b2c42713a6c1eb3f16ca3e13`، والأصول الخمسة موجودة non-zero: Mobile APK + TV APK + iOS UNSIGNED IPA + SHA256SUMS.txt + BUILD_PROVENANCE.txt.
- Android signing: خطوات keystore/signing كانت skipped لغياب secrets؛ لا يوجد دليل release-key signing ولا تصنيف Golden/Stable.
- iOS: `UNSIGNED/no-codesign` وغير قابلة للتثبيت مباشرة بلا signing/provisioning خارجي صالح.

### P0 من اختبار المستخدم

- صور المستخدم أظهرت قبل الإصلاح 0 بث صالح فعليًا في الخوادم و0 في المستخرجات. لذلك health diagnostics أصبحت fail-closed: domain reachability أو HTTP أو مجرد extracted URL لا يساوي تشغيلًا ناجحًا.
- الحالات أصبحت تميز بين player-start confirmed / resolved URL / failed / uncertain، مع نصوص كاملة بدل ellipsis وعدادات مجموعات غير مضللة.
- أضيف Canonical Theeb Arab migration registry من 27 هوية فريدة. الحقيقة الحالية: 5 overlaps موجودة أصلًا في runtime (`Videasy`, `VidFast`, `2Embed`, `Frembed`, `VidLink`) و22 net-new pending حتى يوجد Adapter/URL contract موثّق ومسموح لكل منها. التسجيل ليس دليل تشغيل.
- direct search الحالي يظل TMDB `/search/multi` بعقد `include_adult=false` و`language=ar-SA` مع regression test. Theeb Engine `/api/search` غير مربوط حتى يتوفر production HTTPS base URL مثبت ومصرح.
- أضيف زر رجوع صريح لتفاصيل الفيلم والمسلسل بما في ذلك loading state، مع pause للـtrailer و`Navigator.maybePop()`.
- أضيف runtime buffering watchdog: buffering لمدة نحو 12 ثانية بلا تقدم position ولا `hasError` يوسم الخادم failed للجلسة ويبدأ fallback بدل التعليق، مع cancellation على recovery/exit/dispose.

### Release Readiness الحالية

**Developer/Beta-candidate متقدم، وليست Golden/Stable مثبتة.**

مثبت آليًا:
- analyze/tests خضراء على PR exact head.
- Mobile APK + TV APK + iOS no-codesign builds ناجحة.
- version/build parity ناجحة.
- release `v2.1.3` منشور من exact main/release commit نفسه مع checksums/provenance.

غير مثبت بعد:
- Android release-key signature عبر `apksigner` أو مكافئ.
- iOS signed/provisioned installable IPA.
- device E2E بعد v2.1.3 لمسارات Back/focus/playback على iPhone/Android/Android TV.
- أي من الـ22 net-new server adapters كـworking-confirmed حتى يمر resolver + URL validation + player-start progress فعليًا.
- production HTTPS endpoint مصرح لـTheeb Engine direct-search provider.

### أهداف التشغيل التالي

1. إعادة اختبار الجهاز على v2.1.3 لمسار `Home/Search → Details → Player → Back → Details → Back` على iPhone وAndroid وAndroid TV، مع focus/scroll restoration.
2. تشغيل Health diagnostics على نفس المحتوى الذي كان يفشل وتسجيل عدد `player-start confirmed` الحقيقي؛ أي source غير مثبت يبقى resolved/uncertain لا أخضر.
3. تحويل الـ22 net-new server identities تدريجيًا إلى adapters حقيقية فقط عند توفر contract موثّق ومسموح، مع capability/timeouts/cancellation/tests لكل adapter ومنع duplicate runtime identities.
4. إضافة Theeb Engine direct-search provider فقط بعد إثبات production HTTPS base URL المصرح، مع dedup/error/loading/retry واختبار Search → Details → Episodes → Watch/Download.
5. توسيع regression tests للـBack أثناء loading/error/dialog/server-picker/fullscreen ولـAndroid TV remote Back + focus restoration.
6. تقوية buffering watchdog ضد loop على نفس server/media URL وحفظ/استعادة آخر stable position بعد fallback.
7. مراجعة Android release signing؛ لا ترقية readiness قبل `apksigner` evidence فعلي.
8. مواصلة التعريب/RTL وتنظيف أي نصوص إنجليزية مرئية أو dead code مثبتة دون تغيير identifiers بلا سبب توافق.

---

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


## Hotfix 2.0.1 — restore original extracted playback core

User device test on v2.0.0 still showed:
- no playable source
- status stuck/retrying around VixSrc
- health diagnostics had more green providers than the actual runtime core.

Forensic reference:
- exact extraction-only commit: `30753308c417393587f1db805c7899e463ea11f5`
- current v2.0.0 main before this hotfix: `311ca08b337531693d47088e5b0e8381227ea55c`

Confirmed regression versus extraction-only source:
1. Original `extractServer()` explicitly bypassed strict `validateStream()` for `VidLink` and `2Embed`; v2.0.0 removed that exception and validated every final stream. This can reject browser/WebView-backed sources before the player gets a chance to initialize them.
2. Original active `serverProviders` contained only `StaticTmdbProvider`, `VidrockServerProvider`, and `PrimeSrcServerProvider`. v2.0.0 promoted Moflix/Community/Frembed into the primary discovery path, increasing pre-resolution work and coupling playback startup to extra providers that were only defined but inactive in the extracted source.
3. The core player load/initialize flow is otherwise substantially the same as the extracted source; the regression is concentrated in resolver/provider policy rather than the UI.

Hotfix actions:
- Restore original primary provider set.
- Restore VidLink/2Embed validation bypass.
- Keep optional provider implementations available in code but outside the primary resolver.
- Provider-health "servers" count now lists only providers used by the active primary path.
- Version bump to `2.0.1+15`; Android TV parity `2.0.1 / 15`.

### Next goals
1. Run branch CI + Android Mobile + Android TV + iOS unsigned builds.
2. Merge only when all green with [release] title.
3. Publish v2.0.1 triplet from the same main commit.
4. Re-test the exact failing title on device and inspect runtime logs if fallback still fails.


## Release 2.1.0 — 2026-09-08

- Version bump: Flutter `2.1.0+16`.
- Android TV parity: `versionName 2.1.0`, `versionCode 16`.
- Basis: restored original playback core from v2.0.1 hotfix.
- No additional playback-behavior changes are introduced in this version bump itself.
- Release must be built and published from one green commit with Android Mobile APK + Android TV APK + iOS UNSIGNED/no-codesign IPA + SHA256SUMS + BUILD_PROVENANCE.

### أهداف التشغيل التالي
1. إكمال CI والبناء الثلاثي على PR 2.1.0.
2. دمج PR فقط بعد خضرة كل required checks.
3. نشر v2.1.0 من نفس commit إلى GitHub Releases.
4. إعادة اختبار نفس المحتوى الذي كان يفشل على الجهاز للتأكد من أن restore-original-playback-core هو المرجع الفعلي للتشغيل.