import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'const/city_data.dart';

class PrayerTimesWidget extends StatefulWidget {
  @override
  State<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  PrayerTimes? prayerTimes;
  Timer? _timer;
  Duration remainingTime = Duration.zero;
  String currentPrayerName = '';
  Coordinates? selectedCoordinates;
  String selectedCity = 'Dhaka'; // default

  final prayerLabels = {
    'fajr': 'ফজর',
    'dhuhr': 'জুহর',
    'asr': 'আসর',
    'maghrib': 'মাগরিব',
    'isha': 'ইশা',
    'sunrise': 'সূর্যোদয়',
  };

  final banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  String formatBanglaTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;

    String formatted = '$hour:${minute.toString().padLeft(2, '0')}';
    return formatted.replaceAllMapped(RegExp(r'\d'), (match) {
      return banglaDigits[int.parse(match.group(0)!)];
    });
  }

  String formatBanglaDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);


    String bangla(String number) {
      const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
      return number.replaceAllMapped(RegExp(r'\d'), (match) {
        return banglaDigits[int.parse(match.group(0)!)];
      });
    }

    String hoursStr = hours > 0 ? '${bangla(hours.toString())} ঘণ্টা ' : '';
    String minutesStr = minutes > 0 ? '${bangla(minutes.toString())} মিনিট ' : '';
    String secondsStr = '${bangla(seconds.toString())} সেকেন্ড';

    return '$hoursStr$minutesStr$secondsStr'.trim();
  }


  @override
  void initState() {
    super.initState();
    selectedCoordinates = CityCoordinates.cityMap[selectedCity];
    calculatePrayerTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void calculatePrayerTimes() {
    final today = DateComponents.from(DateTime.now());
    final params = CalculationMethod.muslim_world_league.getParameters();
    if (selectedCoordinates != null) {
      prayerTimes = PrayerTimes(selectedCoordinates!, today, params);
    }
    updateCurrentPrayer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        updateCurrentPrayer();
      });
    });
  }

  void updateCurrentPrayer() {
    if (prayerTimes == null) return;

    final now = DateTime.now();
    final nextPrayerTimes = {
      'ফজর': prayerTimes!.fajr,
      'জুহর': prayerTimes!.dhuhr,
      'আসর': prayerTimes!.asr,
      'মাগরিব': prayerTimes!.maghrib,
      'ইশা': prayerTimes!.isha,
    };

    // সঠিক পরবর্তী সময় বের করা
    for (final entry in nextPrayerTimes.entries) {
      final name = entry.key;
      final time = entry.value;

      if (now.isBefore(time)) {
        currentPrayerName = name;
        remainingTime = time.difference(now);
        return;
      }
    }

    // যদি সব ওয়াক্ত পেরিয়ে যায়, তাহলে আগামী দিনের ফজর
    final tomorrowFajr = prayerTimes!.fajr.add(Duration(days: 1));
    currentPrayerName = 'ফজর';
    remainingTime = tomorrowFajr.difference(now);
  }



  Widget prayerRow(String label, DateTime start, DateTime? end) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            '${formatBanglaTime(start)} - ${end != null ? formatBanglaTime(end) : '---'}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (prayerTimes == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2e7d32), // গা dark সবুজ
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // আসন্ন নামাজ স্ট্যাটাস
          if (currentPrayerName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '$currentPrayerName ওয়াক্ত শুরু হতে বাকি আছে ${formatBanglaDuration(remainingTime)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

            ),

          // Dropdown
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCity,
                    dropdownColor: Colors.green[800],
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.white,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCity = newValue;
                          selectedCoordinates = CityCoordinates.cityMap[selectedCity];
                          calculatePrayerTimes();
                        });
                      }
                    },
                    items: CityCoordinates.cityMap.keys.map<DropdownMenuItem<String>>((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white30, height: 24),

          prayerRow(prayerLabels['fajr']!, prayerTimes!.fajr, prayerTimes!.sunrise),
          prayerRow(prayerLabels['dhuhr']!, prayerTimes!.dhuhr, prayerTimes!.asr),
          prayerRow(prayerLabels['asr']!, prayerTimes!.asr, prayerTimes!.maghrib),
          prayerRow(prayerLabels['maghrib']!, prayerTimes!.maghrib, prayerTimes!.isha),
          prayerRow(prayerLabels['isha']!, prayerTimes!.isha, prayerTimes!.fajr.add(Duration(days: 1)).subtract(Duration(minutes: 5))),
        ],
      ),
    );
  }
}
