import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../database/database_helper.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    // Skip initialization on web platform (notifications not supported)
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Gérer le tap sur la notification
  }

  Future<void> scheduleWarrantyNotifications() async {
    // Skip on web platform (notifications not supported)
    if (kIsWeb) return;

    // Supprimer toutes les notifications existantes
    await _notifications.cancelAll();

    // Récupérer les garanties qui expirent dans les 30 prochains jours
    final warranties = await DatabaseHelper.instance.getExpiringWarranties(30);

    for (final warranty in warranties) {
      if (warranty.isExpired || warranty.id == null) continue;

      // Notification 7 jours avant expiration
      if (warranty.daysUntilExpiry >= 7) {
        final notificationDate = warranty.expiryDate.subtract(const Duration(days: 7));
        await _scheduleNotification(
          id: warranty.id! * 10 + 1,
          title: 'Garantie expire bientôt',
          body: 'La garantie de ${warranty.productName} expire dans 7 jours',
          scheduledDate: notificationDate,
        );
      }

      // Notification 1 jour avant expiration
      if (warranty.daysUntilExpiry >= 1) {
        final notificationDate = warranty.expiryDate.subtract(const Duration(days: 1));
        await _scheduleNotification(
          id: warranty.id! * 10 + 2,
          title: 'Garantie expire demain',
          body: 'La garantie de ${warranty.productName} expire demain',
          scheduledDate: notificationDate,
        );
      }

      // Notification le jour de l'expiration
      await _scheduleNotification(
        id: warranty.id! * 10 + 3,
        title: 'Garantie expirée',
        body: 'La garantie de ${warranty.productName} expire aujourd\'hui',
        scheduledDate: warranty.expiryDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Skip on web platform (notifications not supported)
    if (kIsWeb) return;

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'warranty_channel',
          'Garanties',
          channelDescription: 'Notifications pour les garanties qui expirent',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

