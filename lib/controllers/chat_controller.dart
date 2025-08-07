import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  var messages = <Map<String, String>>[].obs;

  final database = FirebaseDatabase.instance;
  final box = GetStorage();
  // 🗓 Format date like '2025-08-08'
  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());
  // Optional: Used for daily greeting timestamp
  DateTime? lastGreetingShown;

  @override
  void onInit() {
    super.onInit();
    _maybeSendGreeting();
    //_loadTodayChat();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final userMsg = {
      'sender': 'user',
      'text': text.trim(),
      'timestamp': now.toIso8601String(),
    };

    messages.add(userMsg);
    messageController.clear();

    Future.delayed(Duration(milliseconds: 200), () {
      _scrollToBottom();
    });

    // 🔐 Save user message to Firebase
    _saveMessageToFirebase(dateKey, userMsg);
    // 🔍 Bot reply after user sends message
    _handleBotReply(text.trim());
  }

  void _handleBotReply(String text) {
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final toolSuggestions = Get.find<HomeController>().suggestToolsFromMessage(text);

    var botMsg = {
      'sender': 'bot',
      'text': "Thinking...",
      'timestamp': now.toIso8601String(),
    };

    if (toolSuggestions.isNotEmpty) {
      final suggestionText = toolSuggestions.map((t) {
        final url = t['url'] ?? '';
        return "🔹 ${t['name']}${url.isNotEmpty ? "\n🔗 $url" : ""}";
      }).join("\n");

      botMsg = {
        'sender': 'bot',
        'text': "Here are some AI tools you might find helpful:\n$suggestionText",
        'timestamp': DateTime.now().toIso8601String(),
      };
    } else {
      botMsg = {
        'sender': 'bot',
        'text': "Sorry, I couldn't find any matching tools. Try rephrasing your request.",
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
    messages.add(botMsg);
    _saveMessageToFirebase(dateKey, botMsg);

    Future.delayed(Duration(milliseconds: 200), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _saveMessageToFirebase(String dateKey, Map<String, String> msg) async {
    final userId = box.read('userId');
    if (userId == null) return;

    final ref = database.ref("users/$userId/chat_history/$dateKey");
    await ref.push().set(msg);
  }

  /// ✅ Loads today's messages from Firebase
  void loadMessagesByDate(String date) async {
    final todayMessages = await fetchMessagesByDate(date);
    messages.addAll(todayMessages);

    Future.delayed(Duration(milliseconds: 200), () {
      _scrollToBottom();
    });
  }

  /// 📥 Fetch chat messages from Firebase by date
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

      // ✅ Sort by timestamp ASCENDING
      messages.sort((a, b) {
        final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
        final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
        return aTime.compareTo(bTime); // ascending
      });

      return messages;
    }

    return [];
  }

  void _maybeSendGreeting() {
    final now = DateTime.now();
    if (lastGreetingShown == null || now.difference(lastGreetingShown!).inHours >= 24) {
      messages.add({
        'sender': 'bot',
        'text': "👋 Welcome back! Ask me what you need help with today.",
        'timestamp': now.toIso8601String(),
      });
      lastGreetingShown = now;
    }
  }

  void clearOldMessages() {
    final now = DateTime.now();
    messages.removeWhere((m) {
      final msgTime = DateTime.tryParse(m['timestamp'] ?? '');
      return msgTime != null && now.difference(msgTime).inHours >= 24;
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
