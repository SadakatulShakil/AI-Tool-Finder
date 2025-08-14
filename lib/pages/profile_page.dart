import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controllers.dart';

class ProfilePage extends StatefulWidget {
  final bool isBackButton;
  const ProfilePage({super.key, required this.isBackButton});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        automaticallyImplyLeading: widget.isBackButton,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final user = controller.userData;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.tealAccent.shade200,
                    child: CircleAvatar(
                      radius: 63,
                      backgroundImage: user['profile_image'] != null &&
                          user['profile_image'] != ''
                          ? NetworkImage(user['profile_image'])
                          : const AssetImage('assets/images/user.png')
                      as ImageProvider,
                    ),
                  ),
                  // Edit Icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.tealAccent.shade400,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.snackbar(
                            "Coming Soon",
                            "This feature is under development.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white,
                            colorText: Colors.black,
                          );
                        },
                        icon: const Icon(Icons.camera_alt_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Fields
              _buildField("Name", controller.nameController),
              _buildField("Email", controller.emailController),
              _buildField("Phone",
                  TextEditingController(text: user['phone'] ?? ''), readOnly: true),

              const SizedBox(height: 8),

              // Date of Birth Picker
              TextField(
                controller: controller.dobController,
                readOnly: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                    const BorderSide(color: Colors.grey, width: 1),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today,
                      color: Colors.tealAccent, size: 20),
                ),
                cursorColor: Colors.tealAccent,
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

              // Save Button
              ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Update Profile",
                    style: TextStyle(color: Colors.white)),
                onPressed: controller.updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      }),
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
}
