import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iomdailyazkar/core/local_storage/user_pref.dart';
import 'package:iomdailyazkar/core/theme/app_theme.dart';
import 'package:iomdailyazkar/core/universal_widgets/app_snackbar.dart';
import 'package:iomdailyazkar/features/onboarding_screen.dart';
import 'package:iomdailyazkar/home_page.dart';
import 'package:upgrader/upgrader.dart';
import 'core/local_storage/app_preferences.dart';
import 'core/theme/app_text_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(FontController());
  await AppPreferences.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {


    final appTheme = AppTheme();
    bool firstTime = AppPreferences.isFirstTimeOpenApp;

    final screen = firstTime ? OnboardingScreen() : HomeScreen();

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Iom Daily Azkar',
      theme: appTheme.lightTheme,
      home: UpgradeAlert(
        dialogStyle: UpgradeDialogStyle.material,
        barrierDismissible: false,
        onIgnore: () {
          AppSnackbar.showError('You have ignored this update. You may miss important features and bug fixes.');
          return true;
        },
        onLater: () {
          AppSnackbar.showInfo('You can update the app later from the google play store.');
          return true;
        },
        child: screen,
      ),
    ));


  }
}