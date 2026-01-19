import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../widgets/dua_list_card_widget.dart';
import '../widgets/dua_search_widget.dart';

class DuaListScreen extends StatefulWidget {
  final String tag;
  final List<dynamic> duaData;

  const DuaListScreen({required this.tag, required this.duaData, Key? key}) : super(key: key);

  @override
  _DuaListScreenState createState() => _DuaListScreenState();
}

class _DuaListScreenState extends State<DuaListScreen> {
  List<dynamic> _filteredDuas = [];
  List<dynamic> _displayedDuas = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filterDuas();
    _searchController.addListener(_onSearchChanged);
  }

  void _filterDuas() {
    _filteredDuas = widget.duaData.where((dua) {
      return dua['category']?.toString().trim() == widget.tag.trim();
    }).toList();

    _displayedDuas = List.from(_filteredDuas);
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
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'দোয়ার তালিকা',
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
                ? const Center(child: Text('কোনো দোয়া খুঁজে পাওয়া যায়নি।'))
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _displayedDuas.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final dua = _displayedDuas[index];
                return DuaListCardWidget(
                  dua: dua,
                  index: index,
                  duaList: _displayedDuas,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
