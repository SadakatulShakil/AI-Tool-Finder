import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controllers.dart';

class ProfilePage extends StatefulWidget {
  final bool isBackButton;
  ProfilePage({super.key, required this.isBackButton});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body: Obx(() {
        final user = controller.userData;
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                children: [
                  Obx(() => CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.deepPurpleAccent.shade200,
                    child: CircleAvatar(
                      radius: 62,
                      backgroundImage: user['profile_image'] != null && user['profile_image'] != ''
                          ? NetworkImage(user['profile_image'])
                          : AssetImage('assets/images/user.png',) as ImageProvider,
                    ),
                  )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.cyan.shade100,
                      foregroundColor: Colors.deepPurpleAccent.shade200,
                      child: IconButton(
                        onPressed: (){
                          Get.snackbar(
                            "Coming Soon",
                            "This feature is under development.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white,
                            colorText: Colors.black,
                          );
                        },
                        icon: Icon(Icons.camera_alt_rounded, size: 20),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              _buildField("Name", controller.nameController),
              _buildField("Email", controller.emailController),
              _buildField("Phone", TextEditingController(text: user['phone']), readOnly: true),
              const SizedBox(height: 8),
              TextField(
                controller: controller.dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.deepPurpleAccent),
                ),
                cursorColor: Colors.deepPurpleAccent,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    controller.dobController.text =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text("Update Profile"),
                onPressed: controller.updateProfile,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
