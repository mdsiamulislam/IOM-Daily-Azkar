import 'package:shared_preferences/shared_preferences.dart';

class UserPref{

  void setPrayerTimeSingle(bool isSingleTimeTable)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSingleTimeTable', isSingleTimeTable);
  }

  Future<bool> getPrayerTimeSingle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSingleTimeTable') ?? true;
  }


  // ===== User Current City ===== //
  void setUserCurrentCity(String city)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userCurrentCity', city);
  }
  Future<String> getUserCurrentCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userCurrentCity') ?? "Medina";
  }

}