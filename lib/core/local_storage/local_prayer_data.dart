import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/prayer_time/models/local_prayer_time_model.dart';

class LocalPrayerData {
  static const _key = 'local_prayer_schedules';

  // Get all mosque schedules
  Future<List<MosqueSchedule>> getAllMosqueSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => MosqueSchedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Add a new mosque schedule
  Future<void> addMosqueSchedule(MosqueSchedule schedule) async {
    final schedules = await getAllMosqueSchedules();
    schedules.add(schedule);
    await _saveAllSchedules(schedules);
  }

  // Update a mosque schedule at specific index
  Future<void> updateMosqueSchedule(int index, MosqueSchedule schedule) async {
    final schedules = await getAllMosqueSchedules();
    if (index >= 0 && index < schedules.length) {
      schedules[index] = schedule;
      await _saveAllSchedules(schedules);
    }
  }

  // Delete a mosque schedule at specific index
  Future<void> deleteMosqueSchedule(int index) async {
    final schedules = await getAllMosqueSchedules();
    if (index >= 0 && index < schedules.length) {
      schedules.removeAt(index);
      await _saveAllSchedules(schedules);
    }
  }

  // Private method to save all schedules
  Future<void> _saveAllSchedules(List<MosqueSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(schedules.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  // Clear all schedules
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Legacy method for backward compatibility (optional)
  @Deprecated('Use getAllMosqueSchedules instead')
  Future<(String?, List<PrayerTime>)?> getPrayerData() async {
    final schedules = await getAllMosqueSchedules();
    if (schedules.isEmpty) return null;

    final first = schedules.first;
    return (first.mosqueName, first.prayerTimes);
  }

  // Legacy method for backward compatibility (optional)
  @Deprecated('Use addMosqueSchedule instead')
  Future<void> savePrayerData(String mosqueName, List<PrayerTime> times) async {
    final schedule = MosqueSchedule(
      mosqueName: mosqueName,
      prayerTimes: times,
    );

    // Check if we're updating the first schedule or adding new
    final schedules = await getAllMosqueSchedules();
    if (schedules.isEmpty) {
      await addMosqueSchedule(schedule);
    } else {
      await updateMosqueSchedule(0, schedule);
    }
  }
}







// File: lib/features/prayer_time/models/local_prayer_time_model.dart

class PrayerTime {
  final String name;
  final String time;

  PrayerTime({
    required this.name,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time,
  };

  factory PrayerTime.fromJson(Map<String, dynamic> json) => PrayerTime(
    name: json['name'] as String,
    time: json['time'] as String,
  );
}

class MosqueSchedule {
  final String mosqueName;
  final List<PrayerTime> prayerTimes;

  MosqueSchedule({
    required this.mosqueName,
    required this.prayerTimes,
  });

  Map<String, dynamic> toJson() => {
    'mosqueName': mosqueName,
    'prayerTimes': prayerTimes.map((p) => p.toJson()).toList(),
  };

  factory MosqueSchedule.fromJson(Map<String, dynamic> json) => MosqueSchedule(
    mosqueName: json['mosqueName'] as String,
    prayerTimes: (json['prayerTimes'] as List)
        .map((p) => PrayerTime.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}