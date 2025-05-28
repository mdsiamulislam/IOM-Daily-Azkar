import 'package:flutter/material.dart';



class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

class AppRoutes {
  static const String categories = '/categories';
  static const String detail = '/detail';
}

//https://script.google.com/macros/s/AKfycbz6gZBH5qs6YlZZK6I7uMrkUITUPaVPxisCcFGHhe1QavpPQQ3SvRv4-Fp06baSgq10/exec

class DuaData {
  Map<String, List<Map<String, String>>> dua = {
    "morning_evening": [
      {
        "title": "সকাল ও সন্ধ্যার দোয়া",
        "description": "দিনের শুরু ও শেষের সময়ে পড়ার দোয়া।",
        "dua": "আল্লাহুম্মা ইন্নি আসআলুকা খাইরাল ইয়াওমি হাযা...",
        "dua_english": "Allahumma inni as'aluka khayra al-yawmi hadha...",
        "dua_arabic": "اللّهُمَّ إنّي أَسْأَلُكَ خَيْرَ هذَا الْيَوْمِ",
        "tafseer": "এই দোয়াটির মাধ্যমে আমরা আল্লাহর কাছে ঐ দিনের কল্যাণ কামনা করি ও ক্ষতি থেকে বাঁচার দোয়া করি।",
        "reference": "সহীহ মুসলিম",
        "rules": "সকাল ও সন্ধ্যার সময়ে পড়া।"
      },
    ],
    "healing": [
      {
        "title": "রোগ মুক্তির দোয়া",
        "description": "রোগ ও অসুস্থতার সময়ে পড়ার দোয়া।",
        "dua": "আল্লাহুম্মা রব্বান্ নাস, আযহিবিল-বা’স, ইশফি, আনতাশ্ শাফি, লা শিফা’আ ইল্লা শিফাউক, শিফা’আন লা ইউগাদিরু সাকামা।",
        "dua_english": "O Allah! Lord of mankind! Remove the trouble and heal, You are the Healer. There is no healing except Your healing. A healing that leaves no illness behind.",
        "dua_arabic": "اللّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِ أَنْتَ الشَّافِي لاَ شِفَاءَ إِلاَّ شِفَاؤُكَ شِفَاءً لاَ يُغَادِرُ سَقَمًا",
        "tafseer": "এই দোয়াটি রোগমুক্তির জন্য রাসূল (সা.) পড়তেন। এতে রোগ দূরীকরণ এবং সম্পূর্ণ আরোগ্যের আবেদন করা হয়।",
        "reference": "সহীহ বুখারী",
        "rules": "রোগাক্রান্ত ব্যক্তি বা কারো জন্য দোয়া করতে পারেন।"
      }
    ],
    "self_rukiah": [
      {
        "title": "রুকিয়া দোয়া",
        "description": "নিজেকে শয়তান, জ্বিন ও হিংসা থেকে রক্ষা করার দোয়া।",
        "dua": "আঊজু বিকালিমাতিল্লাহিত তাম্মাতি মিন শাররি মা খালাক",
        "dua_english": "I seek refuge in the Perfect Words of Allah from the evil of what He has created.",
        "dua_arabic": "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
        "tafseer": "এই দোয়াটির মাধ্যমে আল্লাহর পরিপূর্ণ বাণীর আশ্রয় নেওয়া হয়, যা সব অনিষ্ট থেকে রক্ষা করে।",
        "reference": "সহীহ মুসলিম",
        "rules": "রাতে ঘুমানোর সময়, ভয়ের সময় বা অশুভ কিছু অনুভব করলে পড়তে পারেন।"
      }
    ],
    "muslim_timeline": [
      {
        "title": "ঘুমের পূর্বে দোয়া",
        "description": "ঘুমানোর পূর্বে পাঠ করার দোয়া।",
        "dua": "বিসমিকাল্লাহুম্মা আমুতু ওয়া আহইয়া।",
        "dua_english": "In Your name, O Allah, I die and I live.",
        "dua_arabic": "بِاسْمِكَ اللَّهُمَّ أَحْيَا وَأَمُوتُ",
        "tafseer": "এই দোয়ায় আমরা আল্লাহর নামে ঘুমিয়ে পড়ি, এবং তার ইচ্ছায় জাগ্রত হই - এতে তাঁর উপর পূর্ণ নির্ভরতা প্রকাশ পায়।",
        "reference": "সহীহ বুখারী",
        "rules": "ঘুমানোর আগে বিছানায় শুয়ে পড়া।"
      }
    ],
  };
}




class Categories {
  // a list there have title , icon, tag
  List<Map<String, dynamic>> categories = [
    {
      "title": "সকাল সন্ধ্যা দোয়া",
      "icon": Icons.sunny_snowing,
      "tag": "morning_evening",
    },
    {
      "title": "নববী চিকিৎসা",
      "icon": Icons.healing,
      "tag": "healing",
    },
    {
      "title": "সেলফ রুকইয়াহ",
      "icon": Icons.self_improvement,
      "tag": "self_rukiah",
    },
    {
      "title": "মুসলিম টাইমলাইন",
      "icon": Icons.access_time,
      "tag": "muslim_timeline",
    },
  ];
}

class Hadith {
  List<Map<String, String>> hadithData = [
    {
      "text": "সব কাজই নিয়তের ওপর নির্ভরশীল।",
      "source": "সহীহ বুখারী ও মুসলিম"
    },
    {
      "text": "তোমাদের মধ্যে উত্তম হলো সে ব্যক্তি, যার চরিত্র উত্তম।",
      "source": "সহীহ বুখারী"
    },
    {
      "text": "তোমাদের মাঝে সালাম প্রচার করো।",
      "source": "সহীহ মুসলিম"
    },
    {
      "text": "যে ব্যক্তি আল্লাহর সন্তুষ্টির জন্য বিনয়ী হয়, আল্লাহ তাকে মর্যাদায় উন্নীত করেন।",
      "source": "সহীহ মুসলিম"
    },
    {
      "text": "তুমি দুনিয়াতে এমনভাবে থাকো যেন তুমি একজন আগন্তুক বা পথিক।",
      "source": "সহীহ বুখারী"
    },
  ];

}