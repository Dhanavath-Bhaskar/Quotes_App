import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// Handles FCM push notifications, token management, and rich notifications.
class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Call this in main() after initializing Firebase and local notifications.
  static Future<void> initialize() async {
    // Android notification channel setup (one time)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _plugin.initialize(initializationSettings);

    // Listen for foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await showRichNotification(message);
    });

    // Listen for FCM token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      print('FCM Token refreshed: $newToken');
      await _saveTokenToFirestore(newToken);
    });

    // Get and save/log FCM token at startup
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('FCM Token (startup): $token');
      await _saveTokenToFirestore(token);
    }
  }

  /// Save FCM token to Firestore in user's document (creates doc if missing)
  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  /// Show a "rich" notification with image, if available.
  static Future<void> showRichNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // --- Image url extraction for Android/iOS/Data ---
    String? imageUrl;
    if (notification.android?.imageUrl != null && notification.android!.imageUrl!.isNotEmpty) {
      imageUrl = notification.android!.imageUrl;
    } else if (notification.apple?.imageUrl != null && notification.apple!.imageUrl!.isNotEmpty) {
      imageUrl = notification.apple!.imageUrl;
    } else if (message.data['image'] != null && message.data['image'].isNotEmpty) {
      imageUrl = message.data['image'];
    }

    String? bigPicturePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/push_img_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await file.writeAsBytes(bytes);
          bigPicturePath = file.path;
        }
      } catch (_) {}
    }

    final bigPictureStyleInformation = bigPicturePath != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            contentTitle: notification.title,
            summaryText: notification.body,
          )
        : null;

    final androidDetails = AndroidNotificationDetails(
      'push_quote_channel',
      'Push Quotes',
      channelDescription: 'FCM push quotes with images',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation ?? const DefaultStyleInformation(true, true),
    );

    await _plugin.show(
      1,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails),
    );
  }

  /// Utility: Get and print the current FCM token (does NOT force refresh).
  static Future<void> printFreshFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('Fresh FCM Token: $token');
  }

  /// Utility: Force-refresh FCM token by deleting and getting a new one.
  static Future<String?> forceRefreshFcmToken() async {
    await FirebaseMessaging.instance.deleteToken();
    String? newToken = await FirebaseMessaging.instance.getToken();
    print('Force-refreshed FCM Token: $newToken');
    // Optionally save the new token to Firestore here:
    await _saveTokenToFirestore(newToken ?? "");
    return newToken;
  }
}
