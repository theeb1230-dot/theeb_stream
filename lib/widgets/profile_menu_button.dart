import 'dart:io';

import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../screens/maxstream_more_screen.dart';

class ProfileMenuButton extends StatefulWidget {
  const ProfileMenuButton({super.key});

  @override
  State<ProfileMenuButton> createState() => _ProfileMenuButtonState();
}

class _ProfileMenuButtonState extends State<ProfileMenuButton> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _userService.loadAvatar();
    _userService.loadProfilePicture();
  }

  void _openSettings() {
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
    return GestureDetector(
      onTap: () => _showProfileMenu(context),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF00F2FE),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: ValueListenableBuilder<String?>(
          valueListenable: _userService.profilePictureUrl,
          builder: (context, profilePictureUrl, _) {
            final hasPicture =
                profilePictureUrl != null && File(profilePictureUrl).existsSync();
            if (hasPicture) {
              return ClipOval(
                child: Image.file(File(profilePictureUrl), fit: BoxFit.cover),
              );
            }
            return ValueListenableBuilder<String>(
              valueListenable: _userService.avatar,
              builder: (context, avatar, _) {
                return Center(
                  child: Text(
                    avatar.isNotEmpty ? avatar : 'ذ',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).padding.top + kToolbarHeight + 8,
        16,
        0,
      ),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: const [
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'الإعدادات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'settings' && mounted) {
        _openSettings();
      }
    });
  }
}
