import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyAzkarTaskScreen extends StatefulWidget {
  const DailyAzkarTaskScreen({super.key});

  @override
  State<DailyAzkarTaskScreen> createState() => _DailyAzkarTaskScreenState();
}

class _DailyAzkarTaskScreenState extends State<DailyAzkarTaskScreen> {
  bool _morningAzkar = false;
  bool _eveningAzkar = false;
  bool _prayerAzkar = false;
  bool _allTasksCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _morningAzkar = prefs.getBool('morningAzkar') ?? false;
      _eveningAzkar = prefs.getBool('eveningAzkar') ?? false;
      _prayerAzkar = prefs.getBool('prayerAzkar') ?? false;
      _updateCompletionStatus(); // ডেটা লোড হওয়ার পরে স্ট্যাটাস আপডেট করুন
    });
  }

  Future<void> _saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morningAzkar', _morningAzkar);
    await prefs.setBool('eveningAzkar', _eveningAzkar);
    await prefs.setBool('prayerAzkar', _prayerAzkar);
    await prefs.setBool('allTasksCompleted', _allTasksCompleted);
  }

  void _updateCompletionStatus() {
    final completed = _morningAzkar && _eveningAzkar && _prayerAzkar;

    setState(() {
      _allTasksCompleted = completed;
    });

    _saveValues(); // স্ট্যাটাস সেভ করুন

    if (completed) {
      // সমস্ত কাজ সম্পন্ন হলে HomeScreen কে জানানোর জন্য
      // নিশ্চিত করুন যে আপনি Navigator.pop(context, true) ব্যবহার করছেন
      // শুধুমাত্র যদি এটি একটি ModalRoute থেকে পপ করা হয়।
      // এই ক্ষেত্রে, HomeScreen থেকে push করা হয়েছে, তাই এটি কাজ করবে।
      if (Navigator.canPop(context)) { // নিশ্চিত করুন যে পপ করা যাবে
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text('প্রতিদিনের আজকার ও দোয়া',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.green[700],
      ),
      body: ListView( // <--- Expanded উইজেটটি সরিয়ে দেওয়া হয়েছে
        children: [
          _buildAzkarTile(
            title: 'সকালের আজকার',
            subtitle: 'সকালের আজকার সম্পন্ন করুন ।',
            icon: Icons.wb_sunny,
            value: _morningAzkar,
            onChanged: (value) {
              setState(() => _morningAzkar = value ?? false);
              _updateCompletionStatus();
            },
          ),
          _buildAzkarTile(
            title: 'বিকালের আজকার',
            subtitle: ' বিকালের আজকার সম্পন্ন করুন ।',
            icon: Icons.nightlight_round,
            value: _eveningAzkar,
            onChanged: (value) {
              setState(() => _eveningAzkar = value ?? false);
              _updateCompletionStatus();
            },
          ),
          _buildAzkarTile(
            title: ' নামাজের আজকার',
            subtitle: ' নামাজের আজকার সম্পন্ন করুন ।',
            icon: Icons.safety_check,
            value: _prayerAzkar,
            onChanged: (value) {
              setState(() => _prayerAzkar = value ?? false);
              _updateCompletionStatus();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: Colors.green[700]),
        activeColor: Colors.green[700],
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}