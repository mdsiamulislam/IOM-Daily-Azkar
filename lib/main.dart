import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iomdailyazkar/core/theme/app_theme.dart';
import 'package:iomdailyazkar/home_page.dart';
import 'core/theme/app_text_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FontController
  Get.put(FontController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {


    final appTheme = AppTheme();

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Iom Daily Azkar',
      theme: appTheme.lightTheme,
      home: const HomeScreen(),
    ));


  }
}