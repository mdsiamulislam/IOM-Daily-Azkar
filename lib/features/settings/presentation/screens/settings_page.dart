import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iomdailyazkar/core/universal_widgets/app_snackbar.dart';

import '../../../../core/theme/app_text_styles.dart';

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
    'Default',
  ];

  final List<String> arabicFonts = [
    'Amiri',
    'Scheherazade_New',
    'Uthmanic',
    'IndoPak',
    'Default',
  ];

  /// Default হলে null return করবে
  String? _resolveFont(String font) {
    return font == 'Default' ? null : font;
  }

  Future<void> _saveFont({
    required String banglaFont,
    required String arabicFont,
  }) async {
    await fontController.updateFont(
      banglaFont: banglaFont,
      arabicFont: arabicFont,
    );

    AppSnackbar.showInfo('ফন্ট সফলভাবে সংরক্ষিত হয়েছে।');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('বাংলা ফন্ট নির্বাচন'),
            const SizedBox(height: 8),

            Obx(() => _fontDropdown(
              fonts: banglaFonts,
              selectedFont: fontController.fontFamily.value,
              onChanged: (value) {
                _saveFont(
                  banglaFont: value,
                  arabicFont: fontController.arabicFontFamily.value,
                );
              },
            )),

            const SizedBox(height: 24),

            Obx(() => _fontPreview(
              title: 'ফন্ট প্রিভিউ',
              text: 'এই ফন্টটি বাংলা টেক্সট প্রদর্শনের জন্য ব্যবহৃত হবে।',
              font: fontController.fontFamily.value,
            )),

            const SizedBox(height: 32),

            _sectionTitle('আরবি ফন্ট নির্বাচন'),
            const SizedBox(height: 8),

            Obx(() => _fontDropdown(
              fonts: arabicFonts,
              selectedFont: fontController.arabicFontFamily.value,
              onChanged: (value) {
                _saveFont(
                  banglaFont: fontController.fontFamily.value,
                  arabicFont: value,
                );
              },
            )),

            const SizedBox(height: 24),

            Obx(() => _fontPreview(
              title: 'ফন্ট প্রিভিউ',
              text: '''
                بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ ۞
                ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ ۝
                ''',
              font: fontController.arabicFontFamily.value,
              isArabic: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _fontDropdown({
    required List<String> fonts,
    required String selectedFont,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: fonts.contains(selectedFont) ? selectedFont : null,
          items: fonts.map((font) {
            return DropdownMenuItem(
              value: font,
              child: Text(
                font,
                style: TextStyle(fontFamily: _resolveFont(font)),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }

  Widget _fontPreview({
    required String title,
    required String text,
    required String font,
    bool isArabic = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: isArabic ? 20 : 16,
            height: isArabic ? 1.8 : 1.4,
            fontFamily: _resolveFont(font),
          ),
        ),
      ],
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
