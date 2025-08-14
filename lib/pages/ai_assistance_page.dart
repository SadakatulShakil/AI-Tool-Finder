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
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(color: Colors.white),
        ));
      }
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunchUrl(Uri.parse(url))) {
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(color: Colors.white),
      ));
    }

    return spans;
  }

  @override
  void initState() {
    super.initState();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controller.loadMessagesByDate(widget.isFromHistory
        ? (widget.date ?? today)
        : today);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (controller.scrollController.hasClients) {
      controller.scrollController.jumpTo(
        controller.scrollController.position.maxScrollExtent + 200,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('AI Assistance', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
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
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? LinearGradient(
                        colors: [
                          Colors.deepPurpleAccent.shade200,
                          Colors.deepPurple.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [
                          Colors.grey.shade800,
                          Colors.grey.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft:
                        isUser ? const Radius.circular(20) : Radius.zero,
                        bottomRight:
                        isUser ? Radius.zero : const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: SelectableText.rich(
                      TextSpan(children: _buildTextWithLinks(message['text'] ?? '')),
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (value) {
                      controller.sendMessage(value);
                      _scrollToBottom();
                    },
                    decoration: InputDecoration(
                      hintText: "Ask about AI tool...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.deepPurpleAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      controller.sendMessage(controller.messageController.text);
                      _scrollToBottom();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
