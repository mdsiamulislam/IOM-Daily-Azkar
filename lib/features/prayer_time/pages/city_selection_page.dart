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
        child: Column(
          children: [
            Obx(() {
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade700, width: 1.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "সালাতের সময় গণনা সম্পর্কে তথ্য",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "এই অ্যাপ্লিকেশনটি সালাতের সময় নির্ধারণ করতে University of Karachi লাইব্রেরির offline calculation ব্যবহার করে। "
                              "লক্ষ্য করুন যে, এটি offline ভিত্তিক হিসাব, তাই সময় ২–৩ মিনিটের কম-বেশি পার্থক্য থাকতে পারে। "
                              "সঠিক সময় নিশ্চিত করতে স্থানীয় মসজিদের সময়সূচী বা সরকারি নির্ধারিত সময়সূচীর সাথে মিলিয়ে নেয়া উত্তম। "
                              "মাদহাব হিসেবে Hanafi ব্যবহার করা হয়েছে, যা কিছু ফিকহি পার্থক্যের জন্য প্রভাব ফেলতে পারে।",
                          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
