import 'package:get/get.dart';
import 'package:iomdailyazkar/core/local_storage/user_pref.dart';

class PrayerTimesController extends GetxController {
  RxString city = 'Dhaka'.obs;
  RxBool useCurrentLocation = false.obs;
  RxBool isLocationLoading = false.obs;

  final UserPref _userPref = UserPref();

  @override
  void onInit() {
    super.onInit();
    loadUserCity();
  }

  Future<void> loadUserCity() async {
    final savedCity = await _userPref.getUserCurrentCity();
    if (savedCity.isNotEmpty) {
      city.value = savedCity;
    }
  }

  Future<void> setCity(String newCity) async {
    city.value = newCity;
    // await _userPref.setUserCurrentCity(newCity);
  }

  Future<void> enableLocation() async {
    useCurrentLocation.value = true;
    isLocationLoading.value = true;

    // simulate gps fetch
    await Future.delayed(const Duration(seconds: 1));

    // TODO: set city from GPS here
    isLocationLoading.value = false;
  }

  void disableLocation() {
    useCurrentLocation.value = false;
  }
}
