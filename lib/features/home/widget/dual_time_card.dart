import 'package:adhan/adhan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iomdailyazkar/core/local_storage/user_pref.dart';
import '../../../core/constants/city_data.dart';
import '../../../core/local_storage/local_prayer_time.dart';
import '../../prayer_times/presentation/widgets/prayer_time_widget.dart';
class DualTimeCard extends StatelessWidget {
  bool isSingleTimeTable;
  String city;
  DualTimeCard({super.key, required this.isSingleTimeTable, required this.city});

  @override
  Widget build(BuildContext context) {
    return isSingleTimeTable
          ? CombinedPrayerTimesWidget(
      city: city,
    )
          : PrayerTimeWidget(
              city: city,
    );
  }
}






class PrayerTimeWidget extends StatefulWidget {
  String city;
  PrayerTimeWidget({
    required this.city,
    super.key
  });

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
    final coordinates = CityCoordinates.cityMap[widget.city] ?? Coordinates(23.8103, 90.4125);
    final params = CalculationMethod.kuwait.getParameters();
    params.madhab = Madhab.hanafi;
    final prayerTimes = PrayerTimes.today(coordinates, params);

    String _convertToBangla(String input) {
      const english = ['0','1','2','3','4','5','6','7','8','9','AM','PM'];
      const bangla = ['০','১','২','৩','৪','৫','৬','৭','৮','৯','এএম','পিএম'];
      for (int i = 0; i < english.length; i++) {
        input = input.replaceAll(english[i], bangla[i]);
      }
      return input;
    }


   final prayerTimesBangla = [
     _convertToBangla(DateFormat.jm().format(prayerTimes.fajr)),
     _convertToBangla(DateFormat.jm().format(prayerTimes.sunrise)),
     _convertToBangla(DateFormat.jm().format(prayerTimes.dhuhr)),
     _convertToBangla(DateFormat.jm().format(prayerTimes.asr)),
     _convertToBangla(DateFormat.jm().format(prayerTimes.maghrib)),
     _convertToBangla(DateFormat.jm().format(prayerTimes.isha)),
   ];

    return Column(
      children: [
        Row(
          children: [
            // বাম পাশ (শহরের নামাজের সময়)
            Expanded(
              flex: 4,
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
                        "${CityNamesBN.cityNamesBN[widget.city] ?? "ঢাকা"} এর নামাজের সময়",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Divider(),
                      _buildPrayerRow("ফজর", prayerTimesBangla[0] + " - " + prayerTimesBangla[1]),
                      _buildPrayerRow("যোহর", prayerTimesBangla[2] + " - " + prayerTimesBangla[3]),
                      _buildPrayerRow("আসর", prayerTimesBangla[3] + " - " + prayerTimesBangla[4]),
                      _buildPrayerRow("মাগরিব", prayerTimesBangla[4] + " - " + prayerTimesBangla[5]),
                      _buildPrayerRow("ইশা", prayerTimesBangla[5] + " - " + prayerTimesBangla[0]),
                    ],
                  ),
                ),
              ),
            ),

            const VerticalDivider(width: 10),

            // ডান পাশ (সেভ করা স্থানীয় মসজিদের জামাতের সময়)
            Expanded(
              flex: 3,
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
                          fontSize: 10,
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

