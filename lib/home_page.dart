import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomdailyazkar/prayer_time_widget.dart';
import 'package:iomdailyazkar/screen/about_app_screen.dart';
import 'package:iomdailyazkar/screen/settings_page.dart';
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
  List<dynamic> data = [];
  bool isLoading = true;
  int randomIndex = 0;
  bool _allTasksCompleted = false;
  late Timer _dailyResetTimer;
  DateTime? _lastResetDate;

  int generateRandomIndex(int max) => (DateTime.now().millisecondsSinceEpoch % max).toInt();

  @override
  void initState() {
    super.initState();
    _initializeDailyTasks();
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

    // Check if we need to reset (new day after 1AM)
    _checkAndResetDailyTasks();

    // Set up timer to check every hour
    _dailyResetTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkAndResetDailyTasks();
    });
  }

  void _checkAndResetDailyTasks() async {
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

    setState(() {
      _allTasksCompleted = false;
    });
  }


  Future<void> loadDataFromDevice() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final storedCategories = prefs.getString('categories');
      final storedHadithList = prefs.getString('hadithList');
      final storedData = prefs.getString('data');
      final storedDuaData = prefs.getString('duaData');

      if (storedCategories != null &&
          storedHadithList != null &&
          storedData != null &&
          storedDuaData != null) {
        categories = json.decode(storedCategories);
        hadithList = json.decode(storedHadithList);
        data = json.decode(storedData);
        duaData = json.decode(storedDuaData);
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

        categories = result['categories'] ?? [];
        hadithList = result['hadith'] ?? [];
        duaData = result['dua'] ?? [];
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("ডেটা লোড করতে ব্যর্থ হয়েছে। ইন্টারনেট চেক করুন।"),
      ));
      setState(() => isLoading = false);
    }
  }

  Icon getIconFromName(String iconName) {
    switch (iconName) {
      case 'sunny_snowing':
        return Icon(Icons.wb_sunny, color: AppColors.white, size: 40);
      case 'healing':
        return Icon(Icons.healing, color: AppColors.white, size: 40);
      case 'self_improvement':
        return Icon(Icons.self_improvement, color: AppColors.white, size: 40);
      case 'access_time':
        return Icon(Icons.access_time, color: AppColors.white, size: 40);
      default:
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
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: Text("IOM Daily Azkars",
          style: TextStyle(
            fontSize: 20,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.white),
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
            padding: EdgeInsets.all(16),
            children: [
              if (!_allTasksCompleted) // Only show if tasks aren't completed
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => DailyAzkarTaskScreen()),
                    );

                    if (result != null && result) {
                      setState(() {
                        _allTasksCompleted = true;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DailyTaskWidget(),
                  ),
                ),
              SizedBox(height: 10),
              PrayerTimesWidget(),
              SizedBox(height: 16),
              isLoading ? _buildShimmerCard() : _buildHadithCard(hadithText, hadithRef),
              SizedBox(height: 24),
              isLoading ? _buildShimmerGrid() : _buildCategoryGrid(),
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
            decoration: BoxDecoration(color: AppColors.primaryGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                ),
                SizedBox(height: 8),
                Text('স্বাগতম আপনাকে, এখানে প্রতিদিনের জন্য দোয়া ও আজকার পেয়ে জাবেন ইনশাল্লাহ', textAlign: TextAlign.center, style: AppTextStyles.bold.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                )),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.share),
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
            leading: Icon(Icons.star),
            title: Text('রেটিং দিন', style: AppTextStyles.regular,),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              final packageName = info.packageName;
              final url = 'https://play.google.com/store/apps/details?id=$packageName';

              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              } else {
                // fallback or show error
                print("Could not launch Play Store");
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('ফিডব্যাক দিন', style: AppTextStyles.regular),
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'siamuldiu@gmail.com',
                query: Uri.encodeFull('subject=Feedback for IOM Daily Azkar App'),
              );

              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              } else {
                print("Could not launch email app");
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(
            hadithText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primaryGreen,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "হাদিস রেফারেন্স: $hadithRef",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.primaryGreen),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.share, color: AppColors.primaryGreen),
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
      physics: NeverScrollableScrollPhysics(),
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
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getIconFromName(iconName),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
      physics: NeverScrollableScrollPhysics(),
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

