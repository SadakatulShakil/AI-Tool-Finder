import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../pages/login_page.dart';
import '../pages/navigation_view.dart';
import 'navigation_controller.dart';

class AuthController extends GetxController {
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final box = GetStorage();
  final database = FirebaseDatabase.instance.ref();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  var isLoggedIn = false.obs;
  var userData = {}.obs;
  var countryCode = "+880".obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  void checkLogin() {
    if (box.hasData('userId')) {
      isLoggedIn.value = true;
      fetchUserData(box.read('userId'));
    }
  }

  /// ✅ Normalize phone numbers properly
  String normalizePhone(String phone) {
    String p = phone.trim();

    // Remove spaces and dashes
    p = p.replaceAll(RegExp(r'\s+|-'), "");

    // ✅ Special rule for Bangladesh (+880)
    if (countryCode.value == "+880") {
      // Accepts "01751..." and converts to +8801751...
      if (p.startsWith("0")) {
        p = p.substring(1);
      }

      // Must be exactly 10 digits after removing the leading 0
      if (p.length != 10) {
        throw "Bangladesh phone numbers must be 11 digits (e.g., 017XXXXXXXX)";
      }
    }

    // If starts with country code without + → add +
    if (p.startsWith(countryCode.value.replaceAll("+", ""))) {
      p = "+$p";
    }

    // If not starting with +, add countryCode
    if (!p.startsWith("+")) {
      p = countryCode.value + p;
    }

    // ✅ General length validation
    final digitsOnly = p.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      throw "Invalid phone number length";
    }

    return p;
  }

  Future<void> loginUser() async {
    try {
      isLoading(true);
      errorMessage('');

      final phone = phoneController.text.trim();
      final dob = dobController.text.trim();

      if (phone.isEmpty || dob.isEmpty) {
        throw 'Please fill in all fields';
      }

      // ✅ Normalize & validate phone
      final normalizedPhone = normalizePhone(phone);

      // Use phone without '+' for userId key
      final userId = normalizedPhone.replaceAll("+", "").replaceAll(" ", "");

      final userRef = database.child("users/$userId");
      final snapshot = await userRef.get();

      if (!snapshot.exists) {
        await userRef.set({
          "phone": normalizedPhone,
          "dob": dob,
          "created_at": DateTime.now().toIso8601String(),
          "name": "",
          "email": "",
          "wishlist": [],
          "search_history": [],
          "preferred_categories": [],
          "profile_image": "",
        });
      }

      box.write('userId', userId);

      fetchUserData(userId);
      isLoggedIn.value = true;


      Get.offAll(() => NavigationView(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300));
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Login Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void fetchUserData(String userId) async {
    final snapshot = await database.child("users/$userId").get();
    if (snapshot.exists) {
      userData.value = Map<String, dynamic>.from(snapshot.value as Map);
    }
  }

  void logout() {
    box.erase();
    isLoggedIn.value = false;
    userData.clear();
    Get.offAll(() => LoginPage(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300));
  }
}