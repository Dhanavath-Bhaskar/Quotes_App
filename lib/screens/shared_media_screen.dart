import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'video_player_screen.dart';
import '../services/google_translation_service.dart';

// --- Supported languages map as in your previous code above ---

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


class SharedMediaScreen extends StatefulWidget {
  final String? highlightId;
  const SharedMediaScreen({Key? key, this.highlightId}) : super(key: key);

  @override
  State<SharedMediaScreen> createState() => _SharedMediaScreenState();
}

class _SharedMediaScreenState extends State<SharedMediaScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _imageScroll = ScrollController();
  final ScrollController _videoScroll = ScrollController();
  final ScrollController _recordedScroll = ScrollController();

  String _preferredLanguage = 'en';
  final GoogleTranslationService _googleTranslator = GoogleTranslationService(
    apiKey: 'AIzaSyC2T82ER-8u1X3Z7UKF6F4tPBdkCo4sXlY',
    
  );
  bool _hasScrolled = false;
  final Map<String, String?> _videoThumbCache = {};

  // UI labels (with translation support)
  String _title = 'Shared Media';
  String _tabImages = 'Images';
  String _tabVideos = 'Videos';
  String _tabRecorded = 'Recorded Videos';
  String _noSharedImages = 'No shared images yet';
  String _noSharedVideos = 'No shared videos yet';
  String _noRecordedVideos = 'No recorded videos yet';
  String _noImageAvailable = 'No image available';
  String _noVideoThumbnail = 'No video thumbnail';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLanguageAndTranslateLabels();
  }

  Future<void> _loadLanguageAndTranslateLabels() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('prefs')
            .get();
        _preferredLanguage = snap.data()?['preferredLanguage'] ?? 'en';
      }
    } catch (_) {
      _preferredLanguage = 'en';
    }
    await _translateLabels();
    setState(() {});
  }

  Future<void> _translateLabels() async {
    if (_preferredLanguage == 'en') return;
    try {
      final results = await Future.wait([
        _googleTranslator.translate(text: 'Shared Media', targetLang: _preferredLanguage),
        _googleTranslator.translate(text: 'Images', targetLang: _preferredLanguage),
        _googleTranslator.translate(text: 'Videos', targetLang: _preferredLanguage),
        _googleTranslator.translate(text: 'Recorded Videos', targetLang: _preferredLanguage),
        _googleTranslator.translate(text: 'No shared images yet', targetLang: _preferredLanguage),
        _googleTranslator.translate(text: 'No shared videos yet', targetLang: _preferredLanguage),
        _googleTranslator.translate(text: 'No recorded videos yet', targetLang: _preferredLanguage),
        _googleTranslator.translate(text: 'No image available', targetLang: _preferredLanguage),
        _googleTranslator.translate(text: 'No video thumbnail', targetLang: _preferredLanguage),
      ]);
      _title = results[0];
      _tabImages = results[1];
      _tabVideos = results[2];
      _tabRecorded = results[3];
      _noSharedImages = results[4];
      _noSharedVideos = results[5];
      _noRecordedVideos = results[6];
      _noImageAvailable = results[7];
      _noVideoThumbnail = results[8];
    } catch (_) {}
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _mediaStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sharedMedia')
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  Future<String> _downloadToTemp(String url, {String? filename}) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${filename ?? DateTime.now().millisecondsSinceEpoch}');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    }
    throw Exception('Failed to download file');
  }

  Future<void> _shareRemoteFile(String url, {String? filename, String? text}) async {
    try {
      final localPath = await _downloadToTemp(url, filename: filename);
      await Share.shareFiles([localPath], text: text ?? '');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download/Share failed: $e')));
      }
    }
  }

  Future<void> _deleteFromFirebaseStorage(String url) async {
    try {
      if (url.startsWith('http')) {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      }
    } catch (_) {}
  }

  Map<String, String> _mapMedia(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return {
      'quote': (data['quote'] ?? '').toString(),
      'author': (data['author'] ?? '').toString(),
      'userName': (data['userName'] ?? 'Anonymous').toString(),
      'imagePath': (data['url'] ?? '').toString(),
      'videoPath': (data['url'] ?? '').toString(),
      'category': (data['category'] ?? 'Uncategorized').toString(),
      'firebaseId': doc.id,
      'type': (data['type'] ?? '').toString(),
      'thumbnail': (data['thumbnail'] ?? '').toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(_title, style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(24),
              ),
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.75),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              tabs: [
                Tab(text: _tabImages),
                Tab(text: _tabVideos),
                Tab(text: _tabRecorded),
              ],
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              splashBorderRadius: BorderRadius.circular(24),
              overlayColor: MaterialStateProperty.all(colorScheme.primary.withOpacity(0.06)),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _mediaStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          final images = docs
              .where((doc) => doc.data()['type'] == 'image')
              .map((doc) => _mapMedia(doc))
              .toList();
          final videos = docs
              .where((doc) => doc.data()['type'] == 'video')
              .map((doc) => _mapMedia(doc))
              .toList();
          final recorded = docs
              .where((doc) => doc.data()['type'] == 'recorded_video')
              .map((doc) => _mapMedia(doc))
              .toList();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_hasScrolled && widget.highlightId != null) {
              int idx = images.indexWhere((m) => m['firebaseId'] == widget.highlightId);
              if (idx != -1) {
                _imageScroll.animateTo(
                  idx * 350.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
                _hasScrolled = true;
              } else {
                idx = videos.indexWhere((m) => m['firebaseId'] == widget.highlightId);
                if (idx != -1) {
                  _tabController.animateTo(1);
                  _videoScroll.animateTo(
                    idx * 350.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                  _hasScrolled = true;
                } else {
                  idx = recorded.indexWhere((m) => m['firebaseId'] == widget.highlightId);
                  if (idx != -1) {
                    _tabController.animateTo(2);
                    _recordedScroll.animateTo(
                      idx * 350.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                    _hasScrolled = true;
                  }
                }
              }
            }
          });

          return TabBarView(
            controller: _tabController,
            children: [
              _buildImageList(images, _imageScroll, colorScheme),
              _buildVideoList(videos, _videoScroll, false, colorScheme),
              _buildVideoList(recorded, _recordedScroll, true, colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageList(List<Map<String, String>> mediaList, ScrollController controller, ColorScheme colorScheme) {
    if (mediaList.isEmpty) {
      return Center(child: Text(_noSharedImages, style: TextStyle(color: colorScheme.onSurface)));
    }
    return ListView.builder(
      controller: controller,
      itemCount: mediaList.length,
      itemBuilder: (context, idx) {
        final m = mediaList[idx];
        final imageUrl = m['imagePath'] ?? '';
        final isHighlighted = m['firebaseId'] == widget.highlightId;

        Widget imageWidget;
        if (imageUrl.startsWith('http')) {
          imageWidget = Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => _imagePlaceholder(colorScheme),
          );
        } else if (imageUrl.isNotEmpty) {
          imageWidget = Image.file(
            File(imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => _imagePlaceholder(colorScheme),
          );
        } else {
          imageWidget = _imagePlaceholder(colorScheme);
        }

        return Container(
          decoration: isHighlighted
              ? BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 4),
                  borderRadius: BorderRadius.circular(28),
                  color: colorScheme.primary.withOpacity(0.07),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageWidget,
                        Container(color: Colors.black.withOpacity(0.2)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share, color: colorScheme.primary),
                      onPressed: () => _shareImage(m),
                      tooltip: 'Share',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete'),
                            content: const Text('Are you sure you want to delete this image?'),
                            actions: [
                              TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(ctx, false)),
                              TextButton(child: const Text('Delete'), onPressed: () => Navigator.pop(ctx, true)),
                            ],
                          ),
                        );
                        if (ok == true) await _deleteMedia(m, isImage: true);
                      },
                      tooltip: 'Delete',
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- VIDEO THUMBNAIL GENERATION ---
  Future<Widget> _videoThumbnailWidget(
    String videoPath,
    ColorScheme colorScheme, {
    String? thumbnailUrl,
  }) async {
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      if (thumbnailUrl.startsWith('http')) {
        return Container(
          decoration: BoxDecoration(color: colorScheme.surfaceVariant),
          child: Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => _videoPlaceholder(colorScheme),
          ),
        );
      } else if (File(thumbnailUrl).existsSync()) {
        return Container(
          decoration: BoxDecoration(color: colorScheme.surfaceVariant),
          child: Image.file(
            File(thumbnailUrl),
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => _videoPlaceholder(colorScheme),
          ),
        );
      }
    }
    if (videoPath.isEmpty) return _videoPlaceholder(colorScheme);
    if (_videoThumbCache.containsKey(videoPath)) {
      final thumb = _videoThumbCache[videoPath];
      if (thumb != null && File(thumb).existsSync()) {
        return Container(
          decoration: BoxDecoration(color: colorScheme.surfaceVariant),
          child: Image.file(File(thumb), fit: BoxFit.cover),
        );
      }
    }
    try {
      final thumb = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 480,
        quality: 65,
      );
      if (thumb != null && File(thumb).existsSync()) {
        _videoThumbCache[videoPath] = thumb;
        return Container(
          decoration: BoxDecoration(color: colorScheme.surfaceVariant),
          child: Image.file(File(thumb), fit: BoxFit.cover),
        );
      }
    } catch (_) {}
    return _videoPlaceholder(colorScheme);
  }

  Widget _buildVideoList(List<Map<String, String>> mediaList, ScrollController controller, bool isRecorded, ColorScheme colorScheme) {
    if (mediaList.isEmpty) {
      return Center(child: Text(isRecorded ? _noRecordedVideos : _noSharedVideos, style: TextStyle(color: colorScheme.onSurface)));
    }
    return ListView.builder(
      controller: controller,
      itemCount: mediaList.length,
      itemBuilder: (context, idx) {
        final m = mediaList[idx];
        final videoPath = m['videoPath'] ?? '';
        final thumbnailUrl = isRecorded ? (m['thumbnail'] ?? '') : null;
        final isHighlighted = m['firebaseId'] == widget.highlightId;

        return Container(
          decoration: isHighlighted
              ? BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 4),
                  borderRadius: BorderRadius.circular(28),
                  color: colorScheme.primary.withOpacity(0.07),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (videoPath.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(
                            videoPath: videoPath,
                            thumbnailPath: thumbnailUrl ?? '',
                            category: m['category'] ?? '',
                          ),
                        ),
                      );
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FutureBuilder<Widget>(
                            future: _videoThumbnailWidget(
                              videoPath,
                              colorScheme,
                              thumbnailUrl: thumbnailUrl,
                            ),
                            builder: (context, snap) {
                              if (snap.connectionState == ConnectionState.done && snap.hasData) {
                                return snap.data!;
                              }
                              return _videoPlaceholder(colorScheme);
                            },
                          ),
                          Icon(
                            Icons.play_circle_fill,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            size: 70,
                          ),
                          Container(color: Colors.black.withOpacity(0.04)),
                          if (isRecorded)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'REC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share, color: colorScheme.primary),
                      onPressed: () => _shareVideo(m),
                      tooltip: 'Share',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete'),
                            content: Text('Are you sure you want to delete this video?'),
                            actions: [
                              TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(ctx, false)),
                              TextButton(child: const Text('Delete'), onPressed: () => Navigator.pop(ctx, true)),
                            ],
                          ),
                        );
                        if (ok == true) await _deleteMedia(m, isImage: false);
                      },
                      tooltip: 'Delete',
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imagePlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 150,
      color: colorScheme.surfaceVariant,
      child: Center(child: Text(_noImageAvailable, style: TextStyle(color: colorScheme.onSurface))),
    );
  }

  Widget _videoPlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 180,
      color: colorScheme.surfaceVariant,
      child: Center(child: Text(_noVideoThumbnail, style: TextStyle(color: colorScheme.onSurface))),
    );
  }

  Future<void> _shareImage(Map<String, String> m) async {
    final path = m['imagePath'];
    if (path == null || path.isEmpty) return;
    if (path.startsWith("http")) {
      await _shareRemoteFile(path, filename: 'shared_image.jpg', text: '"${m['quote'] ?? ''}"\n- ${m['author'] ?? ''}');
    } else if (File(path).existsSync()) {
      await Share.shareFiles([path], text: '"${m['quote'] ?? ''}"\n- ${m['author'] ?? ''}');
    }
  }

  Future<void> _shareVideo(Map<String, String> m) async {
    final path = m['videoPath'];
    if (path == null || path.isEmpty) return;
    if (path.startsWith("http")) {
      await _shareRemoteFile(path, filename: 'shared_video.mp4', text: '"${m['quote'] ?? ''}"\n- ${m['author'] ?? ''}');
    } else if (File(path).existsSync()) {
      await Share.shareFiles([path], text: '"${m['quote'] ?? ''}"\n- ${m['author'] ?? ''}');
    }
  }

  Future<void> _deleteMedia(Map<String, String> m, {required bool isImage}) async {
    final url = isImage ? m['imagePath'] ?? '' : m['videoPath'] ?? '';
    if (url.startsWith('http')) await _deleteFromFirebaseStorage(url);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && m['firebaseId'] != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sharedMedia')
          .doc(m['firebaseId'])
          .delete();
    }
  }
}
