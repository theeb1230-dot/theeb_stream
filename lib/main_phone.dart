import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/maxstream_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for phone app
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaxStreamPhone());
}

class MaxStreamPhone extends StatelessWidget {
  const MaxStreamPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ذيب ستريم',
      theme: ThemeData.dark(),
      home: const MaxStreamMainScreen(),
    );
  }
}
