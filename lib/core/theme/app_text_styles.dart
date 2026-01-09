import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';


class FontController extends GetxController {
  // Observable font family
  var fontFamily = 'HindSiliguri'.obs;

  @override
  void onInit() {
    super.onInit();
    loadFont();
  }

  Future<void> loadFont() async {
    print('Loading font preference...');
    final prefs = await SharedPreferences.getInstance();
    fontFamily.value = prefs.getString('banglaFont') ?? 'HindSiliguri';
  }

  Future<void> updateFont(String newFont) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('banglaFont', newFont);
    fontFamily.value = newFont;
  }
}

class FontManager {
  static String fontFamily = 'HindSiliguri';

  static Future<void> loadFont() async {

    print('Loading font preference...');

    final prefs = await SharedPreferences.getInstance();
    fontFamily = prefs.getString('banglaFont') ?? 'HindSiliguri';
  }
}


class AppTextStyles {
  static FontController get _fontController => Get.find<FontController>();

  static TextStyle get regular => TextStyle(
    fontFamily: _fontController.fontFamily.value,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: Colors.black,
  );

  static TextStyle get bold => TextStyle(
    fontFamily: _fontController.fontFamily.value,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: Colors.black,
  );

  static TextStyle get light => TextStyle(
    fontFamily: _fontController.fontFamily.value,
    fontWeight: FontWeight.w300,
    fontSize: 14,
    color: Colors.grey,
  );

  static TextStyle get heading1 => TextStyle(
    fontFamily: _fontController.fontFamily.value,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    color: Colors.blueAccent,
  );

  static TextStyle customSize({
    required double fontSize,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: _fontController.fontFamily.value,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
