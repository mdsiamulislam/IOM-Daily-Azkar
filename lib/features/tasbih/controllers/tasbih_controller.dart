import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihController extends GetxController {
  var count = 0.obs;
  var targetCount = 33.obs;
  var isAnimating = false.obs;
  var isVibrating = true.obs;
  var beadAnimation = <int>[].obs;

  final List<int> _targetPresets = [33, 99, 100];
  int _presetIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _loadCount();
    _loadSettings();
  }

  void increment() {
    if (count.value >= targetCount.value) {
      _celebrateCompletion();
      return;
    }

    count.value++;
    _saveCount();

    // Add animation effect
    beadAnimation.add(count.value);
    Future.delayed(Duration(milliseconds: 300), () {
      beadAnimation.remove(count.value);
    });

    // Check if target reached
    if (count.value == targetCount.value) {
      _celebrateCompletion();
    }
  }

  void reset() {
    count.value = 0;
    _saveCount();
    Get.snackbar(
      'রিসেট সম্পন্ন',
      'গণনা আবার শুরু করুন',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void changeTarget() {
    _presetIndex = (_presetIndex + 1) % _targetPresets.length;
    targetCount.value = _targetPresets[_presetIndex];
    _saveSettings();
  }

  void toggleVibration() {
    isVibrating.value = !isVibrating.value;
    _saveSettings();
  }

  Future<void> _celebrateCompletion() async {
    isAnimating.value = true;

    // Show completion dialog
    Future.delayed(Duration(milliseconds: 500), () {
      Get.dialog(
        _CompletionDialog(targetCount: targetCount.value),
        barrierDismissible: true,
      );
    });

    Future.delayed(Duration(milliseconds: 2000), () {
      isAnimating.value = false;
    });
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    count.value = prefs.getInt('tasbihCount') ?? 0;
    targetCount.value = prefs.getInt('targetCount') ?? 33;
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbihCount', count.value);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isVibrating.value = prefs.getBool('vibrationEnabled') ?? true;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetCount', targetCount.value);
    await prefs.setBool('vibrationEnabled', isVibrating.value);
  }
}

class _CompletionDialog extends StatelessWidget {
  final int targetCount;

  const _CompletionDialog({required this.targetCount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              "মাশাআল্লাহ!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "$targetCount বার তসবিহ সম্পন্ন হয়েছে",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text("ঠিক আছে"),
            ),
          ],
        ),
      ),
    );
  }
}