import 'package:get/get.dart';
import 'package:iomdailyazkar/core/local_storage/user_pref.dart';

class PrayerTimesController extends GetxController {
  RxString city = ''.obs;
  final UserPref _userPref = UserPref();

  @override
  void onInit() {
    super.onInit();
    loadUserCity();
  }

  Future<void> loadUserCity() async {
    city.value = await _userPref.getUserCurrentCity();
  }

  Future<void> setCity(String newCity) async {
    city.value = newCity;
    _userPref.setUserCurrentCity(newCity);
  }
}
