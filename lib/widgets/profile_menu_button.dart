import 'package:flutter/material.dart';

import '../screens/maxstream_more_screen.dart';

/// زر إعدادات مباشر. أزيلت منه صورة/أفاتار الملف الشخصي لأن التطبيق لا
/// يعتمد على حساب مستخدم، ولأن فتح قائمة وسيطة قبل الإعدادات لم يعد له معنى.
class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MaxStreamMoreScreen(),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'الإعدادات',
      onPressed: () => _openSettings(context),
      icon: const Icon(Icons.settings_rounded, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF1A1A1A),
        side: BorderSide(color: Colors.white24),
      ),
    );
  }
}
