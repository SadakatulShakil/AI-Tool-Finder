import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/webview_view.dart';
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
        .where((tool) =>
    tool['category'] == currentCategory && tool['id'] != currentToolId)
        .toList();
  }

  void _updateTool(String newToolId) {
    setState(() {
      currentToolId = newToolId;
    });
  }

  Widget _buildPricingSection(Map<dynamic, dynamic>? pricing) {
    if (pricing == null || pricing.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text("💰 Pricing",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        ...pricing.entries.map((entry) {
          final planName = entry.key;
          final planData = (entry.value is Map)
              ? Map<String, dynamic>.from(entry.value as Map)
              : <String, dynamic>{};

          return Card(
            color: const Color(0xFF1E1E1E),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  ...((planData['features'] as List?) ?? [])
                      .map((f) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(f,
                              style: const TextStyle(color: Colors.white70))),
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
    if (api == null || api.isEmpty) return const SizedBox.shrink();

    final available = api['available'] == true;
    final note = api['note']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text("🔌 API Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Card(
          color: const Color(0xFF1E1E1E),
          elevation: 0,
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
                    const SizedBox(width: 8),
                    Text(
                      available ? "Available" : "Not Available",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ],
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
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
      backgroundColor: const Color(0xFF121212),
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

                // Dark gradient overlay
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(tool['description'] ?? 'No description',
                        style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    Divider(
                      color: Colors.white24,
                      thickness: 1,
                      height: 20,
                    ),
                    Row(
                      children: [
                        Chip(
                          label: Text(tool['isFree'] == true ? 'Free' : 'Paid'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: tool['isFree'] == true
                              ? Colors.green
                              : Colors.red,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Chip(
                          label: Text(categoryName),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.blueGrey.shade700,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: tags.map((tagId) {
                        final tagName =
                            widget.allTags[tagId]?['label'] ?? tagId;
                        return Chip(
                          label: Text(tagName),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.blueGrey.shade800,
                          labelStyle: const TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: const Text('Visit Tool Website', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => Get.to(() => const WebviewView(),
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
                      const SizedBox(height: 20),
                      const Text(
                        '🛠️ Similar Tools',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: similarTools.map((simTool) {
                            return GestureDetector(
                              onTap: () => _updateTool(simTool['id']),
                              child: Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage: (simTool['logo'] ?? '').toString().isNotEmpty
                                              ? NetworkImage(simTool['logo'])
                                              : null,
                                          child: (simTool['logo'] ?? '').toString().isEmpty
                                              ? const Icon(Icons.extension)
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          simTool['name'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          simTool['description'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white70),
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
