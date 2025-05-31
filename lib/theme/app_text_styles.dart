import 'package:flutter/material.dart';

class AppTextStyles {
  static const String _fontFamily = 'Ador-Noirrit';

  static const TextStyle regular = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400, // Regular এর জন্য
    fontSize: 16.0,
    color: Colors.black,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700, // Bold এর জন্য
    fontSize: 18.0,
    color: Colors.black,
  );

  static const TextStyle light = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w300, // Light এর জন্য
    fontSize: 14.0,
    color: Colors.grey,
  );

  // অন্যান্য স্টাইল, যেমন বড় টাইটেল
  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w800, // Extra-bold এর কাছাকাছি
    fontSize: 24.0,
    color: Colors.blueAccent,
  );

  // আপনি চাইলে ফন্ট সাইজ বা কালার প্যারামিটার হিসেবেও দিতে পারেন
  static TextStyle customSize({required double fontSize, Color color = Colors.black}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      color: color,
    );
  }
}