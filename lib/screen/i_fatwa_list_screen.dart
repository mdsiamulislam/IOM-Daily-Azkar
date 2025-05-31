import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const/constants.dart'; // আপনার AppColors এর জন্য

class IFatwaListScreen extends StatefulWidget {
  final List<dynamic> fatwaData;
  final String? filterTag; // নতুন প্যারামিটার: ঐচ্ছিক ফিল্টার ট্যাগ

  const IFatwaListScreen({
    Key? key,
    required this.fatwaData,
    this.filterTag, // constructor এ যোগ করুন
  }) : super(key: key);

  @override
  State<IFatwaListScreen> createState() => _IFatwaListScreenState();
}

class _IFatwaListScreenState extends State<IFatwaListScreen> {
  List<dynamic> _allFatwas = []; // সমস্ত ফতোয়া ডেটা সংরক্ষণ করবে
  List<dynamic> _displayedFatwas = []; // বর্তমানে প্রদর্শিত ফতোয়া
  TextEditingController _searchController = TextEditingController();

  // ট্যাগের জন্য একটি সেট যাতে ডুপ্লিকেট ট্যাগ না থাকে
  Set<String> _uniqueTags = {};
  String? _selectedTag; // বর্তমানে নির্বাচিত ট্যাগ

  @override
  void initState() {
    super.initState();
    _allFatwas = List.from(widget.fatwaData); // সব ফতোয়া সংরক্ষণ করুন

    // ফতোয়া থেকে সব অনন্য ট্যাগ সংগ্রহ করুন
    for (var fatwa in _allFatwas) {
      if (fatwa['tag'] != null) {
        _uniqueTags.add(fatwa['tag']);
      }
    }

    // যদি filterTag পাঠানো হয়, তাহলে সেটি প্রাথমিক নির্বাচিত ট্যাগ হবে
    if (widget.filterTag != null && _uniqueTags.contains(widget.filterTag)) {
      _selectedTag = widget.filterTag;
    }

    _applyFilters(); // প্রাথমিক ফিল্টারিং প্রয়োগ করুন
    _searchController.addListener(_onSearchChanged);
  }

  // ডেটা ফিল্টার এবং সার্চ করার জন্য একটি নতুন ফাংশন
  void _applyFilters() {
    List<dynamic> filteredByTag = [];

    if (_selectedTag == null || _selectedTag == 'All') { // 'All' ট্যাগ সব দেখাবে
      filteredByTag = List.from(_allFatwas);
    } else {
      filteredByTag = _allFatwas.where((fatwa) {
        return fatwa['tag'] == _selectedTag;
      }).toList();
    }

    final query = _searchController.text.toLowerCase().trim(); // অতিরিক্ত স্পেস সরান
    // যদি সার্চ কোয়েরি খালি থাকে, তাহলে শুধু ট্যাগ ফিল্টার করা ডেটা দেখান
    if (query.isEmpty) {
      setState(() {
        _displayedFatwas = filteredByTag;
      });
      return;
    }

    // একাধিক শব্দ দিয়ে সার্চ করার জন্য লজিক
    final searchTerms = query.split(' ').where((s) => s.isNotEmpty).toList(); // স্পেস দিয়ে ভাগ করুন

    setState(() {
      _displayedFatwas = filteredByTag.where((fatwa) {
        final title = fatwa['question_title']?.toLowerCase() ?? '';
        final details = fatwa['question_details']?.toLowerCase() ?? '';
        final answer = fatwa['answer']?.toLowerCase() ?? '';

        // প্রতিটি সার্চ টার্ম দিয়ে চেক করুন যদি কোনো ফিল্ডে ম্যাচ করে
        return searchTerms.any((term) =>
        title.contains(term) ||
            details.contains(term) ||
            answer.contains(term));
      }).toList();
    });
  }

  void _onSearchChanged() {
    _applyFilters(); // সার্চ টেক্সট পরিবর্তন হলে ফিল্টার আবার প্রয়োগ করুন
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
              // আপনার আগের সুন্দর ডিজাইন ফিরিয়ে আনা হয়েছে
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12), // আগের মত গোলাকার কোণা
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ফতোয়া খুঁজুন...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryGreen),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  )
                      : null,
                  border: OutlineInputBorder( // OutlineInputBorder ফিরিয়ে আনা হয়েছে
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // নো বর্ডার
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryGreen, width: 2), // ফোকাস করলে সবুজ বর্ডার
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // এনেবল থাকাকালে কোনো বর্ডার নেই
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                cursorColor: AppColors.primaryGreen,
              ),
            ),
          ),
          // ট্যাগ ফিল্টার ড্রপডাউন
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Padding ঠিক করা হয়েছে
            child: DropdownButtonFormField<String>(
              value: _selectedTag,
              decoration: InputDecoration(
                labelText: 'ট্যাগ নির্বাচন করুন',
                labelStyle: TextStyle(color: AppColors.primaryGreen),
                prefixIcon: Icon(Icons.filter_list, color: AppColors.primaryGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
                ),
                enabledBorder: OutlineInputBorder( // এনেবল থাকাকালে বর্ডার
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('সব ট্যাগ'),
                ),
                ..._uniqueTags.map((tag) {
                  return DropdownMenuItem(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTag = newValue;
                  _applyFilters();
                });
              },
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
              maxLines: 3, // প্রথম কয়েক লাইন দেখানোর জন্য
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