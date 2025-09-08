// lib/services/category_decorations.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_decoration.dart';

/// A singleton that fetches distinct category names from Firestore
/// and assigns each a Gradient + IconData + textColor dynamically.
class CategoryDecorationService {
  // Cached map, once built.
  static Map<String, CategoryDecoration>? _cachedDecorations;

  /// Returns a map from category name → CategoryDecoration.
  /// If not yet built, fetches distinct categories from /quotes in Firestore
  /// and assigns each a gradient, icon, and textColor based on a hash.
  static Future<Map<String, CategoryDecoration>>
  getCategoryDecorations() async {
    if (_cachedDecorations != null) {
      return _cachedDecorations!;
    }

    // 1) Fetch all categories from Firestore /quotes
    final snapshot =
        await FirebaseFirestore.instance.collection('quotes').get();

    // Collect unique category strings
    final categorySet = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final cat = (data['category'] as String?)?.trim();
      if (cat != null && cat.isNotEmpty) {
        categorySet.add(cat);
      }
    }

    final categories = categorySet.toList()..sort(); // Sort alphabetically

    // 2) Build a decoration for each category
    //    We use a hash of the category name to pick from fixed lists.
    const possibleColors = <Color>[
      Colors.deepPurple,
      Colors.teal,
      Colors.amber,
      Colors.lightBlue,
      Colors.cyan,
      Colors.orange,
      Colors.lime,
      Colors.pink,
      Colors.indigo,
      Colors.redAccent,
      Colors.green,
    ];

    const possibleIcons = <IconData>[
      Icons.book,
      Icons.lightbulb,
      Icons.self_improvement,
      Icons.brush,
      Icons.school,
      Icons.event,
      Icons.sentiment_satisfied,
      Icons.spa,
      Icons.flight_takeoff,
      Icons.music_note,
      Icons.camera_alt,
    ];

    final decoMap = <String, CategoryDecoration>{};

    for (var catName in categories) {
      // Hash category name to pick consistent index
      final hash = catName.hashCode;
      final baseColor = possibleColors[hash.abs() % possibleColors.length];
      final icon = possibleIcons[hash.abs() % possibleIcons.length];

      // Build a simple linear gradient using the base color and a slightly transparent variant
      final backgroundGradient = LinearGradient(
        colors: [baseColor, baseColor.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      // Choose textColor for contrast
      final textColor =
          (ThemeData.estimateBrightnessForColor(baseColor) == Brightness.dark)
              ? Colors.white
              : Colors.black87;

      decoMap[catName] = CategoryDecoration(
        backgroundGradient: backgroundGradient,
        icon: icon,
        textColor: textColor,
      );
    }

    _cachedDecorations = decoMap;
    return decoMap;
  }
}
