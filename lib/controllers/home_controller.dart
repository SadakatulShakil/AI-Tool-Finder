import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeController extends GetxController {
  var searchQuery = ''.obs;
  var tools = [].obs;
  var selectedCategory = ''.obs;
  var categories = <Map<String, dynamic>>[].obs;

  final database = FirebaseDatabase.instance;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchTools();
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
