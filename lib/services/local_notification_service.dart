import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../main.dart' show navigatorKey;
import '../screens/home_screen.dart';
import '../constant.dart' as constants;

// --- Pixabay API Key ---
const String kPixabayKey = '50180577-5f0d84f67bd57fb18ae937c93';

// ... Paste your _pixabayQueries map here as in your app (for brevity, not repeated) ...
const Map<String, String> _pixabayQueries = {
  'All': 'nature',
  'Action': 'action',
  'Adventure': 'adventure',
  'Art': 'art',
  'Balance': 'balance',
  'Belief': 'belief',
  'Change': 'change',
  'Charity': 'charity',
  'Childhood': 'childhood',
  'Community': 'community',
  'Confidence': 'confidence',
  'Courage': 'courage',
  'Creativity & Inspiration': 'creative art',
  'Culture': 'culture',
  'Decision': 'decision',
  'Determination': 'determination',
  'Discipline': 'discipline',
  'Diversity': 'diversity',
  'Dreams': 'dreams',
  'Education': 'education',
  'Empathy': 'empathy',
  'Endings': 'endings',
  'Equality': 'equality',
  'Faith': 'faith',
  'Family': 'family',
  'Focus': 'focus',
  'Forging Ahead': 'progress',
  'Forgiveness': 'forgiveness',
  'Freedom': 'freedom',
  'Friendship': 'friendship',
  'Giving': 'giving',
  'Gratitude': 'gratitude',
  'Growth': 'growth',
  'Hard Work': 'hard work',
  'Happiness & Joy': 'happy moments',
  'Health': 'health',
  'Hope': 'hope',
  'Honesty': 'honesty',
  'Humility': 'humility',
  'Humor': 'humor',
  'Imagination': 'imagination',
  'Inclusion': 'inclusion',
  'Innovation': 'innovation',
  'Integrity': 'integrity',
  'Justice': 'justice',
  'Kindness': 'kindness',
  'Leadership': 'leadership',
  'Learning': 'learning',
  'Legacy': 'legacy',
  'Life': 'life',
  'Listening': 'listening',
  'Love': 'love',
  'Memories': 'memories',
  'Mindfulness': 'mindfulness',
  'Mindfulness & Letting Go': 'mindfulness meditation',
  'Mindset': 'mindset',
  'Motivation & Achievement': 'motivation success',
  'Music': 'music',
  'Natural': 'natural',
  'New Beginnings': 'new beginnings',
  'Opportunity': 'opportunity',
  'Overcoming Obstacles': 'overcoming obstacles',
  'Parenting': 'parenting',
  'Passion': 'passion',
  'Patience': 'patience',
  'Peace': 'peace',
  'Peace & Inner Calm': 'peaceful scenery',
  'Perseverance': 'perseverance',
  'Philosophy': 'philosophy books',
  'Positivity': 'positivity',
  'Prosperity': 'prosperity',
  'Purpose': 'purpose',
  'Reflection': 'reflection',
  'Relationships & Connection': 'relationship love',
  'Resilience': 'resilience',
  'Responsibility': 'responsibility',
  'Risk': 'risk',
  'Sacrifice': 'sacrifice',
  'Self-Discovery': 'self discovery',
  'Self-Improvement': 'self improvement',
  'Self-Love': 'self love',
  'Service': 'service',
  'Silence': 'silence',
  'Simplicity': 'simplicity',
  'Sincerity': 'sincerity',
  'Spirituality': 'spirituality',
  'Strength': 'strength',
  'Success': 'success',
  'Teamwork': 'teamwork',
  'Time': 'time',
  'Travel': 'travel',
  'Trust': 'trust',
  'Unity': 'unity',
  'Value': 'integrity',
  'Vision': 'vision',
  'Wealth': 'wealth',
  'Wellness': 'wellness',
  'Wisdom': 'wisdom',
  'Wisdom of Age': 'wisdom age',
  'Worry & Anxiety': 'anxiety relief',
  'Youth': 'youth',
  'Uncategorized': 'abstract art',
};

