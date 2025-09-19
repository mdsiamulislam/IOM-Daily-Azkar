import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:iomdailyazkar/core/constants/constants.dart';

import '../../../../core/constants/city_data.dart';
import '../../../../core/local_storage/user_pref.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../screens/forbidden_prayer_times_page.dart';

class CombinedPrayerTimesWidget extends StatefulWidget {
  final String? city; // City from previous screen

  const CombinedPrayerTimesWidget({super.key, this.city});

  @override
  State<CombinedPrayerTimesWidget> createState() =>
      _CombinedPrayerTimesWidgetState();
}

class _CombinedPrayerTimesWidgetState extends State<CombinedPrayerTimesWidget> {
  String currentCityDisplay = "ঢাকা";
  String selectedCityKey = 'Dhaka';
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

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initCityAndPrayerTimes();
  }

  Future<void> _initCityAndPrayerTimes() async {
    String keyToUse = 'Dhaka';

    // 1. Priority: City from previous screen
    if (widget.city != null && widget.city!.isNotEmpty) {
      if (CityCoordinates.cityMap.containsKey(widget.city)) {
        keyToUse = widget.city!;
      } else {
        final foundKey = CityNamesBN.cityNamesBN.entries
            .firstWhere(
              (e) => e.value == widget.city,
          orElse: () => const MapEntry('', ''),
        )
            .key;
        if (foundKey.isNotEmpty &&
            CityCoordinates.cityMap.containsKey(foundKey)) {
          keyToUse = foundKey;
        }
      }
    } else {
      // 2. Check UserPref
      String? saved = await UserPref().getUserCurrentCity();
      if (saved != null && saved.isNotEmpty) {
        if (CityCoordinates.cityMap.containsKey(saved)) {
          keyToUse = saved;
        } else {
          final foundKey = CityNamesBN.cityNamesBN.entries
              .firstWhere(
                (e) => e.value == saved,
            orElse: () => const MapEntry('', ''),
          )
              .key;
          if (foundKey.isNotEmpty &&
              CityCoordinates.cityMap.containsKey(foundKey)) {
            keyToUse = foundKey;
          }
        }
      }
    }

    // Apply
    selectedCityKey = keyToUse;
    selectedCoordinates =
        CityCoordinates.cityMap[selectedCityKey] ?? selectedCoordinates;
    currentCityDisplay =
        CityNamesBN.cityNamesBN[selectedCityKey] ?? currentCityDisplay;

    // Optionally save to UserPref
    UserPref().setUserCurrentCity(selectedCityKey);

    calculatePrayerTimes();
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatBanglaTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String amPm = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '${_toBanglaDigit(hour)}:${_toBanglaDigit(minute.toString().padLeft(2, '0'))} $amPm';
  }

  String _toBanglaDigit(dynamic number) {
    String numStr = number.toString();
    return numStr.replaceAllMapped(RegExp(r'\d'), (match) {
      return banglaDigits[int.parse(match.group(0)!)];
    });
  }

  String formatBanglaDuration(Duration duration) {
    if (duration.isNegative) return '০ সেকেন্ড';
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    String hoursStr = hours > 0 ? '${_toBanglaDigit(hours)} ঘণ্টা ' : '';
    String minutesStr = minutes > 0 ? '${_toBanglaDigit(minutes)} মিনিট ' : '';
    String secondsStr = '${_toBanglaDigit(seconds)} সেকেন্ড';
    return '$hoursStr$minutesStr$secondsStr'.trim();
  }

  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  bool _isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 360 &&
        MediaQuery.of(context).size.width < 600;
  }

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
      debugPrint('Error calculating prayer times: $e');
    }
  }

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
      final params = CalculationMethod.muslim_world_league.getParameters()
        ..madhab = Madhab.hanafi;
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
      _updatePrayerTimesInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = _isSmallScreen(context);
    final isMediumScreen = _isMediumScreen(context);

    final double containerPadding =
    isSmallScreen ? 8.0 : isMediumScreen ? 10.0 : 12.0;
    final double iconSize = isSmallScreen ? 14.0 : 16.0;
    final double headerFontSize = isSmallScreen
        ? 11.0
        : isMediumScreen
        ? 13.0
        : 14.0;
    final double timerFontSize = isSmallScreen
        ? 14.0
        : isMediumScreen
        ? 16.0
        : 18.0;
    final double prayerNameFontSize = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 14.0
        : 15.0;
    final double prayerTimeFontSize = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 14.0
        : 15.0;

    if (prayerTimes == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final tomorrowFajr = (() {
      final tomorrow =
      DateComponents.from(DateTime.now().add(const Duration(days: 1)));
      final params = CalculationMethod.muslim_world_league.getParameters()
        ..madhab = Madhab.hanafi;
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
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForbiddenPrayerTimesPage(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'যে যে সময়ে নামায নিষিদ্ধ',
                    style: AppTextStyles.bold.copyWith(
                      color: Colors.red,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(
              color: Colors.white54,
              height: isSmallScreen ? 16 : 20,
              thickness: 1),
          LayoutBuilder(
            builder: (context, constraints) {
              const int crossAxisCount = 2;
              double crossAxisSpacing = isSmallScreen
                  ? 6
                  : isMediumScreen
                  ? 8
                  : 10;
              double mainAxisSpacing = isSmallScreen
                  ? 6
                  : isMediumScreen
                  ? 8
                  : 10;

              return Wrap(
                spacing: crossAxisSpacing,
                runSpacing: mainAxisSpacing,
                children: List.generate(prayers.length, (index) {
                  final prayer = prayers[index];
                  final String name = prayer['name'];
                  final DateTime start = prayer['start'];
                  final DateTime end = prayer['end'];
                  final bool isActive = (name == currentPrayerName);

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

                  final double itemWidth = (constraints.maxWidth - crossAxisSpacing) / 2;

                  return SizedBox(
                    width: itemWidth,
                    child: IntrinsicHeight(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withOpacity(0.25)
                              : Colors.white.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(isSmallScreen ? 8 : 12),
                          border: isActive
                              ? Border.all(
                              color: Colors.white,
                              width: isSmallScreen ? 1.5 : 2)
                              : null,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              ClipRRect(
                                borderRadius:
                                BorderRadius.circular(isSmallScreen ? 3 : 5),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor:
                                  Colors.white.withOpacity(0.3),
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      Colors.lightGreenAccent),
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
