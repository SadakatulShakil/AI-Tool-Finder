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
      appBar: AppBar(title: const Text("Chat History")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final dates = controller.historyDates;

        if (dates.isEmpty) {
          return const Center(child: Text("No chat history found."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dates.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final date = dates[index];
            return ListTile(
              title: Text(date),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                //final messages = await controller.fetchMessagesByDate(date);
                //print('messages: $messages');
                Get.delete<ChatController>(); // 🧹 clear old state
                Get.to(() => AiAssistancePage(date: date, isFromHistory: true));
              },
            );
          },
        );
      }),
    );
  }
}
