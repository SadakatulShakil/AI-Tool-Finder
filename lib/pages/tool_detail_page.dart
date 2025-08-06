import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/webview_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bindings/webview_binding.dart';
import '../controllers/home_controller.dart';

class ToolDetailPage extends StatelessWidget {
  final Map<String, dynamic> tool;
  final Map<String, dynamic> allCategories;
  final Map<String, dynamic> allTags;
  final List<Map<String, dynamic>> similarTools;

  const ToolDetailPage({
    super.key,
    required this.tool,
    required this.allCategories,
    required this.allTags,
    this.similarTools = const [],
  });

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    //final isWishlisted = controller.isInWishlist(tool['id']);

    final categoryId = tool['category'];
    final categoryName = allCategories[categoryId]?['name'] ?? categoryId;
    final tags = (tool['tags'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(tool['name'] ?? 'Tool Detail'),
        actions: [
          Obx(() {
            final isWishlisted = controller.isWishlisted(tool['id']);
            return IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : null,
              ),
              onPressed: () => controller.toggleWishlist(tool['id']),
            );
          })

        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: tool['logo'] != null
                  ? Image.network(tool['logo'], height: 80)
                  : Icon(Icons.extension, size: 80),
            ),
            SizedBox(height: 20),
            Text(tool['name'] ?? 'Tool Name',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(tool['description'] ?? 'No description',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            Row(
              children: [
                Chip(
                  label: Text(tool['is_free'] == true ? 'Free' : 'Paid'),
                  backgroundColor:
                  tool['is_free'] == true ? Colors.green : Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 10),
                Chip(label: Text(categoryName)),
              ],
            ),

            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: tags.map((tagId) {
                final tagName = allTags[tagId]?['label'] ?? tagId;
                return Chip(label: Text(tagName));
              }).toList(),
            ),

            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.open_in_new),
              label: Text('Visit Tool Website'),
              onPressed: () => Get.to(() => WebviewView(),
                  binding: WebviewBinding(), arguments: tool, transition: Transition.rightToLeft),
            ),

            if (similarTools.isNotEmpty) ...[
              SizedBox(height: 30),
              Text('Similar Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...similarTools.map((simTool) => ListTile(
                leading: simTool['logo'] != null
                    ? Image.network(simTool['logo'], width: 40, height: 40)
                    : Icon(Icons.extension),
                title: Text(simTool['name'] ?? ''),
                subtitle: Text(simTool['description'] ?? ''),
                  onTap: () {
                  print("Tapped on similar tool: ${simTool['name']}");
                    final selectedCategory = simTool['category'];
                    final moreSimilar = Get.find<HomeController>().filteredTools.where((t) =>
                    t['id'] != simTool['id'] &&
                        t['category'] == selectedCategory).toList();

                  Get.to(() => ToolDetailPage(
                    tool: simTool,
                    allCategories: allCategories,
                    allTags: allTags,
                    similarTools: moreSimilar,
                  ));
                  }
              ))
            ]
          ],
        ),
      ),
    );
  }
}

