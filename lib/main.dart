import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'core/theme/app_text_styles.dart';
import 'features/home/screens/home_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

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
      home: UpgradeAlert(
        child: HomeScreen(),
      ), // Ensure HomeScreen exists
    );
  }
}