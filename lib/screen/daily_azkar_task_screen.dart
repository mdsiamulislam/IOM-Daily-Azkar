import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iomdailyazkar/const/constants.dart'; // AppColors এর জন্য

class DailyAzkarTaskScreen extends StatefulWidget {
  const DailyAzkarTaskScreen({super.key});

  @override
  State<DailyAzkarTaskScreen> createState() => _DailyAzkarTaskScreenState();
}

class _DailyAzkarTaskScreenState extends State<DailyAzkarTaskScreen> {
  // প্রতিটি আজকার সম্পন্ন হয়েছে কিনা তা ট্র্যাক করার জন্য স্টেট ভেরিয়েবল
  bool _morningAzkar = false;
  bool _eveningAzkar = false;
  bool _prayerAzkar = false;
  // সমস্ত কাজ সম্পন্ন হয়েছে কিনা তা ট্র্যাক করার জন্য
  bool _allTasksCompleted = false;

  @override
  void initState() {
    super.initState();
    // স্ক্রিন লোড হওয়ার সাথে সাথে সেভ করা মানগুলো লোড করুন
    _loadSavedValues();
  }

  /// SharedPreferences থেকে সেভ করা আজকারের অবস্থা লোড করে।
  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _morningAzkar = prefs.getBool('morningAzkar') ?? false;
      _eveningAzkar = prefs.getBool('eveningAzkar') ?? false;
      _prayerAzkar = prefs.getBool('prayerAzkar') ?? false;
      // ডেটা লোড হওয়ার পরে সমস্ত কাজ সম্পন্ন হয়েছে কিনা তা আপডেট করুন
      _updateCompletionStatus();
    });
  }

  /// বর্তমান আজকারের অবস্থা SharedPreferences এ সেভ করে।
  Future<void> _saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morningAzkar', _morningAzkar);
    await prefs.setBool('eveningAzkar', _eveningAzkar);
    await prefs.setBool('prayerAzkar', _prayerAzkar);
    await prefs.setBool('allTasksCompleted', _allTasksCompleted);
  }

  /// সমস্ত আজকার সম্পন্ন হয়েছে কিনা তা পরীক্ষা করে এবং সেই অনুযায়ী স্টেট আপডেট করে।
  /// যদি সমস্ত কাজ সম্পন্ন হয়, তাহলে HomeScreen-কে জানানোর জন্য true সহ পপ করে।
  void _updateCompletionStatus() {
    final completed = _morningAzkar && _eveningAzkar && _prayerAzkar;

    // যদি স্ট্যাটাস পরিবর্তন হয়, তাহলে setState কল করুন
    if (_allTasksCompleted != completed) {
      setState(() {
        _allTasksCompleted = completed;
      });
      _saveValues(); // নতুন স্ট্যাটাস সেভ করুন

      if (completed) {
        // সমস্ত কাজ সম্পন্ন হলে HomeScreen কে জানানোর জন্য true সহ পপ করুন।
        // এটি HomeScreen-এর Navigator.push().then() ব্লকে ধরা পড়বে।
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } else {
      // যদি স্ট্যাটাস পরিবর্তন না হয় (যেমন, একটি কাজ আনচেক করা হয়েছে),
      // তাহলে শুধু সেভ করুন, পপ করার দরকার নেই।
      _saveValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.white), // AppColors ব্যবহার করা হয়েছে
        centerTitle: true,
        title: const Text(
          'প্রতিদিনের আজকার ও দোয়া',
          style: TextStyle(
            color: AppColors.white, // AppColors ব্যবহার করা হয়েছে
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700, // AppColors ব্যবহার করা হয়েছে
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0), // ListView-তে প্যাডিং যোগ করা হয়েছে
        children: [
          _buildAzkarTile(
            title: 'সকালের আজকার',
            subtitle: 'সকালের আজকার সম্পন্ন করুন।',
            icon: Icons.wb_sunny,
            value: _morningAzkar,
            onChanged: (value) {
              setState(() => _morningAzkar = value ?? false);
              _updateCompletionStatus();
            },
          ),
          _buildAzkarTile(
            title: 'বিকালের আজকার',
            subtitle: 'বিকালের আজকার সম্পন্ন করুন।',
            icon: Icons.nightlight_round,
            value: _eveningAzkar,
            onChanged: (value) {
              setState(() => _eveningAzkar = value ?? false);
              _updateCompletionStatus();
            },
          ),
          _buildAzkarTile(
            title: 'নামাজের আজকার',
            subtitle: 'নামাজের আজকার সম্পন্ন করুন।',
            icon: Icons.safety_check,
            value: _prayerAzkar,
            onChanged: (value) {
              setState(() => _prayerAzkar = value ?? false);
              _updateCompletionStatus();
            },
          ),
          // সমস্ত কাজ সম্পন্ন হলে একটি বার্তা দেখানোর জন্য
          if (_allTasksCompleted)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: AppColors.primaryGreen.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'আজকের সমস্ত আজকার সম্পন্ন হয়েছে! আলহামদুলিল্লাহ।',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// প্রতিটি আজকারের জন্য একটি কাস্টমাইজড CheckboxListTile তৈরি করে।
  Widget _buildAzkarTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4, // কার্ডের শ্যাডো যোগ করা হয়েছে
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // কার্ডের কোণা গোলাকার করা হয়েছে
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
        secondary: Icon(icon, color: Colors.green.shade700, size: 30), // AppColors ব্যবহার করা হয়েছে, আইকন সাইজ বাড়ানো হয়েছে
        activeColor: Colors.green.shade700, // AppColors ব্যবহার করা হয়েছে
        checkColor: AppColors.white, // চেকবক্সের টিক চিহ্ন সাদা করা হয়েছে
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // প্যাডিং বাড়ানো হয়েছে
      ),
    );
  }
}