import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/constants.dart';

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

  Set<String> _uniqueTags = {};
  String? _selectedTag;

  // Pagination variables
  int _currentPage = 0;
  static const int _limit = 20;
  bool _isLoading = false;
  bool _hasMoreData = true;
  ScrollController _scrollController = ScrollController();

  // Search state
  bool _isSearchMode = false;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void _initializeData() {
    // Initialize with local data first
    _allFatwas = List.from(widget.fatwaData);
    _displayedFatwas = List.from(_allFatwas);

    // Extract unique tags from local data
    for (var fatwa in _allFatwas) {
      final tags = _extractTags(fatwa);
      _uniqueTags.addAll(tags);
    }

    if (widget.filterTag != null && _uniqueTags.contains(widget.filterTag)) {
      _selectedTag = widget.filterTag;
      _applyLocalFilters();
    }

    // Load initial data from API
    _loadApiData();
  }

  // Helper method to extract tags from both data structures
  List<String> _extractTags(dynamic fatwa) {
    List<String> tags = [];

    // For local data structure
    if (fatwa['tag'] != null) {
      tags.add(fatwa['tag']);
    }

    // For API data structure
    if (fatwa['tags'] != null && fatwa['tags'] is List) {
      for (var tag in fatwa['tags']) {
        if (tag != null && tag.toString().isNotEmpty) {
          tags.add(tag.toString());
        }
      }
    }

    return tags;
  }

  // Helper method to get field value with fallback
  String? _getFieldValue(dynamic fatwa, String localField, String apiField) {
    return fatwa[localField] ?? fatwa[apiField];
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        if (_isSearchMode && _searchController.text.trim().isNotEmpty) {
        } else {
          _loadApiData(loadMore: true);
        }
      }
    }
  }

  Future<void> _loadApiData({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // final offset = loadMore ? _displayedFatwas.length : 0;
      // final queryParams = {
      //   'limit': _limit.toString(),
      //   'offset': offset.toString(),
      //   if (_selectedTag != null && _selectedTag != 'All')
      //     'tags': _selectedTag!,
      // };

      final response = await http.post(
        Uri.parse('https://search.ifatwa.info/indexes/posts/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : 'Bearer bdbad192801a4f64141931602d982d78139a4d1f5c1ff686fb4741d7f65a31cd'
        },
        body: jsonEncode(
            {
              'q':'posts',
              'limit': 1000
            }
        )
      );
      
      print('API Response: ${response.body}');



      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> hits = data['hits'] ?? [];

        setState(() {
          if (loadMore) {
            _displayedFatwas.addAll(hits);
          } else {
            // Mix API data with local data for better results
            _displayedFatwas = [...hits, ..._allFatwas];
            _currentPage = 0;
          }

          _hasMoreData = hits.length == _limit;
          _isSearchMode = false;
          _isLoading = false;
        });

        // Update unique tags from API results
        _updateTagsFromResults(hits);
      } else {
        setState(() {
          _isLoading = false;
        });
        // Handle error case
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data. Status: ${response.statusCode} and body ${response.body}')),
        );
      }
    } catch (e) {
      print('API error: $e');
      setState(() => _isLoading = false);

      // Fallback to local data
      if (!loadMore) {
        _applyLocalFilters();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ডেটা লোড করতে সমস্যা হয়েছে। স্থানীয় ডেটা দেখানো হচ্ছে।')),
      );
    }
  }


  void _updateTagsFromResults(List<dynamic> results) {
    for (var result in results) {
      final tags = _extractTags(result);
      _uniqueTags.addAll(tags);
    }
  }

  void _searchLocal(String query) {
    final searchTerms = query.toLowerCase().split(' ').where((s) => s.isNotEmpty).toList();

    setState(() {
      _displayedFatwas = _allFatwas.where((fatwa) {
        if (_selectedTag != null && _selectedTag != 'All') {
          final tags = _extractTags(fatwa);
          if (!tags.contains(_selectedTag)) {
            return false;
          }
        }

        final title = (_getFieldValue(fatwa, 'question_title', 'qtitle') ?? '').toLowerCase();
        final details = (_getFieldValue(fatwa, 'question_details', 'question') ?? '').toLowerCase();
        final answer = (_getFieldValue(fatwa, 'answer', 'content') ?? '').toLowerCase();

        return searchTerms.any((term) =>
        title.contains(term) ||
            details.contains(term) ||
            answer.contains(term));
      }).toList();

      _displayedFatwas.sort((a, b) {
        final timestampA = a['timestamp'] ?? a['createdAt'];
        final timestampB = b['timestamp'] ?? b['createdAt'];

        if (timestampA == null && timestampB == null) return 0;
        if (timestampA == null) return 1;
        if (timestampB == null) return -1;

        return (timestampA as Comparable).compareTo(timestampB as Comparable);
      });

      _isSearchMode = true;
      _hasMoreData = false;
    });
  }

  void _applyLocalFilters() {
    List<dynamic> filteredByTag = [];

    if (_selectedTag == null || _selectedTag == 'All') {
      filteredByTag = List.from(_allFatwas);
    } else {
      filteredByTag = _allFatwas.where((fatwa) {
        final tags = _extractTags(fatwa);
        return tags.contains(_selectedTag);
      }).toList();
    }

    setState(() {
      _displayedFatwas = filteredByTag;
      _displayedFatwas.sort((a, b) {
        final timestampA = a['timestamp'] ?? a['createdAt'];
        final timestampB = b['timestamp'] ?? b['createdAt'];

        if (timestampA == null && timestampB == null) return 0;
        if (timestampA == null) return 1;
        if (timestampB == null) return -1;

        return (timestampA as Comparable).compareTo(timestampB as Comparable);
      });

      _isSearchMode = false;
      _hasMoreData = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      // Reset to tag-filtered data
      if (_selectedTag != null && _selectedTag != 'All') {
        _loadApiData();
      } else {
        _loadApiData();
      }
    } else {
      // Debounce search
      Future.delayed(Duration(milliseconds: 500), () {
        if (_searchController.text.trim() == query && query.isNotEmpty) {
          // _searchApiData(query);
        }
      });
    }
  }

  void _onTagChanged(String? newTag) {
    setState(() {
      _selectedTag = newTag;
      _searchController.clear();
    });

    if (newTag == null || newTag == 'All') {
      _loadApiData();
    } else {
      _loadApiData();
    }
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
      appBar: AppBar(
        title: const Text(
          'ফতোয়ার তালিকা'
        ),
      ),
      body: Column(
        children: [
          // Search Field
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
              ),
            ),
          ),

          // Filter Row
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
                    onChanged: _onTagChanged,
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

          // Results List
          Expanded(
            child: _displayedFatwas.isEmpty && !_isLoading
                ? const Center(child: Text('কোনো ফতোয়া খুঁজে পাওয়া যায়নি।'))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _displayedFatwas.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _displayedFatwas.length) {
                  return _buildLoadingIndicator();
                }

                final fatwa = _displayedFatwas[index];
                return FatwaCardWidget(fatwa: fatwa);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
      ),
    );
  }
}

