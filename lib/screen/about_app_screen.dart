import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  void _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আমাদের অ্যাপ সম্পর্কে',style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'IOM Daily Azkar',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'আমাদের অ্যাপটি ইসলামী দোয়া ও জিকিরের জন্য একটি সহজ এবং কার্যকরী অ্যাপ।  এটি ব্যবহারকারীদের জন্য বিভিন্ন দোয়া ও জিকিরের তালিকা প্রদান করে, যা তাদের দৈনন্দিন জীবনে সাহায্য করে। অ্যাপটির উদ্দেশ্য হলো মুসলিমদের জন্য একটি সহজ এবং কার্যকরী উপায় প্রদান করা যাতে তারা তাদের দৈনন্দিন জীবনে দোয়া ও জিকির করতে পারেন।',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Divider(),

            /// 🔗 প্রয়োজনীয় লিঙ্ক
            Text('প্রয়োজনীয় লিঙ্ক', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            // ListTile(
            //   leading: const Icon(Icons.video_library),
            //   title: const Text('ক্লাস রেকর্ডিং'),
            //   onTap: () => _openLink('https://example.com/class-recordings'),
            // ),
            // ListTile(
            //   leading: const Icon(Icons.note),
            //   title: const Text('নোটস ও রিসোর্স'),
            //   onTap: () => _openLink('https://example.com/notes'),
            // ),
            ListTile(
              leading: const Icon(Icons.telegram),
              title: const Text('টেলিগ্রাম গ্রুপ'),
              onTap: () => _openLink('https://t.me/+mmZEWQmF-SEwNjdl'),
            ),
            ListTile(
              leading: const Icon(Icons.web),
              title: const Text('ওয়েবসাইট'),
              onTap: () => _openLink('http://iom.edu.bd/'),
            ),
            // Privacy Policy
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('গোপনীয়তা নীতি'),
              onTap: () => _openLink('https://example.com/privacy-policy'),
            ),
            //
            // const Divider(),
            //
            // /// 👨‍💻 ডেভেলপার তথ্য
            // Text('ডেভেলপার তথ্য', style: Theme.of(context).textTheme.titleLarge),
            // const SizedBox(height: 10),
            // ListTile(
            //   leading: const Icon(Icons.person),
            //   title: const Text('Md Siamul Islam Soaib'),
            //   subtitle: const Text('Software Developer | BSC in CSE - DIU'),
            // ),
            // ListTile(
            //   leading: const Icon(Icons.link),
            //   title: const Text('GitHub: mdsiamulislam'),
            //   onTap: () => _openLink('https://github.com/mdsiamulislam'),
            // ),
            // ListTile(
            //   leading: const Icon(Icons.email),
            //   title: const Text('ইমেইল'),
            //   subtitle: const Text('siamuldev@gmail.com'),
            //   onTap: () => _openLink('mailto:mdsiamulislamsoaib@gmail.com'),
            // ),

            const Divider(),

            /// © কপিরাইট
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  const Text(
                    '© IOM Daily Azkar 2025 - All rights reserved',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      // Replace with your actual developer portfolio or GitHub link
                      launchUrl(Uri.parse('https://github.com/mdsiamulislam'));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
}
