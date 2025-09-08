import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qns/widgets/falling_emoji_effect.dart';
import 'package:video_player/video_player.dart';

// Make sure FallingEmojiEffect is imported in your file/project

class SharedVideoCard extends StatefulWidget {
  final String videoPath;
  final String quote;
  final String author;
  final String userName;
  final String emoji;

  const SharedVideoCard({
    Key? key,
    required this.videoPath,
    required this.quote,
    required this.author,
    required this.userName,
    required this.emoji,
  }) : super(key: key);

  @override
  State<SharedVideoCard> createState() => _SharedVideoCardState();
}

class _SharedVideoCardState extends State<SharedVideoCard> {
  late VideoPlayerController _controller;
  bool _showPlayOverlay = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.setLooping(true);
        _controller.play();
      }).catchError((_) {
        setState(() {
          _error = true;
        });
      });
    _controller.addListener(() {
      if (!mounted) return;
      setState(() {}); // For play/pause/seek updates
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showPlayOverlay = true);
    } else {
      _controller.play();
      setState(() => _showPlayOverlay = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = 380.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: cardHeight,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video or error/loader
            if (_error)
              Center(
                child: Text(
                  "Could not load video.",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              )
            else if (_controller.value.isInitialized)
              GestureDetector(
                onTap: _togglePlayPause,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoPlayer(_controller),
                    // Play overlay icon
                    if (!_controller.value.isPlaying || _showPlayOverlay)
                      Center(
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white70,
                            size: 70,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),

            // Black transparent overlay for readability
            Container(color: Colors.black.withOpacity(0.4)),

            // Animated emoji background
            IgnorePointer(child: FallingEmojiEffect(emoji: widget.emoji)),

            // Text overlays
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '"${widget.quote}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black54,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '- ${widget.author} -',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.tealAccent,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploaded by ${widget.userName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
