import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'theme/theme_notifier.dart';
import 'providers/settings_provider.dart';
import 'constant.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/local_notification_service.dart';
import 'services/push_notification_service.dart';

// --- GLOBAL NAVIGATOR KEY (for notification tap navigation) ---
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// --- Firestore Initializer (for first-run seeding) ---
class _AppInitializer {
  static Future<void> seedQuotes() async {
    final col = FirebaseFirestore.instance.collection('quotes');
    final snap = await col.limit(1).get();
    if (snap.docs.isEmpty) {
      final String jsonStr = await rootBundle.loadString('assets/quotes_seed.json');
      final List<dynamic> quotesList = jsonDecode(jsonStr);
      final batch = FirebaseFirestore.instance.batch();
      for (var q in quotesList) {
        if (q[kQuoteKey] == null || q[kAuthorKey] == null || q[kCategory] == null) continue;
        batch.set(col.doc(), {
          kQuoteKey: q[kQuoteKey],
          kAuthorKey: q[kAuthorKey],
          kCategory: q[kCategory] ?? 'Uncategorized',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('Quotes seeded into Firestore.');
    } else {
      debugPrint('Quotes already exist in Firestore.');
    }
  }

  static Future<void> seedUserPrefs(String uid) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('prefs');
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'audioEnabled': true,
        'isDarkMode': false,
        'textSize': 1.0,
        'defaultCategory': 'All',
        'showNewestFirst': true,
        'animationsEnabled': true,
        'preferredLanguage': 'en',
        'accentColor': 0xFFE91E63,
        'notificationsEnabled': true,
        'notificationHour': 8,
        'notificationMinute': 0,
      });
      debugPrint('User prefs seeded.');
    } else {
      debugPrint('User prefs already exist.');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firebase AppCheck with Play Integrity ONLY for Android
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Optional: sign in anonymously if no user (for demo/test use)
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  await PushNotificationService.initialize();
  await LocalNotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(isDark: false, accentColor: 0xFFE91E63)),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadFromFirestore()),
      ],
      child: const DailyQApp(),
    ),
  );
}

class DailyQApp extends StatelessWidget {
  const DailyQApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctxAuth, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        final user = authSnap.data;
        if (user == null) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SignInScreen(),
          );
        }
        // Seed prefs and Firestore data, then launch the app
        return FutureBuilder(
          future: Future.wait([
            _AppInitializer.seedUserPrefs(user.uid),
            _AppInitializer.seedQuotes(),
          ]),
          builder: (ctxSeed, seedSnap) {
            if (seedSnap.connectionState != ConnectionState.done) {
              return const MaterialApp(
                home: Scaffold(body: Center(child: CircularProgressIndicator())),
              );
            }
            if (seedSnap.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text(
                      'Error during app initialization:\n${seedSnap.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Daily Q',
              debugShowCheckedModeBanner: false,
              theme: buildTheme(
                isDark: false,
                accentColor: themeNotifier.accentColor,
              ),
              darkTheme: buildTheme(
                isDark: true,
                accentColor: themeNotifier.accentColor,
              ),
              themeMode: themeNotifier.themeMode,
              home: const HomeScreen(),
              routes: {
                '/settings': (ctx) => const SettingsScreen(),
              },
            );
          },
        );
      },
    );
  }
}
