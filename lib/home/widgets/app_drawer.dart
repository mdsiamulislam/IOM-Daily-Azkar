import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/about/presentation/screens/about_app_screen.dart';
import '../../features/about/presentation/screens/our_apps_screen.dart';
import '../../features/settings/presentation/screens/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.context,
    required this.mounted,
  });

  final BuildContext context;
  final bool mounted;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                ),
                const SizedBox(height: 4),
                Text('স্বাগতম আপনাকে, এখানে প্রতিদিনের জন্য দোয়া ও আজকার পেয়ে জাবেন ইনশাল্লাহ', textAlign: TextAlign.center, style: AppTextStyles.bold.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                )),
              ],
            ),
          ),

          // Setting Page
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('সেটিংস'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.apps),
            title: const Text('আমাদের অন্যান্য অ্যাপস'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OurAppsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.share),
            title: Text('অ্যাপ শেয়ার করুন'),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              final packageName = info.packageName;
              final shareText =
                  'IOM Daily Azkar App\n\nhttps://play.google.com/store/apps/details?id=$packageName';
              Share.share(shareText);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text('রেটিং দিন'),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              final packageName = info.packageName;
              final url = 'https://play.google.com/store/apps/details?id=$packageName';

              // Using canLaunchUrl and launchUrl directly as launchUrl is deprecated
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              } else {
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Play Store খুলতে ব্যর্থ হয়েছে।')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: Text('ফিডব্যাক দিন'),
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'mdsiamulislams@gmail.com',
                query: Uri.encodeFull('subject=Feedback for IOM Daily Azkar App'),
              );

              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              } else {
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ইমেইল অ্যাপ খুলতে ব্যর্থ হয়েছে।')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('অ্যাপ সম্পর্কে'),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}