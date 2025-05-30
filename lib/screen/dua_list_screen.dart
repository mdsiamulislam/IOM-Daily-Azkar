import 'package:flutter/material.dart';
import '../const/constants.dart';
import '../widget/dua_list_card_widget.dart';
import '../widget/dua_search_widget.dart';

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
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filterDuas();
    _searchController.addListener(_onSearchChanged);
  }

  void _filterDuas() {
    _filteredDuas = widget.duaData.where((dua) {
      return dua['category_tag'] == widget.tag;
    }).toList();

    _displayedDuas = List.from(_filteredDuas);
    setState(() {
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedDuas = _filteredDuas.where((dua) {
        final title = dua['title']?.toLowerCase() ?? '';
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
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'দোয়ার তালিকা',
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
          DuaSearchWidget(searchController: _searchController),
          Expanded(
            child: _displayedDuas.isEmpty
                ? const Center(child: Text('কোনো দোয়া খুঁজে পাওয়া যায়নি।'))
                : ListView.builder(
              itemCount: _displayedDuas.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final dua = _displayedDuas[index];
                return DuaListCardWidget(dua: dua, index: index, duaList: _displayedDuas);
              },
            ),
          ),
        ],
      ),
    );
  }
}
