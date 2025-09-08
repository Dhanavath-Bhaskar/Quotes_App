import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qns/widgets/quote_share_full_detail_card.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/return_code.dart';
import '../services/google_translation_service.dart'; // <-- Import your service here
import 'package:qns/screens/favorite_detail_screen.dart';
import 'record_screen.dart';
import '../widgets/non_intrusive_emoji_rain.dart';

// --- Utility functions for extracting quote/author/category/imageUrl ---
String getQuote(Map<String, dynamic> data) {
  return data['kQuote'] ?? data['quote'] ?? '';
}
String getAuthor(Map<String, dynamic> data) {
  return data['kAuthor'] ?? data['author'] ?? '';
}
String getCategory(Map<String, dynamic> data) {
  return data['kCategory'] ?? data['category'] ?? '';
}
String getImageUrl(Map<String, dynamic> data) {
  if (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty) return data['imageUrl'];
  return '';
}

// ... [CATEGORY AUDIO, EMOJI, SUPPORTED LANGS constants go here, unchanged] ...
// ---------------------
const Map<String, String> _categoryAudio = {
  'Action': 'assets/audio/action_fixed.m4a',
  'Adventure': 'assets/audio/adventure_fixed.m4a',
  'All': 'assets/audio/nature_fixed.m4a',
  'Art': 'assets/audio/art_fixed.m4a',
  'Balance': 'assets/audio/balance_fixed.m4a',
  'Belief': 'assets/audio/belief_fixed.m4a',
  'Change': 'assets/audio/change_fixed.m4a',
  'Charity': 'assets/audio/charity_fixed.m4a',
  'Childhood': 'assets/audio/childhood_fixed.m4a',
  'Community': 'assets/audio/community_fixed.m4a',
  'Confidence': 'assets/audio/confidence_fixed.m4a',
  'Courage': 'assets/audio/courage_fixed.m4a',
  'Creativity & Inspiration': 'assets/audio/inspire_fixed.m4a',
  'Culture': 'assets/audio/culture_fixed.m4a',
  'Decision': 'assets/audio/decision_fixed.m4a',
  'Determination': 'assets/audio/determination_fixed.m4a',
  'Discipline': 'assets/audio/discipline_fixed.m4a',
  'Diversity': 'assets/audio/diversity_fixed.m4a',
  'Dreams': 'assets/audio/dreams_fixed.m4a',
  'Education': 'assets/audio/education_fixed.m4a',
  'Empathy': 'assets/audio/empathy_fixed.m4a',
  'Endings': 'assets/audio/endings_fixed.m4a',
  'Equality': 'assets/audio/equality_fixed.m4a',
  'Faith': 'assets/audio/faith_fixed.m4a',
  'Family': 'assets/audio/family_fixed.m4a',
  'Focus': 'assets/audio/focus_fixed.m4a',
  'Forging Ahead': 'assets/audio/progress_fixed.m4a',
  'Forgiveness': 'assets/audio/forgiveness_fixed.m4a',
  'Freedom': 'assets/audio/freedom_fixed.m4a',
  'Friendship': 'assets/audio/friendship_fixed.m4a',
  'Giving': 'assets/audio/giving_fixed.m4a',
  'Gratitude': 'assets/audio/gratitude_fixed.m4a',
  'Growth': 'assets/audio/growth_fixed.m4a',
  'Hard Work': 'assets/audio/hardwork_fixed.m4a',
  'Happiness & Joy': 'assets/audio/happy_fixed.m4a',
  'Health': 'assets/audio/health_fixed.m4a',
  'Honesty': 'assets/audio/honesty_fixed.m4a',
  'Hope': 'assets/audio/hope_fixed.m4a',
  'Humility': 'assets/audio/humility_fixed.m4a',
  'Humor': 'assets/audio/humor_fixed.m4a',
  'Imagination': 'assets/audio/imagination_fixed.m4a',
  'Inclusion': 'assets/audio/inclusion_fixed.m4a',
  'Innovation': 'assets/audio/innovation_fixed.m4a',
  'Integrity': 'assets/audio/integrity_fixed.m4a',
  'Justice': 'assets/audio/justice_fixed.m4a',
  'Kindness': 'assets/audio/kindness_fixed.m4a',
  'Leadership': 'assets/audio/leadership_fixed.m4a',
  'Learning': 'assets/audio/learning_fixed.m4a',
  'Legacy': 'assets/audio/legacy_fixed.m4a',
  'Life': 'assets/audio/life_fixed.m4a',
  'Listening': 'assets/audio/listening_fixed.m4a',
  'Love': 'assets/audio/love_fixed.m4a',
  'Memories': 'assets/audio/memories_fixed.m4a',
  'Mindfulness': 'assets/audio/mindfulness_fixed.m4a',
  'Mindfulness & Letting Go': 'assets/audio/meditation_fixed.m4a',
  'Mindset': 'assets/audio/mindset_fixed.m4a',
  'Motivation & Achievement': 'assets/audio/motivation_fixed.m4a',
  'Music': 'assets/audio/music_fixed.m4a',
  'Natural': 'assets/audio/natural_fixed.m4a',
  'New Beginnings': 'assets/audio/newbeginnings_fixed.m4a',
  'Opportunity': 'assets/audio/opportunity_fixed.m4a',
  'Overcoming Obstacles': 'assets/audio/overcomingobstacles_fixed.m4a',
  'Parenting': 'assets/audio/parenting_fixed.m4a',
  'Passion': 'assets/audio/passion_fixed.m4a',
  'Patience': 'assets/audio/patience_fixed.m4a',
  'Peace': 'assets/audio/peace_fixed.m4a',
  'Peace & Inner Calm': 'assets/audio/peace_inner_fixed.m4a',
  'Perseverance': 'assets/audio/perseverance_fixed.m4a',
  'Philosophy': 'assets/audio/philosophy_fixed.m4a',
  'Positivity': 'assets/audio/positivity_fixed.m4a',
  'Prosperity': 'assets/audio/prosperity_fixed.m4a',
  'Purpose': 'assets/audio/purpose_fixed.m4a',
  'Reflection': 'assets/audio/reflection_fixed.m4a',
  'Relationships & Connection': 'assets/audio/relationships_fixed.m4a',
  'Resilience': 'assets/audio/resilience_fixed.m4a',
  'Responsibility': 'assets/audio/responsibility_fixed.m4a',
  'Risk': 'assets/audio/risk_fixed.m4a',
  'Sacrifice': 'assets/audio/sacrifice_fixed.m4a',
  'Self-Discovery': 'assets/audio/selfdiscovery_fixed.m4a',
  'Self-Improvement': 'assets/audio/selfimprovement_fixed.m4a',
  'Self-Love': 'assets/audio/selflove_fixed.m4a',
  'Service': 'assets/audio/service_fixed.m4a',
  'Silence': 'assets/audio/silence_fixed.m4a',
  'Simplicity': 'assets/audio/simplicity_fixed.m4a',
  'Sincerity': 'assets/audio/sincerity_fixed.m4a',
  'Spirituality': 'assets/audio/spirituality_fixed.m4a',
  'Strength': 'assets/audio/strength_fixed.m4a',
  'Success': 'assets/audio/success_fixed.m4a',
  'Teamwork': 'assets/audio/teamwork_fixed.m4a',
  'Time': 'assets/audio/time_fixed.m4a',
  'Travel': 'assets/audio/travel_fixed.m4a',
  'Trust': 'assets/audio/trust_fixed.m4a',
  'Value': 'assets/audio/value_fixed.m4a',
  'Vision': 'assets/audio/vision_fixed.m4a',
  'Wealth': 'assets/audio/wealth_fixed.m4a',
  'Wellness': 'assets/audio/wellness_fixed.m4a',
  'Wisdom': 'assets/audio/wisdom_fixed.m4a',
  'Wisdom of Age': 'assets/audio/wisdomage_fixed.m4a',
  'Worry & Anxiety': 'assets/audio/calm_fixed.m4a',
  'Youth': 'assets/audio/youth_fixed.m4a',
  'Uncategorized': 'assets/audio/abstract_fixed.m4a',
};


