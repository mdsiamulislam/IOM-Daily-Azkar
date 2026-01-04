import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/constants.dart';
import '../../controllers/fatwah_controllers.dart';

class IFatwaListScreen extends StatefulWidget {
  final List<dynamic> fatwaData;
  final String? filterTag;

  IFatwaListScreen({
    Key? key,
    required this.fatwaData,
    this.filterTag,
  }) : super(key: key);

  @override
  State<IFatwaListScreen> createState() => _IFatwaListScreenState();
}

class _IFatwaListScreenState extends State<IFatwaListScreen> {
  List<dynamic> _allFatwas = [];
  List<dynamic> _displayedFatwas = [];
  TextEditingController _searchController = TextEditingController();
  final fatwahControllers = Get.put(FatwahControllers());

  Set<String> _uniqueTags = {};
  String? _selectedTag;

  @override
  void initState() {
    fatwahControllers.fetchFatwah();
    super.initState();
    _allFatwas = List.from(widget.fatwaData);

    for (var fatwa in _allFatwas) {
      if (fatwa['tag'] != null) {
        _uniqueTags.add(fatwa['tag']);
      }
    }

    if (widget.filterTag != null && _uniqueTags.contains(widget.filterTag)) {
      _selectedTag = widget.filterTag;
    }

    _applyFilters();
    _searchController.addListener(_onSearchChanged);
  }

  void _applyFilters() {
    List<dynamic> filteredByTag = [];

    if (_selectedTag == null || _selectedTag == 'All') {
      filteredByTag = List.from(_allFatwas);
    } else {
      filteredByTag = _allFatwas.where((fatwa) {
        return fatwa['tag'] == _selectedTag;
      }).toList();
    }

    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _displayedFatwas = filteredByTag;
        _displayedFatwas.sort((a, b) {
          final timestampA = a['timestamp'];
          final timestampB = b['timestamp'];

          if (timestampA == null && timestampB == null) return 0;
          if (timestampA == null) return 1;
          if (timestampB == null) return -1;

          // অ্যাসেন্ডিং অর্ডারের জন্য (পুরোনোতম প্রথমে)
          return (timestampA as Comparable).compareTo(timestampB as Comparable);
        });
      });
      return;
    }

    final searchTerms = query.split(' ').where((s) => s.isNotEmpty).toList();

    setState(() {
      _displayedFatwas = filteredByTag.where((fatwa) {
        final title = fatwa['question_title']?.toLowerCase() ?? '';
        final details = fatwa['question_details']?.toLowerCase() ?? '';
        final answer = fatwa['answer']?.toLowerCase() ?? '';

        return searchTerms.any((term) =>
        title.contains(term) ||
            details.contains(term) ||
            answer.contains(term));
      }).toList();

      _displayedFatwas.sort((a, b) {
        final timestampA = a['timestamp'];
        final timestampB = b['timestamp'];

        if (timestampA == null && timestampB == null) return 0;
        if (timestampA == null) return 1;
        if (timestampB == null) return -1;

        // অ্যাসেন্ডিং অর্ডারের জন্য (পুরোনোতম প্রথমে)
        return (timestampA as Comparable).compareTo(timestampB as Comparable);
      });
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'ফতোয়ার তালিকা',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.white.withOpacity(0.7),
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: AppColors.innerShadowColor.withOpacity(0.1),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ফতোয়া খুঁজুন...',
                  hintStyle: TextStyle(color: Colors.grey[700]),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryGreen, size: 24),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryGreen, width: 2.0),
                  ),
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                cursorColor: AppColors.primaryGreen,
                style: TextStyle(color: Colors.black87, fontSize: 16),
                onChanged: (query) {
                  if (mounted) {
                    setState(() {});
                  }
                },
                textInputAction: TextInputAction.search,
                onSubmitted: (query) {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              children: [
                const Text(
                  'ট্যাগ:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedTag,
                    hint: const Text('সব'),
                    isExpanded: true,
                    underline: Container(),
                    items: ['All', ..._uniqueTags].map((String tag) {
                      return DropdownMenuItem<String>(
                        value: tag,
                        child: Text(tag),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTag = newValue;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon:Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.question_answer, color: AppColors.primaryGreen),
                      const SizedBox(width: 4),
                      const Text('প্রশ্ন করুন', style: TextStyle(color: AppColors.primaryGreen)),
                    ],
                  ),
                  onPressed: () {
                    const url = 'https://ifatwa.info/rules';
                    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('লিঙ্ক খুলতে ব্যর্থ হয়েছে।')),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _displayedFatwas.isEmpty
                ? const Center(child: Text('কোনো ফতোয়া খুঁজে পাওয়া যায়নি।'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _displayedFatwas.length,
              itemBuilder: (context, index) {
                final fatwa = _displayedFatwas[index];
                return FatwaCardWidget(fatwa: fatwa);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FatwaCardWidget extends StatelessWidget {
  final dynamic fatwa;

  const FatwaCardWidget({Key? key, required this.fatwa}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fatwa['question_title'] ?? 'শিরোনাম নেই',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              fatwa['question_details'] ?? 'প্রশ্নটি পাওয়া যায়নি।',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FatwaDetailScreen(fatwa: fatwa),
                    ),
                  );
                },
                child: const Text(
                  'বিস্তারিত পড়ুন',
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FatwaDetailScreen extends StatelessWidget {
  final dynamic fatwa;

  const FatwaDetailScreen({Key? key, required this.fatwa}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          fatwa['question_title'] ?? 'ফতোয়ার বিস্তারিত',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "প্রশ্ন:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
                ],
              ),
              child: Text(
                fatwa['question_details'] ?? 'প্রশ্নটি পাওয়া যায়নি।',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "উত্তর:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
                ],
              ),
              child: Text(
                fatwa['answer'] ?? 'উত্তরটি পাওয়া যায়নি।',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),
            if (fatwa['fatwa_link'] != null && fatwa['fatwa_link'].isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final url = fatwa['fatwa_link'];
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('লিঙ্ক খুলতে ব্যর্থ হয়েছে।')),
                      );
                    }
                  },
                  icon: const Icon(Icons.link, color: AppColors.primaryGreen),
                  label: const Text(
                    'মূল ফতোয়ার লিঙ্ক',
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
