import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF4DB6AC); // Teal accent for dark mode

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected?Colors.white: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: selected,
      checkmarkColor: Colors.white,
      selectedColor: accentColor,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? accentColor : Color(0xFF1E1E1E),
          width: 0,
        ),
      ),
      onSelected: (_) => onTap(),
    );
  }
}
