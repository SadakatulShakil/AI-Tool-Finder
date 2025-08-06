import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tool_finder/pages/tool_detail_page.dart';
import 'package:tool_finder/widgets/app_drawer_widget.dart';

import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text("Find Your AI Tool"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search Field
            TextField(
              onChanged: controller.searchTool,
              decoration: InputDecoration(
                hintText: "Search what you want to do...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // 📌 Categories from Firebase
            Obx(() {
              final categories = controller.categories;
              return SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ChoiceChip(
                        label: Text("All"),
                        selected: controller.selectedCategory.value == '',
                        onSelected: (_) => controller.selectCategory(''),
                      ),
                    ),
                    ...categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat['name'] ?? ""),
                          selected: controller.selectedCategory.value == cat['id'],
                          onSelected: (_) => controller.selectCategory(cat['id']),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }),
            SizedBox(height: 20),

            // 🧠 Filtered Tools List
            Expanded(
              child: Obx(() {
                if (controller.tools.isEmpty || controller.categories.isEmpty || controller.tagsMap.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                final results = controller.filteredTools;

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No tools found."),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: controller.fetchHomeData,
                          child: Text("Reload"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final tool = results[index];
                    return Card(
                      child: ListTile(
                        leading: tool['logo'] != null
                            ? Image.network(tool['logo'], width: 40, height: 40)
                            : Icon(Icons.extension),
                        title: Text(tool['name'] ?? "No name"),
                        subtitle: Text(tool['description'] ?? "No description"),
                        trailing: Text(tool['isFree'] == true ? "Free" : "Paid"),
                          onTap: () {
                            final selectedCategory = tool['category'];
                            final similar = controller.filteredTools.where((t) =>
                            t['id'] != tool['id'] && t['category'] == selectedCategory
                            ).toList();

                            Get.to(() => ToolDetailPage(
                              tool: tool,
                              allCategories: controller.categoriesMap,
                              allTags: controller.tagsMap,
                              similarTools: similar,
                            ));
                          }
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
