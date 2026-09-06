import 'dart:async';

import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/maxstream_main_screen.dart';
import 'services/notification_service.dart';
import 'services/notification_router.dart';
import 'services/media_download_manager.dart';
import 'services/theme_service.dart';
import 'services/crashlytics_service.dart';
import 'services/memory_service.dart';
import 'widgets/crash_screen.dart';
import 'package:fvp/fvp.dart' as fvp;

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  fvp.registerWith(options: {'platforms': ['android', 'ios']});
  installGlobalCrashHandlers();
  installMemoryTrimHandler();
  await checkForNativeCrash();
  await checkUnexpectedExit();
  runZonedGuarded(
    () => runApp(const CrashReportGate(child: _StartupGate())),
    (error, stack) {
      if (isBenignError(error)) return;
      recordCrash('UncaughtZone', error, stack);
      unawaited(reportCrashlytics('UncaughtZone', error, stack));
    },
  );
}

/// Starts the user-facing shell even when optional network-backed services fail.
/// Playback/navigation must not depend on Firebase, notifications or downloads.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _bestEffort(String name, Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error, stack) {
      recordCrash('Bootstrap:$name', error, stack);
    }
  }

  Future<void> _initialize() async {
    var firebaseReady = false;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      firebaseReady = true;
    } catch (error, stack) {
      recordCrash('Bootstrap:Firebase', error, stack);
    }

    if (firebaseReady) {
      await _bestEffort('Crashlytics', () async {
        await enableCrashlyticsReporting();
        attachCrashlyticsFatalHandlers();
      });
    }

    if (!kIsWeb) {
      await _bestEffort('Notifications', () => NotificationService().initialize());
      await _bestEffort(
        'Downloads',
        () => MediaDownloadManager.instance.initialize(),
      );
    }
    await _bestEffort('Theme', () => ThemeService.instance.loadTheme());

    if (!mounted) return;
    setState(() => _ready = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationRouter.registerNavigator(appNavigatorKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeService.darkTheme,
        home: const Scaffold(
          backgroundColor: Color(0xFF0F172A),
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F2FE)),
            ),
          ),
        ),
      );
    }
    return const TheebStreamApp();
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'تعذر تشغيل التطبيق حاليًا. أعد المحاولة بعد قليل.',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class TheebStreamApp extends StatelessWidget {
  const TheebStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ذيب ستريم',
      navigatorKey: appNavigatorKey,
      theme: ThemeService.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.3,
        );
        final content = Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
        if (clamped == mq.textScaler) return content;
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: content,
        );
      },
      home: const MaxStreamMainScreen(),
    );
  }
}
