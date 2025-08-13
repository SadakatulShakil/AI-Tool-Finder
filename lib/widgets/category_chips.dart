import 'dart:math';

import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  CategoryChip({required this.label, required this.selected, required this.onTap});

  Color _getSoftRandomColor() {
    final random = Random();
    final hue = random.nextDouble() * 180; // 0 to 360
    final hsl = HSLColor.fromAHSL(1.0, hue, 0.4, 0.85);
    //saturation = 0.4 (soft), lightness = 0.85 (light pastel)
    return hsl.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      backgroundColor: _getSoftRandomColor(),
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
          borderRadius: BorderRadius.circular(16)
      ),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}