const Map<String, String> _categoryEmoji = {
  'All': '🌸',
  'Action': '⚡️',
  'Adventure': '🏔️',
  'Art': '🖼️',
  'Balance': '🤹',
  'Belief': '🙌',
  'Change': '🔄',
  'Charity': '🎁',
  'Childhood': '🧸',
  'Community': '🏘️',
  'Confidence': '😎',
  'Courage': '🦁',
  'Creativity & Inspiration': '🎨',
  'Culture': '🎭',
  'Decision': '🔀',
  'Determination': '⛰️',
  'Discipline': '🥋',
  'Diversity': '🌈',
  'Dreams': '🌙',
  'Education': '🎓',
  'Empathy': '💗',
  'Endings': '🌇',
  'Equality': '🟰',
  'Faith': '🕍',
  'Family': '👨‍👩‍👧‍👦',
  'Focus': '🧐',
  'Forging Ahead': '🚀',
  'Forgiveness': '🫂',
  'Freedom': '🗽',
  'Friendship': '👫',
  'Giving': '💝',
  'Gratitude': '🙏',
  'Growth': '🌿',
  'Hard Work': '💪',
  'Happiness & Joy': '😊',
  'Health': '🍎',
  'Hope': '🌅',
  'Honesty': '🪞',
  'Humility': '🪶',
  'Humor': '😂',
  'Imagination': '🦋',
  'Inclusion': '🧑‍🤝‍🧑',
  'Innovation': '💡',
  'Integrity': '🦾',
  'Justice': '⚖️',
  'Kindness': '🤗',
  'Leadership': '👑',
  'Learning': '📖',
  'Legacy': '🏛️',
  'Life': '🌱',
  'Listening': '👂',
  'Love': '💖',
  'Memories': '📷',
  'Mindfulness': '🧘',
  'Mindfulness & Letting Go': '🍃',
  'Mindset': '🧠',
  'Motivation & Achievement': '🏆',
  'Music': '🎵',
  'Natural': '🌳',
  'New Beginnings': '🥚',
  'Opportunity': '🪟',
  'Overcoming Obstacles': '⛷️',
  'Parenting': '🧑‍🍼',
  'Passion': '🔥',
  'Patience': '⏳',
  'Peace': '🕊️',
  'Peace & Inner Calm': '☮️',
  'Perseverance': '🛤️',
  'Philosophy': '📜',
  'Positivity': '🌞',
  'Prosperity': '🪙',
  'Purpose': '🎯',
  'Reflection': '🔮',
  'Relationships & Connection': '💞',
  'Resilience': '🌵',
  'Responsibility': '🧑‍💼',
  'Risk': '🎲',
  'Sacrifice': '⚰️',
  'Self-Discovery': '🧭',
  'Self-Improvement': '🔝',
  'Self-Love': '💓',
  'Service': '🧹',
  'Silence': '🔇',
  'Simplicity': '🔹',
  'Sincerity': '🫶',
  'Spirituality': '🕉️',
  'Strength': '🦾',
  'Success': '🏅',
  'Teamwork': '🤼',
  'Time': '⏰',
  'Travel': '✈️',
  'Trust': '🗝️',
  'Unity': '🔗',
  'Value': '💎',
  'Vision': '🔭',
  'Wealth': '💸',
  'Wellness': '🥦',
  'Wisdom': '🦉',
  'Wisdom of Age': '👵',
  'Worry & Anxiety': '😟',
  'Youth': '🧑',
  'Uncategorized': '✨',
};


