import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/featured_tool_page.dart';
import 'package:tool_finder/pages/search_page.dart';
import 'package:tool_finder/widgets/app_drawer_widget.dart';

import '../controllers/home_controller.dart';
import '../widgets/category_chips.dart';
import '../widgets/popular_carousel.dart';
import '../widgets/section_header.dart';
import '../widgets/tool_scroller.dart';
import 'category_wise_page.dart';
import 'tool_detail_page.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Find My AI'),
      ),
      body: Obx(() {
        if (controller.tools.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchHomeData(),
          child: ListView(
            children: [
              // Search field (tappable)
              GestureDetector(
                onTap: () => Get.to(() => SearchPage()),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 10),
                        Text('Search tool', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Categories (horizontal chips)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryChip(
                        label: 'All',
                        selected: controller.selectedCategory.value.isEmpty,
                        onTap: () => Get.to(() => CategoryWiseToolPage(
                          selectedId: '',
                        )),
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
              const SizedBox(height: 5),
              // Featured tools carousel
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: SectionHeader(
                  title: 'Featured',
                  onSeeAll: () => Get.to(FeaturedAIToolPage(), arguments: {
                    'title': 'Featured Tools',
                    'tag': 'featured',
                  })
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PopularCarousel(
                    items: controller.popularTools,
                    onTap: (tool) => Get.to(() => ToolDetailPage(
                                initialToolId: tool['id'],
                                allCategories: controller.categoriesMap,
                                allTags: controller.tagsMap,
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              // Popular tools section
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: SectionHeader(
                  title: 'Popular',
                  onSeeAll: () => Get.to(FeaturedAIToolPage(), arguments: {
                    'title': 'Popular Tools',
                    'tag': 'popular',
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: HorizontalToolScroller(
                  items: controller.popularTools,
                  onTap: (tool) => Get.to(() => ToolDetailPage(
                    initialToolId: tool['id'],
                    allCategories: controller.categoriesMap,
                    allTags: controller.tagsMap,
                  )),
                ),
              ),
              const SizedBox(height: 5),
              // Trending tools section
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: SectionHeader(
                  title: 'Trending',
                  onSeeAll: () => Get.to(FeaturedAIToolPage(), arguments: {
                    'title': 'Trending Tools',
                    'tag': 'trending',
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: HorizontalToolScroller(
                  items: controller.trendingTools,
                  onTap: (tool) => Get.toNamed('/tool', arguments: {
                    'toolId': tool['id'],
                    'allCategories': controller.categoriesMap,
                    'allTags': controller.tagsMap,
                  }),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

