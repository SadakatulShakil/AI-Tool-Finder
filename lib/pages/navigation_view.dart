import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/navigation_controller.dart';
import 'ai_assistance_page.dart';

class NavigationView extends GetView<NavigationController> {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurpleAccent;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: GestureDetector(
          onTap: () {
            Get.to(() => AiAssistancePage(),
                transition: Transition.rightToLeft)?.then((_) {
              // After back, ensure we are in Home
              final navCtrl = Get.find<NavigationController>();
              navCtrl.changePage(0);
            });
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(Icons.smart_toy, color: Colors.white, size: 36.sp),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, -2),
            )
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 32.w),
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
      borderRadius: BorderRadius.circular(8.r),
      child: Obx(() {
        final isSelected = controller.currentTab.value == index;
        final color = isSelected ? activeColor : Colors.black54;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        );
      }),
    );
  }
}
