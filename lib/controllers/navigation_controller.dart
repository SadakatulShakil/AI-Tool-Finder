import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tool_finder/pages/ai_assistance_page.dart';
import 'package:tool_finder/pages/home_page.dart';
import 'package:tool_finder/pages/profile_page.dart';

import 'auth_controller.dart';

class NavigationController extends GetxController {
  static NavigationController get to => Get.find();
  final authController = Get.find<AuthController>();
  final name = ''.obs;
  final email = ''.obs;
  final currentTab = 0.obs;
  final box = GetStorage();
  final database = FirebaseDatabase.instance.ref();
  var userData = {}.obs;
  String get userId => box.read('userId');

  @override
  void onInit() {
    super.onInit();
    getLocalData();
  }

  /// Load user info from SharedPreferences
  Future<void> getLocalData() async {
    final snapshot = await database.child("users/$userId").get();
    if (snapshot.exists) {
      userData.value = Map<String, dynamic>.from(snapshot.value as Map);
    }
    name.value = userData["name"]?.toString() ?? '';
    email.value = userData["email"]?.toString() ?? '';

    print('User ID: $userId - Name: ${name.value} - Email: ${email.value}');
    checkAndPromptUserInfo();
  }

  /// Check if user info is invalid and show prompt
  Future<void> checkAndPromptUserInfo() async {
    final isNameInvalid = name.value.trim().isEmpty || name.value == 'null' || name.value == 'Hello, ...';

    if (isNameInvalid) {
      await Future.delayed(const Duration(milliseconds: 300));
      _showInfoDialog();
    }
  }

  /// Show dialog to complete profile
  void _showInfoDialog() {
    final RxBool showInstruction = false.obs;
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    Get.dialog(
      PopScope(
        canPop: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return MediaQuery.removeViewInsets(
              context: context,
              removeBottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.9,
                    maxWidth: 320.w,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 50.h),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 40.h),
                                Text(
                                  "Complete your profile",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.tealAccent,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                _buildField("Name", nameController),
                                SizedBox(height: 16.h),
                                _buildField("Email (optional", addressController),
                                SizedBox(height: 24.h),
                                SizedBox(
                                  width: double.infinity,
                                  child:  ElevatedButton.icon(
                                    icon: const Icon(Icons.save, color: Colors.white),
                                    label: const Text("Update",
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: (){
                                      _handleProfileUpdate(nameController, addressController);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.tealAccent.shade400,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)),
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
        
                          /// ℹ️ Info icon toggle
                          Positioned(
                            top: 60.h,
                            right: 12.w,
                            child: GestureDetector(
                              onTap: () => showInstruction.value = !showInstruction.value,
                              child: Icon(Icons.info_outline, size: 20.sp, color: Colors.tealAccent.shade400),
                            ),
                          ),
        
                          /// 💬 Instruction bubble
                          Positioned(
                            top: 100.h,
                            right: 12.w,
                            child: Obx(() => Visibility(
                              visible: showInstruction.value,
                              child: Container(
                                width: 250.w,
                                height: 50.h,
                                margin: EdgeInsets.only(top: 5.h),
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent.shade400,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.r),
                                    bottomLeft: Radius.circular(8.r),
                                    bottomRight: Radius.circular(16.r),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Your name and email (optional) need to update",
                                  style: TextStyle(fontSize: 10.sp, color: Colors.black),
                                ),
                              ),
                            )),
                          ),
        
                          /// 🟡 App Logo at top center
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40.r,
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    'assets/logo/icon.png',
                                    width: 70.w,
                                    height: 70.h,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "AI Tool Hub App",
                                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        cursorColor: Colors.tealAccent,
      ),
    );
  }

  /// Handle profile update API and shared pref update
  Future<void> _handleProfileUpdate(
      TextEditingController nameCtrl,
      TextEditingController emailCtrl,
      ) async {
    final inputName = nameCtrl.text.trim();
    final inputEmail = emailCtrl.text.trim();

    if (inputName.isEmpty || inputName == 's') {
      Get.snackbar('Invalid Input', 'Name is required!',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final updatedData = {
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
    };

    await database.child("users/$userId").update(updatedData);
    authController.fetchUserData(userId);
    Get.back();
    Get.snackbar("Success", "Profile updated successfully", snackPosition: SnackPosition.BOTTOM);
  }

  /// Main screen based on bottom nav
  Widget get currentScreen {
    switch (currentTab.value) {
      case 0:
        return HomePage();
      case 1:
        return ProfilePage(isBackButton: false);
      default:
        return HomePage();
    }
  }

  void changePage(int index) => currentTab.value = index;
}
