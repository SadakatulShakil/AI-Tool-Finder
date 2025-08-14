// lib/pages/featured_ai_tool_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/tool_detail_page.dart';
import '../controllers/home_controller.dart';

class FeaturedAIToolPage extends StatefulWidget {
  const FeaturedAIToolPage({super.key});

  @override
  State<FeaturedAIToolPage> createState() => _FeaturedAIToolPageState();
}

class _FeaturedAIToolPageState extends State<FeaturedAIToolPage> {
  final hc = Get.find<HomeController>();
  final textCtrl = TextEditingController();
  late final String title;
  late final String tagLabel;

  @override
  void initState() {
    super.initState();
    title = Get.arguments?['title'] ?? 'Featured';
    tagLabel = (Get.arguments?['tag'] ?? '').toString().toLowerCase(); // 'popular' | 'trending'
  }

  @override
  Widget build(BuildContext context) {
    final all = hc.toolsByTagLabel(tagLabel);
    final filtered = all.where((t) {
      final q = textCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      final name = (t['name'] ?? '').toString().toLowerCase();
      final desc = (t['description'] ?? '').toString().toLowerCase();
      return ('$name $desc').contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: textCtrl,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: textCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
                  onPressed: () {
                    textCtrl.clear();
                    setState(() {});
                  },
                )
                    : null,
                hintText: 'Search $title',
                hintStyle: const TextStyle(color: Colors.white38),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isNotEmpty
                ? ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final t = filtered[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: t['logo'] != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          t['logo'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(Icons.extension, color: Colors.white70),
                      title: Text(
                        t['name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        t['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      onTap: () => Get.to(() => ToolDetailPage(
                        initialToolId: t['id'],
                        allCategories: hc.categoriesMap,
                        allTags: hc.tagsMap,
                      )),
                    ),
                  ),
                );
              },
            )
                : const Center(
              child: Text(
                'No tools found',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
