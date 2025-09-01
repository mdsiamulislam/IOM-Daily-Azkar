import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../../../../core/constants/constants.dart';
import '../../widgets/fatwa_detail_screen.dart';

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
  ScrollController _scrollController = ScrollController();

  Set<String> _uniqueTags = {};
  String? _selectedTag;

  // Pagination variables
  int _currentOffset = 0;
  final int _limit = 20; // Number of items per page
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
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
    _scrollController.addListener(_onScroll);

    // Load initial data
    getFatwaData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Reached the bottom, load more data
      _loadMoreData();
    }
  }

  Future<void> getFatwaData({bool isLoadingMore = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
          Uri.parse('https://search.ifatwa.info/indexes/posts/search?offset=$_currentOffset&limit=$_limit'),
          headers: {
            'Authorization': 'Bearer a43fb2279a2dcb627542879ce0cb7fa11205888381429322f2f128b03d2c8220'
          }
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> newFatwas = responseData['hits'] ?? [];

        if (newFatwas.isEmpty) {
          setState(() {
            _hasMoreData = false;
          });
        } else {
          setState(() {
            if (isLoadingMore) {
              // Add new fatwas to existing list
              _allFatwas.addAll(newFatwas);
            } else {
              // Replace with new data (for initial load or refresh)
              _allFatwas = newFatwas;
            }

            // Update unique tags
            for (var fatwa in newFatwas) {
              if (fatwa['tags'] != null && fatwa['tags'] is List) {
                for (String tag in fatwa['tags']) {
                  _uniqueTags.add(tag);
                }
              }
            }

            _applyFilters();
          });
        }
      } else {
        print('Failed to load fatwa data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ডেটা লোড করতে ব্যর্থ হয়েছে।')),
        );
      }
    } catch (e) {
      print('Error loading fatwa data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('নেটওয়ার্ক ত্রুটি।')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMoreData || _isLoading) return;

    _currentOffset += _limit;
    await getFatwaData(isLoadingMore: true);
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentOffset = 0;
      _hasMoreData = true;
      _allFatwas.clear();
    });
    await getFatwaData();
  }

  void _applyFilters() {
    List<dynamic> filteredByTag = [];

    if (_selectedTag == null || _selectedTag == 'All') {
      filteredByTag = List.from(_allFatwas);
    } else {
      filteredByTag = _allFatwas.where((fatwa) {
        if (fatwa['tags'] != null && fatwa['tags'] is List) {
          return fatwa['tags'].contains(_selectedTag);
        }
        return false;
      }).toList();
    }

    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _displayedFatwas = filteredByTag;
        _sortFatwas();
      });
      return;
    }

    final searchTerms = query.split(' ').where((s) => s.isNotEmpty).toList();

    setState(() {
      _displayedFatwas = filteredByTag.where((fatwa) {
        final title = fatwa['qtitle']?.toLowerCase() ?? '';
        final details = fatwa['question']?.toLowerCase() ?? '';
        final answer = fatwa['content']?.toLowerCase() ?? '';

        return searchTerms.any((term) =>
        title.contains(term) ||
            details.contains(term) ||
            answer.contains(term));
      }).toList();

      _sortFatwas();
    });
  }

  void _sortFatwas() {
    _displayedFatwas.sort((a, b) {
      final timestampA = a['createdAt'];
      final timestampB = b['createdAt'];

      if (timestampA == null && timestampB == null) return 0;
      if (timestampA == null) return 1;
      if (timestampB == null) return -1;

      return (timestampA as Comparable).compareTo(timestampB as Comparable);
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
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
                  SizedBox(width: 10),
                  IconButton(
                    icon: Row(
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
            // Data count display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    'মোট ফতোয়া: ${_displayedFatwas.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_hasMoreData) ...[
                    const Spacer(),
                    Text(
                      'আরো লোড করুন...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _displayedFatwas.isEmpty
                  ? Center(
                  child: _isLoading
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryGreen),
                      const SizedBox(height: 16),
                      const Text('ফতোয়া লোড হচ্ছে...'),
                    ],
                  )
                      : const Text('কোনো ফতোয়া খুঁজে পাওয়া যায়নি।')
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _displayedFatwas.length + (_hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _displayedFatwas.length) {
                    final fatwa = _displayedFatwas[index];
                    return FatwaCardWidget(fatwa: fatwa);
                  } else {
                    // Loading indicator at the bottom
                    return Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryGreen),
                          const SizedBox(height: 8),
                          const Text('আরো ফতোয়া লোড হচ্ছে...'),
                        ],
                      )
                          : ElevatedButton(
                        onPressed: _loadMoreData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('আরো লোড করুন'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FatwaCardWidget extends StatelessWidget {
  final dynamic fatwa;

  const FatwaCardWidget({Key? key, required this.fatwa}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract tags for display
    List<String> tags = [];
    if (fatwa['tags'] != null && fatwa['tags'] is List) {
      tags = List<String>.from(fatwa['tags']);
    }

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
              fatwa['qtitle'] ?? 'শিরোনাম নেই',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              fatwa['question'] ?? 'প্রশ্নটি পাওয়া যায়নি।',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // Display tags
            if (tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: tags.take(3).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (fatwa['createdAt'] != null)
                  Text(
                    fatwa['createdAt'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                TextButton(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
