import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/navigation_controller.dart';
import 'ai_assistance_page.dart';

class NavigationView extends GetView<NavigationController> {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.tealAccent;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      // Floating AI Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: GestureDetector(
          onTap: () {
            Get.to(() => AiAssistancePage(),
                transition: Transition.rightToLeft)?.then((_) {
              // Go back to home tab after AI assistance
              final navCtrl = Get.find<NavigationController>();
              navCtrl.changePage(0);
            });
          },
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4DB6AC), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.smart_toy, color: Colors.black, size: 34.sp),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Dark mode background
      backgroundColor: const Color(0xFF121212),

      // Dark bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 32.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_filled, "Home", 0, primaryColor),
              _buildNavItem(Icons.person, "Profile", 1, primaryColor),
            ],
          ),
        ),
      ),

      body: Obx(() => controller.currentScreen),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, Color activeColor) {
    return InkWell(
      onTap: () => controller.changePage(index),
      borderRadius: BorderRadius.circular(20.r),
      child: Obx(() {
        final isSelected = controller.currentTab.value == index;
        final iconColor = isSelected ? activeColor : Colors.white70;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    activeColor.withOpacity(0.3),
                    activeColor.withOpacity(0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
                color: iconColor,
              ),
            ),
          ],
        );
      }),
    );
  }
}
