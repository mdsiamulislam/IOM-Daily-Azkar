import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/constants.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});


  void _openLink(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'আমাদের অ্যাপ সম্পর্কে'
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen, // অ্যাপের থিমের সাথে সামঞ্জস্যপূর্ণ
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // অ্যাপ লোগো এবং নাম
            Center(
              child: Column(
                children: [
                  const CircleAvatar( // const যোগ করা হয়েছে
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/logo.png'), // আপনার অ্যাপের লোগো
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'IOM Daily Azkar',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryGreen, // থিমের সাথে কালার
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'আপনার দৈনন্দিন জীবনের সঙ্গী', // একটি ট্যাগলাইন যোগ করা হলো
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// 📖 অ্যাপ পরিচিতি
            const Text( // const যোগ করা হয়েছে
              'আমাদের অ্যাপটি ইসলামী দোয়া ও জিকিরের জন্য একটি সহজ এবং কার্যকরী অ্যাপ। এটি ব্যবহারকারীদের জন্য বিভিন্ন দোয়া ও জিকিরের তালিকা প্রদান করে, যা তাদের দৈনন্দিন জীবনে সাহায্য করে। অ্যাপটির উদ্দেশ্য হলো মুসলিমদের জন্য একটি সহজ এবং কার্যকরী উপায় প্রদান করা যাতে তারা তাদের দৈনন্দিন জীবনে দোয়া ও জিকির করতে পারেন।',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.primaryGreen), // const যোগ করা হয়েছে
            const SizedBox(height: 16),

            /// 🔗 প্রয়োজনীয় লিঙ্ক
            Text(
              'প্রয়োজনীয় লিঙ্ক',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildLinkTile(
              context,
              icon: Icons.telegram,
              title: 'টেলিগ্রাম গ্রুপ',
              url: 'https://t.me/+DtkT6BwXw6QwZTZl', // আপনার টেলিগ্রাম লিঙ্ক
            ),
            _buildLinkTile(
              context,
              icon: Icons.web,
              title: 'ওয়েবসাইট',
              url: 'https://appsalsabil.blogspot.com/', // আপনার ওয়েবসাইট লিঙ্ক
            ),
            _buildLinkTile(
              context,
              icon: Icons.privacy_tip,
              title: 'গোপনীয়তা নীতি',
              url: 'https://appsalsabil.blogspot.com/p/privacy-policy-iom-daily-azkar.html', // আপনার গোপনীয়তা নীতির লিঙ্ক
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.primaryGreen), // const যোগ করা হয়েছে
            const SizedBox(height: 16),

            /// 🏢 প্যারেন্ট কোম্পানি ফুটপ্রিন্ট
            Text(
              'আমাদের প্রতিষ্ঠান',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  const CircleAvatar( // const যোগ করা হয়েছে
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/iom_logo.png'), // আপনার প্যারেন্ট কোম্পানির লোগো
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Islamic Online Madrasah (IOM)', // প্যারেন্ট কোম্পানির নাম
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'ইসলামী শিক্ষা ও সংস্কৃতির প্রসারে নিবেদিত', // প্যারেন্ট কোম্পানির ট্যাগলাইন/মিশন
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => _openLink('http://iom.edu.bd/', context), // context যোগ করা হয়েছে
                    icon: const Icon(Icons.link, color: Colors.blue),
                    label: const Text(
                      'আরও জানুন',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.primaryGreen), // const যোগ করা হয়েছে
            const SizedBox(height: 16),

            /// © কপিরাইট ও ডেভেলপার তথ্য
            Center(
              child: Column(
                children: [
                  Text( // const যোগ করা হয়েছে
                    '© IOM Daily Azkar ${ DateTime.now().year } - All rights reserved',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      _openLink('https://github.com/mdsiamulislam', context); // context যোগ করা হয়েছে
                    },
                    child: const Row( // const যোগ করা হয়েছে
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.code, size: 18, color: Colors.black54),
                        SizedBox(width: 5),
                        Text(
                          'Developed by Md Siamul Islam Soaib',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // লিঙ্ক টাইলের জন্য একটি রিইউজেবল উইজেট
  // এটিই একমাত্র _buildLinkTile ফাংশন যা থাকবে
  Widget _buildLinkTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String url,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: () => _openLink(url, context), // context যোগ করা হয়েছে
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}