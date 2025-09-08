import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/settings_provider.dart';

// --- FULL ISO 639-1 Language List: (code, name) ---
const supportedLangs = [
  {'code': 'af', 'name': 'Afrikaans'},
  {'code': 'sq', 'name': 'Albanian'},
  {'code': 'am', 'name': 'Amharic'},
  {'code': 'ar', 'name': 'Arabic'},
  {'code': 'hy', 'name': 'Armenian'},
  {'code': 'az', 'name': 'Azerbaijani'},
  {'code': 'eu', 'name': 'Basque'},
  {'code': 'be', 'name': 'Belarusian'},
  {'code': 'bn', 'name': 'Bengali'},
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
  {'code': 'nl', 'name': 'Dutch'},
  {'code': 'en', 'name': 'English'},
  {'code': 'eo', 'name': 'Esperanto'},
  {'code': 'et', 'name': 'Estonian'},
  {'code': 'fi', 'name': 'Finnish'},
  {'code': 'fr', 'name': 'French'},
  {'code': 'fy', 'name': 'Frisian'},
  {'code': 'gl', 'name': 'Galician'},
  {'code': 'ka', 'name': 'Georgian'},
  {'code': 'de', 'name': 'German'},
  {'code': 'el', 'name': 'Greek'},
  {'code': 'gu', 'name': 'Gujarati'},
  {'code': 'ht', 'name': 'Haitian Creole'},
  {'code': 'ha', 'name': 'Hausa'},
  {'code': 'haw', 'name': 'Hawaiian'},
  {'code': 'iw', 'name': 'Hebrew'},
  {'code': 'hi', 'name': 'Hindi'},
  {'code': 'hmn', 'name': 'Hmong'},
  {'code': 'hu', 'name': 'Hungarian'},
  {'code': 'is', 'name': 'Icelandic'},
  {'code': 'ig', 'name': 'Igbo'},
  {'code': 'id', 'name': 'Indonesian'},
  {'code': 'ga', 'name': 'Irish'},
  {'code': 'it', 'name': 'Italian'},
  {'code': 'ja', 'name': 'Japanese'},
  {'code': 'jw', 'name': 'Javanese'},
  {'code': 'kn', 'name': 'Kannada'},
  {'code': 'kk', 'name': 'Kazakh'},
  {'code': 'km', 'name': 'Khmer'},
  {'code': 'ko', 'name': 'Korean'},
  {'code': 'ku', 'name': 'Kurdish (Kurmanji)'},
  {'code': 'ky', 'name': 'Kyrgyz'},
  {'code': 'lo', 'name': 'Lao'},
  {'code': 'la', 'name': 'Latin'},
  {'code': 'lv', 'name': 'Latvian'},
  {'code': 'lt', 'name': 'Lithuanian'},
  {'code': 'lb', 'name': 'Luxembourgish'},
  {'code': 'mk', 'name': 'Macedonian'},
  {'code': 'mg', 'name': 'Malagasy'},
  {'code': 'ms', 'name': 'Malay'},
  {'code': 'ml', 'name': 'Malayalam'},
  {'code': 'mt', 'name': 'Maltese'},
  {'code': 'mi', 'name': 'Maori'},
  {'code': 'mr', 'name': 'Marathi'},
  {'code': 'mn', 'name': 'Mongolian'},
  {'code': 'my', 'name': 'Myanmar (Burmese)'},
  {'code': 'ne', 'name': 'Nepali'},
  {'code': 'no', 'name': 'Norwegian'},
  {'code': 'or', 'name': 'Odia (Oriya)'},
  {'code': 'ps', 'name': 'Pashto'},
  {'code': 'fa', 'name': 'Persian'},
  {'code': 'pl', 'name': 'Polish'},
  {'code': 'pt', 'name': 'Portuguese'},
  {'code': 'pa', 'name': 'Punjabi'},
  {'code': 'ro', 'name': 'Romanian'},
  {'code': 'ru', 'name': 'Russian'},
  {'code': 'sm', 'name': 'Samoan'},
  {'code': 'gd', 'name': 'Scots Gaelic'},
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
  {'code': 'tl', 'name': 'Tagalog (Filipino)'},
  {'code': 'tg', 'name': 'Tajik'},
  {'code': 'ta', 'name': 'Tamil'},
  {'code': 'tt', 'name': 'Tatar'},
  {'code': 'te', 'name': 'Telugu'},
  {'code': 'th', 'name': 'Thai'},
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


class VideoPlayerScreen extends StatefulWidget {
  final String videoPath; // Local file path or network URL
  final String? quote;
  final String? author;
  final String? category;
  final String? thumbnailPath;

  const VideoPlayerScreen({
    Key? key,
    required this.videoPath,
    this.quote,
    this.author,
    this.category,
    this.thumbnailPath,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isError = false;
  bool _showControls = true;
  bool _muted = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      if (widget.videoPath.startsWith('http') || widget.videoPath.startsWith('https')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      } else {
        _controller = VideoPlayerController.file(File(widget.videoPath));
      }
      await _controller.initialize();
      setState(() {
        _initialized = true;
      });
      if (mounted) _controller.play();
      _controller.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    if (_initialized) _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      _controller.setVolume(_muted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: true);
    final textSize = settings.textSize;
    final accent = Color(settings.accentColor);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.category ?? 'Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * textSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: accent),
      ),
      body: _isError
          ? Center(
              child: Text(
                'Could not load video.',
                style: TextStyle(color: Colors.white, fontSize: 18 * textSize),
              ),
            )
          : !_initialized
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onTap: _toggleControls,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      if (_showControls)
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _showControls ? 1 : 0,
                            child: Container(
                              color: Colors.black45,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (widget.quote != null && widget.quote!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
                                      child: Text(
                                        '"${widget.quote!}"',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22 * textSize,
                                          fontStyle: FontStyle.italic,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 10,
                                              color: Colors.black,
                                              offset: Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  if (widget.author != null && widget.author!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        '- ${widget.author!} -',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16 * textSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  _videoControls(accent, textSize),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _videoControls(Color accent, double textSize) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                backgroundColor: Colors.grey,
                playedColor: accent,
                bufferedColor: Colors.white30,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30 * textSize,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    _muted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 24 * textSize,
                  ),
                  onPressed: _toggleMute,
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: () {
                    final pos = _controller.value.position - const Duration(seconds: 10);
                    _controller.seekTo(pos > Duration.zero ? pos : Duration.zero);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: () {
                    final pos = _controller.value.position + const Duration(seconds: 10);
                    _controller.seekTo(
                      pos < _controller.value.duration ? pos : _controller.value.duration,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
