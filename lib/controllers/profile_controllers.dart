import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'auth_controller.dart';

class ProfileController extends GetxController {
  final authController = Get.find<AuthController>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();

  final box = GetStorage();
  final database = FirebaseDatabase.instance.ref();
  final storage = FirebaseStorage.instance;
  var userData = <String, dynamic>{}.obs;
  final picker = ImagePicker();

  String get userId => box.read('userId');

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() async {
    final snapshot = await database.child("users/$userId").get();
    if (snapshot.exists) {
      userData.value = Map<String, dynamic>.from(snapshot.value as Map);
      nameController.text = userData['name'] ?? '';
      emailController.text = userData['email'] ?? '';
      dobController.text = userData['dob'] ?? '';
    }
  }

  Future<void> updateProfile() async {
    final updatedData = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'dob': dobController.text.trim(),
    };

    await database.child("users/$userId").update(updatedData);
    loadProfile();
    authController.fetchUserData(userId);
    Get.snackbar("Success", "Profile updated successfully", snackPosition: SnackPosition.BOTTOM);
  }
}
