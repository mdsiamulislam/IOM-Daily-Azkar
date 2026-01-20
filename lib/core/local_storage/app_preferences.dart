import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static bool? _isFirstTimeOpenApp;

  // Initialize once at app start
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTimeOpenApp = prefs.getBool('isFirstTimeOpenApp') ?? true;
  }

  // Getter (sync)
  static bool get isFirstTimeOpenApp => _isFirstTimeOpenApp ?? true;

  // Setter
  static Future<void> setFirstTimeOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeOpenApp', false);
    _isFirstTimeOpenApp = false;
  }
}
