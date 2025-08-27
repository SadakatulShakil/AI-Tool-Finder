import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset('assets/logo/icon.png', height: 100, width: 100),
            const SizedBox(height: 12),
            const Text('AI Tool Hub',
                style: TextStyle(fontSize: 12, color: Colors.white)),
            const SizedBox(height: 20),
            const Text('Login to Explore AI Tools',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),

            const SizedBox(height: 20),

            // 📱 Country Code + Phone
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CountryCodePicker(
                    onChanged: (code) {
                      controller.countryCode.value = code.dialCode ?? "+880";
                    },
                    initialSelection: 'BD',
                    favorite: const ['+880', 'BD'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey)),
                    ),
                    cursorColor: Colors.tealAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📅 Date of Birth
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
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                suffixIcon: const Icon(Icons.calendar_today,
                    color: Colors.tealAccent, size: 20),
              ),
              cursorColor: Colors.tealAccent,
              onTap: () async {
                final today = DateTime.now();
                final minAllowedDate = DateTime(today.year - 13, today.month, today.day);

                final date = await showDatePicker(
                  context: context,
                  initialDate: minAllowedDate, // default to max valid date
                  firstDate: DateTime(1900),   // oldest possible DOB
                  lastDate: minAllowedDate,    // cannot select younger than 13
                );
                if (date != null) {
                  controller.dobController.text =
                  "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                }
              },
            ),

            const SizedBox(height: 20),

            // 🔘 Login Button
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent));
              }
              return ElevatedButton.icon(
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text("Login",
                    style: TextStyle(color: Colors.white)),
                onPressed: controller.loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(double.infinity, 50),
                ),
              );
            }),

            // ⚠️ Error Message
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red)),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
