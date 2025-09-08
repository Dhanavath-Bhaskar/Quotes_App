import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/return_code.dart';
import '../widgets/non_intrusive_emoji_rain.dart';
import '../widgets/quote_full_screen_for_share.dart';
import 'record_screen.dart';
import '../services/google_translation_service.dart';

// --- Your _categoryAudio, _categoryEmoji, supportedLangs etc. constants here ---
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


// ---------------------
// CATEGORY EMOJI
// ---------------------
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

// ---------------------
// SUPPORTED LANGUAGES
// ---------------------
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



class FavoriteDetailScreen extends StatefulWidget {
  final String docId;
  final String quote;
  final String author;
  final String category;
  final String imageUrl;
  final String userName;

  const FavoriteDetailScreen({
    Key? key,
    required this.docId,
    required this.quote,
    required this.author,
    required this.category,
    required this.imageUrl,
    required this.userName,
  }) : super(key: key);

  @override
  State<FavoriteDetailScreen> createState() => _FavoriteDetailScreenState();
}

class _FavoriteDetailScreenState extends State<FavoriteDetailScreen> {
  final GlobalKey _shareCardKey = GlobalKey();

  final GoogleTranslationService _googleTranslator = GoogleTranslationService(
    apiKey: 'AIzaSyC2T82ER-8u1X3Z7UKF6F4tPBdkCo4sXlY',
  );

  late final String _userId;
  late final CollectionReference _favCol;

  bool _loadingFavorite = true;
  bool _isFavorite = true; // since this is already in favorites
  bool _translating = false;
  String _preferredLanguage = 'en';
  Map<String, String> _ui = {};

  String _uiTitle = 'Favorite Detail';
  String _uiShareImage = 'Share Image';
  String _uiShareVideo = 'Share Video';
  String _uiRecord = 'Record';
  String _uiRemoveFromFav = 'Remove from Favorites';

