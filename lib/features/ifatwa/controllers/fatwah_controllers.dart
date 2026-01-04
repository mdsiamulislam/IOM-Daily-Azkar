import 'dart:convert';
import 'package:get/get.dart';
import 'package:meilisearch/meilisearch.dart';

class FatwahControllers extends GetxController {
  RxList fatwahList = [].obs;
  RxBool isLoading = false.obs;

  void fetchFatwah() async {
    isLoading.value = true;

    const String apiUrl = 'https://search.ifatwa.info/';
    const String apiKey =
        'bdbad192801a4f64141931602d982d78139a4d1f5c1ff686fb4741d7f65a31cd';

    try {
      final client = MeiliSearchClient(apiUrl, apiKey);
      final index = client.index('posts');

      final result =
      await index.search('');

      fatwahList.value = result.hits;

      // 🔹 Print full JSON data
      print(jsonEncode(result.hits));

      // যদি সুন্দরভাবে formatted দেখতে চাও:
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      print(encoder.convert(result.hits));

      isLoading.value = false;
    } catch (e) {
      print('Error fetching fatwah: $e');
      isLoading.value = false;
    }
  }
}
