import 'package:flutter/material.dart';

import '../screens/maxstream_about_screen.dart';
import '../screens/provider_health_screen.dart';
import '../screens/streaming_provider_settings_screen.dart';
import '../screens/updates_screen.dart';

class MaxStreamMoreScreen extends StatelessWidget {
  const MaxStreamMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'الإعدادات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              icon: Icons.tv,
              title: 'خدمات البث',
              page: const StreamingProviderSettingsScreen(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.health_and_safety,
              title: 'حالة المصادر',
              page: const ProviderHealthScreen(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.system_update,
              title: 'التحديثات',
              page: const UpdatesScreen(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'عن ذيب ستريم',
              page: const MaxStreamAboutScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE50914),
            child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ذيب ستريم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'لا يتطلب حسابًا أو تسجيل دخول',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_back_ios_new,
        color: Colors.grey,
        size: 16,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.white.withAlpha(12),
      splashColor: Colors.white.withAlpha(25),
    );
  }
}
