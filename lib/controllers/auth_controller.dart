import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/login_page.dart';
import 'package:get_storage/get_storage.dart';
import '../pages/home_page.dart';

class AuthController extends GetxController {
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final box = GetStorage();
  final database = FirebaseDatabase.instance.ref();

  var isLoggedIn = false.obs;
  var userData = {}.obs;

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

  Future<void> loginUser() async {
    final phone = phoneController.text.trim();
    final dob = dobController.text.trim();
    final userId = phone.replaceAll("+", "").replaceAll(" ", "");
    final userRef = database.child("users/$userId");

    final snapshot = await userRef.get();
    if (!snapshot.exists) {
      await userRef.set({
        "phone": phone,
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
    Get.to(() => HomePage(), transition: Transition.rightToLeft, duration: Duration(milliseconds: 300));
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
    Get.to(() => LoginPage(), transition: Transition.rightToLeft, duration: Duration(milliseconds: 300));
  }
}