  Map<String, dynamic>? _pendingShareData;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid ?? '';
    _favCol = FirebaseFirestore.instance.collection('users').doc(_userId).collection('favorites');
    _ui = {
      'quote': widget.quote,
      'author': widget.author,
      'category': widget.category,
    };
    _fetchAndApplyLanguage();
  }

  Future<void> _fetchAndApplyLanguage() async {
    String lang = 'en';
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('prefs')
          .get();
      lang = snap.data()?['preferredLanguage'] ?? 'en';
    } catch (_) {}
    await _updateLanguageAndTranslateUI(lang);
  }

  Future<void> _updateLanguageAndTranslateUI(String lang) async {
    if (lang == _preferredLanguage && _uiTitle != 'Favorite Detail') return;
    setState(() {
      _translating = true;
      _preferredLanguage = lang;
    });
    if (lang == 'en') {
      setState(() {
        _uiTitle = 'Favorite Detail';
        _uiShareImage = 'Share Image';
        _uiShareVideo = 'Share Video';
        _uiRecord = 'Record';
        _uiRemoveFromFav = 'Remove from Favorites';
        _ui['quote'] = widget.quote;
        _ui['author'] = widget.author;
        _ui['category'] = widget.category;
      });
    } else {
      try {
        final results = await Future.wait([
          _googleTranslator.translate(text: 'Favorite Detail', targetLang: lang),
          _googleTranslator.translate(text: 'Share Image', targetLang: lang),
          _googleTranslator.translate(text: 'Share Video', targetLang: lang),
          _googleTranslator.translate(text: 'Record', targetLang: lang),
          _googleTranslator.translate(text: 'Remove from Favorites', targetLang: lang),
          _googleTranslator.translate(text: widget.quote, targetLang: lang),
          _googleTranslator.translate(text: widget.author, targetLang: lang),
          _googleTranslator.translate(text: widget.category, targetLang: lang),
        ]);
        setState(() {
          _uiTitle = results[0];
          _uiShareImage = results[1];
          _uiShareVideo = results[2];
          _uiRecord = results[3];
          _uiRemoveFromFav = results[4];
          _ui['quote'] = results[5];
          _ui['author'] = results[6];
          _ui['category'] = results[7];
        });
      } catch (e) {
        setState(() {
          _uiTitle = 'Favorite Detail';
          _uiShareImage = 'Share Image';
          _uiShareVideo = 'Share Video';
          _uiRecord = 'Record';
          _uiRemoveFromFav = 'Remove from Favorites';
          _ui['quote'] = widget.quote;
          _ui['author'] = widget.author;
          _ui['category'] = widget.category;
        });
      }
    }
    setState(() {
      _translating = false;
    });
  }

  Future<Uint8List?> _captureCardToPng() async {
    final boundary = _shareCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
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
    final args = [
      '-y',
      '-loop', '1',
      '-i', imagePath,
      '-i', audioFile.path,
      '-c:v', 'libx264',
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

  Future<String> _uploadFileToFirebaseStorage(File file, String fileName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user');
    final ref = FirebaseStorage.instance.ref().child('users/${user.uid}/shared_media/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _saveSharedMediaToFirestore({
    required String type,
    required String url,
    required String quote,
    required String author,
    required String category,
    String? userName,
    String? language,
    String? imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final now = DateTime.now();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sharedMedia')
        .add({
      'type': type,
      'quote': quote,
      'author': author,
      'category': category,
      'userName': userName ?? '',
      'language': language ?? 'en',
      'url': url,
      'imageUrl': imageUrl ?? '',
      'uploadedAt': now,
    });
  }

  Future<void> _shareAsImage() async {
    final emoji = (_categoryEmoji[widget.category] ?? '');
    _pendingShareData = {
      'quote': _ui['quote'],
      'author': _ui['author'],
      'imageUrl': widget.imageUrl,
      'emoji': emoji,
      'category': _ui['category'],
      'language': _preferredLanguage,
      'animationsEnabled': false,
    };
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 120));
    final pngBytes = await _captureCardToPng();
    _pendingShareData = null;
    setState(() {});
    if (pngBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't capture image.")));
      return;
    }
    final tmp = await getTemporaryDirectory();
    final fileName = 'favorite_share_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tmp.path}/$fileName')..writeAsBytesSync(pngBytes);

    await Share.shareXFiles([XFile(file.path)], text: '"${_ui['quote']}"\n- ${_ui['author']}"');

    final url = await _uploadFileToFirebaseStorage(file, fileName);
    await _saveSharedMediaToFirestore(
      type: 'image',
      url: url,
      quote: _ui['quote']!,
      author: _ui['author']!,
      category: _ui['category']!,
      userName: widget.userName,
      language: _preferredLanguage,
      imageUrl: widget.imageUrl,
    );
  }

  Future<void> _shareAsVideo() async {
    final emoji = (_categoryEmoji[widget.category] ?? '');
    final audioAsset = _categoryAudio[widget.category] ?? _categoryAudio['All']!;
    _pendingShareData = {
      'quote': _ui['quote'],
      'author': _ui['author'],
      'imageUrl': widget.imageUrl,
      'emoji': emoji,
      'category': _ui['category'],
      'language': _preferredLanguage,
      'animationsEnabled': false,
    };
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 120));
    final pngBytes = await _captureCardToPng();
    _pendingShareData = null;
    setState(() {});
    if (pngBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't capture card image.")));
      return;
    }
    final tmp = await getTemporaryDirectory();
    final fileName = 'favorite_share_card_${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File('${tmp.path}/$fileName')..writeAsBytesSync(pngBytes);

    try {
      final videoFile = await _generateVideoWithPngFrame(
        imagePath: imgFile.path,
        audioAsset: audioAsset,
      );
      await Share.shareXFiles([XFile(videoFile.path)], text: '"${_ui['quote']}"\n- ${_ui['author']}"');

      final videoFileName = 'favorite_share_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final url = await _uploadFileToFirebaseStorage(videoFile, videoFileName);

      await _saveSharedMediaToFirestore(
        type: 'video',
        url: url,
        quote: _ui['quote']!,
        author: _ui['author']!,
        category: _ui['category']!,
        userName: widget.userName,
        language: _preferredLanguage,
        imageUrl: widget.imageUrl,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Video share failed: $e")));
    }
  }

  Future<void> _deleteFavorite() async {
    if (_userId.isEmpty) return;
    try {
      await _favCol.doc(widget.docId).delete();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = (_categoryEmoji[widget.category] ?? '');
    final emojiSeed = widget.docId.hashCode;

    final quoteText = _ui['quote']?.toString().trim().isNotEmpty == true ? _ui['quote']! : 'No quote available';
    final authorText = _ui['author']?.toString().trim().isNotEmpty == true ? _ui['author']! : 'Unknown';
    final categoryText = _ui['category']?.toString().trim().isNotEmpty == true ? _ui['category']! : 'Uncategorized';

    return Stack(
      children: [
        _translating
            ? const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator()),
              )
            : Scaffold(
                backgroundColor: Colors.black,
                extendBodyBehindAppBar: true,
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
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    ),
                  ),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _uiTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      tooltip: _uiShareImage,
                      onPressed: _shareAsImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.white),
                      tooltip: _uiShareVideo,
                      onPressed: _shareAsVideo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.fiber_manual_record, color: Colors.redAccent),
                      tooltip: _uiRecord,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecordScreen(
                              quote: quoteText,
                              author: authorText,
                              userName: widget.userName,
                              imageUrl: widget.imageUrl,
                              emoji: emoji,
                              category: categoryText,
                              language: _preferredLanguage,
                              randomSeed: emojiSeed,
                              animationsEnabled: true,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: _uiRemoveFromFav,
                      onPressed: _deleteFavorite,
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    if (widget.imageUrl.isNotEmpty)
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          imageBuilder: (_, prov) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: prov,
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.6),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (emoji.isNotEmpty)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: NonIntrusiveEmojiRain(
                            emoji: emoji,
                            randomSeed: emojiSeed,
                            count: 24,
                            duration: const Duration(seconds: 30),
                          ),
                        ),
                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SingleChildScrollView(
                              child: Text(
                                '"$quoteText"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontStyle: FontStyle.italic,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black87,
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '- $authorText -',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black45,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Chip(
                              label: Text(
                                categoryText,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.deepPurple.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        Offstage(
          offstage: _pendingShareData == null,
          child: RepaintBoundary(
            key: _shareCardKey,
            child: _pendingShareData == null
                ? const SizedBox.shrink()
                : QuoteFullScreenForShare(
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
