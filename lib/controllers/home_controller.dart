import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  var searchQuery = ''.obs;
  var tools = [].obs;
  var selectedCategory = ''.obs;
  var categories = <Map<String, dynamic>>[].obs;
  var categoriesMap = <String, dynamic>{}.obs;
  var tagsMap = <String, dynamic>{}.obs;
  final database = FirebaseDatabase.instance;
  var usersWishlist = <String, List<String>>{}.obs;
  var currentWishlist = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  void wishlistTool(String toolId) async {
    final userPhone = GetStorage().read('phone');
    if (userPhone == null) return;

    final userRef = database.ref("users/$userPhone");

    final snapshot = await userRef.get();
    final currentData = snapshot.value as Map?;

    final currentWishlist = List<String>.from(currentData?['wishlist'] ?? []);

    if (currentWishlist.contains(toolId)) {
      currentWishlist.remove(toolId);
      Get.snackbar("Wishlist", "Removed from wishlist");
    } else {
      currentWishlist.add(toolId);
      Get.snackbar("Wishlist", "Added to wishlist");
    }

    await userRef.update({"wishlist": currentWishlist});
  }

  List<Map<String, dynamic>> suggestToolsFromMessage(String message) {
    final keywords = message
        .toLowerCase()
        .split(RegExp(r'\W+')) // split on non-word characters
        .where((w) => w.length > 2)
        .toList();

    return tools.where((tool) {
      final name = (tool['name'] ?? '').toString().toLowerCase();
      final desc = (tool['description'] ?? '').toString().toLowerCase();
      final tags = (tool['tags'] ?? []).join(' ').toLowerCase();
      final allContent = "$name $desc $tags";

      return keywords.any((word) => allContent.contains(word));
    }).toList().cast<Map<String, dynamic>>().take(5).toList(); // top 5
  }


  Future<List<Map<String, dynamic>>> getWishlistTools() async {
    final userPhone = GetStorage().read('userId');
    if (userPhone == null) return [];

    final userRef = database.ref("users/$userPhone");
    final snapshot = await userRef.get();
    final userData = snapshot.value as Map?;

    final wishlistIds = List<String>.from(userData?['wishlist'] ?? []);

    // ✅ Update both
    usersWishlist[userPhone] = wishlistIds;
    currentWishlist.assignAll(wishlistIds); // ✅ so Obx works

    final wishlistTools = tools
        .where((tool) => wishlistIds.contains(tool['id']))
        .map((tool) => tool as Map<String, dynamic>)
        .toList();

    return wishlistTools;
  }

  bool isWishlisted(String toolId) {
    return currentWishlist.contains(toolId);
  }

  // Map<String, dynamic>? getToolById(String id) {
  //   return filteredTools.firstWhereOrNull((tool) => tool['id'] == id);
  // }

  bool isInWishlist(String toolId) {
    final userPhone = GetStorage().read('phone');
    if (userPhone == null) return false;

    final userWishlist = usersWishlist[userPhone] ?? [];
    return userWishlist.contains(toolId);
  }

  void toggleWishlist(String toolId) async {
    final userPhone = GetStorage().read('userId');
    print("User phone: $userPhone, Tool ID: $toolId");
    if (userPhone == null) return;

    final userRef = database.ref("users/$userPhone");
    final snapshot = await userRef.get();
    final currentData = snapshot.value as Map?;
    final currentWishlist = List<String>.from(currentData?['wishlist'] ?? []);

    if (currentWishlist.contains(toolId)) {
      currentWishlist.remove(toolId);
      Get.snackbar("Wishlist", "Removed from wishlist");
    } else {
      currentWishlist.add(toolId);
      Get.snackbar("Wishlist", "Added to wishlist");
    }

    try {
      await userRef.update({"wishlist": currentWishlist});
      print("Wishlist updated in Firebase: $currentWishlist");
      usersWishlist[userPhone] = currentWishlist;
      this.currentWishlist.value = currentWishlist; // force update
    } catch (e) {
      print("Failed to update wishlist: $e");
    }

  }


  void fetchHomeData() {
    fetchCategories();
    fetchTags();
    fetchTools();
    getWishlistTools();
  }

  String tagLabel(String tagId) {
    final raw = tagsMap[tagId];
    if (raw is Map && raw['label'] != null) return raw['label'].toString();
    if (raw is String) return raw;
    return tagId;
  }

  bool toolHasTagLabel(Map<String, dynamic> tool, String desiredLabel) {
    final desired = desiredLabel.trim().toLowerCase();
    final tagIds = (tool['tags'] ?? []).cast<String>();
    for (final tid in tagIds) {
      final lbl = tagLabel(tid).toLowerCase();
      if (lbl == desired) return true;
      // also allow raw match just in case DB put "popular" inside tags directly
      if (tid.toLowerCase() == desired) return true;
    }
    return false;
  }

  List<Map<String, dynamic>> toolsByTagLabel(String label, {int? limit}) {
    final list = tools
        .whereType<Map<String, dynamic>>()
        .where((t) => toolHasTagLabel(t, label))
        .toList();
    if (limit != null && list.length > limit) return list.take(limit).toList();
    return list;
  }

  // Popular == Recommended For You
  List<Map<String, dynamic>> get popularTools => toolsByTagLabel('popular');
  List<Map<String, dynamic>> get trendingTools => toolsByTagLabel('trending');

  Map<String, dynamic>? getToolById(String id) {
    return tools.cast<Map<String, dynamic>?>().firstWhere(
          (t) => t?['id'] == id,
      orElse: () => null,
    );
  }

  // Reusable search (name + desc + tags + category)
  List<Map<String, dynamic>> searchTools({String q = '', String? categoryId}) {
    final query = q.trim().toLowerCase();
    return tools.whereType<Map<String, dynamic>>().where((tool) {
      final name = (tool['name'] ?? '').toString().toLowerCase();
      final desc = (tool['description'] ?? '').toString().toLowerCase();
      final tags = (tool['tags'] ?? []).cast<String>()
          .map((tid) => tagLabel(tid).toLowerCase())
          .join(' ');
      final catOk = (categoryId == null || categoryId.isEmpty)
          ? true
          : (tool['category'] == categoryId);
      final textOk = query.isEmpty
          ? true
          : ('$name $desc $tags').contains(query);
      return catOk && textOk;
    }).toList();
  }

  void fetchCategories() async {
    final catSnapshot = await database.ref("categories").get();
    if (catSnapshot.exists) {
      final data = Map<String, dynamic>.from(catSnapshot.value as Map);

      final categoryList = data.entries.map((e) {
        return {
          "id": e.key,
          ...Map<String, dynamic>.from(e.value),
        };
      }).toList();

      // 🔁 Store as map for lookup
      categoriesMap.value = data;
      // 🔢 Sort by numeric suffix from IDs like cat01, cat10
      categoryList.sort((a, b) {
        final aNum = int.tryParse(a['id'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b['id'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });

      categories.value = categoryList;
      selectedCategory.value = ''; // default to All
    }
  }

  void fetchTags() async {
    final tagSnapshot = await database.ref("tags").get();
    if (tagSnapshot.exists) {
      final data = Map<String, dynamic>.from(tagSnapshot.value as Map);
      tagsMap.value = data;
    }
  }

  void fetchTools() async {
    final toolSnapshot = await database.ref("tools").get();
    if (toolSnapshot.exists) {
      final data = Map<String, dynamic>.from(toolSnapshot.value as Map);
      final toolList = data.entries.map((e) {
        return {
          "id": e.key,
          ...Map<String, dynamic>.from(e.value),
        };
      }).toList();

      // Sort by numeric part of the key (tool_1 to tool_50)
      toolList.sort((a, b) {
        final aNum = int.tryParse(a['id'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b['id'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });

      tools.value = toolList;
    }
  }

  void searchTool(String query) {
    searchQuery.value = query;
  }

  void selectCategory(String id) {
    if (selectedCategory.value == id) {
      selectedCategory.value = ''; // Toggle off to show all
    } else {
      selectedCategory.value = id;
    }
  }

  List<Map<String, dynamic>> get filteredTools {
    return tools.where((tool) {
      final matchesSearch = searchQuery.value.isEmpty ||
          tool['name'].toString().toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          tool['description'].toString().toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesCategory = selectedCategory.value.isEmpty ||
          tool['category'] == selectedCategory.value;

      return matchesSearch && matchesCategory;
    }).cast<Map<String, dynamic>>().toList();
  }
}
