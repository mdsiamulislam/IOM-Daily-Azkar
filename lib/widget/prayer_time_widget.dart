// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:adhan/adhan.dart';
// import '../const/city_data.dart';
// import 'package:iomdailyazkar/theme/app_text_styles.dart';
//
// class PrayerTimesWidget extends StatefulWidget {
//   const PrayerTimesWidget({super.key});
//
//   @override
//   State<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
// }
//
// class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
//   PrayerTimes? prayerTimes;
//   Timer? _timer;
//   Duration remainingTime = Duration.zero;
//   String currentPrayerName = '';
//   String nextPrayerName = '';
//   Coordinates? selectedCoordinates;
//   String selectedCity = 'Dhaka';
//
//   final Map<String, String> prayerLabels = {
//     'fajr': 'ফজর',
//     'sunrise': 'সূর্যোদয়',
//     'dhuhr': 'জুহর',
//     'asr': 'আসর',
//     'maghrib': 'মাগরিব',
//     'isha': 'ইশা',
//   };
//
//   final banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
//
//   // --- Helper Functions ---
//   String formatBanglaTime(DateTime time) {
//     int hour = time.hour;
//     int minute = time.minute;
//     String amPm = '';
//
//     if (hour >= 12) {
//       amPm = 'PM';
//     } else {
//       amPm = 'AM';
//     }
//
//     if (hour > 12) {
//       hour -= 12;
//     }
//     if (hour == 0) {
//       hour = 12; // 00:xx -> 12:xx AM
//     }
//
//     String formatted = '${_toBanglaDigit(hour)}:${_toBanglaDigit(minute.toString().padLeft(2, '0'))} $amPm';
//     return formatted;
//   }
//
//   String _toBanglaDigit(dynamic number) {
//     String numStr = number.toString();
//     return numStr.replaceAllMapped(RegExp(r'\d'), (match) {
//       return banglaDigits[int.parse(match.group(0)!)];
//     });
//   }
//
//   String formatBanglaDuration(Duration duration) {
//     if (duration.isNegative) {
//       return '০ সেকেন্ড'; // সময় পার হলে ০ সেকেন্ড দেখাবে
//     }
//     int hours = duration.inHours;
//     int minutes = duration.inMinutes.remainder(60);
//     int seconds = duration.inSeconds.remainder(60);
//
//     String hoursStr = hours > 0 ? '${_toBanglaDigit(hours)} ঘণ্টা ' : '';
//     String minutesStr = minutes > 0 ? '${_toBanglaDigit(minutes)} মিনিট ' : '';
//     String secondsStr = '${_toBanglaDigit(seconds)} সেকেন্ড';
//
//     return '$hoursStr$minutesStr$secondsStr'.trim();
//   }
//
//   // --- Lifecycle Methods ---
//   @override
//   void initState() {
//     super.initState();
//     selectedCoordinates = CityCoordinates.cityMap[selectedCity];
//     calculatePrayerTimes();
//     _startTimer();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   // --- Calculate Prayer Times ---
//   void calculatePrayerTimes() {
//     if (selectedCoordinates == null) return;
//
//     final today = DateComponents.from(DateTime.now());
//     final params = CalculationMethod.muslim_world_league.getParameters();
//     params.madhab = Madhab.hanafi;
//
//     setState(() {
//       prayerTimes = PrayerTimes(selectedCoordinates!, today, params);
//       updateCurrentPrayer();
//     });
//   }
//
//   // --- Update Current and Next Prayer Time ---
//   void updateCurrentPrayer() {
//     if (prayerTimes == null) return;
//
//     final now = DateTime.now();
//     final adhanNextPrayer = prayerTimes!.nextPrayer();
//     final adhanCurrentPrayer = prayerTimes!.currentPrayer();
//
//     String newNextPrayerName = '';
//     String newCurrentPrayerName = '';
//     Duration newRemainingTime = Duration.zero;
//
//     if (adhanNextPrayer == Prayer.none) {
//       // যদি আজকের সব নামাজ শেষ হয়ে যায়, তাহলে পরের দিনের ফজর
//       final tomorrow = DateComponents.from(now.add(const Duration(days: 1)));
//       final tomorrowPrayerTimes = PrayerTimes(selectedCoordinates!, tomorrow, CalculationMethod.muslim_world_league.getParameters());
//       newNextPrayerName = prayerLabels['fajr']!;
//       newRemainingTime = tomorrowPrayerTimes.fajr.difference(now);
//       newCurrentPrayerName = prayerLabels['isha']!; // বর্তমান নামাজ ইশা ধরে নেওয়া হলো
//     } else {
//       newNextPrayerName = prayerLabels[adhanNextPrayer.name.toLowerCase()] ?? '';
//       newCurrentPrayerName = prayerLabels[adhanCurrentPrayer.name.toLowerCase()] ?? '';
//
//       DateTime nextPrayerTime;
//       switch (adhanNextPrayer) {
//         case Prayer.fajr:
//           nextPrayerTime = prayerTimes!.fajr;
//           break;
//         case Prayer.sunrise:
//           nextPrayerTime = prayerTimes!.sunrise;
//           break;
//         case Prayer.dhuhr:
//           nextPrayerTime = prayerTimes!.dhuhr;
//           break;
//         case Prayer.asr:
//           nextPrayerTime = prayerTimes!.asr;
//           break;
//         case Prayer.maghrib:
//           nextPrayerTime = prayerTimes!.maghrib;
//           break;
//         case Prayer.isha:
//           nextPrayerTime = prayerTimes!.isha;
//           break;
//         default:
//           nextPrayerTime = now;
//       }
//       newRemainingTime = nextPrayerTime.difference(now);
//     }
//
//     if (newNextPrayerName != nextPrayerName ||
//         newCurrentPrayerName != currentPrayerName ||
//         newRemainingTime != remainingTime) {
//       setState(() {
//         nextPrayerName = newNextPrayerName;
//         currentPrayerName = newCurrentPrayerName;
//         remainingTime = newRemainingTime;
//       });
//     }
//   }
//
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       updateCurrentPrayer();
//     });
//   }
//
//   // --- UI Widget ---
//   // শুরু এবং শেষ সময় সহ প্রার্থনা রো তৈরি করার নতুন ফাংশন
//   Widget _buildPrayerIntervalRow(String label, DateTime startTime, DateTime endTime) {
//     // বর্তমান ওয়াক্ত হাইলাইট করার লজিক
//     bool isCurrentPrayer = (label == currentPrayerName);
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 3), // মার্জিন কমানো হয়েছে
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // প্যাডিং সামঞ্জস্য করা হয়েছে
//       decoration: BoxDecoration(
//         color: isCurrentPrayer ? Colors.white.withOpacity(0.25) : Colors.transparent, // হাইলাইট কালার
//         borderRadius: BorderRadius.circular(8),
//         border: isCurrentPrayer ? Border.all(color: Colors.white, width: 1.5) : null, // হাইলাইট বর্ডার
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: AppTextStyles.bold.copyWith(fontSize: 16, color: Colors.white),
//           ),
//           Text(
//             '${formatBanglaTime(startTime)} - ${formatBanglaTime(endTime)}',
//             style: AppTextStyles.bold.copyWith(fontSize: 16, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (prayerTimes == null) {
//       return const Center(child: CircularProgressIndicator(color: Colors.white));
//     }
//
//     final tomorrowFajr = prayerTimes!.fajr.add(const Duration(days: 1));
//
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2e7d32),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Current/Next Prayer Info
//           Align(
//             alignment: Alignment.center,
//             child: Column(
//               children: [
//                 Text(
//                   (remainingTime.isNegative)
//                       ? 'পরবর্তী ওয়াক্তের জন্য অপেক্ষা করুন'
//                       : 'আসন্ন ওয়াক্ত: $nextPrayerName', // মেসেজ আরও স্পষ্ট
//                   style: AppTextStyles.regular.copyWith(fontSize: 16, color: Colors.white70),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   formatBanglaDuration(remainingTime),
//                   style: AppTextStyles.bold.copyWith(fontSize: 28, color: Colors.white), // ফন্ট সাইজ আরও বড় করা হয়েছে
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//
//           // City Selector - কম হাইলাইট করা হয়েছে
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.location_on, color: Colors.white, size: 20),
//               const SizedBox(width: 8),
//               Flexible(
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: selectedCity,
//                     dropdownColor: const Color(0xFF1b5e20),
//                     style: AppTextStyles.regular.copyWith(color: Colors.white),
//                     icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
//                     onChanged: (String? newValue) {
//                       if (newValue != null) {
//                         setState(() {
//                           selectedCity = newValue;
//                           selectedCoordinates = CityCoordinates.cityMap[selectedCity];
//                           calculatePrayerTimes();
//                         });
//                       }
//                     },
//                     items: CityCoordinates.cityMap.keys.map<DropdownMenuItem<String>>((String city) {
//                       return DropdownMenuItem<String>(
//                         value: city,
//                         child: Text(city, style: AppTextStyles.regular.copyWith(color: Colors.white)),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//
//           const Divider(color: Colors.white54, height: 30),
//
//           // Prayer Times List with start and end times
//           _buildPrayerIntervalRow(prayerLabels['fajr']!, prayerTimes!.fajr, prayerTimes!.sunrise),
//           _buildPrayerIntervalRow(prayerLabels['sunrise']!, prayerTimes!.sunrise, prayerTimes!.dhuhr),
//           _buildPrayerIntervalRow(prayerLabels['dhuhr']!, prayerTimes!.dhuhr, prayerTimes!.asr),
//           _buildPrayerIntervalRow(prayerLabels['asr']!, prayerTimes!.asr, prayerTimes!.maghrib),
//           _buildPrayerIntervalRow(prayerLabels['maghrib']!, prayerTimes!.maghrib, prayerTimes!.isha),
//           _buildPrayerIntervalRow(prayerLabels['isha']!, prayerTimes!.isha, tomorrowFajr),
//         ],
//       ),
//     );
//   }
// }


