import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._(); // private constructor

  static void showSuccess(String message) {
    _show(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  static void showError(String message) {
    _show(
      message: message,
      backgroundColor: Colors.red,
    );
  }

  static void showInfo(String message) {
    _show(
      message: message,
      backgroundColor: Colors.blue,
    );
  }

  static void _show({
    required String message,
    required Color backgroundColor,
  }) {
    if (Get.context == null) return;

    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
