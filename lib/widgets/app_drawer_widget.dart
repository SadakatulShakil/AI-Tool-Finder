import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/chat_history_page.dart';
import '../controllers/auth_controller.dart';
import '../pages/profile_page.dart';
import '../pages/wishlist_page.dart';

class AppDrawer extends StatelessWidget {
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final user = authController.userData;

    final String name = user["name"]?.toString().isNotEmpty == true
        ? user["name"]
        : "N/A";
    final String phone = user["phone"] ?? "N/A";

    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(
                    () => ProfilePage(isBackButton: true),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: Stack(
              children: [
                // Background image
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/drawer_bg.jpg"), // Change to your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Purple gradient + dark overlay
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        const Color(0xFF7B1FA2).withOpacity(0.6),
                        const Color(0xFF512DA8).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // User info
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: user['profile_image'] != null &&
                                user['profile_image'] != ''
                                ? NetworkImage(user['profile_image'])
                                : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            phone,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          _drawerTile(
            icon: Icons.favorite,
            label: "Wishlist",
            onTap: () => Get.to(
                  () => WishlistPage(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            ),
          ),
          _drawerTile(
            icon: Icons.chat,
            label: "AI Chat History",
            onTap: () => Get.to(
                  () => ChatHistoryPage(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            ),
          ),
          _drawerTile(
            icon: Icons.logout,
            label: "Logout",
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.tealAccent),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      hoverColor: Colors.deepPurpleAccent.withOpacity(0.2),
    );
  }
}
