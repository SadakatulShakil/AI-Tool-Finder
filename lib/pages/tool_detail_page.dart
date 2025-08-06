import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tool_finder/pages/webview_view.dart';

import '../bindings/webview_binding.dart';


class ToolDetailPage extends StatelessWidget {
  final Map<String, dynamic> tool;

  const ToolDetailPage({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tool['name'] ?? 'Tool Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: tool['logo'] != null
                  ? Image.network(tool['logo'], height: 80)
                  : Icon(Icons.extension, size: 80),
            ),
            SizedBox(height: 20),
            Text(tool['name'] ?? 'Tool Name',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(tool['description'] ?? 'No description',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Row(
              children: [
                Chip(
                  label: Text(tool['isFree'] == true ? 'Free' : 'Paid'),
                  backgroundColor:
                  tool['isFree'] == true ? Colors.green : Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 10),
                if (tool['category'] != null)
                  Chip(label: Text(tool['category'])),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.open_in_new),
              label: Text('Visit Tool Website'),
              onPressed: () => Get.to(() => WebviewView(),
                  binding: WebviewBinding(), arguments: tool, transition: Transition.rightToLeft),
            ),
          ],
        ),
      ),
    );
  }
}
