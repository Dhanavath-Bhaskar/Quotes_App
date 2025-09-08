import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_new_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../widgets/non_intrusive_emoji_rain.dart';
import '../services/google_translation_service.dart';

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


Future<String> _copyAssetToFile(BuildContext context, String assetPath) async {
  final data = await DefaultAssetBundle.of(context).load(assetPath);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${assetPath.split('/').last}');
  await file.writeAsBytes(data.buffer.asUint8List());
  return file.path;
}

class RecordScreen extends StatefulWidget {
  final String quote;
  final String author;
  final String userName;
  final String imageUrl;
  final String emoji;
  final String category;
  final String language;
  final int? randomSeed;
  final bool animationsEnabled;

  const RecordScreen({
    Key? key,
    required this.quote,
    required this.author,
    required this.userName,
    required this.imageUrl,
    required this.emoji,
    required this.category,
    required this.language,
    this.randomSeed,
    required this.animationsEnabled,
  }) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> with SingleTickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  final GoogleTranslationService _googleTranslator = GoogleTranslationService(
    apiKey: 'AIzaSyC2T82ER-8u1X3Z7UKF6F4tPBdkCo4sXlY',
  );

  bool _recording = false;
  double _progress = 0;
  String? _outputVideo;
  String? _uploadedUrl;
  String? _thumbnailPath;

  late AnimationController _controller;
  static const int _fps = 12;

  // Translation fields
  String? _translatedQuote, _translatedAuthor, _translatedUploader, _translatedCategory;
  String _recordButtonLabel = 'Record Video';
  String _shareButtonLabel = 'Share';
  String _recordingProgressLabel = 'Recording...';
  String _videoReadyLabel = 'Video recorded! Tap Share.';
  String _exportFailedLabel = 'Video export failed.';
  String _shareFirstLabel = 'Please record the video first!';
  String _uploadedLabel = 'Video uploaded!';
  bool _translating = true;

  // For background image preloading
  ui.Image? _bgUiImage;
  bool _bgImageLoaded = false;
  bool _bgImageTried = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..value = 0;
    _translateTexts();
    _loadBgImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _translateTexts() async {
    final lang = widget.language;
    if (lang == 'en') {
      setState(() {
        _translatedQuote = widget.quote;
        _translatedAuthor = widget.author;
        _translatedUploader = 'Uploaded by ${widget.userName}';
        _translatedCategory = widget.category;
        _recordButtonLabel = 'Record Video';
        _shareButtonLabel = 'Share';
        _recordingProgressLabel = 'Recording...';
        _videoReadyLabel = 'Video recorded! Tap Share.';
        _exportFailedLabel = 'Video export failed.';
        _shareFirstLabel = 'Please record the video first!';
        _uploadedLabel = 'Video uploaded!';
        _translating = false;
      });
      return;
    }
    try {
      final results = await Future.wait([
        _googleTranslator.translate(text: widget.quote, targetLang: lang),
        _googleTranslator.translate(text: widget.author, targetLang: lang),
        _googleTranslator.translate(text: 'Uploaded by ${widget.userName}', targetLang: lang),
        _googleTranslator.translate(text: widget.category, targetLang: lang),
        _googleTranslator.translate(text: 'Record Video', targetLang: lang),
        _googleTranslator.translate(text: 'Share', targetLang: lang),
        _googleTranslator.translate(text: 'Recording...', targetLang: lang),
        _googleTranslator.translate(text: 'Video recorded! Tap Share.', targetLang: lang),
        _googleTranslator.translate(text: 'Video export failed.', targetLang: lang),
        _googleTranslator.translate(text: 'Please record the video first!', targetLang: lang),
        _googleTranslator.translate(text: 'Video uploaded!', targetLang: lang),
      ]);
      setState(() {
        _translatedQuote = results[0];
        _translatedAuthor = results[1];
        _translatedUploader = results[2];
        _translatedCategory = results[3];
        _recordButtonLabel = results[4];
        _shareButtonLabel = results[5];
        _recordingProgressLabel = results[6];
        _videoReadyLabel = results[7];
        _exportFailedLabel = results[8];
        _shareFirstLabel = results[9];
        _uploadedLabel = results[10];
        _translating = false;
      });
    } catch (_) {
      setState(() => _translating = false);
    }
  }

