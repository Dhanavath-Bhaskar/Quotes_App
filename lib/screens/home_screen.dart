import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_new_gpl/ffmpeg_kit.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:just_audio/just_audio.dart';
import 'package:qns/screens/record_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/google_translation_service.dart';
import '../services/local_notification_service.dart';
import '../services/push_notification_service.dart';
import '../widgets/non_intrusive_emoji_rain.dart';
import '../widgets/app_drawer.dart';
import '../screens/settings_screen.dart';
import '../screens/quote_detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/shared_media_screen.dart';
import '../widgets/quote_share_full_detail_card.dart';
import '../constant.dart' as consts;
import '../utils/shared_image_store.dart';

// -- QUOTES LOADER --
class QuotesLoader {
  static List<Map<String, String>>? _quotes;
  static Future<List<Map<String, String>>> load() async {
    if (_quotes != null) return _quotes!;
    final jsonStr = await rootBundle.loadString('assets/quotes_seed.json');
    final raw = json.decode(jsonStr) as List;
    _quotes = raw
        .map((e) => {
              "kQuote": (e["kQuote"] ?? "").toString(),
              "kAuthor": (e["kAuthor"] ?? "").toString(),
              "kCategory": (e["kCategory"] ?? "").toString(),
              "imageUrl": (e["imageUrl"] ?? "").toString(),
            })
        .toList();
    return _quotes!;
  }
}

// --- CATEGORY TO PIXABAY QUERY MAP ---
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

final Map<String, String> _uiTexts = {
  'title': 'Daily Q',
  'settings': 'Settings',
  'favorites': 'Favorites',
  'flowers': 'Flower Gallery',
  'searchHint': 'Search…',
  'language': 'Language',
  'noImages': 'No images available.',
  'empty': 'No quotes found.',
  'shareImage': 'Share Image',
  'shareVideo': 'Share Video',
  'record': 'Record Screen',
  'favorite': 'Favorite',
  'pauseMusic': 'Pause music',
  'playMusic': 'Play music',
  'sharedMedia': 'Shared Media',
  'failedCaptureImage': 'Failed to capture image.',
  'failedCaptureVideo': 'Failed to capture image for video.',
  'imageDecodeFailed': 'Image decode failed.',
  'audioNotFound': 'Audio file not found!',
  'failedGenerateVideo': 'Failed to generate video!',
};

class PositionData {
  final Duration position;
  final Duration duration;
  PositionData(this.position, this.duration);
}

