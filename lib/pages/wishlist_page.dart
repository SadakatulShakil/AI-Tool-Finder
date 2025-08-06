import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'tool_detail_page.dart';

class WishlistPage extends StatelessWidget {
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Wishlist")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.getWishlistTools(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Your wishlist is empty."));
          }

          final wishlistTools = snapshot.data!;

          return ListView.builder(
            itemCount: wishlistTools.length,
            itemBuilder: (context, index) {
              final tool = wishlistTools[index];
              return Card(
                child: ListTile(
                  leading: tool['logo'] != null
                      ? Image.network(tool['logo'], width: 40, height: 40)
                      : Icon(Icons.extension),
                  title: Text(tool['name'] ?? "No name"),
                  subtitle: Text(tool['description'] ?? "No description"),
                  trailing: Text(tool['is_free'] == true ? "Free" : "Paid"),
                  onTap: () {
                    final selectedCategory = tool['category'];
                    final similar = controller.filteredTools.where((t) =>
                    t['id'] != tool['id'] &&
                        t['category'] == selectedCategory).toList();

                    Get.to(() => ToolDetailPage(
                      tool: tool,
                      allCategories: controller.categoriesMap,
                      allTags: controller.tagsMap,
                      similarTools: similar,
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
