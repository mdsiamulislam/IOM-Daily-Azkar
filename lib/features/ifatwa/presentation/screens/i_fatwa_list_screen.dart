import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:iomdailyazkar/core/universal_widgets/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class IFatwaListScreen extends StatefulWidget {
  final String? filterTag;

  const IFatwaListScreen({
    super.key,
    this.filterTag,
  });

  @override
  State<IFatwaListScreen> createState() => _IFatwaListScreenState();
}

class _IFatwaListScreenState extends State<IFatwaListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<dynamic> _allFatwas = [];
  List<dynamic> _displayedFatwas = [];
  Set<String> _tags = {'সকল'};
  Set<String> _bookmarkedFatwas = {};

  bool _isLoading = false;
  bool _hasMore = true;
  bool _showSearchBar = false;
  bool _showTagsSheet = false;

  String _searchQuery = '';
  String _selectedTag = 'সকল';
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _extractInitialTags();
    _applyFilters();
    _scrollController.addListener(_onScroll);
    _fetchFatwas();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_fatwas') ?? [];
    setState(() {
      _bookmarkedFatwas = bookmarks.toSet();
    });
  }

  Future<void> _toggleBookmark(String fatwaId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_bookmarkedFatwas.contains(fatwaId)) {
      _bookmarkedFatwas.remove(fatwaId);
    } else {
      _bookmarkedFatwas.add(fatwaId);
    }
    await prefs.setStringList('bookmarked_fatwas', _bookmarkedFatwas.toList());
    setState(() {});
  }

  Future<void> _fetchFatwas() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://search.ifatwa.info/indexes/posts/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
          'Bearer bdbad192801a4f64141931602d982d78139a4d1f5c1ff686fb4741d7f65a31cd',
        },
        body: jsonEncode({
          'q': _searchQuery.isNotEmpty ? _searchQuery : 'posts',
          'limit': 20,
          'offset': _currentPage * 20,
        }),
      );

      if (response.statusCode == 200) {
        final hits = jsonDecode(response.body)['hits'] ?? [];

        if (hits.isEmpty) {
          _hasMore = false;
        } else {
          if (_currentPage == 0) {
            _allFatwas = hits;
          } else {
            _allFatwas.addAll(hits);
          }
          _updateTags(hits);
          _applyFilters();
          _currentPage++;
        }
      }
    } catch (_) {
      AppSnackbar.showError(
        'ফতোয়া লোড করতে সমস্যা হয়েছে। অনুগ্রহ করে পরে আবার চেষ্টা করুন।',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 300) {
      _fetchFatwas();
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value.trim();
    _currentPage = 0;
    _hasMore = true;
    _applyFilters();
    if (value.isNotEmpty) {
      _fetchFatwas();
    }
  }

  void _onTagChanged(String tag) {
    setState(() => _selectedTag = tag);
    _applyFilters();
    if (_showTagsSheet) {
      Navigator.pop(context);
      _showTagsSheet = false;
    }
  }

  void _applyFilters() {
    List<dynamic> list = List.from(_allFatwas);

    if (_selectedTag != 'সকল') {
      list = list.where((f) => _extractTags(f).contains(_selectedTag)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((f) {
        final title = _getFatwaField(f, 'question_title', 'qtitle').toLowerCase();
        final question = _getFatwaField(f, 'question_details', 'question').toLowerCase();
        final answer = _getFatwaField(f, 'answer', 'content').toLowerCase();

        return title.contains(query) ||
            question.contains(query) ||
            answer.contains(query);
      }).toList();
    }

    list.sort((a, b) {
      final at = a['createdAt'] ?? a['timestamp'] ?? '';
      final bt = b['createdAt'] ?? b['timestamp'] ?? '';
      return bt.toString().compareTo(at.toString());
    });

    setState(() => _displayedFatwas = list);
  }

  String _getFatwaField(dynamic fatwa, String field1, String field2) {
    return (fatwa[field1] ?? fatwa[field2] ?? '').toString().trim();
  }

  void _extractInitialTags() {
    for (var f in _allFatwas) {
      _tags.addAll(_extractTags(f));
    }
  }

  void _updateTags(List<dynamic> list) {
    for (var f in list) {
      _tags.addAll(_extractTags(f));
    }
  }

  List<String> _extractTags(dynamic fatwa) {
    List<String> tags = [];

    if (fatwa['tag'] != null && fatwa['tag'].toString().isNotEmpty) {
      tags.add(fatwa['tag'].toString());
    }

    if (fatwa['tags'] is List) {
      final tagList = fatwa['tags'] as List;
      for (var tag in tagList) {
        if (tag.toString().isNotEmpty) {
          tags.add(tag.toString());
        }
      }
    }

    return tags.where((tag) => tag.isNotEmpty).toList();
  }

  void _showFilterBottomSheet() {
    _showTagsSheet = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ট্যাগ নির্বাচন করুন',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return FilterChip(
                      label: Text(tag),
                      selected: _selectedTag == tag,
                      onSelected: (_) => _onTagChanged(tag),
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.blue.shade100,
                      labelStyle: TextStyle(
                        color: _selectedTag == tag ? Colors.blue.shade800 : Colors.grey.shade800,
                        fontWeight: _selectedTag == tag ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      _showTagsSheet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar ? null : const Text('ফতোয়ার তালিকা'),
        actions: [
          if (!_showSearchBar)
            IconButton(
              onPressed: () {
                setState(() => _showSearchBar = true);
                Future.delayed(const Duration(milliseconds: 100), () {
                  _searchFocusNode.requestFocus();
                });
              },
              icon: const Icon(Icons.search),
            ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookmarkedFatwasScreen(
                  allFatwas: _allFatwas,
                  bookmarkedIds: _bookmarkedFatwas,
                ),
              ),
            ),
            icon: Stack(
              children: [
                const Icon(Icons.bookmark_border),
                if (_bookmarkedFatwas.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_bookmarkedFatwas.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearchBar) _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildFatwaList()),
        ],
      ),
      floatingActionButton: _selectedTag != 'সকল'
          ? FloatingActionButton.extended(
        onPressed: _showFilterBottomSheet,
        icon: const Icon(Icons.filter_alt),
        label: Text(_selectedTag),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ফতোয়া খুঁজুন...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() => _showSearchBar = false);
              _searchController.clear();
              _onSearchChanged('');
              _searchFocusNode.unfocus();
            },
            child: const Text('বাতিল'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final popularTags = _tags.where((tag) => tag != 'সকল').take(10).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('সকল'),
              selected: _selectedTag == 'সকল',
              onSelected: (_) => _onTagChanged('সকল'),
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.blue.shade100,
              labelStyle: TextStyle(
                color: _selectedTag == 'সকল' ? Colors.blue.shade800 : Colors.grey.shade800,
                fontWeight: _selectedTag == 'সকল' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            ...popularTags.map((tag) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(tag),
                  selected: _selectedTag == tag,
                  onSelected: (_) => _onTagChanged(tag),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.blue.shade100,
                  labelStyle: TextStyle(
                    color: _selectedTag == tag ? Colors.blue.shade800 : Colors.grey.shade800,
                    fontWeight: _selectedTag == tag ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: _showFilterBottomSheet,
              tooltip: 'সমস্ত ট্যাগ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFatwaList() {
    if (_displayedFatwas.isEmpty && _isLoading) {
      return ListView.builder(
        itemCount: 10,
        itemBuilder: (_, i) => _buildShimmerCard(),
      );
    }

    if (_displayedFatwas.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? '"$_searchQuery" এর জন্য কোনো ফলাফল নেই'
                  : 'কোনো ফতোয়া পাওয়া যায়নি',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            if (_searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: const Text('সকল ফতোয়া দেখুন'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 0;
        _hasMore = true;
        await _fetchFatwas();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _displayedFatwas.length + (_isLoading ? 1 : 0),
        separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          if (i == _displayedFatwas.length) {
            return _buildLoadingIndicator();
          }
          return FatwaCardWidget(
            fatwa: _displayedFatwas[i],
            isBookmarked: _bookmarkedFatwas.contains(_displayedFatwas[i]['id'].toString()),
            onBookmarkToggle: (id) => _toggleBookmark(id),
          );
        },
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 20,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 16,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 24,
                  color: Colors.grey.shade200,
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 24,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'আরো ফতোয়া লোড হচ্ছে...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
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
  final bool isBookmarked;
  final Function(String) onBookmarkToggle;

  const FatwaCardWidget({
    super.key,
    required this.fatwa,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  String _getField(String field1, String field2) {
    return (fatwa[field1] ?? fatwa[field2] ?? '').toString().trim();
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    final parts = date.split(' ');
    if (parts.length >= 3) {
      return '${parts[0]} ${parts[1]}, ${parts[2]}';
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final title = _getField('question_title', 'qtitle');
    final question = _getField('question_details', 'question');
    final date = _formatDate(fatwa['createdAt']?.toString() ?? fatwa['timestamp']?.toString() ?? '');
    final tags = _extractTags(fatwa);
    final id = fatwa['id'].toString();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FatwaDetailScreen(
                fatwa: fatwa,
                isBookmarked: isBookmarked,
                onBookmarkToggle: () => onBookmarkToggle(id),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (date.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              date,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onBookmarkToggle(id),
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.amber.shade700 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              if (question.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    question,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (tags.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tags.map((tag) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6, top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _extractTags(dynamic fatwa) {
    List<String> tags = [];

    if (fatwa['tag'] != null && fatwa['tag'].toString().isNotEmpty) {
      tags.add(fatwa['tag'].toString());
    }

    if (fatwa['tags'] is List) {
      final tagList = fatwa['tags'] as List;
      for (var tag in tagList) {
        if (tag.toString().isNotEmpty) {
          tags.add(tag.toString());
        }
      }
    }

    return tags.take(3).toList();
  }
}

class FatwaDetailScreen extends StatefulWidget {
  final dynamic fatwa;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const FatwaDetailScreen({
    super.key,
    required this.fatwa,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  State<FatwaDetailScreen> createState() => _FatwaDetailScreenState();
}

class _FatwaDetailScreenState extends State<FatwaDetailScreen> {
  bool _showFullAnswer = false;
  bool _showFullQuestion = false;

  String _getField(String field1, String field2) {
    return (widget.fatwa[field1] ?? widget.fatwa[field2] ?? '').toString().trim();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('কপি করা হয়েছে'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareFatwa() async {
    final title = _getField('question_title', 'qtitle');
    final question = _getField('question_details', 'question');
    final answer = _getField('answer', 'content');

    await Share.share(
      'প্রশ্ন: $title\n\n$question\n\nউত্তর: $answer\n\nসূত্র: ifatwa.info',
      subject: 'ফতোয়া: $title',
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _getField('question_title', 'qtitle');
    final question = _getField('question_details', 'question');
    final answer = _getField('answer', 'content');
    final date = widget.fatwa['createdAt']?.toString() ??
        widget.fatwa['timestamp']?.toString() ?? '';
    final tags = _extractTags(widget.fatwa);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title.isNotEmpty ? title : 'ফতোয়ার বিস্তারিত',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {
              final fullText = "প্রশ্ন:\n${question.isNotEmpty ? question : title}\n\nউত্তর:\n$answer";
              _copyToClipboard(context, fullText);
            },
            icon: const Icon(Icons.copy),
          ),
          IconButton(
            onPressed: _shareFatwa,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags
            if (tags.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tags.map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Date
            if (date.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'তারিখ: $date',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Question Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.question_answer,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'প্রশ্ন',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MarkdownBody(
                    data: question.isNotEmpty ? question : title,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      a: TextStyle(color: Colors.blue.shade700),
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(
                          Uri.parse(href),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Answer Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'উত্তর',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MarkdownBody(
                    data: answer.isNotEmpty ? answer : 'কোনো উত্তর নেই',
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                      a: TextStyle(color: Colors.blue.shade700),
                      blockquoteDecoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      blockquotePadding: const EdgeInsets.all(8),
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(
                          Uri.parse(href),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.copy,
                  label: 'কপি',
                  color: Colors.blue,
                  onTap: () {
                    final fullText = "প্রশ্ন:\n${question.isNotEmpty ? question : title}\n\nউত্তর:\n$answer";
                    _copyToClipboard(context, fullText);
                  },
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'শেয়ার',
                  color: Colors.green,
                  onTap: _shareFatwa,
                ),
                _buildActionButton(
                  icon: Icons.bookmark,
                  label: widget.isBookmarked ? 'সেভড' : 'সেভ',
                  color: Colors.amber,
                  onTap: widget.onBookmarkToggle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color:  Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color:  Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<String> _extractTags(dynamic fatwa) {
    List<String> tags = [];

    if (fatwa['tag'] != null && fatwa['tag'].toString().isNotEmpty) {
      tags.add(fatwa['tag'].toString());
    }

    if (fatwa['tags'] is List) {
      final tagList = fatwa['tags'] as List;
      for (var tag in tagList) {
        if (tag.toString().isNotEmpty) {
          tags.add(tag.toString());
        }
      }
    }

    return tags;
  }
}

class BookmarkedFatwasScreen extends StatelessWidget {
  final List<dynamic> allFatwas;
  final Set<String> bookmarkedIds;

  const BookmarkedFatwasScreen({
    super.key,
    required this.allFatwas,
    required this.bookmarkedIds,
  });



  @override
  Widget build(BuildContext context) {
    final bookmarkedFatwas = allFatwas.where(
          (fatwa) => bookmarkedIds.contains(fatwa['id'].toString()),
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('সেভ করা ফতোয়া')
      ),
      body: bookmarkedFatwas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'কোনো সেভ করা ফতোয়া নেই',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarkedFatwas.length,
        separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final fatwa = bookmarkedFatwas[i];
          return FatwaCardWidget(
            fatwa: fatwa,
            isBookmarked: true,
            onBookmarkToggle: (id){
            },
          );
        },
      ),
    );
  }
}