class HomeScreen extends StatefulWidget {
  final String? settingsCategory;
  const HomeScreen({Key? key, this.settingsCategory}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final GoogleTranslationService _googleTranslator;
  final GlobalKey _mainCardKey = GlobalKey();
  final GlobalKey _shareCardKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic>? _pendingShareData;
  late CollectionReference _favCol;
  late StreamSubscription<QuerySnapshot> _favSub;
  late DocumentReference<Map<String, dynamic>> _prefsRef;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _prefsSub;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _uploadsSub;
  late AudioPlayer _audioPlayer;

  bool _audioEnabled = true;
  bool _loading = true;
  int _pageIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<String> _categories = [];
  String _preferredLanguage = 'en';
  int? _emojiSeed;
  Set<String> _favoriteIds = {};
  List<dynamic>? _currentImages;
  final Map<String, List<dynamic>> _imagesByCategory = {};
  List<Map<String, String>> _uploadedQuotes = [];
  Map<String, Map<String, String>> _translations = {};
  List<Map<String, String>> _localQuotes = [];
  bool _isSharing = false; // Prevent duplicate share

  @override
  void initState() {
    super.initState();
    _googleTranslator = GoogleTranslationService(
      apiKey: '',
    );
    QuotesLoader.load().then((qs) {
      setState(() {
        _localQuotes = qs;
      });
    });
    PushNotificationService.initialize();
    LocalNotificationService.scheduleDailyQuoteNotification(
      hour: 8,
      minute: 0,
      category: 'All',
    );
    final allCats = _categoryAudio.keys.toSet();
    _categories = ['All', ...allCats.where((c) => c != 'Uncategorized' && c != 'All').toList()..sort()];
    _audioPlayer = AudioPlayer();
    _emojiSeed = DateTime.now().millisecondsSinceEpoch;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _favCol = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites');
      _favSub = _favCol.snapshots().listen((snap) {
        if (!mounted) return;
        setState(() => _favoriteIds = snap.docs.map((d) => d.id).toSet());
      });
      _prefsRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('settings').doc('prefs');
      _prefsSub = _prefsRef.snapshots().listen(_onPrefs);
    } else {
      _favCol = FirebaseFirestore.instance.collection('dummy');
      _prefsRef = FirebaseFirestore.instance.collection('dummy').doc();
      _favSub = const Stream<QuerySnapshot>.empty().listen((_) {});
      _prefsSub = const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty().listen((_) {});
      _startWithCategory(widget.settingsCategory);
    }
    _uploadsSub = FirebaseFirestore.instance
        .collection('quotes')
        .limit(100)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        _uploadedQuotes = snap.docs.map((doc) {
          final data = doc.data();
          if (data == null) return {
            'id': doc.id,
            'kQuote': '',
            'kAuthor': '',
            'kCategory': '',
            'imageUrl': '',
          };
          return {
            'id': doc.id,
            'kQuote': (data['kQuote'] ?? '').toString(),
            'kAuthor': (data['kAuthor'] ?? '').toString(),
            'kCategory': (data['kCategory'] ?? '').toString(),
            'imageUrl': (data['imageUrl'] ?? '').toString(),
          };
        }).toList();
      });
    });

    _translateAllUiTexts();
  }

  Future<void> _translateAllUiTexts() async {
    if (_preferredLanguage == 'en') {
      setState(() {});
      return;
    }
    for (final key in _uiTexts.keys) {
      try {
        final t = await _translate(_uiTexts[key]!);
        _uiTexts[key] = t;
      } catch (_) {}
    }
    setState(() {});
  }

  Future<String> _translate(String text) async {
    if (_preferredLanguage == 'en' || text.trim().isEmpty) return text;
    String lang = _preferredLanguage;
    if (!supportedLangs.any((l) => l['code'] == lang)) lang = 'en';
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
      debugPrint("Translation error: $e");
      return text;
    }
  }

  Future<String> _getAudioFilePath(String assetPath) async {
    final docs = await getApplicationDocumentsDirectory();
    final fileName = path.basename(assetPath);
    final filePath = path.join(docs.path, fileName);
    final file = File(filePath);
    if (!file.existsSync()) {
      final bytes = await rootBundle.load(assetPath);
      await file.writeAsBytes(bytes.buffer.asUint8List());
    }
    return filePath;
  }

  Future<void> _shareCurrentWithEmoji(List<Map<String, String>> filtered, int pageIndex, List<dynamic>? currentImages, {required BuildContext context}) async {
    if (_isSharing) return;
    _isSharing = true;
    setState(() {});
    try {
      final m = filtered[pageIndex.clamp(0, filtered.length - 1)];
      final quote = await _translate(m['kQuote'] ?? '');
      final author = await _translate(m['kAuthor'] ?? '');
      final category = m['kCategory'] ?? 'Uncategorized';
      final imgCount = _currentImages?.length ?? 0;
      final bgUrl = imgCount > 0 ? _currentImages![pageIndex % imgCount]['largeImageURL']! : '';
      final imageUrl = m['imageUrl']?.isNotEmpty == true ? m['imageUrl']! : bgUrl;
      final emoji = _categoryEmoji[category] ?? '✨';
      final language = _preferredLanguage;

      _pendingShareData = {
        'quote': quote,
        'author': author,
        'imageUrl': imageUrl,
        'emoji': emoji,
        'category': category,
        'animationsEnabled': false,
        'language': language,
        'randomSeed': 1,
      };
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 120));

      final pngBytes = await _captureShareCard();
      _pendingShareData = null;
      setState(() {});

      if (pngBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_uiTexts['failedCaptureImage']!)),
        );
        return;
      }

      final docs = await getApplicationDocumentsDirectory();
      final file = File('${docs.path}/share_${DateTime.now().millisecondsSinceEpoch}.png')
        ..writeAsBytesSync(pngBytes);

      await SharedImageStore.save({
        'quote': quote,
        'author': author,
        'imagePath': file.path,
        'category': category,
        'language': language,
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sharedMedia')
            .add({
          'type': 'image',
          'quote': quote,
          'author': author,
          'url': file.path,
          'category': category,
          'language': language,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
      }

      await Share.shareFiles([file.path], text: '"$quote"\n- $author');
    } finally {
      _isSharing = false;
      setState(() {});
    }
  }


    Future<void> _shareCurrentAsVideo(
    List<Map<String, String>> filtered,
    int pageIndex,
    List<dynamic>? currentImages, {
    required BuildContext context,
  }) async {
    if (_isSharing) return;
    _isSharing = true;
    setState(() {});
    try {
      final m = filtered[pageIndex.clamp(0, filtered.length - 1)];
      final quote = await _translate(m['kQuote'] ?? '');
      final author = await _translate(m['kAuthor'] ?? '');
      final category = m['kCategory'] ?? 'Uncategorized';
      final emoji = _categoryEmoji[category] ?? '✨';
      final language = _preferredLanguage;

      final imgCount = _currentImages?.length ?? 0;
      final bgUrl = imgCount > 0 ? _currentImages![pageIndex % imgCount]['largeImageURL']! : '';
      final imageUrl = m['imageUrl']?.isNotEmpty == true ? m['imageUrl']! : bgUrl;

      _pendingShareData = {
        'quote': quote,
        'author': author,
        'imageUrl': imageUrl,
        'emoji': emoji,
        'category': category,
        'animationsEnabled': false,
        'language': language,
        'randomSeed': 1,
      };
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 180));

      final imageBytes = await _captureShareCard();
      _pendingShareData = null;
      setState(() {});

      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_uiTexts['failedCaptureVideo']!)),
        );
        return;
      }

      final docs = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_uiTexts['imageDecodeFailed']!)),
        );
        return;
      }
      final jpgBytes = img.encodeJpg(decoded, quality: 98);
      final jpgPath = path.join(docs.path, 'share_$timestamp.jpg');
      await File(jpgPath).writeAsBytes(jpgBytes);

      final assetAudio = _categoryAudio[category];
      if (assetAudio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_uiTexts['audioNotFound']!)),
        );
        return;
      }
      final audioPath = await _getAudioFilePath(assetAudio);

      if (audioPath.isEmpty || !File(audioPath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_uiTexts['audioNotFound']!)),
        );
        return;
      }

      final player = AudioPlayer();
      await player.setFilePath(audioPath);
      final audioDuration = await player.duration ?? const Duration(seconds: 5);
      await player.dispose();

      final videoSeconds = audioDuration.inSeconds;
      final videoLength = videoSeconds + 2;

      final videoPath = path.join(docs.path, 'share_$timestamp.mp4');
      final cmd =
          '-loop 1 -framerate 30 -t $videoLength -i "$jpgPath" -i "$audioPath" '
          '-map 0:v:0 -map 1:a:0 '
          '-vf "scale=720:1280,fade=t=out:st=$videoSeconds:d=2,format=yuv420p" '
          '-c:v libx264 -c:a aac -pix_fmt yuv420p -y "$videoPath"';

      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();

      if (rc == null || !rc.isValueSuccess() || !File(videoPath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_uiTexts['failedGenerateVideo']!)),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sharedMedia')
            .add({
          'type': 'video',
          'quote': quote,
          'author': author,
          'url': videoPath,
          'thumbnail': jpgPath,
          'category': category,
          'language': language,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
      }

      await Share.shareFiles([videoPath], text: '"$quote"\n- $author');
    } finally {
      _isSharing = false;
      setState(() {});
    }
  }

  Future<Uint8List?> _captureShareCard() async {
    try {
      final boundary = _shareCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing share card: $e');
      return null;
    }
  }

  List<Map<String, String>> _applyFilter() {
    var combined = <Map<String, String>>[..._localQuotes, ..._uploadedQuotes];
    combined = combined.map((q) {
      if (q['id'] == null || q['id']!.isEmpty) {
        return {...q, 'id': _quoteIdFor(q)};
      }
      return q;
    }).toList();

    // Prevent duplicates by ID
    final idSet = <String>{};
    combined = combined.where((q) {
      final id = q['id']!;
      if (idSet.contains(id)) return false;
      idSet.add(id);
      return true;
    }).toList();

    combined = combined.where((q) =>
        (q['kQuote']?.trim().isNotEmpty ?? false) &&
        (q['kAuthor']?.trim().isNotEmpty ?? false)).toList();

    final text = _searchController.text.trim();
    if (text.length >= 1) {
      String? match = _categories.firstWhere(
        (c) => c.toLowerCase().contains(text.toLowerCase()) && c != 'All',
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        combined = combined.where((q) => (q['kCategory'] ?? '').toLowerCase() == match.toLowerCase()).toList();
      } else {
        final ql = _searchQuery.toLowerCase();
        combined = combined.where((m) =>
            (m['kQuote'] ?? '').toLowerCase().contains(ql) ||
            (m['kAuthor'] ?? '').toLowerCase().contains(ql)).toList();
      }
    } else if (_selectedCategory != 'All') {
      combined = combined.where((q) => (q['kCategory'] ?? '').toLowerCase() == _selectedCategory.toLowerCase()).toList();
      if (_searchQuery.isNotEmpty) {
        final ql = _searchQuery.toLowerCase();
        combined = combined.where((m) =>
            (m['kQuote'] ?? '').toLowerCase().contains(ql) ||
            (m['kAuthor'] ?? '').toLowerCase().contains(ql)).toList();
      }
    } else if (_searchQuery.isNotEmpty) {
      final ql = _searchQuery.toLowerCase();
      combined = combined.where((m) =>
          (m['kQuote'] ?? '').toLowerCase().contains(ql) ||
          (m['kAuthor'] ?? '').toLowerCase().contains(ql)).toList();
    }
    return combined;
  }

  Future<void> _toggleFavorite(int idx, List<Map<String, String>> filtered) async {
    final map = filtered[idx];
    final id = _quoteIdFor(map);

    String imageUrl = '';
    if (map['imageUrl'] != null && map['imageUrl']!.isNotEmpty) {
      imageUrl = map['imageUrl']!;
    } else if (_currentImages != null && _currentImages!.isNotEmpty) {
      final imgCount = _currentImages!.length;
      if (imgCount > 0) {
        final bgUrl = _currentImages![idx % imgCount]['largeImageURL'] as String?;
        if (bgUrl != null && bgUrl.isNotEmpty) {
          imageUrl = bgUrl;
        }
      }
    }

    if (_favoriteIds.contains(id)) {
      await _favCol.doc(id).delete();
    } else {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await _favCol.doc(id).set({
        'userId': uid,
        'kQuote': map['kQuote'],
        'kAuthor': map['kAuthor'],
        'kCategory': map['kCategory'],
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _quoteIdFor(Map<String, String> q) {
    if (q['id'] != null && q['id']!.isNotEmpty) return q['id']!;
    final base = '${q['kQuote']}|${q['kAuthor']}|${q['kCategory']}';
    return base.hashCode.toString();
  }

  Widget _buildSearchField() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.pink.shade300, Colors.pink.shade700]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black45)],
    ),
    child: TextField(
      controller: _searchController,
      onChanged: (t) {
        setState(() => _searchQuery = t);
        if (t.trim().isNotEmpty) {
          String? match = _categories.firstWhere(
            (c) => c.toLowerCase().contains(t.trim().toLowerCase()) && c != 'All',
            orElse: () => '',
          );
          if (match.isNotEmpty && match != _selectedCategory) {
            setState(() {
              _selectedCategory = match;
              _searchController.text = match;
              _searchController.selection = TextSelection.fromPosition(TextPosition(offset: match.length));
              _searchQuery = '';
              _emojiSeed = DateTime.now().millisecondsSinceEpoch;
            });
            _moveSelectedCategoryToFront(match);
            _loadImages(match).then((_) {
              if (!mounted) return;
              setState(() => _loading = false);
              if (_audioEnabled) _playMusic(match);
            });
            return;
          }
        }
      },
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        hintText: _uiTexts['searchHint'],
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );

  Widget _buildCategorySelector() => SizedBox(
    height: 40,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemCount: _categories.length,
      itemBuilder: (ctx, i) {
        final c = _categories[i];
        if (c == "Uncategorized") return const SizedBox.shrink();
        final emoji = _categoryEmoji[c] ?? '✨';
        return FutureBuilder<String>(
          future: _translate(c),
          builder: (context, snap) => ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(snap.data ?? c),
              ],
            ),
            selected: c == _selectedCategory,
            onSelected: (_) => _onCategory(c),
          ),
        );
      },
    ),
  );

  Widget _buildCarousel(List<Map<String, String>> filtered, int safeIdx) {
    final imgCount = _currentImages?.length ?? 0;
    return CarouselSlider.builder(
      key: ValueKey(_selectedCategory),
      itemCount: filtered.length,
      itemBuilder: (ctx, idx, _) {
        final q = filtered[idx];
        final bgUrl = imgCount > 0 ? _currentImages![idx % imgCount]['largeImageURL']! : '';
        final imageUrl = q['imageUrl']?.isNotEmpty == true ? q['imageUrl']! : bgUrl;
        final emoji = _categoryEmoji[q['kCategory'] ?? 'Uncategorized'] ?? '✨';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuoteDetailScreen(
                  docId: q['id'] ?? '',
                  quoteData: q,
                  imageUrl: imageUrl,
                  userName: '',
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (bgUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: bgUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                else
                  Container(color: Colors.black),
                NonIntrusiveEmojiRain(
                  emoji: emoji,
                  randomSeed: idx + (_emojiSeed ?? 0),
                  count: 24,
                  duration: const Duration(seconds: 30),
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: FutureBuilder<List<String>>(
                    future: Future.wait([
                      _translate(q['kQuote'] ?? ''),
                      _translate(q['kAuthor'] ?? ''),
                    ]),
                    builder: (context, snapshot) {
                      final translatedQuote = snapshot.data?[0] ?? q['kQuote'] ?? '';
                      final translatedAuthor = snapshot.data?[1] ?? q['kAuthor'] ?? '';
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '"$translatedQuote"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '- $translatedAuthor -',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        initialPage: 0,
        viewportFraction: 1.0,
        scrollDirection: Axis.horizontal,
        enableInfiniteScroll: true,
        autoPlay: false,
        height: double.infinity,
        onPageChanged: (p, _) {
          HapticFeedback.lightImpact();
          setState(() => _pageIndex = p);
          if (_currentImages != null && _currentImages!.isNotEmpty) {
            final next = _currentImages![(p + 1) % _currentImages!.length]['largeImageURL']!;
            precacheImage(NetworkImage(next), context);
          }
        },
      ),
    );
  }

  Widget _buildMusicControls() => Container(
    color: Colors.grey.shade900,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snap) {
        final playing = snap.data?.playing ?? false;
        return Row(
          children: [
            IconButton(
              icon: Icon(
                playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => playing ? _toggleAudio(false) : _toggleAudio(true),
              tooltip: playing ? _uiTexts['pauseMusic'] : _uiTexts['playMusic'],
            ),
            Expanded(
              child: StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context2, s2) {
                  final pd = s2.data;
                  final max = pd?.duration.inMilliseconds.toDouble() ?? 1;
                  final val = min(pd?.position.inMilliseconds.toDouble() ?? 0, max);
                  return Slider(
                    min: 0,
                    max: max,
                    value: val,
                    onChanged: (v) => _audioPlayer.seek(Duration(milliseconds: v.toInt())),
                    activeColor: Colors.deepPurpleAccent,
                    inactiveColor: Colors.white24,
                  );
                },
              ),
            ),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context3, s3) {
                final pd = s3.data;
                String two(int n) => n.toString().padLeft(2, '0');
                return Text(
                  '${two(pd?.position.inMinutes ?? 0)}:${two((pd?.position.inSeconds ?? 0) % 60)} / '
                      '${two(pd?.duration.inMinutes ?? 0)}:${two((pd?.duration.inSeconds ?? 0) % 60)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              },
            ),
          ],
        );
      },
    ),
  );

  Widget _buildBottomBar(List<Map<String, String>> filtered, int safeIdx) =>
      BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildCategorySelector(),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    tooltip: _uiTexts['shareImage'],
                    onPressed: () => _shareCurrentWithEmoji(
                        filtered, _pageIndex, _currentImages, context: context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam, color: Colors.white),
                    tooltip: _uiTexts['shareVideo'],
                    onPressed: () => _shareCurrentAsVideo(
                        filtered, _pageIndex, _currentImages, context: context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fiber_manual_record, color: Colors.redAccent),
                    tooltip: _uiTexts['record'],
                    onPressed: () {
                      final imgCount = _currentImages?.length ?? 0;
                      final filteredMap = filtered[safeIdx];
                      final bgUrl = imgCount > 0 ? _currentImages![safeIdx % imgCount]['largeImageURL']! : '';
                      final imageUrl = filteredMap['imageUrl']?.isNotEmpty == true ? filteredMap['imageUrl']! : bgUrl;
                      final category = filteredMap['kCategory'] ?? 'Uncategorized';
                      final emoji = _categoryEmoji[category] ?? '✨';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecordScreen(
                            quote: filteredMap['kQuote'] ?? '',
                            author: filteredMap['kAuthor'] ?? '',
                            userName: '',
                            imageUrl: imageUrl,
                            emoji: emoji,
                            category: category,
                            language: _preferredLanguage,
                            randomSeed: safeIdx + (_emojiSeed ?? 0),
                            animationsEnabled: true,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _favoriteIds.contains(_quoteIdFor(filtered[safeIdx]))
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    tooltip: _uiTexts['favorite'],
                    onPressed: () => _toggleFavorite(safeIdx, filtered),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _moveSelectedCategoryToFront(String selected) {
    setState(() {
      if (selected == 'All') {
        _categories = ['All', ..._categories.where((c) => c != 'All')];
      } else {
        _categories = ['All', selected, ..._categories.where((c) => c != 'All' && c != selected)];
      }
    });
  }

  void _onCategory(String c) {
    if (c == "Uncategorized") return;
    _moveSelectedCategoryToFront(c);
    setState(() {
      _selectedCategory = c;
      _pageIndex = 0;
      _loading = true;
      _searchController.text = c;
      _emojiSeed = DateTime.now().millisecondsSinceEpoch;
    });
    _prefsRef.set({'defaultCategory': c}, SetOptions(merge: true));
    _loadImages(c).then((_) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_audioEnabled) _playMusic(c);
    });
  }

  void _startWithCategory(String? category) async {
    final qs = await QuotesLoader.load();
    setState(() {
      _localQuotes = qs;
    });
    final c = category ?? 'All';
    if (_categories.contains(c) && c != "Uncategorized") {
      setState(() {
        _selectedCategory = c;
        _searchController.text = c;
        _loading = true;
      });
      _moveSelectedCategoryToFront(c);
      _loadImages(c).then((_) {
        if (!mounted) return;
        setState(() => _loading = false);
      });
    } else {
      setState(() {
        _selectedCategory = 'All';
        _searchController.text = '';
        _loading = false;
      });
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.durationStream,
        (pos, dur) => PositionData(pos, dur ?? Duration.zero),
      );

  void _toggleAudio(bool enable) {
    setState(() => _audioEnabled = enable);
    enable ? _playMusic(_selectedCategory) : _audioPlayer.pause();
    _prefsRef.set({'audioEnabled': enable}, SetOptions(merge: true));
  }

  Future<void> _playMusic(String category) async {
    String lookup = category;
    if (!_categoryAudio.containsKey(lookup)) lookup = 'All';
    final asset = _categoryAudio[lookup];
    if (asset == null) {
      await _audioPlayer.stop();
      return;
    }
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(asset);
      _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
    } catch (e) {}
  }

  Future<void> _loadImages(String category) async {
    if (_imagesByCategory.containsKey(category)) {
      _currentImages = _imagesByCategory[category];
      return;
    }
    final term = Uri.encodeComponent(_pixabayQueries[category] ?? _pixabayQueries['All']!);
    final uri = Uri.parse('https://pixabay.com/api/?key=${consts.pixabayKey}&q=$term&image_type=photo&per_page=60');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final hits = (json.decode(res.body)['hits'] as List<dynamic>)..shuffle();
        _imagesByCategory[category] = hits;
        _currentImages = hits;
        for (var i = 0, max = min(3, hits.length); i < max; i++) {
          precacheImage(NetworkImage(hits[i]['largeImageURL']), context);
        }
      }
    } catch (_) {}
  }

  void _onPrefs(DocumentSnapshot<Map<String, dynamic>> prefsSnap) {
    if (!mounted || !prefsSnap.exists) return;
    final data = prefsSnap.data();
    if (data == null) return;
    String? newCat = data['defaultCategory'] as String?;
    String? newLang = data['preferredLanguage'] as String?;
    if (newCat == null || newCat == "Uncategorized" || !_categories.contains(newCat)) {
      newCat = widget.settingsCategory ?? 'All';
    }
    setState(() {
      _audioEnabled = data['audioEnabled'] as bool? ?? true;
      _preferredLanguage = newLang ?? 'en';
      _selectedCategory = newCat!;
      _moveSelectedCategoryToFront(_selectedCategory);
      _loading = true;
    });
    _translateAllUiTexts();
    _loadImages(_selectedCategory).then((_) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_audioEnabled) _playMusic(_selectedCategory);
      _emojiSeed = DateTime.now().millisecondsSinceEpoch;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilter();
    final hasImages = _currentImages?.isNotEmpty ?? false;
    final safeIdx = filtered.isEmpty ? 0 : min(_pageIndex, filtered.length - 1);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          drawer: const AppDrawer(),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.deepPurple.shade700,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_categoryEmoji[_selectedCategory] ?? '✨', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _uiTexts['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildSearchField(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: _uiTexts['settings'],
                onPressed: () async {
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  if (result != null &&
                      result != _selectedCategory &&
                      _categories.contains(result) &&
                      result != "Uncategorized") {
                    setState(() {
                      _selectedCategory = result;
                      _searchController.text = result;
                      _pageIndex = 0;
                    });
                    _moveSelectedCategoryToFront(result);
                    await _loadImages(result);
                    setState(() {});
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.perm_media, color: Colors.white),
                tooltip: _uiTexts['sharedMedia'],
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SharedMediaScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.white),
                tooltip: _uiTexts['favorites'],
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildCategorySelector(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${_uiTexts['language']!}: ${_preferredLanguage.toUpperCase()}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: SpinKitFadingCircle(color: Colors.white))
                    : hasImages
                        ? SafeArea(
                            child: Center(
                              child: RepaintBoundary(
                                key: _mainCardKey,
                                child: filtered.isEmpty
                                    ? Center(
                                        child: Text(
                                          _uiTexts['empty']!,
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      )
                                    : _buildCarousel(filtered, safeIdx),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(_uiTexts['noImages']!, style: const TextStyle(color: Colors.white70)),
                          ),
              ),
            ],
          ),
          bottomNavigationBar: (hasImages && !_loading && filtered.isNotEmpty)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMusicControls(),
                    _buildBottomBar(filtered, safeIdx),
                  ],
                )
              : null,
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
        )
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _favSub.cancel();
    _prefsSub.cancel();
    _uploadsSub.cancel();
    super.dispose();
  }
}


  

