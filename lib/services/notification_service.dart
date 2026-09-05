import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static late FlutterLocalNotificationsPlugin _notificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: NotificationRouter.handleTap,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'theeb_stream_channel',
          'إشعارات ذيب ستريم',
          channelDescription: 'إشعارات توفر المحتوى',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: 'ic_notification',
          largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  Future<void> showDownloadProgress({
    required int id,
    required String title,
    required String label,
    required int progress,
    String? size,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'theeb_stream_downloads',
      'تنزيلات الوسائط',
      channelDescription: 'تقدم تنزيل الأفلام والحلقات للمشاهدة دون اتصال',
      importance: Importance.low,
      priority: Priority.low,
      category: AndroidNotificationCategory.progress,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress.clamp(0, 100),
      icon: 'ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
    );
    await _notificationsPlugin.show(
      id,
      title,
      '$label · $progress%${size == null ? '' : ' · $size'}',
      NotificationDetails(android: androidDetails),
      payload: 'downloads',
    );
  }

  Future<void> showDownloadFinished({
    required int id,
    required String label,
    String? error,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'theeb_stream_downloads',
      'تنزيلات الوسائط',
      channelDescription: 'تقدم تنزيل الأفلام والحلقات للمشاهدة دون اتصال',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      autoCancel: true,
      onlyAlertOnce: true,
      icon: 'ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
    );
    await _notificationsPlugin.show(
      id,
      error == null ? 'اكتمل التنزيل' : 'فشل التنزيل',
      error == null ? label : '$label · $error',
      const NotificationDetails(android: androidDetails),
      payload: 'downloads',
    );
  }

  Future<void> notifyNewContent({
    required String contentTitle,
    required String providerName,
    required String mediaType,
  }) async {
    await showNotification(
      id: DateTime.now().millisecond,
      title: 'جديد على $providerName',
      body: '$contentTitle متاح الآن على $providerName ($mediaType)',
      payload: 'new_content:$contentTitle:$providerName',
    );
  }

  Future<void> notifyMultipleProvidersAdded({
    required String contentTitle,
    required List<String> providerNames,
    required String mediaType,
  }) async {
    final providers = providerNames.join(', ');
    await showNotification(
      id: DateTime.now().millisecond,
      title: '$contentTitle متاح الآن على عدة مصادر',
      body: 'متاح على: $providers',
      payload: 'content_expanded:$contentTitle',
    );
  }

  Future<void> notifyPreferredProviderUpdate({
    required String contentTitle,
    required String providerName,
  }) async {
    await showNotification(
      id: DateTime.now().millisecond,
      title: 'المحتوى متاح على مصدرك المفضل',
      body: '$contentTitle أصبح متاحًا الآن على $providerName',
      payload: 'preferred:$contentTitle:$providerName',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
