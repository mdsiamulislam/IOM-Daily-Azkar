import 'package:shared_preferences/shared_preferences.dart';

class UserPref{

  void setPrayerTimeSingle(bool isSingleTimeTable)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSingleTimeTable', isSingleTimeTable);
  }

  Future<bool> getPrayerTimeSingle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSingleTimeTable') ?? true; // Default to true if not set
  }

}