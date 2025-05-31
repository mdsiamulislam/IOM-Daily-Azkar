import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

// FlutterLocalNotificationsPlugin এর গ্লোবাল ইনস্ট্যান্স
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// এই ফাইল থেকে notificationTapBackground ফাংশনটি সরানো হয়েছে।
// এটি main.dart এ @pragma('vm:entry-point') সহ থাকবে।

class NotificationService {
  // নোটিফিকেশন সার্ভিস ইনিশিয়ালাইজ করার ফাংশন
  static Future<void> initializeNotifications() async {
    WidgetsFlutterBinding.ensureInitialized(); // নিশ্চিত করুন Flutter সার্ভিস শুরু হয়েছে

    try {
      // tz.initializeAll(); // টাইমজোন ডেটা লোড করুন
      tz.initializeTimeZones(); // টাইমজোন ডেটা লোড করুন
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka')); // ডিভাইসের লোকাল টাইমজোন সেট করুন

      // নোটিফিকেশন পারমিশন চাওয়া (Android 13+ এবং iOS)
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        debugPrint('Notification permission not granted. Status: ${status.name}');
      } else {
        debugPrint('Notification permission granted.');
      }

      // অ্যান্ড্রয়েড ইনিশিয়ালাইজেশন সেটিংস
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS ইনিশিয়ালাইজেশন সেটিংস
      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // ইনিশিয়ালাইজেশন সেটিংস
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // নোটিফিকেশন প্লাগইন ইনিশিয়ালাইজ করুন
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
          // যখন অ্যাপ ফোরগ্রাউন্ডে বা ব্যাকগ্রাউন্ডে থাকে এবং ব্যবহারকারী নোটিফিকেশনে ট্যাপ করে
          debugPrint('Notification tapped: ${notificationResponse.payload}');
          // আপনি এখানে ব্যবহারকারীকে অন্য স্ক্রিনে নেভিগেট করতে পারেন।
          // এই কলব্যাকটি শুধুমাত্র যখন অ্যাপ ফোরগ্রাউন্ডে বা ব্যাকগ্রাউন্ডে থাকে তখন কাজ করে।
        },
        // onDidReceiveBackgroundNotificationResponse এখানে নয়, main.dart এ থাকবে।
        // কারণ এটি একটি টপ-লেভেল ফাংশন কল করে।
      );

      // নোটিফিকেশন চ্যানেল তৈরি করুন (Android 8.0+ এর জন্য আবশ্যক)
      await _createNotificationChannels();
    } catch (e) {
      debugPrint('Error during notification initialization: $e');
    }
  }

  // নোটিফিকেশন চ্যানেল তৈরি করার ফাংশন
  static Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // ইনস্ট্যান্ট নোটিফিকেশন চ্যানেল
      const AndroidNotificationChannel instantChannel = AndroidNotificationChannel(
        'instant_azkar_channel_id',
        'Instant Azkar',
        description: 'Instant reminder to do Azkar',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      // দৈনিক নোটিফিকেশন চ্যানেল
      const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
        'daily_azkar_channel_id',
        'Daily Azkar',
        description: 'Reminder to do Azkar every day',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await androidImplementation.createNotificationChannel(instantChannel);
      await androidImplementation.createNotificationChannel(dailyChannel);
      debugPrint('Notification channels created.');
    }
  }

  /// একটি নির্দিষ্ট সময়ে প্রতিদিনের নোটিফিকেশন শিডিউল করার ফাংশন।
  /// `id`: নোটিফিকেশনের ইউনিক আইডি।
  /// `title`: নোটিফিকেশন টাইটেল।
  /// `body`: নোটিফিকেশন বডি।
  /// `hour`: শিডিউল করার ঘন্টা (২৪-ঘন্টার ফরম্যাটে)।
  /// `minute`: শিডিউল করার মিনিট।
  /// `payload`: নোটিফিকেশনের সাথে যুক্ত ডেটা।
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    String channelId = 'daily_azkar_channel_id',
    String channelName = 'Daily Azkar',
    String channelDescription = 'Reminder to do Azkar every day',
  }) async {
    try {
      tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            ticker: title,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint('Daily notification scheduled for ID $id at $hour:$minute.');
    } catch (e) {
      debugPrint('Error scheduling daily notification (ID $id): $e');
    }
  }

  /// একটি ইনস্ট্যান্ট নোটিফিকেশন শিডিউল করার ফাংশন।
  /// `id`: নোটিফিকেশনের ইউনিক আইডি।
  /// `title`: নোটিফিকেশন টাইটেল।
  /// `body`: নোটিফিকেশন বডি।
  /// `secondsDelay`: কত সেকেন্ড পরে নোটিফিকেশন দেখাবে।
  /// `payload`: নোটিফিকেশনের সাথে যুক্ত ডেটা।
  static Future<void> scheduleInstantNotification({
    required int id,
    required String title,
    required String body,
    required int secondsDelay,
    String? payload,
    String channelId = 'instant_azkar_channel_id',
    String channelName = 'Instant Azkar',
    String channelDescription = 'Instant reminder to do Azkar',
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsDelay)),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            ticker: title,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('Instant notification scheduled for $secondsDelay seconds from now (ID $id).');
    } catch (e) {
      debugPrint('Error scheduling instant notification (ID $id): $e');
    }
  }

  /// সমস্ত শিডিউল করা নোটিফিকেশন বাতিল করার ফাংশন।
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All notifications cancelled.');
  }

  /// একটি নির্দিষ্ট ID এর নোটিফিকেশন বাতিল করার ফাংশন।
  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('Notification with ID $id cancelled.');
  }

  // পরবর্তী নির্ধারিত সময় ক্যালকুলেট করার হেল্পার ফাংশন
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}