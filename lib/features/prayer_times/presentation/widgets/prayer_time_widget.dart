import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/city_data.dart';
import '../../../../core/local_storage/user_pref.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../screens/forbidden_prayer_times_page.dart';

class CombinedPrayerTimesWidget extends StatefulWidget {
  const CombinedPrayerTimesWidget({super.key});

  @override
  State<CombinedPrayerTimesWidget> createState() =>
      _CombinedPrayerTimesWidgetState();
}

class _CombinedPrayerTimesWidgetState extends State<CombinedPrayerTimesWidget> {
  // Display name (Bangla) is derived from selectedCityKey via CityNamesBN
  String currentCityDisplay = "ঢাকা";

  // internal key matching CityCoordinates.cityMap keys
  String selectedCityKey = 'Dhaka';

  // coordinates actually used for calculations
  Coordinates selectedCoordinates = Coordinates(23.8103, 90.4125);

  PrayerTimes? prayerTimes;
  Timer? _timer;
  Duration remainingTime = Duration.zero;
  String currentPrayerName = '';
  String nextPrayerName = '';

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
      hour = hour - 12;
    }
    if (hour == 0) {
      hour = 12; // 00:xx -> 12:xx AM
    }
    String formatted =
        '${_toBanglaDigit(hour)}:${_toBanglaDigit(minute.toString().padLeft(2, '0'))} $amPm';
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
    return MediaQuery.of(context).size.width >= 360 &&
        MediaQuery.of(context).size.width < 600;
  }

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadSavedCityAndInit();
  }

  Future<void> _loadSavedCityAndInit() async {
    // Try to get from your UserPref helper; if it returns a key in CityCoordinates use it.
    String? saved = await UserPref().getUserCurrentCity(); // may return key or name
    String keyToUse = 'Dhaka';

    if (saved != null && saved.isNotEmpty) {
      // if saved matches a key in city map, use it
      if (CityCoordinates.cityMap.containsKey(saved)) {
        keyToUse = saved;
      } else {
        // maybe saved is display name (Bangla) — try to find matching key
        final foundKey = CityNamesBN.cityNamesBN.entries
            .firstWhere(
                (e) => e.value == saved, orElse: () => const MapEntry('', ''))
            .key;
        if (foundKey.isNotEmpty && CityCoordinates.cityMap.containsKey(foundKey)) {
          keyToUse = foundKey;
        }
      }
    }

    // ensure fallback exists
    selectedCityKey = keyToUse;
    selectedCoordinates =
        CityCoordinates.cityMap[selectedCityKey] ?? selectedCoordinates;
    currentCityDisplay =
        CityNamesBN.cityNamesBN[selectedCityKey] ?? currentCityDisplay;

    // calculate prayer times for selected city
    calculatePrayerTimes();
    setState(() {});
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

    try {
      prayerTimes = PrayerTimes(selectedCoordinates, today, params);
      _updatePrayerTimesInfo();
      setState(() {});
    } catch (e) {
      // handle rare errors gracefully
      debugPrint('Error calculating prayer times: $e');
    }
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
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.hanafi;
      final tomorrowPrayerTimes =
      PrayerTimes(selectedCoordinates, tomorrow, params);
      newNextPrayerName = prayerLabels['fajr']!;
      newRemainingTime = tomorrowPrayerTimes.fajr.difference(now);
      newCurrentPrayerName = prayerLabels['isha']!;
    } else {
      newNextPrayerName =
          prayerLabels[adhanNextPrayer.name.toLowerCase()] ?? '';
      newCurrentPrayerName =
          prayerLabels[adhanCurrentPrayer.name.toLowerCase()] ?? '';

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
      // update remaining time and progress if prayerTimes exists
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
      // show loading while prayerTimes are being calculated
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    // Prepare the list of prayer data for the GridView
    final tomorrowFajr = (() {
      // safer way: compute tomorrow prayerTimes.fajr
      final tomorrow = DateComponents.from(DateTime.now().add(const Duration(days: 1)));
      final params = CalculationMethod.muslim_world_league.getParameters()..madhab = Madhab.hanafi;
      final tomorrowPrayerTimes = PrayerTimes(selectedCoordinates, tomorrow, params);
      return tomorrowPrayerTimes.fajr;
    })();

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
        maxWidth: screenWidth * 0.95,
        minWidth: 300,
      ),
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4.0 : 8.0),
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF2e7d32),
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
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCityKey,
                    dropdownColor: const Color(0xFF1b5e20),
                    style: AppTextStyles.regular.copyWith(
                      color: Colors.white,
                      fontSize: headerFontSize,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white70, size: iconSize + 2),
                    isExpanded: true,
                    onChanged: (String? newKey) {
                      if (newKey != null && newKey != selectedCityKey) {
                        setState(() {
                          selectedCityKey = newKey;
                          selectedCoordinates = CityCoordinates.cityMap[selectedCityKey] ?? selectedCoordinates;
                          currentCityDisplay = CityNamesBN.cityNamesBN[selectedCityKey] ?? currentCityDisplay;
                        });
                        calculatePrayerTimes();
                      }
                    },
                    items: CityCoordinates.cityMap.keys.map<DropdownMenuItem<String>>((String cityKey) {
                      final display = CityNamesBN.cityNamesBN[cityKey] ?? cityKey;
                      return DropdownMenuItem<String>(
                        value: cityKey,
                        child: Text(
                          display,
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
                      return const ForbiddenPrayerTimesPage();
                    },
                  );
                },
              ),
            ],
          ),

          // Main Display for Current/Next Prayer (responsive)
          Column(
            children: [
              Text(
                (remainingTime.isNegative) ? 'পরবর্তী ওয়াক্তের জন্য অপেক্ষা করুন' : 'পরবর্তী ওয়াক্ত : $nextPrayerName',
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

          Divider(color: Colors.white54, height: isSmallScreen ? 16 : 20, thickness: 1),

          // Flexible Grid - 2 columns minimum, height adjusts to content
          LayoutBuilder(
            builder: (context, constraints) {
              const int crossAxisCount = 2;
              double crossAxisSpacing = isSmallScreen ? 6 : isMediumScreen ? 8 : 10;
              double mainAxisSpacing = isSmallScreen ? 6 : isMediumScreen ? 8 : 10;

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
                  final now = DateTime.now();
                  if (start.isBefore(now) && now.isBefore(end)) {
                    final totalDuration = end.difference(start).inSeconds;
                    final passedDuration = now.difference(start).inSeconds;
                    progress = totalDuration > 0 ? passedDuration / totalDuration : 0.0;
                  } else if (now.isAfter(end)) {
                    progress = 1.0;
                  } else {
                    progress = 0.0;
                  }

                  // Calculate width for each item (2 per row)
                  final double itemWidth = (constraints.maxWidth - crossAxisSpacing) / 2;

                  return SizedBox(
                    width: itemWidth,
                    child: IntrinsicHeight(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                          border: isActive ? Border.all(color: Colors.white, width: isSmallScreen ? 1.5 : 2) : null,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isSmallScreen ? 4 : 6),

                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 5),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
                                  minHeight: isSmallScreen ? 3 : 4,
                                ),
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