const supportedLangs = [
  {'code': 'af', 'name': 'Afrikaans'},
  {'code': 'ak', 'name': 'Akan'},
  {'code': 'sq', 'name': 'Albanian'},
  {'code': 'am', 'name': 'Amharic'},
  {'code': 'ar', 'name': 'Arabic'},
  {'code': 'hy', 'name': 'Armenian'},
  {'code': 'as', 'name': 'Assamese'},
  {'code': 'ay', 'name': 'Aymara'},
  {'code': 'az', 'name': 'Azerbaijani'},
  {'code': 'bm', 'name': 'Bambara'},
  {'code': 'eu', 'name': 'Basque'},
  {'code': 'be', 'name': 'Belarusian'},
  {'code': 'bn', 'name': 'Bengali'},
  {'code': 'bho', 'name': 'Bhojpuri'},
  {'code': 'bs', 'name': 'Bosnian'},
  {'code': 'bg', 'name': 'Bulgarian'},
  {'code': 'ca', 'name': 'Catalan'},
  {'code': 'ceb', 'name': 'Cebuano'},
  {'code': 'ny', 'name': 'Chichewa'},
  {'code': 'zh-CN', 'name': 'Chinese (Simplified)'},
  {'code': 'zh-TW', 'name': 'Chinese (Traditional)'},
  {'code': 'co', 'name': 'Corsican'},
  {'code': 'hr', 'name': 'Croatian'},
  {'code': 'cs', 'name': 'Czech'},
  {'code': 'da', 'name': 'Danish'},
  {'code': 'dv', 'name': 'Divehi'},
  {'code': 'doi', 'name': 'Dogri'},
  {'code': 'nl', 'name': 'Dutch'},
  {'code': 'en', 'name': 'English'},
  {'code': 'eo', 'name': 'Esperanto'},
  {'code': 'et', 'name': 'Estonian'},
  {'code': 'ee', 'name': 'Ewe'},
  {'code': 'fil', 'name': 'Filipino'},
  {'code': 'fi', 'name': 'Finnish'},
  {'code': 'fr', 'name': 'French'},
  {'code': 'fy', 'name': 'Frisian'},
  {'code': 'gl', 'name': 'Galician'},
  {'code': 'lg', 'name': 'Ganda'},
  {'code': 'ka', 'name': 'Georgian'},
  {'code': 'de', 'name': 'German'},
  {'code': 'el', 'name': 'Greek'},
  {'code': 'gn', 'name': 'Guarani'},
  {'code': 'gu', 'name': 'Gujarati'},
  {'code': 'ht', 'name': 'Haitian Creole'},
  {'code': 'ha', 'name': 'Hausa'},
  {'code': 'haw', 'name': 'Hawaiian'},
  {'code': 'he', 'name': 'Hebrew'},
  {'code': 'hi', 'name': 'Hindi'},
  {'code': 'hmn', 'name': 'Hmong'},
  {'code': 'hu', 'name': 'Hungarian'},
  {'code': 'is', 'name': 'Icelandic'},
  {'code': 'ig', 'name': 'Igbo'},
  {'code': 'ilo', 'name': 'Iloko'},
  {'code': 'id', 'name': 'Indonesian'},
  {'code': 'ga', 'name': 'Irish'},
  {'code': 'it', 'name': 'Italian'},
  {'code': 'ja', 'name': 'Japanese'},
  {'code': 'jv', 'name': 'Javanese'},
  {'code': 'kn', 'name': 'Kannada'},
  {'code': 'kk', 'name': 'Kazakh'},
  {'code': 'km', 'name': 'Khmer'},
  {'code': 'rw', 'name': 'Kinyarwanda'},
  {'code': 'ko', 'name': 'Korean'},
  {'code': 'kri', 'name': 'Krio'},
  {'code': 'ku', 'name': 'Kurdish'},
  {'code': 'ckb', 'name': 'Kurdish (Sorani)'},
  {'code': 'ky', 'name': 'Kyrgyz'},
  {'code': 'lo', 'name': 'Lao'},
  {'code': 'la', 'name': 'Latin'},
  {'code': 'lv', 'name': 'Latvian'},
  {'code': 'ln', 'name': 'Lingala'},
  {'code': 'lt', 'name': 'Lithuanian'},
  {'code': 'lb', 'name': 'Luxembourgish'},
  {'code': 'mk', 'name': 'Macedonian'},
  {'code': 'mai', 'name': 'Maithili'},
  {'code': 'mg', 'name': 'Malagasy'},
  {'code': 'ms', 'name': 'Malay'},
  {'code': 'ml', 'name': 'Malayalam'},
  {'code': 'mt', 'name': 'Maltese'},
  {'code': 'mi', 'name': 'Maori'},
  {'code': 'mr', 'name': 'Marathi'},
  {'code': 'mni-Mtei', 'name': 'Meiteilon (Manipuri)'},
  {'code': 'lus', 'name': 'Mizo'},
  {'code': 'mn', 'name': 'Mongolian'},
  {'code': 'my', 'name': 'Myanmar (Burmese)'},
  {'code': 'ne', 'name': 'Nepali'},
  {'code': 'no', 'name': 'Norwegian'},
  {'code': 'or', 'name': 'Odia (Oriya)'},
  {'code': 'om', 'name': 'Oromo'},
  {'code': 'ps', 'name': 'Pashto'},
  {'code': 'fa', 'name': 'Persian'},
  {'code': 'pl', 'name': 'Polish'},
  {'code': 'pt', 'name': 'Portuguese'},
  {'code': 'pa', 'name': 'Punjabi'},
  {'code': 'qu', 'name': 'Quechua'},
  {'code': 'ro', 'name': 'Romanian'},
  {'code': 'ru', 'name': 'Russian'},
  {'code': 'sm', 'name': 'Samoan'},
  {'code': 'sa', 'name': 'Sanskrit'},
  {'code': 'gd', 'name': 'Scots Gaelic'},
  {'code': 'nso', 'name': 'Sepedi'},
  {'code': 'sr', 'name': 'Serbian'},
  {'code': 'st', 'name': 'Sesotho'},
  {'code': 'sn', 'name': 'Shona'},
  {'code': 'sd', 'name': 'Sindhi'},
  {'code': 'si', 'name': 'Sinhala'},
  {'code': 'sk', 'name': 'Slovak'},
  {'code': 'sl', 'name': 'Slovenian'},
  {'code': 'so', 'name': 'Somali'},
  {'code': 'es', 'name': 'Spanish'},
  {'code': 'su', 'name': 'Sundanese'},
  {'code': 'sw', 'name': 'Swahili'},
  {'code': 'sv', 'name': 'Swedish'},
  {'code': 'tg', 'name': 'Tajik'},
  {'code': 'ta', 'name': 'Tamil'},
  {'code': 'tt', 'name': 'Tatar'},
  {'code': 'te', 'name': 'Telugu'},
  {'code': 'th', 'name': 'Thai'},
  {'code': 'bo', 'name': 'Tibetan'},
  {'code': 'ti', 'name': 'Tigrinya'},
  {'code': 'ts', 'name': 'Tsonga'},
  {'code': 'tr', 'name': 'Turkish'},
  {'code': 'tk', 'name': 'Turkmen'},
  {'code': 'uk', 'name': 'Ukrainian'},
  {'code': 'ur', 'name': 'Urdu'},
  {'code': 'ug', 'name': 'Uyghur'},
  {'code': 'uz', 'name': 'Uzbek'},
  {'code': 'vi', 'name': 'Vietnamese'},
  {'code': 'cy', 'name': 'Welsh'},
  {'code': 'xh', 'name': 'Xhosa'},
  {'code': 'yi', 'name': 'Yiddish'},
  {'code': 'yo', 'name': 'Yoruba'},
  {'code': 'zu', 'name': 'Zulu'},
];
// Your key utility and getX helpers here (unchanged)
const kQuoteKey = 'quote';
const kAuthorKey = 'author';
const kCategory = 'category';

