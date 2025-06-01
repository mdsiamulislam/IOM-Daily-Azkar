import 'package:flutter/material.dart';
import 'package:iomdailyazkar/home_page.dart'; // Make sure this path is correct
import 'package:iomdailyazkar/theme/app_text_styles.dart'; // Make sure this path is correct
import 'package:iomdailyazkar/services/notification_service.dart'; // Ensure this path is correct
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Added for NotificationResponse

// This needs to be a top-level function or a static method of a top-level class
// to be accessible by the plugin when the app is in the background/terminated.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle background notification taps here.
  // This code runs in a separate isolate and does not have direct access to the UI.
  debugPrint('Background notification tapped with payload: ${notificationResponse.payload}');

  // You can perform non-UI tasks here, like:
  // - Saving data to SharedPreferences
  // - Making HTTP requests
  // - Logging analytics
  // - Re-scheduling notifications
  //
  // If you need to navigate or update UI based on this, you'd typically handle
  // it in the `onDidReceiveNotificationResponse` callback when the app is foregrounded,
  // or by passing data to the main app isolate if it's running.
}

Future<void> main() async {
  // Ensure Flutter widgets are initialized before anything else.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service. This is where permission is requested.
  await NotificationService.initializeNotifications();

  runApp(const MyApp());

  // Schedule your daily and instant notifications.
  // It's a good idea to ensure these are only scheduled once,
  // perhaps using a flag in SharedPreferences, if they are static.
  await NotificationService.scheduleDailyNotification(
    id: 0,
    title: 'দৈনিক আযকার reminder ! এখন মিস হয়ে গেলে আর সুযোগ পাবেন না ।',
    body: 'আপনার আজকের আযকারগুলো সম্পন্ন করুন।',
    hour: 11, // 22:30 = রাত 10:30
    minute: 25,
    payload: 'daily_azkar_type_1',
  );

  await NotificationService.scheduleDailyNotification(
    id: 1,
    title: 'সকালের আযকার Reminder!',
    body: 'সকালের আযকারগুলো সম্পন্ন করতে ভুলবেন না।',
    hour: 6, // 6:00 AM
    minute: 0,
    payload: 'daily_azkar_morning',
  );

  await NotificationService.scheduleDailyNotification(
    id: 2,
    title: 'দিনের মধ্যভাগের আযকার Reminder!',
    body: 'দুপুরের আযকারগুলো সম্পন্ন করুন।',
    hour: 11, // 12:30 PM
    minute: 20  ,
    payload: 'daily_azkar_midday',
  );

  await NotificationService.scheduleDailyNotification(
    id: 3,
    title: 'রাতের আযকার Reminder!',
    body: 'রাতের আযকারগুলো সম্পন্ন করতে ভুলবেন না।',
    hour: 18, // 6:00 PM
    minute: 0,
    payload: 'daily_azkar_evening',
  );

  // Example of an instant notification (e.g., for testing or app launch)
  await NotificationService.scheduleInstantNotification(
    id: 99, // Use a unique ID not used by daily notifications
    title: 'অ্যাপ চালু হয়েছে!',
    body: 'এটি একটি টেস্ট নোটিফিকেশন।',
    secondsDelay: 5, // Shows 5 seconds after app launch
    payload: 'app_start_test',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Iom Daily Azkar',
      theme: ThemeData(
        fontFamily: AppTextStyles.regular.fontFamily,
        textTheme: TextTheme(
          displayLarge: AppTextStyles.heading1.copyWith(fontSize: 32.0),
          headlineMedium: AppTextStyles.bold.copyWith(fontSize: 24.0),
          bodyLarge: AppTextStyles.regular.copyWith(fontSize: 18.0),
          bodyMedium: AppTextStyles.regular,
          bodySmall: AppTextStyles.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Ensure HomeScreen exists
    );
  }
}