import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iomdailyazkar/features/prayer_times/controllers/change_widget.dart';

import '../../../core/local_storage/local_prayer_time.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
  }

  Future<void> _loadSavedTimes() async {
    final data = await LocalPrayerTime().getPrayerTime();
    setState(() {
      savedTimes = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // বাম পাশ (শহরের নামাজের সময়)
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
                        "আপনার শহরের নামাজের সময়",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Divider(),
                      _buildPrayerRow("ফজর", "৪:৩০ AM - ৫:০০ AM"),
                      _buildPrayerRow("যোহর", "১২:৪৫ PM - ১:৩০ PM"),
                      _buildPrayerRow("আসর", "৪:১৫ PM - ৪:৪৫ PM"),
                      _buildPrayerRow("মাগরিব", "৬:৩০ PM - ৬:৫০ PM"),
                      _buildPrayerRow("ইশা", "৮:০০ PM - ৮:৩০ PM"),
                    ],
                  ),
                ),
              ),
            ),

            const VerticalDivider(width: 10),

            // ডান পাশ (সেভ করা স্থানীয় মসজিদের জামাতের সময়)
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
                        savedTimes['masqueName'] ?? "স্থানীয় মসজিদের জামাতের সময়",
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
      ],
    );
  }

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

