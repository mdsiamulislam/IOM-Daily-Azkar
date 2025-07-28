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
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'দোয়ার তালিকা',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            priority,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        );
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