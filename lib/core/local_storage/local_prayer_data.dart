import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/prayer_time/models/local_prayer_time_model.dart';

class LocalPrayerData {
  static const _key = 'local_prayer_data';

  Future<void> savePrayerData(
      String mosqueName, List<PrayerTime> times) async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'mosqueName': mosqueName,
      'times': times.map((e) => e.toJson()).toList(),
    };

    await prefs.setString(_key, jsonEncode(data));
  }

  Future<(String?, List<PrayerTime>)?> getPrayerData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return (null);

    final decoded = jsonDecode(raw);
    final mosqueName = decoded['mosqueName'] as String?;

    final times = (decoded['times'] as List)
        .map((e) => PrayerTime.fromJson(e as Map<String, dynamic>))
        .toList();

    return (mosqueName, times);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}