// lib/widgets/combined_prayer_times_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../const/city_data.dart';
import 'package:iomdailyazkar/theme/app_text_styles.dart';

class CombinedPrayerTimesWidget extends StatefulWidget {
  const CombinedPrayerTimesWidget({super.key});

  @override
  State<CombinedPrayerTimesWidget> createState() => _CombinedPrayerTimesWidgetState();
}

class _CombinedPrayerTimesWidgetState extends State<CombinedPrayerTimesWidget> {
  PrayerTimes? prayerTimes;
  Timer? _timer;
  Duration remainingTime = Duration.zero;
  String currentPrayerName = '';
  String nextPrayerName = '';
  Coordinates? selectedCoordinates;
  String selectedCity = 'Dhaka';

  final Map<String, String> prayerLabels = {
    'fajr': 'ফজর',
    'sunrise': 'সূর্যোদয়',
    'dhuhr': 'জুহর',
    'asr': 'আসর',
    'maghrib': 'মাগরিব',
    'isha': 'ইশা',
  };

  final banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  // --- Helper Functions ---
  String formatBanglaTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String amPm = '';

    if (hour >= 12) {
      amPm = 'PM';
    } else {
      amPm = 'AM';
    }

    if (hour > 12) {
      hour -= 12;
    }
    if (hour == 0) {
      hour = 12; // 00:xx -> 12:xx AM
    }

