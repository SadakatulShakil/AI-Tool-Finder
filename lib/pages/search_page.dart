import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/tool_detail_page.dart';
import 'dart:math';
import '../controllers/home_controller.dart';
import '../widgets/category_chips.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = Get.find<HomeController>();
  final textCtrl = TextEditingController();
  String selectedCat = '';

  @override
  Widget build(BuildContext context) {
    final isSearching = textCtrl.text.trim().isNotEmpty;
    final results = controller.searchTools(q: textCtrl.text, categoryId: selectedCat);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                hintText: 'Search tools…',
                hintStyle: const TextStyle(color: Colors.white38),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📂 Horizontal Categories (only if not searching)
          if (!isSearching)
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  CategoryChip(
                    label: 'All',
                    selected: selectedCat.isEmpty,
                    onTap: () => setState(() => selectedCat = ''),
                  ),
                  ...controller.categories.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: CategoryChip(
                        label: c['name'] ?? '',
                        selected: selectedCat == c['id'],
                        onTap: () => setState(() => selectedCat = c['id']),
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 8),

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
                        allCategories: controller.categoriesMap,
                        allTags: controller.tagsMap,
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
