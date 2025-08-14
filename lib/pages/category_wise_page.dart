// lib/pages/category_wise_tool_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/tool_detail_page.dart';
import '../controllers/home_controller.dart';
import '../widgets/category_chips.dart';

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
  Widget build(BuildContext context) {
    final results = hc.searchTools(q: textCtrl.text, categoryId: widget.selectedId);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Browse by Category', style: TextStyle(color: Colors.white)),
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
                hintText: 'Search in category...',
                hintStyle: const TextStyle(color: Colors.white38),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                CategoryChip(
                  label: 'All',
                  selected: widget.selectedId.isEmpty,
                  onTap: () => setState(() => widget.selectedId = ''),
                ),
                ...hc.categories.map((c) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CategoryChip(
                    label: c['name'] ?? '',
                    selected: widget.selectedId == c['id'],
                    onTap: () => setState(() => widget.selectedId = c['id']),
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 8), // spacing
          // 📄 Results
          Expanded(
            child: results.isNotEmpty
                ? ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final t = results[index];
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
