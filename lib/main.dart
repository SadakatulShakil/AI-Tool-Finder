import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/home_page.dart';
import 'package:tool_finder/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tool_finder/pages/navigation_view.dart';
import 'bindings/navigation_binding.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  Get.put(AuthController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X baseline
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tool Finder',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            initialBinding: NavigationBinding(),
            home: Obx(() {
              if (authController.isLoggedIn.value) {
                return NavigationView();
              } else {
                return LoginPage();
              }
            }),
          );
        }
      );
  }
}
