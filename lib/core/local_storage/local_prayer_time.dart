import 'package:shared_preferences/shared_preferences.dart';

class LocalPrayerTime {
  static const _keyMasqueName = 'masqueName';
  static const _keyFajar = 'fajar';
  static const _keyZuhr = 'zuhr';
  static const _keyAsr = 'asr';
  static const _keyMaghrib = 'maghrib';
  static const _keyIsha = 'isha';

  Future<void> savePrayerTime({
    required String masqueName,
    required String fajar,
    required String zuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMasqueName, masqueName);
    await prefs.setString(_keyFajar, fajar);
    await prefs.setString(_keyZuhr, zuhr);
    await prefs.setString(_keyAsr, asr);
    await prefs.setString(_keyMaghrib, maghrib);
    await prefs.setString(_keyIsha, isha);
  }

  Future<Map<String, String?>> getPrayerTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'masqueName': prefs.getString(_keyMasqueName),
      'fajar': prefs.getString(_keyFajar),
      'zuhr': prefs.getString(_keyZuhr),
      'asr': prefs.getString(_keyAsr),
      'maghrib': prefs.getString(_keyMaghrib),
      'isha': prefs.getString(_keyIsha),
    };
  }

  Future<void> clearPrayerTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMasqueName);
    await prefs.remove(_keyFajar);
    await prefs.remove(_keyZuhr);
    await prefs.remove(_keyAsr);
    await prefs.remove(_keyMaghrib);
    await prefs.remove(_keyIsha);
  }
}
