import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iomdailyazkar/core/local_storage/user_pref.dart';
import 'package:iomdailyazkar/features/home/widget/horizontal_card.dart';
import 'package:iomdailyazkar/features/prayer_times/presentation/screens/prayer_time_setting_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../about/presentation/screens/about_app_screen.dart';
import '../../about/presentation/screens/our_apps_screen.dart';
import '../../dua/presentation/screens/dua_list_screen.dart';
import '../../prayer_times/controllers/change_widget.dart';
import '../widget/dual_time_card.dart';

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
  List<dynamic> iomdailyazkar = [];
  List<dynamic> data = [];
  List<dynamic> ads = [];
  bool isLoading = true;
  int randomIndex = 0;

  // Add ScrollController for better control
  ScrollController? _scrollController;

  // Cache valid categories to prevent recalculation during scroll
  List<dynamic> _validCategories = [];

  // Keep alive to prevent rebuilding
  @override
  bool get wantKeepAlive => true;

  int generateRandomIndex(int max) => (DateTime.now().millisecondsSinceEpoch % max).toInt();
  final ChangeWidget _changeWidget = Get.put(ChangeWidget());

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadDataFromDevice();
    _loadTimeTablePreference();
  }

  // Load the time table preference from SharedPreferences
  Future<void> _loadTimeTablePreference() async {
    final isSingle = await UserPref().getPrayerTimeSingle();
    _changeWidget.isSingleTimeTable.value = isSingle;
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
      final storedIomdailyazkarData = prefs.getString('iomdailyazkar');
      final storedAdsData = prefs.getString('ads'); // Add this line to load ads from storage

      if (storedCategories != null &&
          storedHadithList != null &&
          storedData != null &&
          storedDuaData != null &&
          storedFatwaData != null &&
          storedIomdailyazkarData != null) {
        categories = json.decode(storedCategories);
        hadithList = json.decode(storedHadithList);
        data = json.decode(storedData);
        duaData = json.decode(storedDuaData);
        fatwaData = json.decode(storedFatwaData);
        iomdailyazkar = json.decode(storedIomdailyazkarData);

        // Load ads from storage if available
        if (storedAdsData != null) {
          ads = json.decode(storedAdsData);
        }

        fatwaData = fatwaData.where((e) =>
        e['question_title'] != null && e['answer'] != null).toList();

        // Cache valid categories to prevent recalculation during scroll
        _cacheValidCategories();

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

        // Debug: Print full response to see the structure
        print("Full API response: ${response.body}");
        print("Parsed ads from API: ${result['ads']}");

        await prefs.setString('categories', json.encode(result['categories'] ?? []));
        await prefs.setString('hadithList', json.encode(result['hadith'] ?? []));
        await prefs.setString('duaData', json.encode(result['dua'] ?? []));
        await prefs.setString('data', json.encode(result['data'] ?? []));
        await prefs.setString('ifatwaData', json.encode(result['ifatwa'] ?? []));
        await prefs.setString('iomdailyazkar', json.encode(result['iomdailyazkar'] ?? []));
        await prefs.setString('ads', json.encode(result['ads'] ?? [])); // Store ads data

        categories = result['categories'] ?? [];
        hadithList = result['hadith'] ?? [];
        duaData = result['dua'] ?? [];
        iomdailyazkar = result['iomdailyazkar'] ?? [];
        ads = result['ads'] ?? [];
        fatwaData = (result['ifatwa'] ?? []).where((e) =>
        e['question_title'] != null && e['answer'] != null).toList();
        data = result['data'] ?? [];

        // Cache valid categories to prevent recalculation during scroll
        _cacheValidCategories();

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
    'calendarCheck': FontAwesomeIcons.calendarCheck,
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

  // Cache valid categories to prevent recalculation during scroll
  void _cacheValidCategories() {
    _validCategories = categories.where((category) {
      final title = category["title"]?.toString().trim() ?? "";
      final tag = category["tag"]?.toString().trim() ?? "";
      return title.isNotEmpty && tag.isNotEmpty;
    }).toList();
  }

  // Convert Google Drive sharing link to direct download link
  String _convertGoogleDriveUrl(String url) {
    if (url.contains('drive.google.com') && url.contains('/file/d/')) {
      // Extract file ID from Google Drive URL
      RegExp regExp = RegExp(r'/file/d/([a-zA-Z0-9-_]+)');
      RegExpMatch? match = regExp.firstMatch(url);

      if (match != null) {
        String fileId = match.group(1)!;
        // Convert to direct download link
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }
    return url; // Return original URL if not a Google Drive link
  }

  // Check if banner should be shown
  bool _shouldShowBanner() {
    // Don't show if loading
    if (isLoading) return false;

    // Don't show if ads array is empty
    if (ads.isEmpty) return false;

    // Don't show if first ad doesn't have a valid link
    if (ads[0] == null || ads[0]['link'] == null) return false;

    // Don't show if link is empty or invalid
    String imageUrl = ads[0]['link'].toString().trim();
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) return false;

    return true;
  }

  // Banner Image Builder Method
  Widget _buildBannerImage() {
    String originalUrl = ads[0]['link'].toString().trim();
    String imageUrl = _convertGoogleDriveUrl(originalUrl);

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      height: 200,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primaryGreen,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Return empty container on error (hide banner)
        return const SizedBox.shrink();
      },
    );
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
            physics: const ClampingScrollPhysics(), // Better scroll physics
            cacheExtent: 1000, // Cache more content for smoother scrolling
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 10),
                    // Prayer Times Widget - Now using Obx to listen to reactive changes
                    Obx(() => DualTimeCard(
                      isSingleTimeTable: _changeWidget.isSingleTimeTable.value,
                    )),
                    const SizedBox(height: 16),
                    // Hadith Card
                    isLoading ? _buildShimmerCard() : _buildHadithCard(hadithText, hadithRef),
                  ]),
                ),
              ),

              // IOM Daily Azkar Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    isLoading ? _buildShimmerCard() : HorizontalCard(
                      duaData: iomdailyazkar,
                      title: "IOM এর নির্বাচিত বাধ্যতামূলক সকাল সন্ধ্যার  দু'আ",
                      description: "IOM-এর বিশেষ বিন্যাসে সাজানো দু'আ সমূহ ",
                      icon: Icons.checklist,
                    ),
                  ]),
                ),
              ),

              // Banner Section - Only show if banner should be displayed
              if (_shouldShowBanner())
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      child: _buildBannerImage(),
                    ),
                  ),
                ),

              // Add spacing only if banner is shown
              if (_shouldShowBanner())
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),

              // Category Grid
              if (isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildShimmerGridSliver(),
                )
              else if (_validCategories.isNotEmpty)
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
                    isLoading ? _buildShimmerCard() : HorizontalCard(
                      fatwaData: fatwaData,
                      title: "ফতোয়া বিভাগ",
                      description: "ইসলামী আইন ও বিধান সম্পর্কিত প্রশ্নের উত্তর খুঁজুন।",
                      icon: Icons.book_outlined,
                    ),
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
            leading: const Icon(
              Icons.access_time,
              color: Colors.green,
            ),
            title: Text(
              'নামাজের সময় সেট করুন',
              style: AppTextStyles.regular.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.grey.shade100,
            hoverColor: Colors.green.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerTimeSettingScreen()),
              ).then((_) {
                // Refresh the time table preference when returning from settings
                _loadTimeTablePreference();
              });
            },
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
                path: 'soaib.softdev@gmail.com',
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
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
            ],
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
                ),
              ),
              if (ref.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  "রেফারেন্স: $ref",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primaryGreen .withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: 4,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.share, color: AppColors.primaryGreen, size: 20),
            onPressed: () => Share.share("$text${ref.isNotEmpty ? '\n\nহাদিস: $ref' : ''}"),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGridSliver() {
    // Use cached categories to prevent recalculation during scroll
    final crossAxisCount = _getCrossAxisCount(context);
    final aspectRatio = _getChildAspectRatio(context);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final category = _validCategories[index];
          final String title = category["title"];
          final String tag = category["tag"].toString().trim();
          final String iconName = category["icon_name"] ?? "help";

          return _buildCategoryCard(title, tag, iconName);
        },
        childCount: _validCategories.length,
      ),
    );
  }

  // Extract category card building to separate method for better performance
  Widget _buildCategoryCard(String title, String tag, String iconName) {
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
    // Use consistent values to prevent layout shifts
    final crossAxisCount = _getCrossAxisCount(context);
    final aspectRatio = _getChildAspectRatio(context);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
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
        childCount: 6, // Show consistent number of shimmer cards
      ),
    );
  }
}