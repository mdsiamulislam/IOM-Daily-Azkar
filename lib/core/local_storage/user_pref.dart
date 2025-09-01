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

  // Set Location
  void setLocation(String location)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('location', location);
  }

  Future<String> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('location') ?? 'Dhaka';
  }

}