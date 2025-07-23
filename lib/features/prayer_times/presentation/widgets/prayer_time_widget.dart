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

  // Save selected city locally
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

  // --- Screen Size Helper ---
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  bool _isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 360 && MediaQuery.of(context).size.width < 600;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = _isSmallScreen(context);
    final isMediumScreen = _isMediumScreen(context);

    // Responsive sizing
    final double containerPadding = isSmallScreen ? 8.0 : isMediumScreen ? 10.0 : 12.0;
    final double iconSize = isSmallScreen ? 14.0 : 16.0;
    final double headerFontSize = isSmallScreen ? 11.0 : isMediumScreen ? 13.0 : 14.0;
    final double timerFontSize = isSmallScreen ? 14.0 : isMediumScreen ? 16.0 : 18.0;
    final double prayerNameFontSize = isSmallScreen ? 12.0 : isMediumScreen ? 14.0 : 15.0;
    final double prayerTimeFontSize = isSmallScreen ? 10.0 : isMediumScreen ? 13.0 : 14.0;

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
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.95, // Ensure it doesn't exceed 95% of screen width
        minWidth: 300, // Minimum width for very small screens
      ),
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4.0 : 8.0),
      padding: EdgeInsets.all(containerPadding),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // City Selector (responsive)
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: iconSize),
              SizedBox(width: isSmallScreen ? 6 : 10),
              Expanded( // Changed from Flexible to Expanded for better space utilization
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCity,
                    dropdownColor: const Color(0xFF1b5e20),
                    style: AppTextStyles.regular.copyWith(
                      color: Colors.white,
                      fontSize: headerFontSize,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white70, size: iconSize + 2),
                    isExpanded: true, // Make dropdown take full available width
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCity = newValue;
                          selectedCoordinates = CityCoordinates.cityMap[selectedCity];
                          calculatePrayerTimes();
                          _saveSelectedCity(newValue);
                        });
                      }
                    },
                    items: CityCoordinates.cityMap.keys.map<DropdownMenuItem<String>>((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          city,
                          style: AppTextStyles.regular.copyWith(
                            color: Colors.white,
                            fontSize: headerFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.white, size: iconSize + 2),
                padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                constraints: BoxConstraints(
                  minWidth: isSmallScreen ? 32 : 40,
                  minHeight: isSmallScreen ? 32 : 40,
                ),
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

          SizedBox(height: isSmallScreen ? 6 : 8),

          // Main Display for Current/Next Prayer (responsive)
          Column(
            children: [
              Text(
                (remainingTime.isNegative)
                    ? 'পরবর্তী ওয়াক্তের জন্য অপেক্ষা করুন'
                    : 'পরবর্তী ওয়াক্ত : $nextPrayerName',
                style: AppTextStyles.regular.copyWith(
                  fontSize: headerFontSize,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Text(
                formatBanglaDuration(remainingTime),
                style: AppTextStyles.bold.copyWith(
                  fontSize: timerFontSize,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          Divider(
            color: Colors.white54,
            height: isSmallScreen ? 16 : 20,
            thickness: 1,
          ),

          // Flexible Grid - 2 columns minimum, height adjusts to content
          LayoutBuilder(
            builder: (context, constraints) {
              const int crossAxisCount = 2;
              double crossAxisSpacing = isSmallScreen ? 6 : isMediumScreen ? 8 : 10;
              double mainAxisSpacing = isSmallScreen ? 6 : isMediumScreen ? 8 : 10;

              // Calculate each prayer card
              return Wrap(
                spacing: crossAxisSpacing,
                runSpacing: mainAxisSpacing,
                children: List.generate(prayers.length, (index) {
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

                  // Calculate width for each item (2 per row)
                  final double itemWidth = (constraints.maxWidth - crossAxisSpacing) / 2;

                  return SizedBox(
                    width: itemWidth,
                    child: IntrinsicHeight( // This ensures the container takes only the height it needs
                      child: Container(
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withOpacity(0.25)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                          border: isActive
                              ? Border.all(color: Colors.white, width: isSmallScreen ? 1.5 : 2)
                              : null,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Prayer name
                              Text(
                                name,
                                style: AppTextStyles.bold.copyWith(
                                  fontSize: prayerNameFontSize,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),

                              SizedBox(height: isSmallScreen ? 2 : 4),

                              // Prayer times
                              Text(
                                '${formatBanglaTime(start)} - ${formatBanglaTime(end)}',
                                style: AppTextStyles.regular.copyWith(
                                  fontSize: prayerTimeFontSize,
                                  color: Colors.white70,
                                ),
                                maxLines: 2, // Allow 2 lines for time if needed
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: isSmallScreen ? 4 : 6),

                              // Progress bar
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 5),
                                minHeight: isSmallScreen ? 3 : 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}