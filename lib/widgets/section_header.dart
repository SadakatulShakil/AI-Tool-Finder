import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const Spacer(),
        TextButton(onPressed: onSeeAll, child: Container(
            child: const Text('See All', style: TextStyle(fontSize: 14, color: Colors.teal)))),
      ],
    );
  }
}