// lib/screen/our_apps_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const/constants.dart'; // আপনার AppColors এর জন্য

class OurAppsScreen extends StatelessWidget {
  const OurAppsScreen({Key? key}) : super(key: key);

  // আপনার অন্যান্য অ্যাপগুলোর তালিকা
  final List<Map<String, String>> otherApps = const [
    {
      'name': 'Mersus Eduverse',
      'description': 'Marsus EduVerse is your gateway to an inspiring Islamic digital universe – where knowledge meets faith, and learning becomes both engaging and meaningful.',
      'packageName': 'com.proappsbuild.marsuseduverse', // আপনার অ্যাপের আসল প্যাকেজ নাম এখানে দিন
      'imageUrl': 'assets/mersus_eduverse.png', // আপনার অ্যাপের লোগো ইমেজ পাথ
    },
    {
      'name': 'Kaler Diganta',
      'description': 'কালের দিগন্ত অ্যাপের মাধ্যমে সর্বশেষ খবর সবসময় আপনার হাতে। জাতীয় এবং আন্তর্জাতিক খবরের পাশাপাশি, ঢাকাসহ দেশের সকল বিভাগীয় খবর এখন এক জায়গায়। দ্রুত এবং সহজে খবর দেখার অভিজ্ঞতা প্রদান করে এই অ্যাপ।',
      'packageName': 'com.proappsbuild.kalerdiganta', // আপনার অ্যাপের আসল প্যাকেজ নাম এখানে দিন
      'imageUrl': 'assets/kaler_diganta.png', // আপনার অ্যাপের লোগো ইমেজ পাথ
    },
    // আপনার যদি আরও অ্যাপ থাকে, তাহলে এখানে যোগ করুন:
    // {
    //   'name': 'আপনার অন্য অ্যাপের নাম',
    //   'description': 'আপনার অন্য অ্যাপের সংক্ষিপ্ত বিবরণ।',
    //   'packageName': 'com.yourcompany.anotherapp',
    //   'imageUrl': 'assets/another_app_logo.png',
    // },
  ];

  Future<void> _launchURL(String packageName) async {
    final url = 'https://play.google.com/store/apps/details?id=$packageName';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // যদি প্লে স্টোর খোলা না যায়, তাহলে একটি মেসেজ দেখান
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // হালকা সবুজ ব্যাকগ্রাউন্ড
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'আমাদের অন্যান্য অ্যাপস',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: otherApps.isEmpty
          ? const Center(child: Text('বর্তমানে কোনো অ্যাপ উপলব্ধ নেই।'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: otherApps.length,
        itemBuilder: (context, index) {
          final app = otherApps[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            shadowColor: Colors.black26,
            child: InkWell(
              onTap: () => _launchURL(app['packageName']!),
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // অ্যাপ লোগো
                    if (app['imageUrl'] != null && app['imageUrl']!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          app['imageUrl']!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.apps, size: 70, color: AppColors.primaryGreen), // যদি ইমেজ লোড না হয়
                        ),
                      )
                    else
                      const Icon(Icons.apps, size: 70, color: AppColors.primaryGreen),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app['name'] ?? 'অ্যাপের নাম নেই',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            app['description'] ?? 'বিস্তারিত বিবরণ নেই।',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'প্লে স্টোরে দেখুন',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.primaryGreen, size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}