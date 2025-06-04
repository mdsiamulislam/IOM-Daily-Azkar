import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomdailyazkar/widget/badge_info_dialog.dart';
import 'package:iomdailyazkar/widget/prayer_time_widget.dart';
import 'package:iomdailyazkar/screen/about_app_screen.dart';
import 'package:iomdailyazkar/screen/i_fatwa_list_screen.dart';
import 'package:iomdailyazkar/screen/our_apps_screen.dart';
import 'package:iomdailyazkar/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'screen/daily_azkar_task_screen.dart';
import 'const/constants.dart';
import 'screen/dua_list_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widget/daily_task_widget.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
  bool _allTasksCompleted = false;
  late Timer _dailyResetTimer;
  DateTime? _lastResetDate;

  // Badge system state
  int _userLevel = 1; // User's current level, starts at 1
  int _consecutiveDaysCompleted = 0; // Track consecutive task completions

  int generateRandomIndex(int max) => (DateTime.now().millisecondsSinceEpoch % max).toInt();

  @override
  void initState() {
    super.initState();
    _initializeDailyTasks(); // This now also loads user level
    loadDataFromDevice();
  }

  @override
  void dispose() {
    _dailyResetTimer.cancel();
    super.dispose();
  }

  Future<void> _initializeDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    _lastResetDate = DateTime.tryParse(prefs.getString('lastResetDate') ?? '');
    _allTasksCompleted = prefs.getBool('allTasksCompleted') ?? false;

    // Load user level and consecutive days
    _userLevel = prefs.getInt('userLevel') ?? 1;
    _consecutiveDaysCompleted = prefs.getInt('consecutiveDaysCompleted') ?? 0;

    // Check if we need to reset (new day after 1AM)
    await _checkAndResetDailyTasks(); // Await this to ensure state is updated before build

    // Set up timer to check every hour
    _dailyResetTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkAndResetDailyTasks();
    });

    setState(() {
      // Update state after loading everything
    });
  }

  Future<void> _checkAndResetDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final resetTime = DateTime(now.year, now.month, now.day, 1); // 1 AM

    // If we haven't reset today and it's past 1 AM
    if ((_lastResetDate == null || _lastResetDate!.isBefore(today)) && now.isAfter(resetTime)) {
      await _resetDailyTasks();
    }
  }

  Future<void> _resetDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    await prefs.setBool('morningAzkar', false);
    await prefs.setBool('eveningAzkar', false);
    await prefs.setBool('prayerAzkar', false);
    await prefs.setBool('allTasksCompleted', false);
    await prefs.setString('lastResetDate', now.toString());

    // If tasks are reset, consecutive days should be reset too.
    // This is crucial for leveling up based on consistent activity.
    await prefs.setInt('consecutiveDaysCompleted', 0);

    setState(() {
      _allTasksCompleted = false;
      _consecutiveDaysCompleted = 0;
      // Note: _userLevel does not reset here, it only increases.
      // If you want it to decrease, you need to add specific logic for that.
    });
  }

  // Helper function to update user level based on consecutive task completions
  Future<void> _updateUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    int newLevel = 1;

    if (_consecutiveDaysCompleted >= 15) {
      newLevel = 5;
    } else if (_consecutiveDaysCompleted >= 10) {
      newLevel = 4;
    } else if (_consecutiveDaysCompleted >= 5) {
      newLevel = 3;
    } else if (_consecutiveDaysCompleted >= 1) { // Assuming 1 day completed moves to level 2
      newLevel = 2;
    } else {
      newLevel = 1;
    }

    if (newLevel > _userLevel) {
      setState(() {
        _userLevel = newLevel;
      });
      await prefs.setInt('userLevel', _userLevel); // Save the new level
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("আপনি নতুন লেভেলে পৌঁছেছেন: লেভেল $_userLevel!"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    }
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

  Icon getIconFromName(String iconName) {
    switch (iconName) {
      case 'sunny_snowing':
        return const Icon(Icons.wb_sunny, color: AppColors.white, size: 40);
      case 'healing':
        return const Icon(Icons.healing, color: AppColors.white, size: 40);
      case 'self_improvement':
        return const Icon(Icons.health_and_safety, color: AppColors.white, size: 40);
      case 'access_time':
        return const Icon(Icons.access_time, color: AppColors.white, size: 40);
      default:
        return const Icon(Icons.help_outline, color: AppColors.white, size: 40);
    }
  }

  // --- Badge System Helper Functions (Corrected and Consolidated) ---
  IconData _getBadgeIcon(int level) {
    switch (level) {
      case 1:
        return Icons.star_border; // Level 1: An outline star
      case 2:
        return Icons.star; // Level 2: A filled star
      case 3:
        return Icons.military_tech; // Level 3: A medal
      case 4:
        return Icons.workspace_premium; // Level 4: A premium badge
      case 5:
        return Icons.emoji_events; // Level 5: A trophy
      default:
        return Icons.help_outline; // Default for unexpected levels
    }
  }

  Color _getBadgeColor(int level) {
    switch (level) {
      case 1:
        return Colors.white; // Or a subtle grey for level 1
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orangeAccent; // Bronze-like
      case 4:
        return Colors.blueGrey.shade200; // Silver-like
      case 5:
        return Colors.amber; // Gold
      default:
        return AppColors.white; // Fallback color
    }
  }
  // --- End Badge System Helper Functions ---

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
          // Display the badge based on the user's current level
          // Make the badge icon clickable
          InkWell( // Use InkWell for a ripple effect on tap
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return BadgeInfoDialog(
                    currentDayCount: _consecutiveDaysCompleted,
                    currentUserLevel: _userLevel, // এখানে 'userLevel' এর পরিবর্তে 'currentUserLevel' ব্যবহার করুন
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0), // Add some padding
              child: Icon(
                _getBadgeIcon(_userLevel), // Get the icon based on the level
                color: _getBadgeColor(_userLevel), // Get the color based on the level
                size: 28, // Adjust size as needed
              ),
            ),
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
              if (!_allTasksCompleted) // Only show if tasks aren't completed
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => DailyAzkarTaskScreen()),
                    );

                    if (result != null && result) {
                      // If tasks were completed, update consecutive days and check level
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('allTasksCompleted', true); // Mark as completed for today

                      setState(() {
                        _allTasksCompleted = true;
                        _consecutiveDaysCompleted++; // Increment consecutive days
                      });
                      await prefs.setInt('consecutiveDaysCompleted', _consecutiveDaysCompleted);
                      await _updateUserLevel(); // Check if user leveled up
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const DailyTaskWidget(),
                  ),
                ),
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