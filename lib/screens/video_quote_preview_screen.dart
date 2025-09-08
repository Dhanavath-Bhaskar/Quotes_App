import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:qns/widgets/falling_emoji_effect.dart';

const Map<String, String> _categoryEmoji = {
  'All': '🌸',
  'Creativity & Inspiration': '🎨',
  'Worry & Anxiety': '🧘‍♂️',
  'Mindfulness & Letting Go': '🍃',
  'Happiness & Joy': '😊',
  'Motivation & Achievement': '🏆',
  'Relationships & Connection': '❤️',
  'Peace & Inner Calm': '☮️',
  'Philosophy': '📚',
  'Uncategorized': '✨',
};

class VideoQuotePreviewScreen extends StatefulWidget {
  final String videoPath; // Local file path or network URL
  final String videoQuote;
  final String videoAuthor;
  final String videoUploader;
  final String videoCategory;
  final String videoLanguage;
  final int? videoRandomSeed;

  const VideoQuotePreviewScreen({
    Key? key,
    required this.videoPath,
    required this.videoQuote,
    required this.videoAuthor,
    required this.videoUploader,
    required this.videoCategory,
    required this.videoLanguage,
    this.videoRandomSeed,
  }) : super(key: key);

  @override
  State<VideoQuotePreviewScreen> createState() => _VideoQuotePreviewScreenState();
}

class _VideoQuotePreviewScreenState extends State<VideoQuotePreviewScreen> {
  late VideoPlayerController _controller;
  bool _showControls = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }
    _controller.initialize().then((_) {
      setState(() => _isInit = true);
      _controller.play();
    });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.videoCategory;
    final emoji = _categoryEmoji[category] ?? '✨';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Video Quote Preview', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video background
          _isInit && _controller.value.isInitialized
              ? GestureDetector(
                  onTap: () => setState(() => _showControls = !_showControls),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),

          // Falling emojis background
          IgnorePointer(
            child: FallingEmojiEffect(
              emoji: emoji,
              randomSeed: widget.videoRandomSeed,
            ),
          ),

          // Semi-transparent overlay for readability
          Container(color: Colors.black.withOpacity(0.15)),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The quote text
                  Text(
                    '"${widget.videoQuote}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      shadows: [
                        Shadow(blurRadius: 6, color: Colors.black, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // The author
                  Text(
                    '- ${widget.videoAuthor} -',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(blurRadius: 3, color: Colors.black, offset: Offset(1, 1)),
                      ],
                    ),
                  ),

                  // Uploader
                  if (widget.videoUploader.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Uploaded by ${widget.videoUploader}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Category and language at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji & Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.videoCategory,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Language
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Language: ${widget.videoLanguage.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating play/pause button
          if (_isInit && _controller.value.isInitialized)
            Positioned(
              bottom: 80,
              right: 28,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    _showControls = false;
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
