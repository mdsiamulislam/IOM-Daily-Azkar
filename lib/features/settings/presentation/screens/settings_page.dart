import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_text_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FontController fontController = Get.find();

  final List<String> banglaFonts = [
    'HindSiliguri',
    'Ador-Noirrit',
    'NotoSerifBengali',
    'Default'
  ];

  Future<void> _saveFont(String font) async {
    await fontController.updateFont(font);

    Get.snackbar(
      'সফল',
      'ফন্ট পরিবর্তন করা হয়েছে',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      messageText: Text(
        'ফন্ট পরিবর্তন করা হয়েছে',
        style: TextStyle(fontFamily: font, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('সেটিংস'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('বাংলা ফন্ট নির্বাচন'),

            const SizedBox(height: 8),

            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: fontController.fontFamily.value,
                  hint: const Text('ফন্ট নির্বাচন করুন'),
                  items: banglaFonts.map((font) {
                    return DropdownMenuItem<String>(
                      value: font,
                      child: Text(
                        font,
                        style: TextStyle(fontFamily: font),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    _saveFont(value);
                  },
                ),
              ),
            )),

            const SizedBox(height: 24),

            /// Preview
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'প্রিভিউ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'আলহামদুলিল্লাহ, এটি একটি বাংলা ফন্ট প্রিভিউ।',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: fontController.fontFamily.value,
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.green.shade700,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}