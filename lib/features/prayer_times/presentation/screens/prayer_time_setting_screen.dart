import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iomdailyazkar/core/constants/constants.dart';

import '../../../../core/constants/city_data.dart';
import '../../../../core/local_storage/local_prayer_time.dart';
import '../../../../core/local_storage/user_pref.dart';
import '../../../home/widget/dual_time_card.dart';
import '../../controllers/change_widget.dart';
import '../widgets/prayer_time_widget.dart';

enum TimeTableOption { single, dual }

class PrayerTimeSettingScreen extends StatefulWidget {
  const PrayerTimeSettingScreen({super.key});

  @override
  State<PrayerTimeSettingScreen> createState() => _PrayerTimeSettingScreenState();
}

class _PrayerTimeSettingScreenState extends State<PrayerTimeSettingScreen> {
  final _masqueController = TextEditingController();
  final _fajarController = TextEditingController();
  final _zuhrController = TextEditingController();
  final _asrController = TextEditingController();
  final _maghribController = TextEditingController();
  final _ishaController = TextEditingController();

  final LocalPrayerTime _localPrayerTime = LocalPrayerTime();
  final ChangeWidget _changeWidget = Get.put(ChangeWidget());

  // Reactive variables
  final RxString _selectedCity = CityCoordinates.cityMap.keys.first.obs;
  final Rx<TimeTableOption> _selectedOption = TimeTableOption.dual.obs;

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
    _loadPreference();
  }

  Future<void> _loadSavedTimes() async {
    final data = await _localPrayerTime.getPrayerTime();
    _masqueController.text = data['masqueName'] ?? '';
    _fajarController.text = data['fajar'] ?? '';
    _zuhrController.text = data['zuhr'] ?? '';
    _asrController.text = data['asr'] ?? '';
    _maghribController.text = data['maghrib'] ?? '';
    _ishaController.text = data['isha'] ?? '';
  }

  Future<void> _saveTimes() async {
    await _localPrayerTime.savePrayerTime(
      masqueName: _masqueController.text,
      fajar: _fajarController.text,
      zuhr: _zuhrController.text,
      asr: _asrController.text,
      maghrib: _maghribController.text,
      isha: _ishaController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("নামাজের সময় সংরক্ষিত হয়েছে ✅")),
    );
  }

  Future<void> _loadPreference() async {
    final pref = await UserPref().getPrayerTimeSingle();
    _selectedOption.value = pref ? TimeTableOption.single : TimeTableOption.dual;
    _changeWidget.isSingleTimeTable.value = pref;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "নামাজের সময় সেট করুন",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Radio buttons
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "নামাজের সময়সূচি দেখার ধরন",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  RadioListTile<TimeTableOption>(
                    title: const Text("Single Time Card"),
                    value: TimeTableOption.single,
                    groupValue: _selectedOption.value,
                    onChanged: (value) {
                      _selectedOption.value = value!;
                      UserPref().setPrayerTimeSingle(true);
                      _changeWidget.isSingleTimeTable.value = true;
                    },
                  ),
                  RadioListTile<TimeTableOption>(
                    title: const Text("Dual Time Card"),
                    value: TimeTableOption.dual,
                    groupValue: _selectedOption.value,
                    onChanged: (value) {
                      _selectedOption.value = value!;
                      UserPref().setPrayerTimeSingle(false);
                      _changeWidget.isSingleTimeTable.value = false;
                    },
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // Time Table Widget
            Obx(() {
              return _selectedOption.value == TimeTableOption.dual
                  ? const PrayerTimeWidget()
                  : const CombinedPrayerTimesWidget();
            }),

            const SizedBox(height: 20),

            // City and Input Fields (only for dual)
            Obx(() {
              if (_selectedOption.value == TimeTableOption.dual) {
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCity.value,
                      decoration: InputDecoration(
                        labelText: "নামাযের সময়ের জন্য শহর নির্বাচন করুন",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: CityCoordinates.cityMap.keys.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city, style: const TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _selectedCity.value = value!;
                        UserPref().setUserCurrentCity(value);
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField("মসজিদের নাম", _masqueController),
                    _buildTextField("ফজর", _fajarController, hint: "যেমনঃ ৪:৩০ AM"),
                    _buildTextField("যোহর", _zuhrController, hint: "যেমনঃ ১:১৫ PM"),
                    _buildTextField("আসর", _asrController, hint: "যেমনঃ ৪:৪৫ PM"),
                    _buildTextField("মাগরিব", _maghribController, hint: "যেমনঃ ৬:৩০ PM"),
                    _buildTextField("ইশা", _ishaController, hint: "যেমনঃ ৮:১৫ PM"),

                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveTimes,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("সংরক্ষণ করুন", style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
