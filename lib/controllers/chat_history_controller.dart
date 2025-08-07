import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';

class ChatHistoryController extends GetxController {
  final database = FirebaseDatabase.instance;
  final box = GetStorage();

  var isLoading = false.obs;
  var historyDates = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistoryDates();
  }

  void fetchHistoryDates() async {
    final userId = box.read('userId');
    if (userId == null) return;

    isLoading.value = true;

    final ref = database.ref('users/$userId/chat_history');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final dates = data.keys.toList();
      dates.sort((a, b) => b.compareTo(a)); // newest first
      historyDates.value = dates;
    }

    isLoading.value = false;
  }

  Future<List<Map<String, String>>> fetchMessagesByDate(String date) async {
    final userId = box.read('userId');
    if (userId == null) return [];

    final ref = database.ref('users/$userId/chat_history/$date');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final messages = data.values
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
      return messages;
    }

    return [];
  }
}