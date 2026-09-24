import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Panggil sekali dalam main.dart lepas Hive init
  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Android 13+ perlu minta permission runtime
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Schedule reminder berdasarkan task.reminderTime
  Future<void> scheduleReminder(TaskModel task) async {
    if (task.reminderTime == null) return;

    // Skip kalau masa reminder dah lepas
    if (task.reminderTime!.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(task.reminderTime!, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'task_reminders', // channel id
      'Task Reminders', // channel name
      channelDescription: 'Reminder untuk tugasan anda',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // id notification guna hashCode dari task.id (mesti int & unique)
    final notificationId = task.id.hashCode;

    await _notifications.zonedSchedule(
      notificationId,
      task.title,
      task.description.isNotEmpty ? task.description : 'Tugasan akan tamat tak lama lagi!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel reminder (bila task delete atau reminder di-update)
  Future<void> cancelReminder(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}