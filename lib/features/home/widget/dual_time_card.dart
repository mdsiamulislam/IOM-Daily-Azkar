import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:iomdailyazkar/features/prayer_times/controllers/change_widget.dart';

import '../../../core/local_storage/local_prayer_time.dart';
import '../../../core/constants/city_data.dart';
import '../../../core/local_storage/user_pref.dart';
import '../../prayer_times/presentation/widgets/prayer_time_widget.dart';

class DualTimeCard extends StatelessWidget {
  DualTimeCard({super.key});

  final ChangeWidget _changeWidget = Get.put(ChangeWidget());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // This will automatically rebuild when isSingleTimeTable changes
      return _changeWidget.isSingleTimeTable.value
          ? CombinedPrayerTimesWidget()
          : PrayerTimeWidget();
    });
  }
}

class PrayerTimeWidget extends StatefulWidget {
  const PrayerTimeWidget({super.key});

  @override
  State<PrayerTimeWidget> createState() => _PrayerTimeWidgetState();
}

class _PrayerTimeWidgetState extends State<PrayerTimeWidget> {
  Map<String, String?> savedTimes = {};
  PrayerTimes? prayerTimes;
  Timer? _timer;
  String currentPrayerName = '';
  Coordinates? selectedCoordinates;
  String selectedCity = 'Dhaka';

  final Map<String, String> prayerLabels = {
    'fajr': 'ফজর',
    'sunrise': 'সূর্যোদয়',
    'dhuhr': 'যোহর',
    'asr': 'আসর',
    'maghrib': 'মাগরিব',
    'isha': 'ইশা',
  };

  final banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
    _loadSelectedCity();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedTimes() async {
    final data = await LocalPrayerTime().getPrayerTime();
    setState(() {
      savedTimes = data;
    });
  }

  Future<void> _loadSelectedCity() async {
    final city = await UserPref().getLocation();
    setState(() {
      selectedCity = city;
      selectedCoordinates = CityCoordinates.cityMap[selectedCity];
      calculatePrayerTimes();
    });
  }

  void calculatePrayerTimes() {
    if (selectedCoordinates == null) return;

    final today = DateComponents.from(DateTime.now());
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.hanafi;

    setState(() {
      prayerTimes = PrayerTimes(selectedCoordinates!, today, params);
      _updateCurrentPrayer();
    });
  }

  void _updateCurrentPrayer() {
    if (prayerTimes == null) return;

    final adhanCurrentPrayer = prayerTimes!.currentPrayer();
    setState(() {
      currentPrayerName = prayerLabels[adhanCurrentPrayer.name.toLowerCase()] ?? '';
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCurrentPrayer();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight( // This ensures both cards have the same height
          child: Row(
            children: [
              // বাম পাশ (শহরের নামাজের সময়) - Now with actual prayer times
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "আপনার শহরের নামাজের সময়",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Divider(),
                        if (prayerTimes != null) ...[
                          _buildPrayerRowWithActiveState("ফজর",
                              "${formatBanglaTime(prayerTimes!.fajr)} - ${formatBanglaTime(prayerTimes!.sunrise)}", "ফজর"),
                          _buildPrayerRowWithActiveState("যোহর",
                              "${formatBanglaTime(prayerTimes!.dhuhr)} - ${formatBanglaTime(prayerTimes!.asr)}", "যোহর"),
                          _buildPrayerRowWithActiveState("আসর",
                              "${formatBanglaTime(prayerTimes!.asr)} - ${formatBanglaTime(prayerTimes!.maghrib)}", "আসর"),
                          _buildPrayerRowWithActiveState("মাগরিব",
                              "${formatBanglaTime(prayerTimes!.maghrib)} - ${formatBanglaTime(prayerTimes!.isha)}", "মাগরিব"),
                          _buildPrayerRowWithActiveState("ইশা",
                              "${formatBanglaTime(prayerTimes!.isha)} - ${formatBanglaTime(prayerTimes!.fajr.add(const Duration(days: 1)))}", "ইশা"),
                        ] else ...[
                          _buildPrayerRow("ফজর", "লোড হচ্ছে..."),
                          _buildPrayerRow("যোহর", "লোড হচ্ছে..."),
                          _buildPrayerRow("আসর", "লোড হচ্ছে..."),
                          _buildPrayerRow("মাগরিব", "লোড হচ্ছে..."),
                          _buildPrayerRow("ইশা", "লোড হচ্ছে..."),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const VerticalDivider(width: 10),

              // ডান পাশ (সেভ করা স্থানীয় মসজিদের জামাতের সময়)
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          savedTimes['masqueName'] ?? "স্থানীয় মসজিদের জামাতের সময়",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Divider(),
                        _buildPrayerRow("ফজর", savedTimes['fajar'] ?? "--"),
                        _buildPrayerRow("যোহর", savedTimes['zuhr'] ?? "--"),
                        _buildPrayerRow("আসর", savedTimes['asr'] ?? "--"),
                        _buildPrayerRow("মাগরিব", savedTimes['maghrib'] ?? "--"),
                        _buildPrayerRow("ইশা", savedTimes['isha'] ?? "--"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for prayer rows with active state highlighting
  Widget _buildPrayerRowWithActiveState(String prayer, String time, String prayerKey) {
    final bool isActive = (currentPrayerName == prayer);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.green.withOpacity(0.2) : Colors.transparent,
          ),
          child: Row(
            children: [
              Text(
                prayer,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.green.shade700 : Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.green.shade600 : Colors.black54,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  // Regular prayer row for the right side (mosque times)
  static Widget _buildPrayerRow(String prayer, String time) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              prayer,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}