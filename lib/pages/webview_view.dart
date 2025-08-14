import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/webview_controller.dart';

class WebviewView extends GetView<WebviewController> {
  const WebviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (!controller.hasInternet.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.grey, size: 60),
                    SizedBox(height: 16),
                    Text(
                      "No internet connection",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => controller.onInit(),
                        child: Text("Retry", style: TextStyle(fontSize: 14, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              WebViewWidget(controller: controller.webViewController),
              Obx(() => Visibility(
                visible: controller.isPageLoading.value != 100,
                child: CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                ),
              )),
            ],
          );
        }),
      ),
    );
  }
}