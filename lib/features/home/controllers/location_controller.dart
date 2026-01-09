import 'package:get/get.dart';

class LocationController extends GetxController {
  RxString city = ''.obs;

  void setCity(String value) {
    city.value = value;
  }
}
