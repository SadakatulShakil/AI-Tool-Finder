import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}