import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = Get.find<HomeController>();
  final textCtrl = TextEditingController();
  String selectedCat = '';

  Color _getSoftRandomColor() {
    final random = Random();
    final hue = random.nextDouble() * 180; // 0 to 360
    final hsl = HSLColor.fromAHSL(1.0, hue, 0.4, 0.85);
    //saturation = 0.4 (soft), lightness = 0.85 (light pastel)
    return hsl.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = textCtrl.text.trim().isNotEmpty;
    final results =
    controller.searchTools(q: textCtrl.text, categoryId: selectedCat);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          // 🔍 Search Input
          Padding(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 5, bottom: 5),
            child: TextField(
              controller: textCtrl,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: textCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textCtrl.clear();
                    setState(() {});
                  },
                )
                    : null,
                hintText: 'Search tools…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // 📂 Horizontal Categories (only if not searching)
          if (!isSearching)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CatPill(
                    label: 'All',
                    color: _getSoftRandomColor(),
                    selected: selectedCat.isEmpty,
                    onTap: () => setState(() => selectedCat = ''),
                  ),
                  ...controller.categories.map(
                        (c) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CatPill(
                        label: c['name'] ?? '',
                        color: _getSoftRandomColor(),
                        selected: selectedCat == c['id'],
                        onTap: () =>
                            setState(() => selectedCat = c['id']),
                      ),
                    ),
                  ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: t['logo'] != null
                          ? Image.network(t['logo'],
                          width: 40, height: 40)
                          : const Icon(Icons.extension),
                      title: Text(t['name'] ?? ''),
                      subtitle: Text(
                        t['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Get.toNamed('/tool', arguments: {
                        'toolId': t['id'],
                        'allCategories': controller.categoriesMap,
                        'allTags': controller.tagsMap,
                      }),
                    ),
                  ),
                );
              },
            )
                : const Center(
              child: Text('No tools found'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _CatPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: color,
      onSelected: (_) => onTap(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
