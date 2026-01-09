import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final FontController fontController = Get.find();

    return Obx(() => GetMaterialApp(  // Changed to GetMaterialApp
      debugShowCheckedModeBanner: false,
      title: 'Iom Daily Azkar',
      theme: ThemeData(
        fontFamily: fontController.fontFamily.value,
        textTheme: TextTheme(
          displayLarge: AppTextStyles.heading1.copyWith(fontSize: 32),
          headlineMedium: AppTextStyles.bold.copyWith(fontSize: 24),
          bodyLarge: AppTextStyles.regular.copyWith(fontSize: 18),
          bodyMedium: AppTextStyles.regular,
          bodySmall: AppTextStyles.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    ));
  }
}