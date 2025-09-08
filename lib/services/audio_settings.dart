// lib/services/audio_settings.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AudioSettings extends ChangeNotifier {
  final _prefsRef = FirebaseFirestore.instance
      .collection('settings')
      .doc('prefs');

  bool _masterEnabled = true;
  Map<String, bool> _byCategory = {};

  AudioSettings() {
    // subscribe once at startup
    _prefsRef.snapshots().listen((snap) {
      if (!snap.exists) return;
      final data = snap.data()!;
      _masterEnabled = data['audioEnabled'] as bool? ?? true;
      final abc = data['audioByCategory'] as Map<String, dynamic>? ?? {};
      _byCategory = abc.map((k, v) => MapEntry(k, v as bool));
      notifyListeners();
    });
  }

  bool get masterEnabled => _masterEnabled;
  bool isCategoryEnabled(String category) => _byCategory[category] ?? true;
}
