import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/city_data.dart';
import '../controllers/prayer_times_controller.dart';

class CitySelectionPage extends StatelessWidget {
  CitySelectionPage({super.key});

  final PrayerTimesController controller =
  Get.put(PrayerTimesController());

  @override
  Widget build(BuildContext context) {
    final cityKeys = CityCoordinates.cityMap.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('সিটি নির্বাচন করুন'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔘 RADIO BUTTONS
              RadioListTile<bool>(
                title: const Text('বর্তমান অবস্থান ব্যবহার করুন'),
                value: true,
                groupValue: controller.useCurrentLocation.value,
                onChanged: (_) => controller.enableLocation(),
              ),

              RadioListTile<bool>(
                title: const Text('সিটি ম্যানুয়ালি নির্বাচন করুন'),
                value: false,
                groupValue: controller.useCurrentLocation.value,
                onChanged: (_) => controller.disableLocation(),
              ),

              const SizedBox(height: 16),

              /// 📍 LOCATION UI
              if (controller.useCurrentLocation.value)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 12),
                      controller.isLocationLoading.value
                          ? const CircularProgressIndicator()
                          : const Expanded(
                        child: Text(
                          "আপনার বর্তমান অবস্থান নেওয়া হয়েছে",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

              /// 🏙️ CITY SELECTOR
              if (!controller.useCurrentLocation.value) ...[
                const SizedBox(height: 12),
                const Text(
                  'নির্বাচিত সিটি',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: controller.city.value,
                  items: cityKeys.map((key) {
                    return DropdownMenuItem(
                      value: key,
                      child: Text(
                        CityNamesBN.cityNamesBN[key] ?? key,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setCity(value);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    CityNamesBN.cityNamesBN[controller.city.value] ??
                        controller.city.value,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