    String formatted = '${_toBanglaDigit(hour)}:${_toBanglaDigit(minute.toString().padLeft(2, '0'))} $amPm';
    return formatted;
  }

  String _toBanglaDigit(dynamic number) {
    String numStr = number.toString();
    return numStr.replaceAllMapped(RegExp(r'\d'), (match) {
      return banglaDigits[int.parse(match.group(0)!)];
    });
  }

  String formatBanglaDuration(Duration duration) {
    if (duration.isNegative) {
      return '০ সেকেন্ড';
    }
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String hoursStr = hours > 0 ? '${_toBanglaDigit(hours)} ঘণ্টা ' : '';
    String minutesStr = minutes > 0 ? '${_toBanglaDigit(minutes)} মিনিট ' : '';
    String secondsStr = '${_toBanglaDigit(seconds)} সেকেন্ড';

    return '$hoursStr$minutesStr$secondsStr'.trim();
  }

  // --- Lifecycle Methods ---
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

  // --- Calculate Prayer Times ---
  void calculatePrayerTimes() {
    if (selectedCoordinates == null) return;

    final today = DateComponents.from(DateTime.now());
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.hanafi;

    setState(() {
      prayerTimes = PrayerTimes(selectedCoordinates!, today, params);
      _updatePrayerTimesInfo();
    });
  }

  // --- Update Current and Next Prayer Time ---
  void _updatePrayerTimesInfo() {
    if (prayerTimes == null) return;

    final now = DateTime.now();
    final adhanNextPrayer = prayerTimes!.nextPrayer();
    final adhanCurrentPrayer = prayerTimes!.currentPrayer();

    String newNextPrayerName = '';
    String newCurrentPrayerName = '';
    Duration newRemainingTime = Duration.zero;

    if (adhanNextPrayer == Prayer.none) {
      final tomorrow = DateComponents.from(now.add(const Duration(days: 1)));
      final tomorrowPrayerTimes = PrayerTimes(selectedCoordinates!, tomorrow, CalculationMethod.muslim_world_league.getParameters());
      newNextPrayerName = prayerLabels['fajr']!;
      newRemainingTime = tomorrowPrayerTimes.fajr.difference(now);
      newCurrentPrayerName = prayerLabels['isha']!;
    } else {
      newNextPrayerName = prayerLabels[adhanNextPrayer.name.toLowerCase()] ?? '';
      newCurrentPrayerName = prayerLabels[adhanCurrentPrayer.name.toLowerCase()] ?? '';

      DateTime nextPrayerTime;
      switch (adhanNextPrayer) {
        case Prayer.fajr:
          nextPrayerTime = prayerTimes!.fajr;
          break;
        case Prayer.sunrise:
          nextPrayerTime = prayerTimes!.sunrise;
          break;
        case Prayer.dhuhr:
          nextPrayerTime = prayerTimes!.dhuhr;
          break;
        case Prayer.asr:
          nextPrayerTime = prayerTimes!.asr;
          break;
        case Prayer.maghrib:
          nextPrayerTime = prayerTimes!.maghrib;
          break;
        case Prayer.isha:
          nextPrayerTime = prayerTimes!.isha;
          break;
        default:
          nextPrayerTime = now;
      }
      newRemainingTime = nextPrayerTime.difference(now);
    }

    if (newNextPrayerName != nextPrayerName ||
        newCurrentPrayerName != currentPrayerName ||
        newRemainingTime != remainingTime) {
      setState(() {
        nextPrayerName = newNextPrayerName;
        currentPrayerName = newCurrentPrayerName;
        remainingTime = newRemainingTime;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePrayerTimesInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (prayerTimes == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final tomorrowFajr = prayerTimes!.fajr.add(const Duration(days: 1));

    final List<Map<String, dynamic>> prayers = [
      {'name': prayerLabels['fajr']!, 'start': prayerTimes!.fajr, 'end': prayerTimes!.sunrise},
      {'name': prayerLabels['sunrise']!, 'start': prayerTimes!.sunrise, 'end': prayerTimes!.dhuhr},
      {'name': prayerLabels['dhuhr']!, 'start': prayerTimes!.dhuhr, 'end': prayerTimes!.asr},
      {'name': prayerLabels['asr']!, 'start': prayerTimes!.asr, 'end': prayerTimes!.maghrib},
      {'name': prayerLabels['maghrib']!, 'start': prayerTimes!.maghrib, 'end': prayerTimes!.isha},
      {'name': prayerLabels['isha']!, 'start': prayerTimes!.isha, 'end': tomorrowFajr},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2e7d32), // গাঢ় সবুজ
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // পুরো কলাম সেন্টারে
        children: [
          // City Selector (কম হাইলাইট করা হয়েছে, সেন্টারে)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCity,
                    dropdownColor: const Color(0xFF1b5e20),
                    style: AppTextStyles.regular.copyWith(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
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
                        child: Text(city, style: AppTextStyles.regular.copyWith(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          // Main Display for Current/Next Prayer
          Column(
            children: [
              Text(
                style: AppTextStyles.regular.copyWith(fontSize: 16, color: Colors.white70),
                (remainingTime.isNegative)
                    ? 'পরবর্তী ওয়াক্তের জন্য অপেক্ষা করুন'
                    : 'পরবর্তী ওয়াক্ত :' + nextPrayerName,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                formatBanglaDuration(remainingTime),
                style: AppTextStyles.bold.copyWith(fontSize: 20, color: Colors.white), // আরও বড় ফন্ট
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const Divider(color: Colors.white54, height: 10),
          SizedBox(
            height: 10, // ডিভাইডারের নিচে কিছু স্পেস
          ),

          // Prayer Times Grid with Progress Bars
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.2, // অনুপাত কমালে height কমবে
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: prayers.length,
            itemBuilder: (context, index) {
              final prayer = prayers[index];
              final String name = prayer['name'];
              final DateTime start = prayer['start'];
              final DateTime end = prayer['end'];
              final bool isActive = (name == currentPrayerName);

              // Progress Bar Calculation
              double progress = 0.0;
              if (start.isBefore(DateTime.now()) && DateTime.now().isBefore(end)) {
                final totalDuration = end.difference(start).inSeconds;
                final passedDuration = DateTime.now().difference(start).inSeconds;
                progress = totalDuration > 0 ? passedDuration / totalDuration : 0.0;
              } else if (DateTime.now().isAfter(end)) {
                progress = 1.0;
              }

              // Progress bar color
              final Color progressBarColor = Colors.lightGreenAccent;


              return Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.25)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isActive ? Border.all(color: Colors.white, width: 2) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center, <-- এটা বাদ
                    mainAxisSize: MainAxisSize.min, // content অনুযায়ী ছোট রাখবে
                    children: [
                      Text(
                        name,
                        style:
                        AppTextStyles.bold.copyWith(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatBanglaTime(start)} - ${formatBanglaTime(end)}',
                        style: AppTextStyles.regular
                            .copyWith(fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                        borderRadius: BorderRadius.circular(5),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}