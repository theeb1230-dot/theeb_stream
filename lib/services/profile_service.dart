import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-only profile picture storage.
///
/// Theeb Stream does not require an account, so profile customization must not
/// depend on Firebase Authentication or a remote user record.
class ProfileService {
  static const _profilePictureKey = 'user_profile_picture';

  static Future<String?> uploadProfilePicture(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) return null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePictureKey, imagePath);
    return imagePath;
  }

  static Future<String?> getProfilePicturePath() async {
    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString(_profilePictureKey);
    if (localPath == null || localPath.isEmpty) return null;

    if (!File(localPath).existsSync()) {
      await prefs.remove(_profilePictureKey);
      return null;
    }
    return localPath;
  }

  static Future<void> deleteProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString(_profilePictureKey);
    if (localPath != null && File(localPath).existsSync()) {
      try {
        await File(localPath).delete();
      } on FileSystemException {
        // The selected image may belong to another app/provider. Clearing the
        // local reference is sufficient and avoids blocking the UI.
      }
    }
    await prefs.remove(_profilePictureKey);
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final path = await getProfilePicturePath();
    if (path == null) return null;
    return {'profilePicturePath': path};
  }
}
