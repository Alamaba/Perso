import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/debt_credit_item.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
    await _requestPermissions();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Gérer le tap sur la notification
    Get.toNamed('/home');
  }

  Future<void> scheduleReminder(DebtCreditItem item) async {
    if (item.reminderDate == null) return;

    final id = item.id.hashCode;
    final title = item.isDebt ? 'Rappel de remboursement' : 'Rappel de relance';

    final body =
        item.isDebt
            ? 'Tu dois ${item.amount.toStringAsFixed(0)} FDJ à ${item.personName}'
            : '${item.personName} te doit ${item.amount.toStringAsFixed(0)} FDJ';

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(item.reminderDate!),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debt_credit_channel',
          'Rappels de dettes et crédits',
          channelDescription: 'Notifications pour les rappels de remboursement',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(String itemId) async {
    final id = itemId.hashCode;
    await _notifications.cancel(id);
  }

  Future<void> showInstantNotification(String title, String body) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_channel',
        'Notifications instantanées',
        channelDescription: 'Notifications pour les actions instantanées',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  // Convertir DateTime en TZDateTime (simplifié)
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // Pour une implémentation complète, utilisez timezone package
    return dateTime;
  }

  Future<void> scheduleMultipleReminders(List<DebtCreditItem> items) async {
    for (final item in items) {
      if (item.reminderDate != null && !item.isRepaid) {
        await scheduleReminder(item);
      }
    }
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
