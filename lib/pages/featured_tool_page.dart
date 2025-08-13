// lib/pages/featured_ai_tool_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: textCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search $title…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox.shrink(),
              itemBuilder: (_, i) {
                final t = filtered[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Card(
                    child: ListTile(
                      leading: t['logo'] != null ? Image.network(t['logo'], width: 40, height: 40) : const Icon(Icons.extension),
                      title: Text(t['name'] ?? ''),
                      subtitle: Text(t['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => Get.toNamed('/tool', arguments: {
                        'toolId': t['id'],
                        'allCategories': hc.categoriesMap,
                        'allTags': hc.tagsMap,
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
