import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
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

  Future<void> _handleBotReply(String text) async {
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final lowerText = text.toLowerCase();
    final random = Random();
    // 1️⃣ Small talk patterns with multiple possible replies
    final smallTalkPatterns = [
      {
        "keywords": ["hi", "hello", "hey", "yo"],
        "replies": [
          "👋 Hey there! How’s your day going?",
          "Hello! 😊 What kind of AI tool are you searching for?",
          "Hi! 👋 Ready to explore some AI tools?",
          "Hey! Let’s find you the perfect AI tool today."
        ]
      },
      {
        "keywords": ["how are you", "how's it going", "how r u"],
        "replies": [
          "I’m doing great! Thanks for asking 😊 What about you?",
          "Always happy to help! How can I assist you today?",
          "I’m good — just here waiting to suggest some awesome AI tools! 🚀"
        ]
      },
      {
        "keywords": ["good morning"],
        "replies": [
          "☀️ Good morning! Ready to discover some AI magic?",
          "Morning! 🌅 Let’s start the day with amazing tools.",
          "Good morning! 🌞 How can I help you today?"
        ]
      },
      {
        "keywords": ["good evening"],
        "replies": [
          "🌙 Good evening! Looking for an AI companion tonight?",
          "Evening! Let’s find something exciting for you.",
          "Good evening! 🌌 Which AI tool are you curious about?"
        ]
      },
      {
        "keywords": ["thanks", "thank you", "thx"],
        "replies": [
          "You’re welcome! 🙌",
          "No problem at all! 😄",
          "Anytime! I’m here for you. 🤖"
        ]
      },
      {
        "keywords": ["bye", "goodbye", "see you", "later"],
        "replies": [
          "👋 Goodbye! Hope to chat with you again soon.",
          "Take care! Until next time. 👋",
          "Bye! Have an amazing day! 🚀"
        ]
      },
      {
        "keywords": ["help", "suggest", "stop", "what"],
        "replies": [
          "👋 I am here to help! Just ask what AI tool you want or what is your need 🌌"
        ]
      },
      {
        "keywords": ["sex", "vulgar", "nude", "nudity", "porn", "adult", "nsfw", "lgbt"],
        "replies": [
          "👋 You try something that violates our policy of content. Please ask what AI tool you want or what is your need 🌌"
        ]
      },
    ];

    // 2️⃣ Check for small talk
    for (var pattern in smallTalkPatterns) {
      if (pattern["keywords"]!.any((kw) => lowerText.contains(kw))) {
        var botMsg = {
          'sender': 'bot',
          'text': pattern["replies"]![random.nextInt(pattern["replies"]!.length)],
          'timestamp': now.toIso8601String(),
        };

        messages.add(botMsg);
        _saveMessageToFirebase(dateKey, botMsg);
        _scrollToBottom();
        return; // stop here
      }
    }

    // Step 1: Show thinking indicator
    var typingMsg = {
      'sender': 'bot',
      'text': "💭 Thinking...",
      'timestamp': now.toIso8601String(),
    };
    messages.add(typingMsg);
    _saveMessageToFirebase(dateKey, typingMsg);
    _scrollToBottom();

    // Simulate thinking delay
    await Future.delayed(Duration(seconds: 1));

    // Step 2: Get tool suggestions
    final toolSuggestions = Get.find<HomeController>().suggestToolsFromMessage(text);

    String finalReply;
    if (toolSuggestions.isNotEmpty) {
      final openingPhrases = [
        "I’ve analyzed your request and found:",
        "Based on what you said, here are my suggestions:",
        "These tools might be just what you need:",
        "Here’s what I recommend:"
      ];
      final randomPhrase = openingPhrases[DateTime.now().millisecond % openingPhrases.length];

      final suggestionText = toolSuggestions.map((t) {
        final url = t['url'] ?? '';
        return "🔹 ${t['name']}${url.isNotEmpty ? "\n🔗 $url" : ""}";
      }).join("\n\n");

      finalReply = "$randomPhrase\n\n$suggestionText\n\nWant more tools? Just tell me what you need help with!";
    } else {
      finalReply = "I searched my database but couldn’t find a good match. Could you try describing your need in a different way?";
    }

    // Step 3: Replace "Thinking..." with an empty bot message to stream into
    messages.removeLast();
    var streamingMsg = {
      'sender': 'bot',
      'text': "",
      'timestamp': DateTime.now().toIso8601String(),
    };
    messages.add(streamingMsg);

    // Step 4: Stream text character-by-character with smooth scroll
    for (int i = 0; i < finalReply.length; i++) {
      await Future.delayed(Duration(milliseconds: 18)); // typing speed
      streamingMsg['text'] = finalReply.substring(0, i + 1);
      messages[messages.length - 1] = Map<String, String>.from(streamingMsg);

      // Smooth scroll without jerking
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 40, // gradual move
          duration: Duration(milliseconds: 50),
          curve: Curves.easeOut,
        );
      }
    }

    // Step 5: Save final message to Firebase
    _saveMessageToFirebase(dateKey, streamingMsg);
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 250,
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
