import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

// This function needs to be a top-level function or a static method.
// It's the callback for when a notification is tapped while the app is in the foreground/background (but not terminated).
void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (payload != null) {
    debugPrint('Notification tapped with payload: $payload');
    // Here you can handle the payload, e.g., navigate to a specific screen.
    // For navigation, you'd typically use a GlobalKey<NavigatorState> if you're outside a widget.
    // Example (requires Navigator key setup in main.dart):
    // if (navigatorKey.currentState != null) {
    //   navigatorKey.currentState!.pushNamed('/detailPage', arguments: payload);
    // }
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    // Initialize timezone data for scheduled notifications.
    tz.initializeTimeZones();

    // --- Android Specific Setup ---
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Request notification permission for Android 13 (API level 33) and above.
    // This dialog will appear to the user.
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      if (granted == true) {
        debugPrint('Notification permission granted for Android.');
      } else {
        debugPrint('Notification permission denied for Android.');
        // Consider showing a message to the user that notifications won't work.
      }
    }

    // --- iOS/macOS Specific Setup (basic example, customize as needed) ---
    // You might need to add more permissions here for iOS (e.g., sound, badge).
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification, // Required for iOS < 10
    );

    // --- General Initialization ---
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin, // Same settings for macOS
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    debugPrint('Flutter Local Notifications Initialized');
  }

  // For iOS foreground notifications on older iOS versions (<10)
  static void onDidReceiveLocalNotification(
      int id,
      String? title,
      String? body,
      String? payload,
      ) async {
    // Handle the notification when the app is in the foreground on iOS devices prior to iOS 10.
    // You might show an alert dialog or navigate.
    debugPrint('iOS foreground notification received: ID $id, Title: $title, Payload: $payload');
  }

  // --- Notification Scheduling Methods ---

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your_channel_id', // Must match the channel ID in AndroidManifest.xml (if you define one)
      'Your Channel Name',
      channelDescription: 'This is your default channel for app notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
    debugPrint('Instant Notification Shown: $title');
  }

  static Future<void> scheduleInstantNotification({
    required int id,
    required String title,
    required String body,
    required int secondsDelay,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsDelay));

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'instant_notification_channel',
      'Instant Notifications',
      channelDescription: 'Channel for immediate notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Recommended for precise delivery
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
    debugPrint('Instant Notification Scheduled for $secondsDelay seconds from now: $title');
  }


  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // If the scheduled time is in the past for today, schedule it for tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'daily_azkar_channel',
      'Daily Azkar Reminders',
      channelDescription: 'Daily reminders for Azkar completion',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('custom_sound'), // Optional: if you have a custom sound
      playSound: true,
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'custom_sound.aiff', // Optional: if you have a custom sound for iOS
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Recommended for precise delivery
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it daily at the specified time
      payload: payload,
    );
    debugPrint('Daily Notification Scheduled: ID $id at $hour:$minute for "$title"');
  }

  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('Notification with ID $id cancelled.');
  }

  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All notifications cancelled.');
  }
}