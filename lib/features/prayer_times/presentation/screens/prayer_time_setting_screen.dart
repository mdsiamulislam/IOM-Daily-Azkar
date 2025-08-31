import 'package:flutter/material.dart';
import 'package:iomdailyazkar/core/constants/constants.dart';

import '../../../../core/local_storage/local_prayer_time.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("নামাজের সময় সেট করুন", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
