import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iomdailyazkar/home_page.dart';
import 'package:iomdailyazkar/theme/app_text_styles.dart';
import 'package:iomdailyazkar/services/notification_service.dart'; // নতুন সার্ভিস ফাইল ইম্পোর্ট করা হয়েছে

// ব্যাকগ্রাউন্ড নোটিফিকেশন রেসপন্স হ্যান্ডলার
// এটি অবশ্যই `main.dart` এ থাকতে হবে কারণ এটি একটি টপ-লেভেল ফাংশন হতে হবে।
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // আপনার ব্যাকগ্রাউন্ড নোটিফিকেশন হ্যান্ডলিং লজিক এখানে লিখুন।

  // এখানে আপনি SharedPreferences এ ডেটা সেভ করতে পারেন, HTTP রিকোয়েস্ট পাঠাতে পারেন,
  // অথবা কোনো ডেটা প্রসেস করতে পারেন যা অ্যাপের UI এর সাথে সম্পর্কিত নয়।
  debugPrint('Background notification tapped: ${notificationResponse.payload}');

  // যদি আপনি NotificationService এর কোনো মেথড থেকে কোনো লজিক কল করতে চান,
  // তাহলে সেটি NotificationService এ একটি স্ট্যাটিক মেথড হিসেবে ডিফাইন করুন
  // যা UI এর সাথে সরাসরি সম্পর্কিত নয়।
  // উদাহরণস্বরূপ:
  // NotificationService.handleBackgroundPayload(notificationResponse.payload);


}

Future<void> main() async {
  // নোটিফিকেশন সার্ভিস ইনিশিয়ালাইজ করুন
  await NotificationService.initializeNotifications();

  runApp(const MyApp());

  // আপনি চাইলে এখানে ডিফল্ট নোটিফিকেশন শিডিউল করতে পারেন
  // অথবা ব্যবহারকারীকে UI থেকে সেট করার সুযোগ দিতে পারেন।
  await NotificationService.scheduleDailyNotification(
    id: 0,
    title: 'দৈনিক আযকার reminder ! এখন মিস হয়ে গেলে আর সুযোগ পাবেন না ।',
    body: 'আপনার আজকের আযকারগুলো সম্পন্ন করুন।',
    hour: 22, // 22:15 = রাত 10:15
    minute: 30,
    payload: 'daily_azkar_type_1',
  );

  await NotificationService.scheduleDailyNotification(
    id: 1,
    title: 'সকালের আযকার Reminder!',
    body: 'সকালের আযকারগুলো সম্পন্ন করতে ভুলবেন না।',
    hour: 6, // 8:00 AM
    minute: 0,
    payload: 'daily_azkar_morning',
  );

  await NotificationService.scheduleDailyNotification(
    id: 1,
    title: '8:10',
    body: 'সকালের আযকারগুলো সম্পন্ন করতে ভুলবেন না।',
    hour: 9, // 8:00 AM
    minute: 15,
    payload: 'daily_azkar_morning',
  );

  await NotificationService.scheduleDailyNotification(
    id: 1,
    title: '10:10',
    body: 'সকালের আযকারগুলো সম্পন্ন করতে ভুলবেন না।',
    hour: 10, // 8:00 AM
    minute: 10,
    payload: 'daily_azkar_morning',
  );

  await NotificationService.scheduleDailyNotification(
    id: 1,
    title: '10:20',
    body: 'সকালের আযকারগুলো সম্পন্ন করতে ভুলবেন না।',
    hour: 10, // 8:00 AM
    minute: 20,
    payload: 'daily_azkar_morning',
  );

  await NotificationService.scheduleDailyNotification(
    id: 1,
    title: 'রাতের আযকার Reminder!',
    body: 'সকালের আযকারগুলো সম্পন্ন করতে ভুলবেন না।',
    hour: 18, // 8:00 AM
    minute: 0,
    payload: 'daily_azkar_night',
  );

  await NotificationService.scheduleInstantNotification(
    id: 2, // ভিন্ন আইডি
    title: 'অ্যাপ চালু হয়েছে!',
    body: 'এটি একটি টেস্ট নোটিফিকেশন।',
    secondsDelay: 5,
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
      home: HomeScreen(),
    );
  }
}