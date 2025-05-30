import 'package:flutter/material.dart';

import '../const/constants.dart';
import '../screen/dua_detail_screen.dart';

class DuaListCardWidget extends StatelessWidget {
  const DuaListCardWidget({
    super.key,
    required this.dua,
    required this.index,
    required this.duaList,
  });

  final dynamic dua;
  final int index;
  final List<dynamic> duaList;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
          child: Icon(Icons.bookmark_border, color: AppColors.primaryGreen),
        ),
        title: Text(
          dua['title'] ?? 'শিরোনাম নেই',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DuaDetailScreen(
                duaData: duaList,
                duaIndex: index,
              ),
            ),
          );
        },
      ),
    );
  }
}