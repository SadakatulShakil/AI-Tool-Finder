import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tool_finder/widgets/banner_add_widget.dart';

import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/category_chips.dart';
import '../widgets/native_add_widget.dart';
import '../widgets/popular_carousel.dart';
import '../widgets/section_header.dart';
import '../widgets/tool_scroller.dart';
import 'category_wise_page.dart';
import 'featured_tool_page.dart';
import 'search_page.dart';
import 'tool_detail_page.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());
  final authController = Get.find<AuthController>();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = authController.userData;

    final String name = user["name"]?.toString().isNotEmpty == true ? user["name"] : "N/A";
    //final String phone = user["phone"] ?? "N/A";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Obx(() => ListTile(
          title: Text(
            authController.userData["name"]?.toString().isNotEmpty == true
                ? 'Hello, '+authController.userData["name"]
                : "Hello, ...",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp, color: Colors.white),
          ),
          subtitle: Text(controller.initTime.value, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
        )),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4), // space inside the circle
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.tealAccent.shade100, // Ring color
                  width: 1,
                ),
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF4DB6AC), Color(0xFF81C784)],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.menu, color: Colors.white),
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.tools.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
        }

        final itemsWithAd = List<dynamic>.from(controller.popularTools);

// Insert ad at random index
        if (itemsWithAd.isNotEmpty) {
          final randomIndex = DateTime.now().millisecondsSinceEpoch % itemsWithAd.length;
          itemsWithAd.insert(randomIndex, const NativeAdCard());
        }

        return RefreshIndicator(
          color: Colors.tealAccent,
          onRefresh: () async => controller.fetchHomeData(),
          child: ListView(
            children: [
              // Search field
              GestureDetector(
                onTap: () => Get.to(() => const SearchPage()),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text('Search tool', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),

              // Categories
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryChip(
                        label: 'All',
                        selected: controller.selectedCategory.value.isEmpty,
                        onTap: () => Get.to(() => CategoryWiseToolPage(selectedId: '')),
                      ),
                      const SizedBox(width: 8),
                      ...controller.categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          label: cat['name'] ?? '',
                          selected: false,
                          onTap: () => Get.to(() => CategoryWiseToolPage(
                            selectedId: cat['id'] ?? '',
                          )),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Featured carousel with gradient
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16),
                child: SectionHeader(
                  title: 'Featured',
                  onSeeAll: () => Get.to(FeaturedAIToolPage(), arguments: {
                    'title': 'Featured Tools',
                    'tag': 'featured',
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PopularCarousel(
                    items: itemsWithAd,
                    onTap: (tool) => Get.to(() => ToolDetailPage(
                      initialToolId: tool['id'],
                      allCategories: controller.categoriesMap,
                      allTags: controller.tagsMap,
                    )),
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Popular
              _buildSection(
                title: 'Popular',
                tag: 'popular',
                items: controller.popularTools,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: BannerAdWidget(),
              ),
              // Trending
              _buildSection(
                title: 'Trending',
                tag: 'trending',
                items: controller.trendingTools,
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection({required String title, required String tag, required List<Map<String, dynamic>> items}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SectionHeader(
            title: title,
            onSeeAll: () => Get.to(FeaturedAIToolPage(), arguments: {
              'title': '$title Tools',
              'tag': tag,
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: HorizontalToolScroller(
            items: items,
            onTap: (tool) => Get.to(() => ToolDetailPage(
              initialToolId: tool['id'],
              allCategories: controller.categoriesMap,
              allTags: controller.tagsMap,
            )),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

}