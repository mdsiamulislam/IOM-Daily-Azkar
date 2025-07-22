import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../about/presentation/screens/about_app_screen.dart';
import '../../../about/presentation/screens/our_apps_screen.dart';
import '../../../dua/presentation/screens/dua_list_screen.dart';
import '../../../ifatwa/presentation/screens/i_fatwa_list_screen.dart';
import '../../../prayer_times/presentation/widgets/prayer_time_widget.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> categories = [];
  List<dynamic> hadithList = [];
  List<dynamic> duaData = [];
  List<dynamic> fatwaData = [];
  List<dynamic> data = [];
  bool isLoading = true;
  int randomIndex = 0;
  late Timer _dailyResetTimer;

  int generateRandomIndex(int max) => (DateTime.now().millisecondsSinceEpoch % max).toInt();

  @override
  void initState() {
    super.initState(); // This now also loads user level
    loadDataFromDevice();
  }

  @override
  void dispose() {
    _dailyResetTimer.cancel();
    super.dispose();
  }


  Future<void> loadDataFromDevice() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final storedCategories = prefs.getString('categories');
      final storedHadithList = prefs.getString('hadithList');
      final storedData = prefs.getString('data');
      final storedDuaData = prefs.getString('duaData');
      final storedFatwaData = prefs.getString('ifatwaData');

      if (storedCategories != null &&
          storedHadithList != null &&
          storedData != null &&
          storedDuaData != null &&
          storedFatwaData != null) {
        categories = json.decode(storedCategories);
        hadithList = json.decode(storedHadithList);
        data = json.decode(storedData);
        duaData = json.decode(storedDuaData);
        fatwaData = json.decode(storedFatwaData);

        if (hadithList.isNotEmpty) {
          randomIndex = generateRandomIndex(hadithList.length);
        }
        setState(() => isLoading = false);
      } else {
        await fetchAndStoreData();
      }
    } catch (e) {
      print("Local load error: $e");
      await fetchAndStoreData();
    }
  }

  Future<void> fetchAndStoreData() async {
    setState(() => isLoading = true);
    const url = 'https://script.google.com/macros/s/AKfycbz6gZBH5qs6YlZZK6I7uMrkUITUPaVPxisCcFGHhe1QavpPQQ3SvRv4-Fp06baSgq10/exec';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('categories', json.encode(result['categories'] ?? []));
        await prefs.setString('hadithList', json.encode(result['hadith'] ?? []));
        await prefs.setString('duaData', json.encode(result['dua'] ?? []));
        await prefs.setString('data', json.encode(result['data'] ?? []));
        await prefs.setString('ifatwaData', json.encode(result['ifatwa'] ?? []));

        categories = result['categories'] ?? [];
        hadithList = result['hadith'] ?? [];
        duaData = result['dua'] ?? [];
        fatwaData = result['ifatwa'] ?? [];
        data = result['data'] ?? [];

        if (hadithList.isNotEmpty) {
          randomIndex = generateRandomIndex(hadithList.length);
        }

        setState(() => isLoading = false);
      } else {
        throw Exception("Server returned error");
      }
    } catch (e) {
      print("Fetch error: $e");
      if(mounted) { // Check if the widget is still in the tree before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("ডেটা লোড করতে ব্যর্থ হয়েছে। ইন্টারনেট চেক করুন।"),
        ));
      }
      setState(() => isLoading = false);
    }
  }

  final Map<String, dynamic> iconMap = {
    'sunny_snowing': Icons.wb_sunny,
    'moon': Icons.nightlight_round,
    'sun': Icons.wb_sunny,
    'sleep': Icons.bed,
    'healing': Icons.healing,
    'self_improvement': Icons.health_and_safety,
    'access_time': Icons.access_time,
    'quran': FontAwesomeIcons.bookOpen,
    'mosque': FontAwesomeIcons.mosque,
    'prayer': FontAwesomeIcons.prayingHands,
    'help': Icons.help_outline,
    'dua': FontAwesomeIcons.pray,
    'fatwa': FontAwesomeIcons.bookOpenReader,
    'islamic_calendar': FontAwesomeIcons.calendar,
    'islamic_book': FontAwesomeIcons.book,
    'islamic_faith': FontAwesomeIcons.mosque,
    'islamic_knowledge': FontAwesomeIcons.kaaba,
    'islamic_prayer': FontAwesomeIcons.prayingHands,
    'islamic_community': FontAwesomeIcons.peopleArrows,
    'islamic_charity': FontAwesomeIcons.handsHelping,
    'islamic_peace': FontAwesomeIcons.dove,
    'islamic_fasting': FontAwesomeIcons.moon,
    'islamic_zakat': FontAwesomeIcons.coins,
    'islamic_sadaqah': FontAwesomeIcons.handHoldingHeart,
    'islamic_sunnah': FontAwesomeIcons.solidSun,
    'islamic_sharia': FontAwesomeIcons.balanceScale,
    'islamic_education': FontAwesomeIcons.school,
    // Add more mappings as needed
  };

  Widget getIconFromName(String iconName) {
    final iconData = iconMap[iconName];
    if (iconData is IconData) {
      return Icon(iconData, color: AppColors.white, size: 40);
    } else if (iconData != null) {
      // For FontAwesomeIcons (which are IconData but from a different font family)
      return FaIcon(iconData, color: AppColors.white, size: 40);
    } else {
      return Icon(Icons.help_outline, color: AppColors.white, size: 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String hadithText = hadithList.isNotEmpty ? hadithList[randomIndex]['hadis'] ?? '' : 'আজকের হাদিস পাওয়া যায়নি।';
    final String hadithRef = hadithList.isNotEmpty ? hadithList[randomIndex]['ref'] ?? '' : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "IOM Daily Azkars",
          style: TextStyle(
            fontSize: 20,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: fetchAndStoreData,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchAndStoreData,
          color: AppColors.primaryGreen,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              const CombinedPrayerTimesWidget(),
              const SizedBox(height: 16),
              isLoading ? _buildShimmerCard() : _buildHadithCard(hadithText, hadithRef),
              const SizedBox(height: 24),
              isLoading ? _buildShimmerGrid() : _buildCategoryGrid(),
              const SizedBox(height: 24),
              isLoading ? _buildShimmerCard() : _buildFatwaSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
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
                const SizedBox(height: 8),
                Text('স্বাগতম আপনাকে, এখানে প্রতিদিনের জন্য দোয়া ও আজকার পেয়ে জাবেন ইনশাল্লাহ', textAlign: TextAlign.center, style: AppTextStyles.bold.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                )),
              ],
            ),
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
            title: Text('অ্যাপ শেয়ার করুন', style: AppTextStyles.regular),
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
            title: Text('রেটিং দিন', style: AppTextStyles.regular,),
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
            title: Text('ফিডব্যাক দিন', style: AppTextStyles.regular),
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
            title: Text('অ্যাপ সম্পর্কে', style: AppTextStyles.regular),
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

  Widget _buildHadithCard(String hadithText, String hadithRef) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(
            hadithText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primaryGreen,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "রেফারেন্স: $hadithRef",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.primaryGreen),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.share, color: AppColors.primaryGreen),
              onPressed: () => Share.share("$hadithText\n\nহাদিস: $hadithRef"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: categories.map((category) {
        final String title = category["title"] ?? "শিরোনাম নেই";
        final String tag = category["tag"] ?? "";
        final String iconName = category["icon_name"] ?? "help";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DuaListScreen(tag: tag, duaData: duaData),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getIconFromName(iconName),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFatwaSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6,
      shadowColor: Colors.green.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IFatwaListScreen(fatwaData: fatwaData),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.book_outlined,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ফতোয়া বিভাগ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ইসলামী আইন ও বিধান সম্পর্কিত প্রশ্নের উত্তর খুঁজুন।",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }),
    );
  }
}