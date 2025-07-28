import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../dua/presentation/screens/iom_daily_azkar_dua_list_screen.dart';
import '../../ifatwa/presentation/screens/i_fatwa_list_screen.dart';

class HorizontalCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List? fatwaData;
  final List? duaData;

  const HorizontalCard({
    Key? key,
    this.fatwaData,
    this.duaData,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.green.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          if (fatwaData != null && fatwaData!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IFatwaListScreen(
                  fatwaData: fatwaData!,
                ),
              ),
            );
          } else if (duaData != null && duaData!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IomDailyAzkarDuaListScreen(
                  tag: title,
                  duaData: duaData!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No data available for this category')),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColors.primaryGreen, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}