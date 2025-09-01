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
  final RxString _selectedCity = 'Dhaka'.obs; // Default to Dhaka
  final Rx<TimeTableOption> _selectedOption = TimeTableOption.dual.obs;

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
    _loadPreference();
    _loadSelectedCity();
  }

  @override
  void dispose() {
    _masqueController.dispose();
    _fajarController.dispose();
    _zuhrController.dispose();
    _asrController.dispose();
    _maghribController.dispose();
    _ishaController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedTimes() async {
    final data = await _localPrayerTime.getPrayerTime();
    setState(() {
      _masqueController.text = data['masqueName'] ?? '';
      _fajarController.text = data['fajar'] ?? '';
      _zuhrController.text = data['zuhr'] ?? '';
      _asrController.text = data['asr'] ?? '';
      _maghribController.text = data['maghrib'] ?? '';
      _ishaController.text = data['isha'] ?? '';
    });
  }

  Future<void> _loadSelectedCity() async {
    final city = await UserPref().getLocation();
    _selectedCity.value = city;
  }

  Future<void> _saveTimes() async {
    try {
      await _localPrayerTime.savePrayerTime(
        masqueName: _masqueController.text,
        fajar: _fajarController.text,
        zuhr: _zuhrController.text,
        asr: _asrController.text,
        maghrib: _maghribController.text,
        isha: _ishaController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("নামাজের সময় সংরক্ষিত হয়েছে ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ত্রুটি: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSelectedCity(String city) async {
     UserPref().setLocation(city);
    _selectedCity.value = city;
  }

  Future<void> _loadPreference() async {
    try {
      final pref = await UserPref().getPrayerTimeSingle();
      _selectedOption.value = pref ? TimeTableOption.single : TimeTableOption.dual;
      _changeWidget.isSingleTimeTable.value = pref;
    } catch (e) {
      // Default to dual if there's an error
      _selectedOption.value = TimeTableOption.dual;
      _changeWidget.isSingleTimeTable.value = false;
    }
  }

  _setCity(String city) {
    if (CityCoordinates.cityMap.containsKey(city)) {
      _selectedCity.value = city;
      UserPref().setLocation(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "নামাজের সময় সেট করুন",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio buttons for time table type selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "নামাজের সময়সূচি দেখার ধরন",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      return Column(
                        children: [
                          RadioListTile<TimeTableOption>(
                            title: const Text("Single Time Card (শুধু নামাজের সময়)"),
                            subtitle: const Text("একটি কার্ডে সব নামাজের সময়"),
                            value: TimeTableOption.single,
                            groupValue: _selectedOption.value,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              _selectedOption.value = value!;
                              UserPref().setPrayerTimeSingle(true);
                              _changeWidget.isSingleTimeTable.value = true;
                            },
                          ),
                          RadioListTile<TimeTableOption>(
                            title: const Text("Dual Time Card (দুটি কার্ড)"),
                            subtitle: const Text("শহরের সময় + মসজিদের জামাতের সময়"),
                            value: TimeTableOption.dual,
                            groupValue: _selectedOption.value,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              _selectedOption.value = value!;
                              UserPref().setPrayerTimeSingle(false);
                              _changeWidget.isSingleTimeTable.value = false;
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Preview Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.preview, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "প্রিভিউ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      return _selectedOption.value == TimeTableOption.dual
                          ? DualTimeCard()
                          : const CombinedPrayerTimesWidget();
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // City Selection and Mosque Times (only for dual option)
            Obx(() {
              if (_selectedOption.value == TimeTableOption.dual) {
                return Column(
                  children: [
                    // City Selection Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_city, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "শহর নির্বাচন করুন",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: CityCoordinates.cityMap.containsKey(_selectedCity.value)
                                  ? _selectedCity.value
                                  : CityCoordinates.cityMap.keys.first,
                              decoration: InputDecoration(
                                labelText: "নামাযের সময়ের জন্য শহর নির্বাচন করুন",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                              ),
                              items: CityCoordinates.cityMap.keys.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city, style: const TextStyle(fontSize: 16)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _saveSelectedCity(value);
                                  _setCity(value);

                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mosque Times Input Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.mosque, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "মসজিদের জামাতের সময়",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTextField("মসজিদের নাম", _masqueController),
                            _buildTextField("ফজর", _fajarController, hint: "যেমনঃ ৪:৩০ AM"),
                            _buildTextField("যোহর", _zuhrController, hint: "যেমনঃ ১:১৫ PM"),
                            _buildTextField("আসর", _asrController, hint: "যেমনঃ ৪:৪৫ PM"),
                            _buildTextField("মাগরিব", _maghribController, hint: "যেমনঃ ৬:৩০ PM"),
                            _buildTextField("ইশা", _ishaController, hint: "যেমনঃ ৮:১৫ PM"),

                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _saveTimes,
                                icon: const Icon(Icons.save, color: Colors.white),
                                label: const Text(
                                    "সংরক্ষণ করুন",
                                    style: TextStyle(fontSize: 18, color: Colors.white)
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          prefixIcon: _getPrayerIcon(label),
        ),
      ),
    );
  }

  Widget? _getPrayerIcon(String label) {
    switch (label) {
      case "মসজিদের নাম":
        return const Icon(Icons.mosque, color: Colors.green);
      case "ফজর":
        return const Icon(Icons.wb_twilight, color: Colors.orange);
      case "যোহর":
        return const Icon(Icons.wb_sunny, color: Colors.amber);
      case "আসর":
        return const Icon(Icons.wb_cloudy, color: Colors.orange);
      case "মাগরিব":
        return const Icon(Icons.sunny_snowing, color: Colors.deepOrange);
      case "ইশা":
        return const Icon(Icons.nightlight, color: Colors.indigo);
      default:
        return null;
    }
  }
}