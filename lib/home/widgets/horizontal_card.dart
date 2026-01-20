import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/constants.dart';
import '../../features/dua/presentation/screens/iom_daily_azkar_dua_list_screen.dart';
import '../../features/ifatwa/presentation/screens/i_fatwa_list_screen.dart';

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
    final bool isDua = duaData != null;
    return Card(
      margin: EdgeInsets.zero,
      color: isDua ? AppColors.primaryGreen : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.green.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          if (fatwaData != null && fatwaData!.isNotEmpty) {
            Get.to(IFatwaListScreen());
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
                  color: isDua ? Colors.white : AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDua ?  AppColors.primaryGreen : Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDua ? Colors.white : AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDua ? Colors.white : Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDua ? Colors.white : AppColors.primaryGreen,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}