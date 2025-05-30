import 'package:flutter/material.dart';
import 'package:iomdailyazkar/home_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    // Request notification permission (Android 13+)
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      print('Notification permission not granted');
    }

    // Initialize notification plugin
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Create notification channels (required for Android 8.0+)
    await _createNotificationChannels();

    runApp(const MyApp());

    // Schedule notifications
    await scheduleDailyNotification();
    await scheduleInstantNotification();
  } catch (e) {
    print('Error during initialization: $e');
  }
}

Future<void> _createNotificationChannels() async {
  // Instant notification channel
  const AndroidNotificationChannel instantChannel = AndroidNotificationChannel(
    'instant_azkar_channel_id',
    'Instant Azkar',
    description: 'Instant reminder to do Azkar',
    importance: Importance.max,
  );

  // Daily notification channel
  const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
    'daily_azkar_channel_id',
    'Daily Azkar',
    description: 'Reminder to do Azkar every day at 3:15 PM',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(instantChannel);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(dailyChannel);
}

Future<void> scheduleInstantNotification() async {
  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1, // Different ID from the daily notification
      'Azkar Reminder',
      'Time for daily Azkar 🙏',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_azkar_channel_id',
          'Instant Azkar',
          channelDescription: 'Instant reminder to do Azkar',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    print('Instant notification scheduled');
  } catch (e) {
    print('Error scheduling instant notification: $e');
  }
}

Future<void> scheduleDailyNotification() async {
  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Azkar Reminder',
      'Time for daily Azkar 🙏',
      _nextInstanceOfThreePM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_azkar_channel_id',
          'Daily Azkar',
          channelDescription: 'Reminder to do Azkar every day at 3:15 PM',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print('Daily notification scheduled');
  } catch (e) {
    print('Error scheduling daily notification: $e');
  }
}

tz.TZDateTime _nextInstanceOfThreePM() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
  tz.TZDateTime(tz.local, now.year, now.month, now.day, 15, 38); // 3:15 PM

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  print("Next daily notification scheduled at: $scheduledDate");
  return scheduledDate;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}