// The loaded quotes from assets/quotes_seed.json
List<Map<String, dynamic>> _quotesSeed = [];

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Call once on app startup!
  static Future<void> initialize() async {
    print('[DEBUG] LocalNotificationService.initialize called');
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload ?? 'All';
        // Remove all routes, open HomeScreen with category from payload
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => HomeScreen(settingsCategory: payload)),
          (route) => false,
        );
      },
    );

    // Request notification permission only on Android 13+
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        print('[DEBUG] Notification permission granted: ${result.isGranted}');
      } else {
        print('[DEBUG] Notification permission already granted.');
      }
    }

    await loadQuotesSeed();
  }

  // Load all quotes from the bundled JSON asset
  static Future<void> loadQuotesSeed() async {
    if (_quotesSeed.isNotEmpty) return;
    final jsonString = await rootBundle.loadString('assets/quotes_seed.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _quotesSeed =
        jsonList.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Picks a random quote with non-empty kQuote & kAuthor from the given category
  static Map<String, dynamic> pickRandomQuoteFromCategory(String category) {
    final filtered = (category == 'All')
        ? _quotesSeed
        : _quotesSeed.where((q) =>
            (q['kCategory'] ?? '').toString().toLowerCase() ==
            category.toLowerCase()).toList();

    final valid = filtered.where((q) =>
      (q['kQuote'] != null && (q['kQuote'] as String).trim().isNotEmpty) &&
      (q['kAuthor'] != null && (q['kAuthor'] as String).trim().isNotEmpty)
    ).toList();

    if (valid.isEmpty) return {
      'kQuote': 'Stay inspired!',
      'kAuthor': 'DailyQ',
      'kCategory': category,
    };

    final random = Random();
    return valid[random.nextInt(valid.length)];
  }

  // Fetch a Pixabay image URL for a given query/category
  static Future<String> _getPixabayImageUrl(String query) async {
    final url =
        'https://pixabay.com/api/?key=$kPixabayKey&q=${Uri.encodeComponent(query)}&image_type=photo&per_page=50';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = res.body;
        final hits = RegExp(r'"largeImageURL":"([^"]+)"').allMatches(data).toList();
        if (hits.isNotEmpty) {
          final rand = Random().nextInt(hits.length);
          return hits[rand].group(1)?.replaceAll(r'\/', '/') ?? '';
        }
      }
    } catch (_) {}
    // fallback image
    return 'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg';
  }

  /// Show a local notification with image
  static Future<void> showNotificationWithImage({
    required String title,
    required String body,
    required String imageUrl,
    required String payload, // Pass category here
  }) async {
    String? bigPicturePath;
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/notif_img_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      bigPicturePath = file.path;
    } catch (_) {}

    final bigPictureStyleInformation = bigPicturePath != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            contentTitle: '<b>$title</b>',
            summaryText: body,
            htmlFormatContent: true,
            htmlFormatContentTitle: true,
          )
        : null;

    final androidDetails = AndroidNotificationDetails(
      'daily_quote_channel',
      'Daily Quotes',
      channelDescription: 'Get inspired every day!',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation ??
          const DefaultStyleInformation(true, true),
      color: Colors.teal,
      playSound: true,
    );

    await _plugin.show(
      0,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload, // Pass category as payload
    );
  }

  /// Immediate notification with a random quote from quotes_seed.json and a Pixabay image
  static Future<void> showImmediateQuoteNotification({required String category}) async {
    if (_quotesSeed.isEmpty) await loadQuotesSeed();
    final quote = pickRandomQuoteFromCategory(category);
    final author = quote['kAuthor'] ?? '';
    final quoteText = quote['kQuote'] ?? '';
    final categoryName = quote['kCategory'] ?? category;
    final emoji = constants.kCategoryEmoji[categoryName] ?? '';
    final pixabayQuery =
        _pixabayQueries[categoryName] ?? _pixabayQueries['All']!;
    final imageUrl = await _getPixabayImageUrl(pixabayQuery);

    await showNotificationWithImage(
      title: '$emoji Quote of the Day • $categoryName',
      body: '"$quoteText"\n- $author',
      imageUrl: imageUrl,
      payload: categoryName,
    );
  }

  /// Schedule daily quote notification and also show one immediately
  static Future<void> scheduleDailyQuoteNotification({
    int hour = 8,
    int minute = 0,
    String category = 'All',
    BuildContext? context,
  }) async {
    await cancelAll();
    await showImmediateQuoteNotification(category: category);

    try {
      await _plugin.zonedSchedule(
        0,
        'Daily Q',
        'Your quote for today!',
        _nextInstanceOfUtcTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_quote_channel',
            'Daily Quotes',
            channelDescription: 'Get inspired every day!',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: DefaultStyleInformation(true, true),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: category, // Pass the category here!
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted' && context != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Enable Alarms & Reminders'),
            content: const Text(
              'Please enable "Alarms & reminders" permission for the app in system settings:\n\n'
              'Settings > Apps > qns > Alarms & reminders\n\n'
              'Turn ON "Allow setting alarms and reminders".'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        print('[LocalNotificationService] ERROR: $e');
      }
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfUtcTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.UTC);
    var scheduled = tz.TZDateTime(tz.UTC, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
