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
          // 🔄 waiting for prefs load
          if (controller.city.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final selectedCity = cityKeys.contains(controller.city.value)
              ? controller.city.value
              : 'Dhaka';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'নির্বাচিত সিটি',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedCity,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                    controller.setCity(value); // 🔥 SAVE here
                  }
                },
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  CityNamesBN.cityNamesBN[selectedCity] ?? selectedCity,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
