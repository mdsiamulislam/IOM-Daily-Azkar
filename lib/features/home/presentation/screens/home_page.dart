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

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  List<dynamic> categories = [];
  List<dynamic> hadithList = [];
  List<dynamic> duaData = [];
  List<dynamic> fatwaData = [];
  List<dynamic> data = [];
  bool isLoading = true;
  int randomIndex = 0;

  // Add ScrollController for better control
  ScrollController? _scrollController;

  // Keep alive to prevent rebuilding
  @override
  bool get wantKeepAlive => true;

  int generateRandomIndex(int max) => (DateTime.now().millisecondsSinceEpoch % max).toInt();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadDataFromDevice();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
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
        fatwaData = fatwaData.where((e) =>
        e['question_title'] != null && e['answer'] != null).toList();

        if (hadithList.isNotEmpty) {
          randomIndex = generateRandomIndex(hadithList.length);
        }
        if (mounted) {
          setState(() => isLoading = false);
        }
      } else {
        await fetchAndStoreData();
      }
    } catch (e) {
      print("Local load error: $e");
      await fetchAndStoreData();
    }
  }

  Future<void> fetchAndStoreData() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
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
        fatwaData = (result['ifatwa'] ?? []).where((e) =>
        e['question_title'] != null && e['answer'] != null).toList();
        data = result['data'] ?? [];

        if (hadithList.isNotEmpty) {
          randomIndex = generateRandomIndex(hadithList.length);
        }

        if (mounted) {
          setState(() => isLoading = false);
        }
      } else {
        throw Exception("Server returned error");
      }
    } catch (e) {
      print("Fetch error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ডেটা লোড করতে ব্যর্থ হয়েছে। ইন্টারনেট চেক করুন।"),
          ),
        );
        setState(() => isLoading = false);
      }
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
  };

  Widget getIconFromName(String iconName) {
    final iconData = iconMap[iconName.trim()];
    if (iconData is IconData) {
      return Icon(iconData, color: AppColors.white, size: 40);
    } else if (iconData != null) {
      return FaIcon(iconData, color: AppColors.white, size: 40);
    } else {
      return Icon(Icons.help_outline, color: AppColors.white, size: 40);
    }
  }

  // Helper method to get responsive cross axis count
  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 3; // Tablets
    } else if (screenWidth > 400) {
      return 2; // Large phones
    } else {
      return 2; // Small phones
    }
  }

  // Helper method to get responsive aspect ratio
  double _getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 1.1; // Tablets
    } else {
      return 1.0; // Phones
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final String hadithText = hadithList.isNotEmpty && (hadithList[randomIndex]['hadis']?.trim().isNotEmpty ?? false)
        ? hadithList[randomIndex]['hadis']
        : 'আজকের হাদিস পাওয়া যায়নি।';

    final String hadithRef = hadithList.isNotEmpty && (hadithList[randomIndex]['ref']?.trim().isNotEmpty ?? false)
        ? hadithList[randomIndex]['ref']
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "IOM Daily Azkars",
          style: TextStyle(fontSize: 20, color: AppColors.white, fontWeight: FontWeight.bold),
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
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(), // Better scroll physics
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 10),
                    // Prayer Times Widget
                    const CombinedPrayerTimesWidget(),
                    const SizedBox(height: 16),
                    // Hadith Card
                    isLoading ? _buildShimmerCard() : _buildHadithCard(hadithText, hadithRef),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
              // Category Grid
              if (isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildShimmerGridSliver(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildCategoryGridSliver(),
                ),
              // Fatwa Section
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    isLoading ? _buildShimmerCard() : _buildFatwaSection(),
                    const SizedBox(height: 24), // Bottom padding
                  ]),
                ),
              ),
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
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    'স্বাগতম আপনাকে, এখানে প্রতিদিনের জন্য দোয়া ও আজকার পেয়ে জাবেন ইনশাল্লাহ',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold.copyWith(color: Colors.white, fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.apps),
            title: const Text('আমাদের অন্যান্য অ্যাপস'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OurAppsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text('অ্যাপ শেয়ার করুন', style: AppTextStyles.regular),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              final packageName = info.packageName;
              final shareText = 'IOM Daily Azkar App\n\nhttps://play.google.com/store/apps/details?id=$packageName';
              Share.share(shareText);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text('রেটিং দিন', style: AppTextStyles.regular),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              final packageName = info.packageName;
              final url = 'https://play.google.com/store/apps/details?id=$packageName';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
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
                if (mounted) {
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
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(String text, String ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primaryGreen,
                fontStyle: FontStyle.italic,
                height: 1.5,
              )
          ),
          if (ref.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
                "রেফারেন্স: $ref",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                )
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.share, color: AppColors.primaryGreen),
              onPressed: () => Share.share("$text${ref.isNotEmpty ? '\n\nহাদিস: $ref' : ''}"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridSliver() {
    final validCategories = categories.where((category) {
      final title = category["title"]?.toString().trim() ?? "";
      final tag = category["tag"]?.toString().trim() ?? "";
      return title.isNotEmpty && tag.isNotEmpty;
    }).toList();

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _getChildAspectRatio(context),
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final category = validCategories[index];
          final String title = category["title"];
          final String tag = category["tag"].toString().trim();
          final String iconName = category["icon_name"] ?? "help";

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DuaListScreen(tag: tag, duaData: duaData),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getIconFromName(iconName),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: validCategories.length,
      ),
    );
  }

  Widget _buildFatwaSection() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.green.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => IFatwaListScreen(fatwaData: fatwaData)));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle
                ),
                child: const Icon(Icons.book_outlined, color: AppColors.primaryGreen, size: 28),
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
                            color: AppColors.primaryGreen
                        )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ইসলামী আইন ও বিধান সম্পর্কিত প্রশ্নের উত্তর খুঁজুন।",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700]
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
          height: 120,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          )
      ),
    );
  }

  Widget _buildShimmerGridSliver() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _getChildAspectRatio(context),
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)
              ),
            ),
          );
        },
        childCount: 4,
      ),
    );
  }
}