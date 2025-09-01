
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/constants.dart';

class FatwaDetailScreen extends StatelessWidget {
  final dynamic fatwa;

  const FatwaDetailScreen({Key? key, required this.fatwa}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract tags for display
    List<String> tags = [];
    if (fatwa['tags'] != null && fatwa['tags'] is List) {
      tags = List<String>.from(fatwa['tags']);
    }

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          fatwa['qtitle'] ?? 'ফতোয়ার বিস্তারিত',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question title
            Text(
              fatwa['qtitle'] ?? 'শিরোনাম নেই',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),

            // Question section
            Text(
              "প্রশ্ন:",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                fatwa['question'] ?? 'প্রশ্নটি পাওয়া যায়নি।',
                style: const TextStyle(fontSize: 15, color: Colors.black),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),

            // Answer section
            Text(
              "উত্তর:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
                ],
              ),
              child: Text(
                fatwa['content'] ?? 'উত্তরটি পাওয়া যায়নি।',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),

            // Tags section
            if (tags.isNotEmpty) ...[
              Text(
                "ট্যাগসমূহ:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Metadata
            if (fatwa['createdAt'] != null) ...[
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'তারিখ: ${fatwa['createdAt']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Original fatwa link (if available)
            if (fatwa['fatwa_link'] != null && fatwa['fatwa_link'].isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final url = fatwa['fatwa_link'];
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('লিঙ্ক খুলতে ব্যর্থ হয়েছে।')),
                      );
                    }
                  },
                  icon: const Icon(Icons.link, color: AppColors.primaryGreen),
                  label: const Text(
                    'মূল ফতোয়ার লিঙ্ক',
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}