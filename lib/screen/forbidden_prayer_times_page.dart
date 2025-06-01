import 'package:flutter/material.dart';
// Assuming AppTextStyles is available from this path
import 'package:iomdailyazkar/theme/app_text_styles.dart';

class ForbiddenPrayerTimesPage extends StatelessWidget {
  const ForbiddenPrayerTimesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2e7d32), // Dark green background, consistent with previous widget
      appBar: AppBar(
        title: Text(
          'নামাজের নিষিদ্ধ সময়',
          style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1b5e20), // Slightly darker green for app bar
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ইসলামে কিছু নির্দিষ্ট সময় রয়েছে যখন নফল নামাজ আদায় করা নিষিদ্ধ বা মাকরুহ। এই সময়গুলো সম্পর্কে নিচে বিস্তারিত আলোচনা করা হলো:',
              style: AppTextStyles.regular.copyWith(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            _buildForbiddenTimeSection(
              context,
              '১. ফজরের নামাজের পর থেকে সূর্যোদয় পর্যন্ত',
              'ফজরের নামাজ আদায় করার পর থেকে সূর্য সম্পূর্ণ উদিত না হওয়া পর্যন্ত নফল নামাজ পড়া হারাম। তবে এই সময়ে কাজা নামাজ বা জানাজার নামাজ পড়া জায়েজ।',
            ),
            const SizedBox(height: 15),

            _buildForbiddenTimeSection(
              context,
              '২. ঠিক দ্বিপ্রহরের সময় (সূর্য যখন মাথার উপর)',
              'সূর্য যখন ঠিক মাথার উপর থাকে, অর্থাৎ দ্বিপ্রহরের সময়, তখন নামাজ পড়া মাকরুহ তাহরিমি (হারামের কাছাকাছি)। এই সময়টি খুবই সংক্ষিপ্ত। তবে এই সময়ে কাজা নামাজ বা জানাজার নামাজ পড়া জায়েজ।',
            ),
            const SizedBox(height: 15),

            _buildForbiddenTimeSection(
              context,
              '৩. আসরের নামাজের পর থেকে সূর্যাস্ত পর্যন্ত',
              'আসরের নামাজ আদায় করার পর থেকে সূর্য সম্পূর্ণ অস্ত না যাওয়া পর্যন্ত নফল নামাজ পড়া হারাম। তবে এই সময়ে কাজা নামাজ বা জানাজার নামাজ পড়া জায়েজ।',
            ),
            const SizedBox(height: 20),

            Text(
              'গুরুত্বপূর্ণ নোট:',
              style: AppTextStyles.bold.copyWith(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'উপরিউক্ত নিষিদ্ধ সময়গুলোতে শুধুমাত্র নফল নামাজ আদায় করা নিষেধ। ফরয, ওয়াজিব, কাজা নামাজ, জানাজার নামাজ, বা তওয়াফের নামাজ এই নিষেধাজ্ঞার আওতায় পড়ে না এবং এই সময়গুলোতে সেগুলো আদায় করা যায়।',
              style: AppTextStyles.regular.copyWith(fontSize: 15, color: Colors.white70),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            Text(
              'এই নির্দেশিকাটি আপনাকে নামাজের নিষিদ্ধ সময় সম্পর্কে একটি স্পষ্ট ধারণা দিতে সাহায্য করবে।',
              style: AppTextStyles.regular.copyWith(fontSize: 15, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each forbidden time section
  Widget _buildForbiddenTimeSection(BuildContext context, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Slightly transparent white background for sections
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bold.copyWith(fontSize: 17, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.regular.copyWith(fontSize: 15, color: Colors.white70),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
