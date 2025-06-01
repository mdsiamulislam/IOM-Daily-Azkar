import 'package:flutter/material.dart';
import 'package:iomdailyazkar/const/constants.dart'; // AppColors এর জন্য

class BadgeInfoDialog extends StatelessWidget {
  final int currentUserLevel;

  const BadgeInfoDialog({Key? key, required this.currentUserLevel}) : super(key: key);

  // এই ফাংশনগুলি HomeScreen থেকে কপি করা হয়েছে যাতে এখানে ব্যাজ আইকন এবং রঙ দেখানো যায়
  IconData _getBadgeIcon(int level) {
    switch (level) {
      case 1:
        return Icons.star_border;
      case 2:
        return Icons.star;
      case 3:
        return Icons.military_tech;
      case 4:
        return Icons.workspace_premium;
      case 5:
        return Icons.emoji_events;
      default:
        return Icons.help_outline;
    }
  }

  Color _getBadgeColor(int level) {
    switch (level) {
      case 1:
        return Colors.white;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orangeAccent;
      case 4:
        return Colors.blueGrey.shade200;
      case 5:
        return Colors.amber;
      default:
        return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "আপনার ব্যাজ সিস্টেম",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "প্রতিদিন আজকার সম্পন্ন করে নতুন ব্যাজ অর্জন করুন এবং আপনার ইসলামিক অভ্যাসকে আরও শক্তিশালী করুন!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            _buildLevelRow(
              context,
              level: 1,
              title: "নতুন শিক্ষার্থী",
              days: "০ দিন",
              description: "আজকার শুরু করার জন্য এই ব্যাজ।",
            ),
            _buildLevelRow(
              context,
              level: 2,
              title: "নিয়মিত অভ্যাসকারী",
              days: "১+ ধারাবাহিক দিন",
              description: "নিয়মিত আজকার সম্পন্ন করার প্রথম ধাপ।",
            ),
            _buildLevelRow(
              context,
              level: 3,
              title: "নিবেদিতপ্রাণ",
              days: "৫+ ধারাবাহিক দিন",
              description: "আপনি আজকারের প্রতি নিবেদিতপ্রাণ।",
            ),
            _buildLevelRow(
              context,
              level: 4,
              title: "উন্নত সাধক",
              days: "১০+ ধারাবাহিক দিন",
              description: "আপনার অভ্যাস এখন অনেক উন্নত।",
            ),
            _buildLevelRow(
              context,
              level: 5,
              title: "ওস্তাদ",
              days: "১৫+ ধারাবাহিক দিন",
              description: "আজকারের ক্ষেত্রে আপনি একজন ওস্তাদ!",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "বন্ধ করুন",
            style: TextStyle(color: AppColors.primaryGreen, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelRow(BuildContext context, {
    required int level,
    required String title,
    required String days,
    required String description,
  }) {
    final bool isCurrentLevel = level == currentUserLevel;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentLevel ? AppColors.primaryGreen.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: isCurrentLevel ? Border.all(color: AppColors.primaryGreen, width: 2) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getBadgeIcon(level),
            color: _getBadgeColor(level),
            size: 35,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "লেভেল $level: $title",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isCurrentLevel ? AppColors.primaryGreen : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "প্রয়োজনীয় দিন: $days",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}