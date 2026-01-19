import 'package:flutter/material.dart';
import 'package:iomdailyazkar/core/constants/constants.dart';
import 'package:get/get.dart';

import 'app_text_styles.dart';

class AppTheme {
  final FontController fontController = Get.find();

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontController.fontFamily.value,
      scaffoldBackgroundColor: Colors.green[50],
      appBarTheme: AppBarTheme(
        color: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.white,
          weight: 900
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        )
      ),
    );
  }
}
