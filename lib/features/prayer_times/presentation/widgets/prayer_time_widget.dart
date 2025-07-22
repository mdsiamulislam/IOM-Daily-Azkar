import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/city_data.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../screens/forbidden_prayer_times_page.dart';

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
  String selectedCity = 'Dhaka'; // Default city

  // Save selected city  locally
  Future<void> _saveSelectedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
  }

  // get the saved city from local storage
  Future<String> _getSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedCity') ?? 'Dhaka'; // Default to Dhaka if nothing saved
  }

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
    _loadSelectedCity(); // Load city when the widget initializes
    _startTimer();
    // get the saved city from local storage
    _getSavedCity().then((city) {
      setState(() {
        selectedCity = city;
        selectedCoordinates = CityCoordinates.cityMap[selectedCity];
        calculatePrayerTimes();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- SharedPreferences Methods ---
  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCity = prefs.getString('selectedCity') ?? 'Dhaka'; // Default to Dhaka if nothing saved
      selectedCoordinates = CityCoordinates.cityMap[selectedCity];
      calculatePrayerTimes();
    });
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
      // If all prayers for today are over, show Fajr for tomorrow
      final tomorrow = DateComponents.from(now.add(const Duration(days: 1)));
      final tomorrowPrayerTimes = PrayerTimes(selectedCoordinates!, tomorrow, CalculationMethod.muslim_world_league.getParameters());
      newNextPrayerName = prayerLabels['fajr']!;
      newRemainingTime = tomorrowPrayerTimes.fajr.difference(now);
      newCurrentPrayerName = prayerLabels['isha']!; // Assume Isha is the current prayer if all are done for today
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
          nextPrayerTime = now; // Fallback
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

    // Prepare the list of prayer data for the GridView
    final List<Map<String, dynamic>> prayers = [
      {'name': prayerLabels['fajr']!, 'start': prayerTimes!.fajr, 'end': prayerTimes!.sunrise},
      {'name': prayerLabels['sunrise']!, 'start': prayerTimes!.sunrise, 'end': prayerTimes!.dhuhr},
      {'name': prayerLabels['dhuhr']!, 'start': prayerTimes!.dhuhr, 'end': prayerTimes!.asr},
      {'name': prayerLabels['asr']!, 'start': prayerTimes!.asr, 'end': prayerTimes!.maghrib},
      {'name': prayerLabels['maghrib']!, 'start': prayerTimes!.maghrib, 'end': prayerTimes!.isha},
      {'name': prayerLabels['isha']!, 'start': prayerTimes!.isha, 'end': tomorrowFajr},
    ];

    return Container(
      padding: const EdgeInsets.all(10), // Reduced overall padding slightly
      decoration: BoxDecoration(
        color: const Color(0xFF2e7d32), // Dark green background
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
        crossAxisAlignment: CrossAxisAlignment.center, // Center the entire column content
        children: [
          // City Selector (less highlighted, centered)
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 10),
              Flexible( // Use Flexible to ensure the dropdown doesn't overflow
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
                          _saveSelectedCity(newValue); // Save the new city
                        });
                      }
                    },
                    items: CityCoordinates.cityMap.keys.map<DropdownMenuItem<String>>((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          city,
                          style: AppTextStyles.regular.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis, // Ensure city name doesn't overflow
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Spacer(), // Add spacer to push the icon button to the right
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white, size: 18),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ForbiddenPrayerTimesPage();
                    },
                  );
                },
              ),
            ],
          ),

          // Main Display for Current/Next Prayer
          Column(
            children: [
              Text(
                (remainingTime.isNegative)
                    ? 'পরবর্তী ওয়াক্তের জন্য অপেক্ষা করুন'
                    : 'পরবর্তী ওয়াক্ত : ' + nextPrayerName, // Added space for readability
                style: AppTextStyles.regular.copyWith(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                formatBanglaDuration(remainingTime),
                style: AppTextStyles.bold.copyWith(fontSize: 16, color: Colors.white), // Slightly larger font
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const Divider(color: Colors.white54, height: 10),
          const SizedBox(
            height: 10, // Some space below the divider
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final double crossAxisSpacing = 8;
              final int crossAxisCount = 2;

              // Calculate the available width for each grid item
              // (Total width - total cross axis spacing) / number of items
              final double itemWidth = (constraints.maxWidth - (crossAxisSpacing * (crossAxisCount - 1))) / crossAxisCount;

              // Determine a target height for the content inside each grid item.
              // This value is crucial for responsiveness. Adjust it based on your content.
              // For 2 lines of text + progress bar + padding, around 85-95 should work.
              final double targetItemHeight = 90.0; // Experiment with this value

              // Calculate childAspectRatio based on the calculated itemWidth and targetItemHeight
              final double dynamicChildAspectRatio = itemWidth / targetItemHeight;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: dynamicChildAspectRatio, // Use the dynamically calculated aspect ratio
                  crossAxisSpacing: crossAxisSpacing,
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
                        // mainAxisAlignment: MainAxisAlignment.center, // Removed as it can sometimes cause issues with min height
                        mainAxisSize: MainAxisSize.min, // Keep this to make column take minimum vertical space
                        children: [
                          // Use Flexible to ensure text wraps and doesn't overflow
                          Flexible(
                            child: Text(
                              name,
                              style: AppTextStyles.bold.copyWith(fontSize: 14, color: Colors.white),
                              overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                              maxLines: 1, // Limit to one line to save space, adjust if more lines are desired
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${formatBanglaTime(start)} - ${formatBanglaTime(end)}',
                              style: AppTextStyles.regular.copyWith(fontSize: 13, color: Colors.white70),
                              overflow: TextOverflow.ellipsis, // Add ellipsis for long time strings
                              maxLines: 1, // Limit to one line
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          // LinearProgressIndicator will naturally take available width
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                            borderRadius: BorderRadius.circular(5),
                            minHeight: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}