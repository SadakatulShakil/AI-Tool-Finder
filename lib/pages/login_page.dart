import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login to Your Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: 'Phone Number',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.deepPurpleAccent),
                ),
              ),
              cursorColor: Colors.deepPurpleAccent,
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.loginUser,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}