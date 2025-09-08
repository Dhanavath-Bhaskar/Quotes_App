import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsProvider extends ChangeNotifier {
  // --- Private fields with safe defaults ---
  bool _isLoading = false;

  // App Settings
  String _preferredLanguage = 'en';
  bool _isDarkMode = false;
  int _accentColor = 0xFFE91E63;
  double _textSize = 1.0;
  bool _animationsEnabled = true;
  bool _audioEnabled = true;
  bool _showNewestFirst = true;

  // Notification Settings
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  // Quote Category Setting
  String _defaultCategory = 'All';

  // --- Getters ---
  bool get isLoading => _isLoading;

  String get preferredLanguage => _preferredLanguage;
  bool get isDarkMode => _isDarkMode;
  int get accentColor => _accentColor;
  double get textSize => _textSize;
  bool get animationsEnabled => _animationsEnabled;
  bool get audioEnabled => _audioEnabled;
  bool get showNewestFirst => _showNewestFirst;

  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;

  String get category => _defaultCategory;
  String get defaultCategory => _defaultCategory;

  // --- Setters with Firestore sync ---
  set preferredLanguage(String v) => updateSetting('preferredLanguage', v);
  set isDarkMode(bool v) => updateSetting('isDarkMode', v);
  set accentColor(int v) => updateSetting('accentColor', v);
  set textSize(double v) => updateSetting('textSize', v);
  set animationsEnabled(bool v) => updateSetting('animationsEnabled', v);
  set audioEnabled(bool v) => updateSetting('audioEnabled', v);
  set showNewestFirst(bool v) => updateSetting('showNewestFirst', v);
  set notificationsEnabled(bool v) => updateSetting('notificationsEnabled', v);
  set category(String v) => updateSetting('defaultCategory', v);
  set defaultCategory(String v) => updateSetting('defaultCategory', v);

  Future<void> setNotificationTime(TimeOfDay t) async {
    await updateNotificationTime(t);
  }

  // --- Load settings from Firestore ---
  Future<void> loadFromFirestore() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('prefs');
      final snap = await ref.get();

      if (snap.exists) {
        final data = snap.data()!;
        _preferredLanguage   = data['preferredLanguage'] ?? _preferredLanguage;
        _isDarkMode          = data['isDarkMode'] ?? _isDarkMode;
        _accentColor         = data['accentColor'] ?? _accentColor;
        _textSize            = (data['textSize'] ?? _textSize).toDouble();
        _animationsEnabled   = data['animationsEnabled'] ?? _animationsEnabled;
        _audioEnabled        = data['audioEnabled'] ?? _audioEnabled;
        _showNewestFirst     = data['showNewestFirst'] ?? _showNewestFirst;

        _notificationsEnabled = data['notificationsEnabled'] ?? _notificationsEnabled;
        _notificationTime = TimeOfDay(
          hour: data['notificationHour'] ?? _notificationTime.hour,
          minute: data['notificationMinute'] ?? _notificationTime.minute,
        );
        _defaultCategory = data['defaultCategory'] ?? _defaultCategory;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Update a single setting in Firestore and locally ---
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('prefs');
      await ref.set({key: value}, SetOptions(merge: true));
      // Update local value and notify
      switch (key) {
        case 'preferredLanguage':
          _preferredLanguage = value;
          break;
        case 'isDarkMode':
          _isDarkMode = value;
          break;
        case 'accentColor':
          _accentColor = value;
          break;
        case 'textSize':
          _textSize = value.toDouble();
          break;
        case 'animationsEnabled':
          _animationsEnabled = value;
          break;
        case 'audioEnabled':
          _audioEnabled = value;
          break;
        case 'showNewestFirst':
          _showNewestFirst = value;
          break;
        case 'notificationsEnabled':
          _notificationsEnabled = value;
          break;
        case 'defaultCategory':
          _defaultCategory = value;
          break;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating $key: $e');
    }
  }

  // --- Update notification time specifically ---
  Future<void> updateNotificationTime(TimeOfDay t) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('prefs');
      await ref.set({
        'notificationHour': t.hour,
        'notificationMinute': t.minute,
      }, SetOptions(merge: true));
      _notificationTime = t;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating notification time: $e');
    }
  }
}
