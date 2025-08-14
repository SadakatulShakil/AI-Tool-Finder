import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'tool_detail_page.dart';

class WishlistPage extends StatelessWidget {
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
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
              final t = wishlistTools[index];
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
          );
        },
      ),
    );
  }
}
