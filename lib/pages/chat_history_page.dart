import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/chat_history_controller.dart';
import 'ai_assistance_page.dart';

class ChatHistoryPage extends StatelessWidget {
  final controller = Get.put(ChatHistoryController());

  ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('AI Chat History', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final dates = controller.historyDates;

        if (dates.isEmpty) {
          return const Center(child: Text("No chat history found.", style: TextStyle(color: Colors.white70, fontSize: 16)));
        }

        return ListView.builder(
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade700,
                      child: const Icon(Icons.chat, color: Colors.white70)),
                  title: Text('Chat history ${index+1}' , style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text("View chat history for $date", style: const TextStyle(color: Colors.white70)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
                        onTap: () async {
                          Get.delete<ChatController>(); // 🧹 clear old state
                          Get.to(() => AiAssistancePage(date: date, isFromHistory: true));
                        },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
