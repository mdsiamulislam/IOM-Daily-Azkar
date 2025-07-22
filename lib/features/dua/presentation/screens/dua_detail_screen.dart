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
  ValueNotifier<int>? _currentPageNotifier;
  String _appPackageName = '';
  String _appStoreLink = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.duaIndex);
    _currentPageNotifier = ValueNotifier<int>(widget.duaIndex);
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier?.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appPackageName = info.packageName;
      if (Theme.of(context).platform == TargetPlatform.android) {
        _appStoreLink = 'https://play.google.com/store/apps/details?id=$_appPackageName';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        _appStoreLink = 'https://apps.apple.com/us/app/your-app-id';
      } else {
        _appStoreLink = '';
      }
    });
  }

  String _formatDuaText(Map<String, dynamic> dua) {
    String formattedText = '';
    final String title = dua['title'] ?? '';
    final String description = dua['description'] ?? '';
    final String rules = dua['rules'] ?? '';
    final String duaArabic = dua['dua_in_arabic'] ?? '';
    final String duaEnglish = dua['dua_in_english'] ?? '';
    final String duaBangla = dua['dua_in_bangla'] ?? '';
    final String banglaTranslation = dua['bangla_translation'] ?? '';
    final String tafseer = dua['tafseer'] ?? '';
    final String reference = dua['reference'] ?? '';
    final String benefit = dua['benefit'] ?? '';
    final String warning = dua['warning'] ?? '';
    final String hadith = dua['hadith'] ?? '';
    final String footnote = dua['footnote'] ?? '';
    final String benefitorhadith = dua['benefitorhadith'] ?? '';
    final String other = dua['other'] ?? '';

    if (title.isNotEmpty) {
      formattedText += '*** $title ***\n\n';
    }
    if (description.isNotEmpty) {
      formattedText += 'বিবরণ:\n$description\n\n';
    }
    if (rules.isNotEmpty) {
      formattedText += 'নিয়ম:\n$rules\n\n';
    }
    if (duaArabic.isNotEmpty) {
      formattedText += 'আরবি:\n$duaArabic\n\n';
    }
    if (duaEnglish.isNotEmpty) {
      formattedText += 'ইংরেজি উচ্চারণ:\n$duaEnglish\n\n';
    }
    if (duaBangla.isNotEmpty) {
      formattedText += 'বাংলা উচ্চারণ:\n$duaBangla\n\n';
    }
    if (banglaTranslation.isNotEmpty) {
      formattedText += 'বাংলা অনুবাদ:\n$banglaTranslation\n\n';
    }
    if (tafseer.isNotEmpty) {
      formattedText += 'তাফসীর:\n$tafseer\n\n';
    }
    if (benefit.isNotEmpty) {
      formattedText += 'উপকারিতা:\n$benefit\n\n';
    }
    if (hadith.isNotEmpty) {
      formattedText += 'হাদিস:\n$hadith\n\n';
    }
    if (benefitorhadith.isNotEmpty) {
      formattedText += 'উপকারিতা/হাদিস:\n$benefitorhadith\n\n';
    }
    if (warning.isNotEmpty) {
      formattedText += 'সতর্কতা:\n$warning\n\n';
    }
    if (footnote.isNotEmpty) {
      formattedText += 'পাদটীকা:\n$footnote\n\n';
    }
    if (other.isNotEmpty) {
      formattedText += 'অন্যান্য:\n$other\n\n';
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

  void _copyToClipboard() {
    final currentDua = widget.duaData[_pageController.page!.round()];
    final textToCopy = _formatDuaText(currentDua);

    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দোয়া কপি করা হয়েছে')),
      );
    });
  }

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

  // Section title builder
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildWarningBox(String warning) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning,
              style: TextStyle(
                fontSize: banglaFontSize - 2,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
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
          'Loading Dua...',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
            : ValueListenableBuilder<int>(
          valueListenable: _currentPageNotifier!,
          builder: (context, currentPageIndex, child) {
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
              currentDuaForTitle['title']?.isNotEmpty == true
                  ? currentDuaForTitle['title']
                  : 'দোয়া ${currentPageIndex + 1}',
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
          _currentPageNotifier?.value = index;
        },
        itemBuilder: (context, index) {
          final currentDua = widget.duaData[index];
          final String description = currentDua['description'] ?? '';
          final String rules = currentDua['rules'] ?? '';
          final String duaArabic = currentDua['dua_in_arabic'] ?? '';
          final String duaEnglish = currentDua['dua_in_english'] ?? '';
          final String duaBangla = currentDua['dua_in_bangla'] ?? '';
          final String banglaTranslation = currentDua['bangla_translation'] ?? '';
          final String tafseer = currentDua['tafseer'] ?? '';
          final String reference = currentDua['reference'] ?? '';
          final String benefit = currentDua['benefit'] ?? '';
          final String warning = currentDua['warning'] ?? '';
          final String hadith = currentDua['hadith'] ?? '';
          final String footnote = currentDua['footnote'] ?? '';
          final String benefitorhadith = currentDua['benefitorhadith'] ?? '';
          final String other = currentDua['other'] ?? '';

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

                // Description
                if (description.isNotEmpty) ...[
                  _buildSectionTitle('বিবরণ'),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: banglaFontSize,
                      color: Colors.green[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],

                // Rules
                if (rules.isNotEmpty) ...[
                  _buildSectionTitle('নিয়ম'),
                  Text(
                    rules,
                    style: TextStyle(
                      fontSize: banglaFontSize,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],

                // Main Dua Container
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
                      // Arabic Text
                      if (duaArabic.isNotEmpty) ...[
                        _buildSectionTitle('আরবি'),
                        Text(
                          duaArabic,
                          style: TextStyle(
                            fontSize: arabicFontSize,
                            height: 1.8,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // English Pronunciation
                      if (duaEnglish.isNotEmpty) ...[
                        _buildSectionTitle('ইংরেজি উচ্চারণ'),
                        Text(
                          duaEnglish,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Bangla Pronunciation
                      if (duaBangla.isNotEmpty) ...[
                        _buildSectionTitle('বাংলা উচ্চারণ'),
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            border: Border.all(color: Colors.yellow[300]!),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'দ্রষ্টব্য: আরবি দু’আ ও পাঠসমূহ বাংলা হরফে লেখা হয়েছে সহায়তার জন্য। তবে সব আরবি শব্দের সঠিক উচ্চারণ বাংলা ভাষায় প্রকাশ করা সম্ভব নয়। তাই সুযোগ হলে আরবি মূল লেখা দেখে শিখুন, ইনশাআল্লাহ।',
                            style: TextStyle(
                              fontSize: banglaFontSize - 4,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                        Text(
                          duaBangla,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Reference
                      if (reference.isNotEmpty) ...[
                        Text(
                          "- $reference",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(height: 24),
                      ],

                      // Bangla Translation with Warning
                      if (banglaTranslation.isNotEmpty) ...[
                        _buildSectionTitle('বাংলা অনুবাদ'),
                        Text(
                          banglaTranslation,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Tafseer
                      if (tafseer.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildSectionTitle('তাফসীর'),
                        Text(
                          tafseer,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Benefit
                      if (benefit.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildSectionTitle('উপকারিতা'),
                        Text(
                          benefit,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Hadith
                      if (hadith.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildSectionTitle('হাদিস'),
                        Text(
                          hadith,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Benefit or Hadith
                      if (benefitorhadith.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildSectionTitle('উপকারিতা/হাদিস'),
                        Text(
                          benefitorhadith,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Warning
                      if (warning.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildSectionTitle('সতর্কতা'),
                        _buildWarningBox(warning),
                      ],

                      // Footnote
                      if (footnote.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildSectionTitle('পাদটীকা'),
                        Text(
                          footnote,
                          style: TextStyle(
                            fontSize: banglaFontSize - 2,
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Other
                      if (other.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildSectionTitle('অন্যান্য'),
                        Text(
                          other,
                          style: TextStyle(
                            fontSize: banglaFontSize,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                      ],
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

