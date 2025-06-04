import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DuaDetailScreen extends StatefulWidget {
  final int duaIndex;
  final List<dynamic> duaData;

  const DuaDetailScreen({
    super.key,
    required this.duaIndex,
    required this.duaData,
  });

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  bool isBookmarked = false;
  double arabicFontSize = 22.0;
  double banglaFontSize = 18.0;
  late PageController _pageController;
  ValueNotifier<int>? _currentPageNotifier; // বর্তমান পৃষ্ঠা ট্র্যাক করার জন্য, nullable করা হয়েছে
  String _appPackageName = ''; // প্যাকেজ নাম সংরক্ষণের জন্য
  String _appStoreLink = ''; // প্লে স্টোর/অ্যাপ স্টোর লিঙ্ক সংরক্ষণের জন্য

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.duaIndex);
    _currentPageNotifier = ValueNotifier<int>(widget.duaIndex); // বর্তমান পৃষ্ঠা দিয়ে ইনিশিয়ালাইজ করুন
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier?.dispose(); // nullable হওয়ার কারণে সেফ কল (?) ব্যবহার করা হয়েছে
    super.dispose();
  }

  // প্যাকেজ তথ্য লোড করার ফাংশন
  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appPackageName = info.packageName;
      // Android এবং iOS এর জন্য প্লে স্টোর/অ্যাপ স্টোর লিঙ্ক
      // আপনার অ্যাপের আসল লিঙ্ক বসান
      if (Theme.of(context).platform == TargetPlatform.android) {
        _appStoreLink = 'https://play.google.com/store/apps/details?id=$_appPackageName';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        _appStoreLink = 'https://apps.apple.com/us/app/your-app-id'; // আপনার iOS অ্যাপ ID দিন
      } else {
        _appStoreLink = ''; // অন্য প্ল্যাটফর্মের জন্য
      }
    });
  }

  // টেক্সট তৈরির সহায়ক ফাংশন যা সব ফিল্ড গুছিয়ে দেখাবে
  String _formatDuaText(Map<String, dynamic> dua) {
    String formattedText = '';
    final String title = dua['title'] ?? '';
    final String rules = dua['rules'] ?? '';
    final String duaArabic = dua['dua_arabic'] ?? '';
    final String duaBangla = dua['dua_bangla'] ?? ''; // বাংলা উচ্চারণ
    final String banglaTranslation = dua['bangla_translation'] ?? ''; // নতুন ফিল্ড
    final String tafseer = dua['tafseer'] ?? ''; // আপনার ডেটায় 'dua' ফিল্ডটি তাফসীর/অর্থ হিসেবে ব্যবহৃত হলে এটি এখানে যোগ করুন
    final String reference = dua['reference'] ?? '';

    if (title.isNotEmpty) {
      formattedText += '*** $title ***\n\n';
    }

    if (rules.isNotEmpty) {
      formattedText += 'নিয়ম:\n$rules\n\n';
    }

    if (duaArabic.isNotEmpty) {
      formattedText += 'আরবি:\n$duaArabic\n\n';
    }

    if (duaBangla.isNotEmpty) {
      formattedText += 'বাংলা উচ্চারণ:\n$duaBangla\n\n';
    }

    // নতুন যোগ করা ফিল্ড
    if (banglaTranslation.isNotEmpty) {
      formattedText += 'বাংলা অনুবাদ:\n$banglaTranslation\n\n';
    }

    if (tafseer.isNotEmpty) {
      formattedText += 'তাফসীর:\n$tafseer\n\n';
    }

    if (reference.isNotEmpty) {
      formattedText += 'রেফারেন্স:\n$reference\n\n';
    }

    formattedText += '--- IOM Daily Azkar ---\n';
    if (_appStoreLink.isNotEmpty) {
      formattedText += 'আমাদের অ্যাপ ডাউনলোড করুন: $_appStoreLink\n';
    }
    formattedText += 'আল্লাহ আপনাকে উত্তম প্রতিদান দিন। আমীন!\n';

    return formattedText;
  }

  // --- কপি ফাংশন ---
  void _copyToClipboard() {
    final currentDua = widget.duaData[_pageController.page!.round()];
    final textToCopy = _formatDuaText(currentDua);

    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দোয়া কপি করা হয়েছে')),
      );
    });
  }

  // --- শেয়ার ফাংশন ---
  void _shareDua() {
    final currentDua = widget.duaData[_pageController.page!.round()];
    final textToShare = _formatDuaText(currentDua);

    Share.share(textToShare);
  }

  void _loadNextDua() {
    if (_pageController.page!.round() < widget.duaData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এটি শেষ দোয়া')),
      );
    }
  }

  void _loadPreviousDua() {
    if (_pageController.page!.round() > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এটি প্রথম দোয়া')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green[700],
        title: _currentPageNotifier == null
            ? const Text(
          'Loading Dua...', // Fallback title if _currentPageNotifier is null
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
            : ValueListenableBuilder<int>(
          valueListenable: _currentPageNotifier!, // Null check করা হয়েছে, তাই এখানে ! ব্যবহার করা নিরাপদ
          builder: (context, currentPageIndex, child) {
            // নিশ্চিত করুন যে currentPageIndex বৈধ সীমার মধ্যে আছে
            if (currentPageIndex < 0 || currentPageIndex >= widget.duaData.length) {
              return const Text(
                'Invalid Dua',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            final currentDuaForTitle = widget.duaData[currentPageIndex];
            return Text(
              currentDuaForTitle['title'] ?? 'দোয়া ${currentPageIndex + 1}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase, color: Colors.white),
            tooltip: 'ফন্ট বড় করুন',
            onPressed: () {
              setState(() {
                arabicFontSize += 2;
                banglaFontSize += 2;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease, color: Colors.white),
            tooltip: 'ফন্ট ছোট করুন',
            onPressed: () {
              setState(() {
                if (arabicFontSize > 10 && banglaFontSize > 10) {
                  arabicFontSize -= 2;
                  banglaFontSize -= 2;
                }
              });
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.duaData.length,
        onPageChanged: (int index) {
          _currentPageNotifier?.value = index; // পৃষ্ঠা পরিবর্তন হলে ValueNotifier আপডেট করুন
          // প্রয়োজনে এখানে বুকমার্ক স্ট্যাটাস বা অন্যান্য স্টেট আপডেট করুন
        },
        itemBuilder: (context, index) {
          final currentDua = widget.duaData[index];

          // ফিল্ডগুলোর ভ্যালু নিয়ে নিন, যাতে বারবার ম্যাপ অ্যাক্সেস করতে না হয় এবং null চেক করতে সুবিধা হয়।
          final String rules = currentDua['rules'] ?? '';
          final String duaArabic = currentDua['dua_arabic'] ?? '';
          final String duaBangla = currentDua['dua_bangla'] ?? '';
          final String banglaTranslation = currentDua['bangla_translation'] ?? ''; // নতুন ফিল্ড
          final String tafseer = currentDua['tafseer'] ?? ''; // এখানে 'dua' ফিল্ডটি তাফসীর হিসেবে ব্যবহৃত হচ্ছে
          final String reference = currentDua['reference'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {},
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                if (rules.isNotEmpty) // রুলস থাকলে দেখাবে
                  Text(
                    rules,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "দোয়া",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (duaArabic.isNotEmpty) // আরবি দোয়া থাকলে দেখাবে
                        Text(
                          duaArabic,
                          style: TextStyle(
                            fontSize: arabicFontSize,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 8),
                      if (duaBangla.isNotEmpty) // বাংলা উচ্চারণ থাকলে দেখাবে
                        Text(
                          duaBangla,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 10),



                      if (reference.isNotEmpty) // রেফারেন্স থাকলে দেখাবে
                        Text(
                          "- $reference",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const Divider(),
                      const SizedBox(height: 14),// নতুন বাংলা অনুবাদ ফিল্ড
                      if (banglaTranslation.isNotEmpty) // বাংলা অনুবাদ থাকলে দেখাবে
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "বাংলা অনুবাদ", // শিরোনাম
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banglaTranslation,
                              style: TextStyle(
                                fontSize: banglaFontSize,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),

                      const Divider(),
                      const SizedBox(height: 14),
                      // const Text(
                      //   "তাফসীর/অর্থ", // শিরোনাম
                      //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      // ),
                      const SizedBox(height: 8),
                      if (tafseer.isNotEmpty) // তাফসীর থাকলে দেখাবে
                        Text(
                          tafseer,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.green),
                tooltip: 'আগের দোয়া',
                onPressed: _loadPreviousDua,
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.green),
                tooltip: 'কপি করুন',
                onPressed: _copyToClipboard,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.green),
                tooltip: 'শেয়ার করুন',
                onPressed: _shareDua,
              ),
              // বুকমার্ক ফাংশনালিটি যদি ভবিষ্যতে যোগ করা হয়
              // IconButton(
              //   icon: Icon(
              //     isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              //     color: Colors.green,
              //   ),
              //   tooltip: isBookmarked ? 'Bookmark তুলে ফেলুন' : 'Bookmark করুন',
              //   onPressed: () {
              //     setState(() {
              //       isBookmarked = !isBookmarked;
              //     });
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text(
              //           isBookmarked ? 'Bookmark করা হয়েছে' : 'Bookmark তুলে ফেলা হয়েছে',
              //         ),
              //       ),
              //     );
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.green),
                tooltip: 'পরবর্তী দোয়া',
                onPressed: _loadNextDua,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