  Future<void> _loadBgImage() async {
    try {
      Uint8List imgBytes;
      if (widget.imageUrl.isNotEmpty) {
        if (widget.imageUrl.startsWith('http')) {
          final response = await http.get(Uri.parse(widget.imageUrl));
          imgBytes = response.bodyBytes;
        } else {
          imgBytes = await File(widget.imageUrl).readAsBytes();
        }
      } else {
        // Load the default asset image if no imageUrl is provided
        final assetData = await DefaultAssetBundle.of(context).load('assets/default_bg.jpg');
        imgBytes = assetData.buffer.asUint8List();
      }
      final codec = await ui.instantiateImageCodec(imgBytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _bgUiImage = frame.image;
        _bgImageLoaded = true;
        _bgImageTried = true;
      });
    } catch (_) {
      setState(() {
        _bgUiImage = null;
        _bgImageLoaded = false;
        _bgImageTried = true;
      });
    }
  }

  Future<void> _recordVideo() async {
    if (!_bgImageTried || (widget.imageUrl.isNotEmpty && !_bgImageLoaded)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background image is still loading, please wait...')),
      );
      return;
    }
    setState(() {
      _recording = true;
      _progress = 0;
      _outputVideo = null;
      _uploadedUrl = null;
      _thumbnailPath = null;
    });

    final tempDir = await getTemporaryDirectory();
    final frameDir = Directory('${tempDir.path}/frames_${DateTime.now().millisecondsSinceEpoch}');
    await frameDir.create(recursive: true);

    final audioAsset = _categoryAudio[widget.category] ?? _categoryAudio['All']!;
    final audioPath = await _copyAssetToFile(context, audioAsset);

    Duration audioDuration = const Duration(seconds: 30);
    try {
      final player = AudioPlayer();
      await player.setFilePath(audioPath);
      audioDuration = await player.duration ?? const Duration(seconds: 30);
      await player.dispose();
    } catch (_) {}

    final int frameCount = (audioDuration.inMilliseconds / 1000 * _fps).ceil();
    final double animDurationSec = audioDuration.inMilliseconds / 1000;

    _controller.duration = Duration(milliseconds: audioDuration.inMilliseconds);

    List<String> framePaths = [];
    RenderRepaintBoundary? boundary;
    for (int i = 0; i < frameCount; i++) {
      double animValue = i / (frameCount - 1);
      _controller.value = animValue;
      await Future.delayed(const Duration(milliseconds: 4)); // Let the widget update

      boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      List<int> pngBytes = byteData!.buffer.asUint8List();
      String path = '${frameDir.path}/frame_${i.toString().padLeft(3, "0")}.png';
      await File(path).writeAsBytes(pngBytes);
      framePaths.add(path);
      if (i == 0) {
        final thumbPath = '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(thumbPath).writeAsBytes(pngBytes);
        setState(() => _thumbnailPath = thumbPath);
      }
      if (i % 6 == 0 || i == frameCount - 1) {
        setState(() => _progress = i / frameCount);
      }
    }

    final outputPath = '${tempDir.path}/export_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final ffmpegCmd =
        '-y -framerate $_fps -i ${frameDir.path}/frame_%03d.png -i "$audioPath" '
        '-c:v libx264 -c:a aac -shortest -t $animDurationSec '
        '-pix_fmt yuv420p -vf scale=720:-2 $outputPath';
    await FFmpegKit.execute(ffmpegCmd);

    setState(() {
      _progress = 1.0;
      _outputVideo = outputPath;
      _recording = false;
    });

    for (var p in framePaths) {
      try {
        File(p).deleteSync();
      } catch (_) {}
    }
    try {
      frameDir.deleteSync(recursive: true);
    } catch (_) {}

    if (!File(outputPath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_exportFailedLabel)));
      setState(() => _outputVideo = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_videoReadyLabel)));
    }
  }

  Future<void> _shareAndUpload() async {
    if (_outputVideo == null || !File(_outputVideo!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_shareFirstLabel)));
      return;
    }
    await Share.shareFiles([_outputVideo!],
        text: '"${_translatedQuote ?? widget.quote}"\n- ${_translatedAuthor ?? widget.author}');
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login required for upload.')));
        return;
      }
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('shared_media/${user.uid}/recorded_videos/video_${DateTime.now().millisecondsSinceEpoch}.mp4');
      final uploadTask = storageRef.putFile(File(_outputVideo!));
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      String? thumbUrl;
      if (_thumbnailPath != null && File(_thumbnailPath!).existsSync()) {
        final thumbRef = FirebaseStorage.instance
            .ref()
            .child('shared_media/${user.uid}/recorded_videos/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
        final thumbUpload = thumbRef.putFile(File(_thumbnailPath!));
        final thumbSnap = await thumbUpload.whenComplete(() {});
        thumbUrl = await thumbSnap.ref.getDownloadURL();
      }

      setState(() => _uploadedUrl = url);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sharedMedia')
          .add({
        'type': 'recorded_video',
        'quote': _translatedQuote ?? widget.quote,
        'author': _translatedAuthor ?? widget.author,
        'userName': widget.userName,
        'category': _translatedCategory ?? widget.category,
        'language': widget.language,
        'url': url,
        'thumbnail': thumbUrl ?? '',
        'randomSeed': widget.randomSeed ?? 123,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_uploadedLabel)));
    } catch (e) {
      // Ignore upload errors for now
    }
    if (mounted) {
      Navigator.of(context).pop(_outputVideo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double cardWidth = media.size.width * 1.0;
    final double cardHeight = cardWidth * 16 / 9;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _recordButtonLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: _translating
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: Stack(
                          children: [
                            RepaintBoundary(
                              key: _repaintKey,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(36),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (_bgUiImage != null)
                                      Positioned.fill(
                                        child: RawImage(image: _bgUiImage, fit: BoxFit.cover),
                                      )
                                    else
                                      _bgColorWidget(widget.category),
                                    if (widget.animationsEnabled)
                                      NonIntrusiveEmojiRain(
                                        emoji: widget.emoji,
                                        randomSeed: widget.randomSeed ?? 123,
                                        count: 24,
                                        duration: const Duration(seconds: 30),
                                        progress: _recording ? _controller.value : null,
                                      ),
                                    Container(color: Colors.black.withOpacity(0.32)),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: cardWidth * 0.06,
                                        vertical: cardHeight * 0.10,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  '"${_translatedQuote ?? widget.quote}"',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.4,
                                                    letterSpacing: 0.3,
                                                    shadows: [
                                                      Shadow(blurRadius: 3, color: Colors.black, offset: Offset(1, 1)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Text(
                                            '- ${_translatedAuthor ?? widget.author} -',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.tealAccent,
                                              fontSize: 20,
                                              fontStyle: FontStyle.italic,
                                              letterSpacing: 0.3,
                                              height: 1.4,
                                              shadows: [
                                                Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if ((widget.userName).isNotEmpty)
                                            Text(
                                              _translatedUploader ?? 'Uploaded by ${widget.userName}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontStyle: FontStyle.italic,
                                                letterSpacing: 0.3,
                                                height: 1.4,
                                                shadows: [
                                                  Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                                ],
                                              ),
                                            ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '${widget.emoji}  ${_translatedCategory ?? widget.category}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.amberAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              letterSpacing: 0.3,
                                              shadows: [
                                                Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Language: ${widget.language.toUpperCase()}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_recording)
                              Positioned(
                                top: 24,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    'Recording...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      letterSpacing: 1,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 8,
                                          color: Colors.black87,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(54),
                                backgroundColor: Colors.teal,
                                shape: const StadiumBorder(),
                              ),
                              icon: _recording
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.fiber_manual_record, color: Colors.white),
                              label: Text(
                                _recording
                                    ? '${_recordingProgressLabel} (${(_progress * 100).toInt()}%)'
                                    : _recordButtonLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                  letterSpacing: 0.2,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3,
                                      color: Colors.black26,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: _recording ? null : _recordVideo,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(54),
                                backgroundColor: Colors.blue,
                                disabledBackgroundColor: Colors.red,
                                shape: const StadiumBorder(),
                              ),
                              icon: const Icon(Icons.share, color: Colors.white),
                              label: Text(
                                _shareButtonLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              onPressed: _recording || _outputVideo == null ? null : _shareAndUpload,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_uploadedUrl != null)
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: SelectableText(
                          _uploadedLabel,
                          style: const TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _bgColorWidget(String category) {
    switch (category) {
      case 'Action': return Container(color: Colors.red.shade900);
      case 'Adventure': return Container(color: Colors.teal.shade400);
      case 'All': return Container(color: Colors.deepPurple.shade200);
      case 'Art': return Container(color: Colors.purple.shade800);
      case 'Balance': return Container(color: Colors.brown.shade400);
      case 'Belief': return Container(color: Colors.lime.shade900);
      case 'Change': return Container(color: Colors.cyan.shade600);
      case 'Charity': return Container(color: Colors.pink.shade300);
      case 'Childhood': return Container(color: Colors.amber.shade200);
      case 'Community': return Container(color: Colors.indigo.shade400);
      case 'Confidence': return Container(color: Colors.blue.shade800);
      case 'Courage': return Container(color: Colors.orange.shade700);
      case 'Creativity & Inspiration': return Container(color: Colors.deepPurple.shade700);
      case 'Culture': return Container(color: Colors.deepOrange.shade200);
      case 'Decision': return Container(color: Colors.indigo.shade600);
      case 'Determination': return Container(color: Colors.green.shade800);
      case 'Discipline': return Container(color: Colors.teal.shade800);
      case 'Diversity': return Container(color: Colors.lightBlue.shade600);
      case 'Dreams': return Container(color: Colors.purple.shade600);
      case 'Education': return Container(color: Colors.yellow.shade800);
      case 'Empathy': return Container(color: Colors.pink.shade100);
      case 'Endings': return Container(color: Colors.grey.shade800);
      case 'Equality': return Container(color: Colors.blueGrey.shade200);
      case 'Faith': return Container(color: Colors.indigo.shade900);
      case 'Family': return Container(color: Colors.orange.shade200);
      case 'Focus': return Container(color: Colors.cyan.shade900);
      case 'Forging Ahead': return Container(color: Colors.brown.shade700);
      case 'Forgiveness': return Container(color: Colors.green.shade200);
      case 'Freedom': return Container(color: Colors.blue.shade400);
      case 'Friendship': return Container(color: Colors.tealAccent.shade700);
      case 'Giving': return Container(color: Colors.redAccent.shade100);
      case 'Gratitude': return Container(color: Colors.amber.shade400);
      case 'Growth': return Container(color: Colors.green.shade600);
      case 'Hard Work': return Container(color: Colors.brown.shade900);
      case 'Happiness & Joy': return Container(color: Colors.orange.shade700);
      case 'Health': return Container(color: Colors.greenAccent.shade400);
      case 'Honesty': return Container(color: Colors.yellow.shade700);
      case 'Hope': return Container(color: Colors.lightBlue.shade200);
      case 'Humility': return Container(color: Colors.brown.shade200);
      case 'Humor': return Container(color: Colors.pink.shade100);
      case 'Imagination': return Container(color: Colors.deepPurpleAccent.shade100);
      case 'Inclusion': return Container(color: Colors.purple.shade200);
      case 'Innovation': return Container(color: Colors.lightGreen.shade700);
      case 'Integrity': return Container(color: Colors.grey.shade900);
      case 'Justice': return Container(color: Colors.blueGrey.shade800);
      case 'Kindness': return Container(color: Colors.green.shade100);
      case 'Leadership': return Container(color: Colors.amber.shade700);
      case 'Learning': return Container(color: Colors.blue.shade300);
      case 'Legacy': return Container(color: Colors.teal.shade900);
      case 'Life': return Container(color: Colors.green.shade400);
      case 'Listening': return Container(color: Colors.cyan.shade200);
      case 'Love': return Container(color: Colors.red.shade400);
      case 'Memories': return Container(color: Colors.indigoAccent.shade200);
      case 'Mindfulness': return Container(color: Colors.teal.shade200);
      case 'Mindfulness & Letting Go': return Container(color: Colors.green.shade700);
      case 'Mindset': return Container(color: Colors.deepPurpleAccent.shade200);
      case 'Motivation & Achievement': return Container(color: Color(0xFFA61B1B));
      case 'Music': return Container(color: Colors.deepPurple.shade400);
      case 'Natural': return Container(color: Colors.lightGreen.shade200);
      case 'New Beginnings': return Container(color: Colors.lime.shade300);
      case 'Opportunity': return Container(color: Colors.orangeAccent.shade200);
      case 'Overcoming Obstacles': return Container(color: Colors.blueGrey.shade600);
      case 'Parenting': return Container(color: Colors.pinkAccent.shade100);
      case 'Passion': return Container(color: Colors.red.shade800);
      case 'Patience': return Container(color: Colors.yellow.shade200);
      case 'Peace': return Container(color: Colors.lightBlue.shade700);
      case 'Peace & Inner Calm': return Container(color: Colors.teal.shade800);
      case 'Perseverance': return Container(color: Colors.indigo.shade800);
      case 'Philosophy': return Container(color: Colors.indigo.shade900);
      case 'Positivity': return Container(color: Colors.lightGreenAccent.shade400);
      case 'Prosperity': return Container(color: Colors.greenAccent.shade700);
      case 'Purpose': return Container(color: Colors.deepPurple.shade300);
      case 'Reflection': return Container(color: Colors.grey.shade400);
      case 'Relationships & Connection': return Container(color: Colors.pink.shade400);
      case 'Resilience': return Container(color: Colors.tealAccent.shade100);
      case 'Responsibility': return Container(color: Colors.blueGrey.shade700);
      case 'Risk': return Container(color: Colors.deepOrange.shade400);
      case 'Sacrifice': return Container(color: Colors.deepOrangeAccent.shade100);
      case 'Self-Discovery': return Container(color: Colors.deepPurpleAccent.shade700);
      case 'Self-Improvement': return Container(color: Colors.greenAccent.shade200);
      case 'Self-Love': return Container(color: Colors.pinkAccent.shade400);
      case 'Service': return Container(color: Colors.brown.shade500);
      case 'Silence': return Container(color: Colors.blueGrey.shade900);
      case 'Simplicity': return Container(color: Colors.white);
      case 'Sincerity': return Container(color: Colors.amber.shade600);
      case 'Spirituality': return Container(color: Colors.purple.shade300);
      case 'Strength': return Container(color: Colors.redAccent.shade700);
      case 'Success': return Container(color: Colors.green.shade900);
      case 'Teamwork': return Container(color: Colors.cyanAccent.shade400);
      case 'Time': return Container(color: Colors.blueGrey.shade300);
      case 'Travel': return Container(color: Colors.lightBlueAccent.shade100);
      case 'Trust': return Container(color: Colors.blueGrey.shade500);
      case 'Unity': return Container(color: Colors.cyan.shade800);
      case 'Value': return Container(color: Colors.amber.shade900);
      case 'Vision': return Container(color: Colors.purpleAccent.shade100);
      case 'Wealth': return Container(color: Colors.amberAccent.shade400);
      case 'Wellness': return Container(color: Colors.green.shade300);
      case 'Wisdom': return Container(color: Colors.blueAccent.shade700);
      case 'Wisdom of Age': return Container(color: Colors.grey.shade500);
      case 'Worry & Anxiety': return Container(color: Colors.blueGrey.shade800);
      case 'Youth': return Container(color: Colors.lightBlue.shade200);
      case 'Uncategorized': return Container(color: Colors.grey.shade700);
      default: return Container(color: Colors.grey.shade900);
    }
  }
}
