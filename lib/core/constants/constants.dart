import 'package:flutter/material.dart';



class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color backgroundGreen = Color(0xFFE8F5E9);
  static const Color lightGreen = Color(0xFFD4EDDA);
  static const Color innerShadowColor = Color(0xFF000000);
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
      "title": "সকালের আযকার",
      "icon_name": "sunny_snowing",
      "tag": "morning_dua"
    },
    {
      "title": "সন্ধ্যার আযকার",
      "icon_name": "moon",
      "tag": "evening_dua"
    },
    {
      "title": "ঘুমানোর আগে ও ঘুম থেকে ওঠার সময় দোয়া",
      "icon_name": "sleep",
      "tag": "sleep_dua"
    },
    {
      "title": "কুরআনে বর্ণিত দোয়া",
      "icon_name": "quran",
      "tag": "Quranic_Dua "
    },
    {
      "title": "সেলফ রুকইয়াহ",
      "icon_name": "self_improvement",
      "tag": "self_rukiah"
    },
    {
      "title": "মুসলিম টাইমলাইন",
      "icon_name": "access_time",
      "tag": "muslim_timeline"
    }
  ];
}

class Hadith {
  List<Map<String, String>> hadithData = [
    {
      "hadis": "কেবল সাফল্য লাভ করবে সে ব্যক্তি যে বিশুদ্ধ অন্তর নিয়ে আল্লাহর নিকট আসবে।",
      "ref": "• আশ-শুআ'রা | আয়াত ৮৯"
    },
    {
      "hadis": "হে আমার রব, আমাকে প্রজ্ঞা দান করুন এবং আমাকে সৎকর্মশীলদের সাথে শামিল করে দিন।",
      "ref": "আশ-শুআ'রা | আয়াত ৮৩"
    },
    {
      "hadis": "যারা মুমিন তারা আল্লাহর পথে যুদ্ধ করে, আর যারা কাফের তারা তাগূতের পথে যুদ্ধ করে। কাজেই তোমরা শয়তানের বন্ধুদের বিরুদ্ধে যুদ্ধ কর; নিশ্চয় শয়তানের চক্রান্ত দুর্বল।",
      "ref": "• আন-নিসা | আয়াত ৭৬"
    },
    {
      "hadis": "হে মুমিনগণ! যদি তোমরা আল্লাহর (দ্বীনের) সাহায্য কর, তাহলে আল্লাহ তোমাদেরকে সাহায্য করবেন এবং তোমাদের পা দৃঢ়-প্রতিষ্ঠিত রাখবেন।",
      "ref": "মুহাম্মাদ | আয়াত ৭"
    },
    {
      "hadis": "\"আনাস রা. থেকে বর্ণিত,\n\nأَنَّ رَسُولَ اللهِ صَلَّى الله عَليْهِ وسَلَّمَ : نَهَى عَنِ الشُّرْبِ قَائِمًا\n\nরাসূলুল্লাহ সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম দাঁড়িয়ে পানি পান করতে নিষেধ করেছেন।\n\n",
      "ref": "সুনানে ইবনে মাজাহ, হাদীস ৩৪২৪"
    },
    {
      "hadis": "\n\n\"বুরায়দাহ আল-আসলামী রা. থেকে বর্ণিত, নবী সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম বলেন,\n\nمَنْ أَنْظَرَ مُعْسِرًا كَانَ لَهُ بِكُلِّ يَوْمٍ صَدَقَةٌ ، وَمَنْ أَنْظَرَهُ بَعْدَ حِلِّهِ كَانَ لَهُ مِثْلُهُ ، فِي كُلِّ يَوْمٍ صَدَقَةٌ.\n\nযে ব্যক্তি (ঋণগ্রস্ত) অভাবী ব্যক্তিকে অবকাশ দিবে, সে প্রতিদিন দান-খয়রাত করার সওয়াব পাবে। আর যে ব্যক্তি ঋণ শোধের মেয়াদ শেষ হওয়ার পরও সময় বাড়িয়ে দিবে, সে প্রতিদিন (ঋণের সমপরিমাণ) দান-খয়রাত করার সওয়াব পাবে।\n\n",
      "ref": "সুনানে ইবনে মাজাহ, হাদীস ২৪১৮"
    },
    {
      "hadis": "\n\n\"আবদুল্লাহ ইবনু মুগাফ্‌ফাল রা. থেকে বর্ণিত, রাসূলুল্লাহ (সাল্লাল্লাহি আলাইহি ওয়া সাল্লাম) বলেছেন,\n\nإن اللهَ رفيق يُحِبُّ الرّفْقَ، ويُعطِي عليهِ ما لا يُعطِي على العُنْفِ\n\nনিশ্চয়ই মহান আল্লাহ কোমল, তিনি কোমলতা পছন্দ করেন। তিনি কোমল আচরণের জন্য এত বিনিময় দান করেন যা কঠিন আচরণের ওপর দান করেন না।\n\n",
      "ref": "সুনানে আবু দাউদ, হাদীস ৪৮০৭"
    }
  ];

}