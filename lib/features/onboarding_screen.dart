import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iomdailyazkar/core/local_storage/app_preferences.dart';
import 'package:iomdailyazkar/home_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade50,
                  Colors.white,
                  Colors.green.shade50,
                ],
              ),
            ),
          ),

          // Decorative elements in background
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Islamic pattern/design elements
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPatternPainter(),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with improved design
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/logo.png",
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "IOM Daily Azkar এ স্বাগতম",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "আপনার দৈনন্দিন ইবাদতের সহযোগী",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    // Features Section with card
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "এই অ্যাপের মাধ্যমে আপনি:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          _featureTile(Icons.access_time_filled_rounded, "নিত্য সালাতের সময় আপনার শহরের ভিত্তিতে।"),
                          _featureTile(Icons.location_city_rounded, "স্থানীয় মসজিদের জামাত সময় যোগ করতে পারবেন।"),
                          _featureTile(Icons.book_rounded, "দৈনিক হাদীস পড়তে পারবেন।"),
                          _featureTile(Icons.auto_awesome_rounded, "IOM এর ভিত্তিতে দৈনিক আজকার দেখতে পারবেন।"),
                          _featureTile(Icons.lightbulb_rounded, "ফতোয়া বিভাগে ফতোয়া পড়তে পারবেন।"),
                        ],
                      ),
                    ),

                    // Instructions with card
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions, color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "কীভাবে ব্যবহার করবেন:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          _instructionTile(Icons.location_city_rounded, "নিজের শহর নির্বাচন করে উপরের ডান পাশের location icon এ ক্লিক করুন।"),
                          _instructionTile(Icons.add_location_alt_rounded, "স্থানীয় মসজিদের সময় যোগ করলে উপরের ডান পাশের icon এ ক্লিক করুন।"),
                          _instructionTile(Icons.settings_rounded, "ফন্ট পরিবর্তন করতে সেটিংস page এ যান।"),
                          _instructionTile(Icons.refresh_rounded, "ডাটা refresh করতে app bar এর refresh icon এ ক্লিক করুন।"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Warnings with card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.shade100,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "সতর্কবার্তা:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _warningTile(Icons.info_rounded, "প্রথমবার ইন্টারনেট ব্যবহার করে অ্যাপ চালু করুন, যাতে সব ডাটা লোড হয়। পরবর্তীতে দোয়া দেখতে ইন্টারনেট ছাড়াই পারবে।"),
                          _warningTile(Icons.wifi_off_rounded, "ফতোয়া বিভাগ ব্যবহারের জন্য ইন্টারনেট আবশ্যক।"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Done Button with improved design
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade800,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            AppPreferences.setFirstTimeOpened();
                            Get.to(HomeScreen());
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Row(
                              children: [
                                Text(
                                  "শুরু করুন",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Feature row with improved design
  Widget _featureTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Instruction row with improved design
  Widget _instructionTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Warning row with improved design
  Widget _warningTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background pattern
class _DotsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const double spacing = 40;
    const double radius = 1.5;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
