import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

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

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  static Future<bool> requestPermission() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  static Future<void> scheduleHabitReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> days,
  }) async {
    // Cancel existing notifications for this habit
    await cancelHabitReminder(id);

    for (int i = 0; i < days.length; i++) {
      final notificationId = id * 100 + i;
      await _scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        dayOfWeek: days[i],
        hour: hour,
        minute: minute,
      );
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Find the next occurrence of the specified day
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Reminders for your daily habits',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelHabitReminder(int habitId) async {
    // Cancel all notifications for this habit (up to 7 for each day)
    for (int i = 0; i < 7; i++) {
      await _notifications.cancel(habitId * 100 + i);
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_instant',
      'Habit Updates',
      channelDescription: 'Instant notifications for habit achievements',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, notificationDetails);
  }

  static final List<String> motivationalMessages = [
    "Stay consistent today!",
    "You're building great habits!",
    "One step closer to your goal!",
    "Keep up the amazing work!",
    "Your future self will thank you!",
    "Progress, not perfection!",
    "Every day counts!",
    "You're doing great!",
    "Small steps lead to big changes!",
    "Consistency is key!",
  ];

  static String getRandomMotivationalMessage() {
    final index = DateTime.now().millisecondsSinceEpoch % motivationalMessages.length;
    return motivationalMessages[index];
  }

  static String getStreakMessage(int streak) {
    if (streak == 1) {
      return "Great start! Keep it going!";
    } else if (streak == 7) {
      return "One week streak! You're amazing!";
    } else if (streak == 30) {
      return "30 days! You're unstoppable!";
    } else if (streak % 30 == 0) {
      return "$streak days! Incredible dedication!";
    } else {
      return "$streak day streak! Keep it up!";
    }
  }
}
