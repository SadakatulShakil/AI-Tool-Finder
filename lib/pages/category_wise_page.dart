// lib/pages/category_wise_tool_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class CategoryWiseToolPage extends StatefulWidget {
  String selectedId;
  CategoryWiseToolPage({super.key, required this.selectedId});

  @override
  State<CategoryWiseToolPage> createState() => _CategoryWiseToolPageState();
}

class _CategoryWiseToolPageState extends State<CategoryWiseToolPage> {
  final hc = Get.find<HomeController>();
  final textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    //selectedId = (Get.arguments?['selectedId'] ?? '') as String;
  }

  Color _getSoftRandomColor() {
    final random = Random();
    final hue = random.nextDouble() * 180; // 0 to 360
    final hsl = HSLColor.fromAHSL(1.0, hue, 0.4, 0.85);
    //saturation = 0.4 (soft), lightness = 0.85 (light pastel)
    return hsl.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final results = hc.searchTools(q: textCtrl.text, categoryId: widget.selectedId);

    return Scaffold(
      appBar: AppBar(title: const Text('Browse by Category')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 5, top: 5),
            child: TextField(
              controller: textCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search in category…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _chip('All', widget.selectedId.isEmpty, () => setState(() => widget.selectedId = '')),
                ...hc.categories.map((c) => _chip(
                  c['name'] ?? '',
                  widget.selectedId == c['id'],
                      () => setState(() => widget.selectedId = c['id']),
                )),
              ],
            ),
          ),
          SizedBox(height: 8), // spacing
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final t = results[i];
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
          )
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
          backgroundColor: _getSoftRandomColor(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap()),
    );
  }
}
