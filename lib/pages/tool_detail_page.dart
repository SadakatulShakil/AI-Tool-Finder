import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/webview_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bindings/webview_binding.dart';
import '../controllers/home_controller.dart';

class ToolDetailPage extends StatefulWidget {
  final String initialToolId;
  final Map<String, dynamic> allCategories;
  final Map<String, dynamic> allTags;

  const ToolDetailPage({
    super.key,
    required this.initialToolId,
    required this.allCategories,
    required this.allTags,
  });

  @override
  State<ToolDetailPage> createState() => _ToolDetailPageState();
}

class _ToolDetailPageState extends State<ToolDetailPage> {
  late String currentToolId;
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    currentToolId = widget.initialToolId;
    controller = Get.find<HomeController>();
  }

  Map<String, dynamic> get currentTool {
    return controller.getToolById(currentToolId) ?? {};
  }

  List<Map<String, dynamic>> get similarTools {
    final currentCategory = currentTool['category'];
    return controller.filteredTools
        .where((tool) => tool['category'] == currentCategory && tool['id'] != currentToolId)
        .toList();
  }

  void _updateTool(String newToolId) {
    setState(() {
      currentToolId = newToolId;
    });
  }

  Widget _buildPricingSection(Map<dynamic, dynamic>? pricing) {
    if (pricing == null || pricing.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Text("💰 Pricing",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...pricing.entries.map((entry) {
          final planName = entry.key;
          final planData = (entry.value is Map)
              ? Map<String, dynamic>.from(entry.value as Map)
              : <String, dynamic>{};

          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${planName[0].toUpperCase()}${planName.substring(1)} — ${planData['cost'] ?? ''}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...((planData['features'] as List?) ?? [])
                      .map((f) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      SizedBox(width: 6),
                      Expanded(child: Text(f)),
                    ],
                  ))
                      .toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildApiSection(Map<dynamic, dynamic>? api) {
    if (api == null || api.isEmpty) return SizedBox.shrink();

    final available = api['available'] == true;
    final note = api['note']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Text("🔌 API Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      available ? Icons.check_circle : Icons.cancel,
                      color: available ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      available ? "Available" : "Not Available",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (note.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    note,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tool = currentTool;
    final categoryId = tool['category'];
    final categoryName =
        widget.allCategories[categoryId]?['name'] ?? categoryId;
    final tags = (tool['tags'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Cover image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(tool['cover'] ?? ""),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Dark gradient overlay (for better icon visibility)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Top action buttons
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),

                      // Wishlist button
                      Obx(() {
                        final isWishlisted = controller.currentWishlist.contains(currentToolId);
                        return CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.white,
                            ),
                            onPressed: () => controller.toggleWishlist(currentToolId),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

            // Title & Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tool['name'] ?? 'Tool Name',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(tool['description'] ?? 'No description',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                              tool['isFree'] == true ? 'Free' : 'Paid'),
                          backgroundColor: tool['isFree'] == true
                              ? Colors.green
                              : Colors.red,
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
                        final tagName =
                            widget.allTags[tagId]?['label'] ?? tagId;
                        return Chip(label: Text(tagName));
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.open_in_new),
                      label: Text('Visit Tool Website'),
                      onPressed: () => Get.to(() => WebviewView(),
                          binding: WebviewBinding(),
                          arguments: tool,
                          transition: Transition.rightToLeft),
                    ),

                    // Pricing Section
                    _buildPricingSection(tool['pricing']),

                    // API Section
                    _buildApiSection(tool['api']),

                    // Similar Tools
                    if (similarTools.isNotEmpty) ...[
                      SizedBox(height: 10),
                      Text(
                        '🛠️ Similar Tools',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: similarTools.map((simTool) {
                            return GestureDetector(
                              onTap: () => _updateTool(simTool['id']),
                              child: Container(
                                width: 200, // adjust width as needed
                                margin: EdgeInsets.only(right: 8),
                                child: Card(
                                  elevation: 2,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        simTool['logo'] != null
                                            ? Image.network(
                                          simTool['logo'],
                                          width: 40,
                                          height: 40,
                                        )
                                            : Icon(Icons.extension, size: 40),
                                        SizedBox(height: 8),
                                        Text(
                                          simTool['name'] ?? '',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          simTool['description'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ]
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
