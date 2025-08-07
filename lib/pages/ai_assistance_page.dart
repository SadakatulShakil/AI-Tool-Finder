import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';

class AiAssistancePage extends StatefulWidget {
  final String? date;
  final bool isFromHistory;
  AiAssistancePage({this.date, this.isFromHistory = false});

  @override
  State<AiAssistancePage> createState() => _AiAssistancePageState();
}

class _AiAssistancePageState extends State<AiAssistancePage> {
  final ChatController controller = Get.put(ChatController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (widget.isFromHistory) {
      controller.loadMessagesByDate(widget.date ?? today);
    } else {
      controller.loadMessagesByDate(today);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Obx(() => Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    onSubmitted: (value) => controller.sendMessage(value),
                    decoration: InputDecoration(
                      hintText: "Ask anything...",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => controller.sendMessage(controller.messageController.text),
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
