import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../widgets/dua_list_card_widget.dart';
import '../widgets/dua_search_widget.dart';

class IomDailyAzkarDuaListScreen extends StatefulWidget {
  final String tag;
  final List<dynamic> duaData;

  const IomDailyAzkarDuaListScreen({required this.tag, required this.duaData, Key? key}) : super(key: key);

  @override
  State<IomDailyAzkarDuaListScreen> createState() => _IomDailyAzkarDuaListScreenState();
}

class _IomDailyAzkarDuaListScreenState extends State<IomDailyAzkarDuaListScreen> {
  List<dynamic> _filteredDuas = [];
  List<dynamic> _displayedDuas = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  // Grouped by priority with correct order
  List<String> _priorityOrder = ['High', 'Medium', 'Low', 'Self Rukaiya'];
  Map<String, List<dynamic>> _groupedDuas = {};

  @override
  void initState() {
    super.initState();
    _filterDuas();
    _searchController.addListener(_onSearchChanged);
  }

  void _filterDuas() {
    _filteredDuas = widget.duaData; // No tag filter for this design
    _displayedDuas = List.from(_filteredDuas);
    _groupByPriority();
    setState(() {
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _displayedDuas = _filteredDuas.where((dua) {
        final title = dua['title']?.toString().toLowerCase().trim() ?? '';
        return title.contains(query);
      }).toList();
      _groupByPriority();
    });
  }

  void _groupByPriority() {
    _groupedDuas = {};

    // Initialize with priority order
    for (String priority in _priorityOrder) {
      _groupedDuas[priority] = [];
    }

    // Group duas by priority
    for (var dua in _displayedDuas) {
      final priority = (dua['priority'] ?? 'Other').toString();
      if (_groupedDuas.containsKey(priority)) {
        _groupedDuas[priority]!.add(dua);
      } else {
        // Handle any priority not in the predefined order
        _groupedDuas[priority] = [dua];
      }
    }

    // Remove empty groups
    _groupedDuas.removeWhere((key, value) => value.isEmpty);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get priorities in the correct order
    final priorities = _priorityOrder.where((priority) =>
    _groupedDuas.containsKey(priority) && _groupedDuas[priority]!.isNotEmpty
    ).toList();

    // Add any other priorities not in the predefined order
    for (String key in _groupedDuas.keys) {
      if (!_priorityOrder.contains(key)) {
        priorities.add(key);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'হেফাজত এর আমল সমূহ',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: DuaSearchWidget(searchController: _searchController),
          ),
          Expanded(
            child: _displayedDuas.isEmpty
                ? const Center(child: Text('কোনো দোয়া খুঁজে পাওয়া যায়নি।'))
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _calculateTotalItems(priorities),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                return _buildItem(context, index, priorities);
              },
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalItems(List<String> priorities) {
    int total = 0;
    for (String priority in priorities) {
      total += 1; // Header
      total += _groupedDuas[priority]!.length; // Items
    }
    return total;
  }

  Widget _buildItem(BuildContext context, int index, List<String> priorities) {
    int currentIndex = 0;

    for (String priority in priorities) {
      final duaList = _groupedDuas[priority]!;

      // Check if this is the header for this priority
      if (index == currentIndex) {
        return LevelName(priority: priority);
      }
      currentIndex++;

      // Check if this is one of the dua items for this priority
      if (index < currentIndex + duaList.length) {
        final duaIndex = index - currentIndex;
        final dua = duaList[duaIndex];

        // Find the original index in _displayedDuas
        final originalIndex = _displayedDuas.indexOf(dua);

        return DuaListCardWidget(
          dua: dua,
          index: originalIndex >= 0 ? originalIndex : duaIndex, // Use original index if found
          duaList: _displayedDuas,
        );
      }
      currentIndex += duaList.length;
    }

    return const SizedBox.shrink();
  }
}


class LevelName extends StatefulWidget {
  const LevelName({
    super.key,
    required this.priority,
  });

  final String priority;

  @override
  State<LevelName> createState() => _LevelNameState();
}

class _LevelNameState extends State<LevelName> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final priority = widget.priority;

    final headerText = priority == 'High'
        ? 'প্রাথমিক স্তর (সাধারণ নিরাপত্তা): সর্বনিম্ন আমল: সবচেয়ে বেশি শক্তিশালী'
        : priority == 'Medium'
        ? 'দ্বিতীয় স্তর (বিশেষ নিরাপত্তা)'
        : priority == 'Low'
        ? 'তৃতীয় স্তর (উচ্চমানের নিরাপত্তা)'
        : priority == 'Self Rukaiya'
        ? 'হাদিসের কিছু শক্তিশালী রুকইয়াহ বা তিব্বে নববি'
        : priority;

    final descriptionText = priority == 'High'
        ? 'যদি আপনার কোন রুকইয়াহ বিষয়ক সমস্যা না থেকে থাকে এবং নামাজের পর কম সময় দিতে পারেন, তবে এই আমলগুলো দিয়ে শুরু করতে পারেন। এই আমলগুলো ইনশাআল্লাহ হেফাজতের জন্য কাজ করবে। তবে এই স্তরের আমলগুলোতে অভ্যস্ত হয়ে গেলে আস্তে আস্তে নিচের আমলগুলো শুরু করতে হবে।'
        : priority == 'Medium'
        ? 'যদি আপনার রুকইয়াহ বিষয়ক সামান্য কিছু সমস্যা থাকে অথবা আশংকা করছেন তবে ১ম স্তরের সাথে এই আমলগুলো যোগ করতে হবে। তবে ১মগুলো সবচেয়ে শক্তিশালী।'
        : priority == 'Low'
        ? 'যদি আপনার রুকইয়াহ বিষয়ক সমস্যা থাকে, কিংবা জিন-শয়তান আপনাকে নিয়ন্ত্রণ করছে তবে উপরের ১ থেকে শুরু করে শেষ পর্যন্ত পড়তে হবে।'
        : priority == 'Self Rukaiya'
        ? ' এই স্তরের আমলগুলো হাদিসের শক্তিশালী রুকইয়াহ বা তিব্বে নববি। এই আমলগুলো পড়লে ইনশাআল্লাহ শয়তান ও জিনের আক্রমণ থেকে মুক্তি পাওয়া যাবে।'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        headerText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    descriptionText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ),
                if (priority == 'High')
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'নিচের প্রতিটি দুআর ক্ষেত্রে অবশ্যই আরবি দেখে পড়তে হবে কেননা আরবি হরফের উচ্চারণ কখনোই বাংলাতে লেখা সম্ভব নয়। ভুল উচ্চারণ করলে অর্থ বিকৃত হয়ে যাওয়ার সম্ভাবনা থাকে',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
