import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../pages/profile_page.dart';

class AppDrawer extends StatelessWidget {
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final user = authController.userData;

    final String name = user["name"]?.toString().isNotEmpty == true ? user["name"] : "N/A";
    final String phone = user["phone"] ?? "N/A";

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => ProfilePage(), transition: Transition.rightToLeft, duration: Duration(milliseconds: 300));
            },
            child: UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(phone),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user['profile_image'] != null && user['profile_image'] != ''
                    ? NetworkImage(user['profile_image'])
                    : AssetImage('assets/images/user.png',) as ImageProvider,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text("Wishlist"),
            onTap: () {
              // Navigate to wishlist
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }
}
