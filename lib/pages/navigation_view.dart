import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_finder/pages/test_page.dart';
import '../controllers/chat_controller.dart';
import '../controllers/navigation_controller.dart';
import 'ai_assistance_page.dart';

class NavigationView extends GetView<NavigationController> {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurpleAccent;
    final secondaryColor = Colors.white;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        tooltip: "tool".tr,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.r),
        ),
        onPressed: () {
          Get.delete<ChatController>(); // 🧹 ensure clean controller
          Get.to(() => AiAssistancePage());
          //Get.to(() => TestPage());
        },
        child: Image.asset('assets/images/ai_bot.png', height: 35.sp, width: 35.sp, fit: BoxFit.cover),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal.shade50,
        surfaceTintColor: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.w,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor) {
    return InkWell(
      onTap: () => controller.changePage(index),
      splashFactory: NoSplash.splashFactory,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 12.w),
        child: Obx(() {
          final isSelected = controller.currentTab.value == index;
          final color = isSelected ? activeColor : Colors.black54;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22.sp),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
