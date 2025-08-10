import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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

  List<TextSpan> _buildTextWithLinks(String text) {
    final RegExp urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final matches = urlRegex.allMatches(text);
    int lastIndex = 0;
    List<TextSpan> spans = [];

    for (var match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(url)),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (widget.isFromHistory) {
      controller.loadMessagesByDate(widget.date ?? today);
    } else {
      controller.loadMessagesByDate(today);
    }

    //Scroll to bottom when page open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.scrollController.hasClients) {
        controller.scrollController.jumpTo(controller.scrollController.position.maxScrollExtent + 200);
      }
    });

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
                          ? Colors.deepPurpleAccent.shade100
                          : Colors.grey[300],
                      borderRadius: isUser
                          ? BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20))
                          : BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                    ),
                    child: SelectableText.rich(
                      TextSpan(
                        children: _buildTextWithLinks(message['text'] ?? ''),
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
                      hintText: "Ask about AI tool...",
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
