import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/maxstream_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stack) {
    debugPrint('Optional Firebase startup failed: $error');
    debugPrintStack(stackTrace: stack);
  }

  runApp(const TheebStreamPhone());
}

class TheebStreamPhone extends StatelessWidget {
  const TheebStreamPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ذيب ستريم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const MaxStreamMainScreen(),
    );
  }
}