// FAVORITES SCREEN
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final CollectionReference _favCol;
  late final StreamSubscription<QuerySnapshot> _sub;
  List<QueryDocumentSnapshot> _all = [];
  List<QueryDocumentSnapshot> _filtered = [];
  String _searchQuery = '';
  bool _loading = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingDocId;

  String _preferredLanguage = 'en';
  late final GoogleTranslationService _googleTranslator;
  Map<String, Map<String, String>> _translations = {};

  final GlobalKey _shareCardKey = GlobalKey();
  Map<String, dynamic>? _pendingShareData;

  static const _uiKeys = {
    'favorites': 'Favorites',
    'searchHint': 'Search favorites…',
    'noFavorites': 'No favorites found.',
    'playMusic': 'Play Music',
    'pauseMusic': 'Pause Music',
    'shareImage': 'Share Image',
    'shareVideo': 'Share Video',
    'record': 'Record',
    'delete': 'Delete',
  };

  Future<String> _tr(String key) async => _translate(_uiKeys[key]!);

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    print('DEBUG: Current FirebaseAuth UID: $uid');
    _favCol = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');
    print('DEBUG: Firestore path: /users/$uid/favorites');
    _sub = _favCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snap) {
            _all = snap.docs;
            print('DEBUG: All favorites fetched: $_all');
            for (var doc in _all) {
              print('DEBUG: Favorite doc: ${doc.data()}');
              print('DEBUG: imageUrl for doc: ${getImageUrl(doc.data() as Map<String, dynamic>)}');
            }
            _applyFilter();
            setState(() => _loading = false);
          },
          onError: (e) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading favorites: $e')),
            );
            print('DEBUG: Error loading favorites: $e');
          },
        );
    _fetchLanguage();
    _googleTranslator = GoogleTranslationService(
      apiKey: 'AIzaSyC2T82ER-8u1X3Z7UKF6F4tPBdkCo4sXlY',
    );
  }

  Future<void> _fetchLanguage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('prefs')
          .get();
      setState(() {
        _preferredLanguage = snap.data()?['preferredLanguage'] ?? 'en';
      });
      print('DEBUG: Loaded preferred language: $_preferredLanguage');
    } catch (_) {
      setState(() {
        _preferredLanguage = 'en';
      });
      print('DEBUG: Could not load preferred language, defaulting to en');
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String txt) {
    _searchQuery = txt.trim().toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_all);
    } else {
      _filtered = _all.where((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        final quote = getQuote(data).toLowerCase();
        final author = getAuthor(data).toLowerCase();
        final category = getCategory(data).toLowerCase();
        return quote.contains(_searchQuery) ||
            author.contains(_searchQuery) ||
            category.contains(_searchQuery);
      }).toList();
    }
    setState(() {});
  }

  Future<String> _translate(String text) async {
    final lang = _preferredLanguage;
    if (lang == 'en' || text.trim().isEmpty) return text;
    if (_translations[lang]?.containsKey(text) == true) {
      return _translations[lang]![text]!;
    }
    try {
      final t = await _googleTranslator.translate(
        text: text,
        targetLang: lang,
      );
      _translations.putIfAbsent(lang, () => {})[text] = t;
      return t;
    } catch (e) {
      debugPrint("DEBUG: Translation error: $e");
      return text;
    }
  }

  Future<Uint8List?> _captureShareCard() async {
    try {
      final boundary = _shareCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('DEBUG: Error capturing share card: $e');
      return null;
    }
  }

  Future<File> _generateVideoWithPngFrame({
    required String imagePath,
    required String audioAsset,
  }) async {
    final tmp = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final audioData = await rootBundle.load(audioAsset);
    final audioFile = File('${tmp.path}/audio_$ts.wav')
      ..writeAsBytesSync(audioData.buffer.asUint8List());
    final output = '${tmp.path}/video_$ts.mp4';

    final player = AudioPlayer();
    await player.setFilePath(audioFile.path);
    final duration = await player.duration ?? const Duration(seconds: 5);
    await player.dispose();
    final videoSeconds = duration.inSeconds;
    final videoLength = videoSeconds + 2;

    final args = [
      '-y',
      '-loop', '1',
      '-framerate', '30',
      '-t', '$videoLength',
      '-i', imagePath,
      '-i', audioFile.path,
      '-c:v', 'libx264',
      '-vf', 'scale=720:1280,fade=t=out:st=$videoSeconds:d=2,format=yuv420p',
      '-preset', 'ultrafast',
      '-pix_fmt', 'yuv420p',
      '-tune', 'stillimage',
      '-c:a', 'aac',
      '-b:a', '192k',
      '-shortest',
      output,
    ];
    final session = await FFmpegKit.executeWithArguments(args);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg failed: $logs');
    }
    final file = File(output);
    if (!file.existsSync()) throw Exception('FFmpeg output file not found');
    return file;
  }

  Future<void> _addToSharedMedia({
    required String type,
    required String url,
    required String quote,
    required String author,
    required String userName,
    required String category,
    required String language,
    required int randomSeed,
    String? thumbnail,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {
      'type': type,
      'url': url,
      'thumbnail': thumbnail ?? '',
      'quote': quote,
      'author': author,
      'userName': userName,
      'category': category,
      'language': language,
      'randomSeed': randomSeed,
      'uploadedAt': FieldValue.serverTimestamp(),
      'userId': user.uid, // Always store userId for security rule compliance!
    };

    print('DEBUG: Favorite to add: $data');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sharedMedia')
        .add(data);
  }

  Future<void> _shareFavoriteCard({
    required String quote,
    required String author,
    required String userName,
    required String imageUrl,
    required String category,
    required String docId,
  }) async {
    final emoji = _categoryEmoji[category] ?? '';
    final emojiSeed = docId.hashCode;
    final q = await _translate(quote);
    final a = await _translate(author);

    _pendingShareData = {
      'quote': q,
      'author': a,
      'userName': userName,
      'imageUrl': imageUrl,
      'emoji': emoji,
      'category': category,
      'language': _preferredLanguage,
      'randomSeed': emojiSeed,
      'animationsEnabled': false,
    };
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 120));
    final pngBytes = await _captureShareCard();
    _pendingShareData = null;
    setState(() {});
    if (pngBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't capture share card.")),
      );
      return;
    }
    final tmp = await getTemporaryDirectory();
    final path = '${tmp.path}/fav_share_card_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path)..writeAsBytesSync(pngBytes);

    await _addToSharedMedia(
      type: 'image',
      url: file.path,
      quote: q,
      author: a,
      userName: userName,
      category: category,
      language: _preferredLanguage,
      randomSeed: emojiSeed,
    );

    await Share.shareXFiles([XFile(file.path)], text: '"$q"\n- $a');
  }

  Future<void> _shareFavoriteVideo({
    required String quote,
    required String author,
    required String userName,
    required String imageUrl,
    required String category,
    required String docId,
  }) async {
    final emoji = _categoryEmoji[category] ?? '';
    final emojiSeed = docId.hashCode;
    final q = await _translate(quote);
    final a = await _translate(author);
    final audioAsset = _categoryAudio[category] ?? _categoryAudio['All']!;

    _pendingShareData = {
      'quote': q,
      'author': a,
      'userName': userName,
      'imageUrl': imageUrl,
      'emoji': emoji,
      'category': category,
      'language': _preferredLanguage,
      'randomSeed': emojiSeed,
      'animationsEnabled': false,
    };
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 120));
    final pngBytes = await _captureShareCard();
    _pendingShareData = null;
    setState(() {});
    if (pngBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't capture share card image.")),
      );
      return;
    }
    final tmp = await getTemporaryDirectory();
    final pngPath = '${tmp.path}/fav_card_video_${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File(pngPath)..writeAsBytesSync(pngBytes);

    try {
      final videoFile = await _generateVideoWithPngFrame(
        imagePath: imgFile.path,
        audioAsset: audioAsset,
      );

      await _addToSharedMedia(
        type: 'video',
        url: videoFile.path,
        thumbnail: imgFile.path,
        quote: q,
        author: a,
        userName: userName,
        category: category,
        language: _preferredLanguage,
        randomSeed: emojiSeed,
      );

      await Share.shareXFiles(
        [XFile(videoFile.path)],
        text: '"$q"\n- $a',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Video share failed: $e")),
      );
    }
  }

  Future<void> _deleteFavorite(String docId) async {
    await _favCol.doc(docId).delete();
    _all.removeWhere((d) => d.id == docId);
    _applyFilter();
  }

  Future<void> _togglePlay(String docId, String category) async {
    if (_playingDocId == docId) {
      await _audioPlayer.stop();
      setState(() => _playingDocId = null);
      return;
    }
    final asset = _categoryAudio[category] ?? _categoryAudio['All']!;
    try {
      await _audioPlayer.setAsset(asset);
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
      setState(() => _playingDocId = docId);
    } catch (e) {
      debugPrint('DEBUG: Audio error: $e');
    }
  }

  Widget _buildSearchField() {
    return FutureBuilder<String>(
      future: _tr('searchHint'),
      builder: (ctx, snap) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade300, Colors.pink.shade700],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black45)],
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: snap.data ?? _uiKeys['searchHint'],
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  static const TextStyle kWhiteQuoteTextStyle = TextStyle(
    fontSize: 28,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    shadows: [
      Shadow(blurRadius: 3, color: Colors.black, offset: Offset(2, 2)),
    ],
  );
  static const TextStyle kWhiteAuthorTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontStyle: FontStyle.italic,
    fontFamily: 'Roboto',
    shadows: [
      Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            elevation: 4,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
            ),
            title: FutureBuilder<String>(
              future: _tr('favorites'),
              builder: (context, snap) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  snap.data ?? _uiKeys['favorites'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchField(),
              ),
            ),
          ),
          body: _loading
              ? const Center(
                  child: SpinKitFadingCircle(color: Colors.deepPurple),
                )
              : _filtered.isEmpty
                  ? FutureBuilder<String>(
                      future: _tr('noFavorites'),
                      builder: (ctx, snap) => Center(
                        child: Text(
                          snap.data ?? _uiKeys['noFavorites'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontFamily: 'NotoSansDevanagari',
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final doc = _filtered[i];
                        final data = doc.data()! as Map<String, dynamic>;
                        final quoteText = getQuote(data);
                        final authorText = getAuthor(data);
                        final category = getCategory(data);
                        final imageUrl = getImageUrl(data);

                        print('DEBUG: Favorite card - docId: ${doc.id}, quote: $quoteText, author: $authorText, category: $category, imageUrl: $imageUrl');

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: SizedBox(
                            height: 240,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FavoriteDetailScreen(
                                          docId: doc.id,
                                          quote: quoteText,
                                          author: authorText,
                                          category: category,
                                          imageUrl: imageUrl,
                                          userName: '', // Add userName if you store it
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          if ((imageUrl).isNotEmpty)
                                            Positioned.fill(
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) =>
                                                    Container(
                                                  color: Colors.grey.shade900,
                                                ),
                                                errorWidget: (_, __, ___) =>
                                                    Container(
                                                  color: Colors.grey.shade900,
                                                ),
                                              ),
                                            ),
                                          Positioned.fill(
                                            child: Container(
                                              color: Colors.black.withOpacity(0.6),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: (_categoryEmoji[category]?.isNotEmpty ?? false)
                                                  ? NonIntrusiveEmojiRain(
                                                      emoji: _categoryEmoji[category] ?? '',
                                                      randomSeed: doc.id.hashCode,
                                                      count: 18,
                                                      duration: const Duration(seconds: 30),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      _categoryEmoji[category] ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 28,
                                                        color: Colors.white,
                                                        shadows: [
                                                          Shadow(
                                                            blurRadius: 2,
                                                            color: Colors.black,
                                                            offset: Offset(1, 1),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 30,
                                                        child: FutureBuilder<String>(
                                                          future: _translate(category),
                                                          builder: (context, snap) => SingleChildScrollView(
                                                            scrollDirection: Axis.horizontal,
                                                            child: Text(
                                                              snap.data ?? category,
                                                              style: const TextStyle(
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                                fontFamily: 'Roboto',
                                                                shadows: [
                                                                  Shadow(
                                                                    blurRadius: 2,
                                                                    color: Colors.black,
                                                                    offset: Offset(1, 1),
                                                                  ),
                                                                ],
                                                              ),
                                                              overflow: TextOverflow.visible,
                                                              softWrap: false,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    FutureBuilder<String>(
                                                      future: _tr(_playingDocId == doc.id ? 'pauseMusic' : 'playMusic'),
                                                      builder: (ctx, snap) => IconButton(
                                                        icon: Icon(
                                                          _playingDocId == doc.id
                                                              ? Icons.pause_circle_filled
                                                              : Icons.play_circle_fill,
                                                          color: Colors.white,
                                                          size: 24,
                                                        ),
                                                        tooltip: snap.data ?? (_playingDocId == doc.id ? 'Pause Music' : 'Play Music'),
                                                        onPressed: () => _togglePlay(doc.id, category),
                                                        splashRadius: 20,
                                                      ),
                                                    ),
                                                    FutureBuilder<String>(
                                                      future: _tr('shareImage'),
                                                      builder: (ctx, snap) => IconButton(
                                                        icon: const Icon(Icons.share, color: Colors.white, size: 22),
                                                        tooltip: snap.data ?? 'Share Image',
                                                        onPressed: () async {
                                                          await _shareFavoriteCard(
                                                            quote: quoteText,
                                                            author: authorText,
                                                            userName: '',
                                                            imageUrl: imageUrl,
                                                            category: category,
                                                            docId: doc.id,
                                                          );
                                                        },
                                                        splashRadius: 20,
                                                      ),
                                                    ),
                                                    FutureBuilder<String>(
                                                      future: _tr('shareVideo'),
                                                      builder: (ctx, snap) => IconButton(
                                                        icon: const Icon(Icons.videocam, color: Colors.white, size: 22),
                                                        tooltip: snap.data ?? 'Share Video',
                                                        onPressed: () async {
                                                          await _shareFavoriteVideo(
                                                            quote: quoteText,
                                                            author: authorText,
                                                            userName: '',
                                                            imageUrl: imageUrl,
                                                            category: category,
                                                            docId: doc.id,
                                                          );
                                                        },
                                                        splashRadius: 20,
                                                      ),
                                                    ),
                                                    FutureBuilder<String>(
                                                      future: _tr('record'),
                                                      builder: (ctx, snap) => IconButton(
                                                        icon: const Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 22),
                                                        tooltip: snap.data ?? 'Record',
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) => RecordScreen(
                                                                quote: quoteText,
                                                                author: authorText,
                                                                userName: '',
                                                                imageUrl: imageUrl,
                                                                emoji: _categoryEmoji[category] ?? '',
                                                                category: category,
                                                                language: _preferredLanguage,
                                                                randomSeed: doc.id.hashCode,
                                                                animationsEnabled: true,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        splashRadius: 20,
                                                      ),
                                                    ),
                                                    FutureBuilder<String>(
                                                      future: _tr('delete'),
                                                      builder: (ctx, snap) => IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.white, size: 22),
                                                        tooltip: snap.data ?? 'Delete',
                                                        onPressed: () => _deleteFavorite(doc.id),
                                                        splashRadius: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        FutureBuilder<String>(
                                                          future: _translate(quoteText),
                                                          builder: (context, snap) => Text(
                                                            '"${snap.data ?? quoteText}"',
                                                            style: kWhiteQuoteTextStyle,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 12),
                                                        FutureBuilder<String>(
                                                          future: _translate(authorText),
                                                          builder: (context, snap) => Text(
                                                            '- ${snap.data ?? authorText} -',
                                                            style: kWhiteAuthorTextStyle,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
        Offstage(
          offstage: _pendingShareData == null,
          child: RepaintBoundary(
            key: _shareCardKey,
            child: _pendingShareData == null
                ? const SizedBox.shrink()
                : QuoteShareFullDetailCard(
                    quote: _pendingShareData!['quote'],
                    author: _pendingShareData!['author'],
                    imageUrl: _pendingShareData!['imageUrl'],
                    
                    category: _pendingShareData!['category'],
                    language: _pendingShareData!['language'],
                  ),
          ),
        ),
      ],
    );
  }
}
