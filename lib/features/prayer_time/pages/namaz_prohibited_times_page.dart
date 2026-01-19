import 'package:flutter/material.dart';

class NamazProhibitedTimesPage extends StatelessWidget {
  const NamazProhibitedTimesPage({super.key});

  final TextStyle headingStyle =
  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green);
  final TextStyle subHeadingStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87);
  final TextStyle contentStyle =
  const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("নামায নিষিদ্ধ সময় ও ব্যতিক্রম"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "নামায নিষিদ্ধ হওয়ার সময়সমূহ (সাধারণ নির্দেশ):",
              style: headingStyle,
            ),
            const SizedBox(height: 12),
            _bulletPoint("আসরের নামাযের পর সূর্য না ডোবা পর্যন্ত অন্য কোন নামায পড়া নিষিদ্ধ।"),
            _bulletPoint("ফজরের নামাযের পর সূর্য না ওঠা পর্যন্ত অন্য কোন নামায পড়া নিষিদ্ধ।"),
            _bulletPoint("সঠিক সূর্যোদয় থেকে একটু উঁচু না হওয়া পর্যন্ত নামায নিষিদ্ধ।"),
            _bulletPoint("সূর্য ঠিক মাথার উপর আসার পর থেকে একটু ঢলে না যাওয়া পর্যন্ত নামায নিষিদ্ধ।"),
            _bulletPoint("সূর্য ডোবার কাছাকাছি হওয়া থেকে ডুবে না যাওয়া পর্যন্ত নামায নিষিদ্ধ।"),
            const SizedBox(height: 16),
            Text(
              "ব্যতিক্রমসমূহ:",
              style: headingStyle,
            ),
            const SizedBox(height: 12),
            _numberedPoint(
                "যদি ফরয নামায বাকী থাকে, তা আদায় করা জরুরি। যেমন: আসরের পূর্বে সূর্য ডোবার এক রাকআত নামায পাওয়া গেলে বাকী পূর্ণ করা যায়।"),
            _numberedPoint(
                "যদি কোন ফরয নামায ভুলে যাওয়া বা ঘুমিয়ে যাওয়া অবস্থায় থাকে, তা স্মরণ হওয়া মাত্র যে কোনো সময়ে আদায় করা যায়।"),
            _numberedPoint(
                "দুপুরে মসজিদে জুমুআহ পড়তে এসে নফল নামায পড়া বিধেয়, এটি নিষেধের আওতাভুক্ত নয়।"),
            _numberedPoint(
                "ফজরের দু’ রাকআত সুন্নত নামাযের পূর্বে সময় না পেলে ফরযের পরে পড়া যায়।"),
            _numberedPoint(
                "কারণ-সাপেক্ষ যাবতীয় নামায যথাযথ কারণ উপস্থিত হওয়া মাত্র যে কোনো সময়ে পড়া যায়। যেমন- তাওয়াফের পরে, মসজিদে প্রবেশের আগে, সূর্য বা চন্দ্র গ্রহণের নামায, জানাযার নামায ইত্যাদি।"),
            const SizedBox(height: 16),
            Text(
              "উল্লেখ্য:",
              style: headingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              "সাধারণ নফল নামায উক্ত সময়গুলিতে নিষিদ্ধ। তবে আসরের পর সূর্য হ্‌লুদবর্ণ না হওয়া পর্যন্ত কিছু ক্ষেত্রে অনুমতি আছে।",
              style: contentStyle,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: contentStyle),
          ),
        ],
      ),
    );
  }

  Widget _numberedPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("➤  ", style: TextStyle(fontSize: 16, color: Colors.green)),
          Expanded(
            child: Text(text, style: contentStyle),
          ),
        ],
      ),
    );
  }
}
