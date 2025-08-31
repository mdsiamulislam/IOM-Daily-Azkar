import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../prayer_times/presentation/widgets/prayer_time_widget.dart';

class DualTimeCard extends StatefulWidget {
  const DualTimeCard({super.key});

  @override
  State<DualTimeCard> createState() => _DualTimeCardState();
}

class _DualTimeCardState extends State<DualTimeCard> {

  bool isSingleTimeTable = false;

  @override
  Widget build(BuildContext context) {
    return
      isSingleTimeTable
          ? CombinedPrayerTimesWidget()
          : PrayerTimeWidget();
  }
}



class PrayerTimeWidget extends StatelessWidget {
  const PrayerTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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

        // ডান পাশ (মসজিদের জামাতের সময়)
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
                    "স্থানীয় মসজিদের জামাতের সময়",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Divider(),
                  _buildPrayerRow("ফজর", "৪:৩০ AM"),
                  _buildPrayerRow("যোহর", "১:১৫ PM"),
                  _buildPrayerRow("আসর", "৪:৪৫ PM"),
                  _buildPrayerRow("মাগরিব", "৬:৩৫ PM"),
                  _buildPrayerRow("ইশা", "৮:১৫ PM"),
                ],
              ),
            ),
          ),
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