class FatwaCardWidget extends StatelessWidget {
  final dynamic fatwa;

  const FatwaCardWidget({super.key, required this.fatwa});

  String? _getFieldValue(String localField, String apiField) {
    final value = fatwa[localField] ?? fatwa[apiField];
    return value?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final title = _getFieldValue('question_title', 'qtitle');
    final question = _getFieldValue('question_details', 'question');
    final answer = _getFieldValue('answer', 'content');
    final createdAt = fatwa['createdAt']?.toString() ?? fatwa['timestamp']?.toString();

    List<String> tags = [];
    if (fatwa['tags'] != null && fatwa['tags'] is List) {
      tags.addAll((fatwa['tags'] as List).map((t) => t.toString()));
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12)
      ),
      child: ListTile(
        title: Text(
          title ?? "No Title",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (createdAt != null)
              Text(
                "তারিখ: $createdAt",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (question != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6,
                  children: tags
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: const TextStyle(color: Colors.green),
                  ))
                      .toList(),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FatwaDetailScreen(fatwa: fatwa),
            ),
          );
        },
      ),
    );
  }
}


class FatwaDetailScreen extends StatelessWidget {
  final dynamic fatwa;

  const FatwaDetailScreen({super.key, required this.fatwa});

  String? _getFieldValue(String localField, String apiField) {
    final value = fatwa[localField] ?? fatwa[apiField];
    return value?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final title = _getFieldValue('question_title', 'qtitle');
    final question = _getFieldValue('question_details', 'question');
    final answer = _getFieldValue('answer', 'content');
    final createdAt = fatwa['createdAt']?.toString() ?? fatwa['timestamp']?.toString();

    List<String> tags = [];
    if (fatwa['tags'] != null && fatwa['tags'] is List) {
      tags.addAll((fatwa['tags'] as List).map((t) => t.toString()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Fatwa Details", style: TextStyle(
          color: AppColors.white
        ),),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(
          color: AppColors.white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (createdAt != null)
                Text(
                  "তারিখ: $createdAt",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              if (question != null) ...[
                const SizedBox(height: 10),
                Text(
                  "প্রশ্ন:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
                Text(
                  question,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
              if (answer != null) ...[
                const SizedBox(height: 16),
                Text(
                  "উত্তর:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
                Text(
                  answer,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  "Tags:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
                Wrap(
                  spacing: 6,
                  children: tags
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: const TextStyle(color: Colors.green),
                  ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
