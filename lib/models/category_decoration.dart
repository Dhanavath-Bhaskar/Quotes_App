// lib/models/category_decoration.dart

import 'package:flutter/material.dart';

/// Holds decoration data for a specific category.
class CategoryDecoration {
  final Gradient backgroundGradient; // Background gradient for the category
  final IconData icon; // An icon to show next to the category name
  final Color textColor; // Color for text overlaid on the gradient

  const CategoryDecoration({
    required this.backgroundGradient,
    required this.icon,
    required this.textColor,
  });
}
