// lib/widgets/animated_emoji_rain_with_exclusion.dart

import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedEmojiRainWithExclusion extends StatefulWidget {
  final String emoji;
  final Rect excludeRect;
  final int emojiCount;
  final int? seed;
  final double? progress; // Use this to control the animation externally

  const AnimatedEmojiRainWithExclusion({
    Key? key,
    required this.emoji,
    required this.excludeRect,
    this.emojiCount = 20,
    this.seed,
    this.progress,
  }) : super(key: key);

  @override
  State<AnimatedEmojiRainWithExclusion> createState() =>
      _AnimatedEmojiRainWithExclusionState();
}

class _EmojiDrop {
  double x, y, speed, size;
  _EmojiDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}

class _AnimatedEmojiRainWithExclusionState extends State<AnimatedEmojiRainWithExclusion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_EmojiDrop> _emojis;
  late Random rnd;

  @override
  void initState() {
    super.initState();
    rnd = Random(widget.seed ?? 2024);
    _initEmojis();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  void _initEmojis() {
    _emojis = List.generate(widget.emojiCount, (i) {
      return _EmojiDrop(
        x: rnd.nextDouble(),
        y: -rnd.nextDouble() * 0.3, // start slightly above top
        speed: 0.12 + rnd.nextDouble() * 0.10,
        size: 32 + rnd.nextDouble() * 24,
      );
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedEmojiRainWithExclusion oldWidget) {
    if (oldWidget.emoji != widget.emoji ||
        oldWidget.emojiCount != widget.emojiCount ||
        oldWidget.excludeRect != widget.excludeRect) {
      _initEmojis();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use widget.progress when provided (export mode), otherwise use _controller.value (preview/live mode)
    final double animValue = widget.progress ?? _controller.value;

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _EmojiRainPainter(
          emojis: _emojis,
          emoji: widget.emoji,
          progress: animValue,
          excludeRect: widget.excludeRect,
        ),
      ),
    );
  }
}

class _EmojiRainPainter extends CustomPainter {
  final List<_EmojiDrop> emojis;
  final String emoji;
  final double progress;
  final Rect excludeRect;
  final TextPainter _tp = TextPainter(textDirection: TextDirection.ltr);

  _EmojiRainPainter({
    required this.emojis,
    required this.emoji,
    required this.progress,
    required this.excludeRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in emojis) {
      double startY = e.y * size.height;
      double endY = size.height + e.size;
      double y = startY + (endY - startY) * progress * e.speed;

      double x = e.x * size.width;

      // Don't draw if inside the excludeRect (the text area)
      Rect emojiRect = Rect.fromCenter(center: Offset(x, y), width: e.size, height: e.size);
      if (excludeRect.overlaps(emojiRect)) continue;

      // Fade in at top, fade out at bottom
      double fade = 1.0;
      if (y < size.height * 0.10) fade = (y / (size.height * 0.10)).clamp(0.0, 1.0);
      if (y > size.height * 0.90) fade = ((size.height - y) / (size.height * 0.10)).clamp(0.0, 1.0);

      _tp.text = TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: e.size,
          color: Colors.white.withOpacity(0.75 * fade),
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.28 * fade), blurRadius: 2),
          ],
        ),
      );
      _tp.layout();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(0); // (optionally: add random rotation)
      _tp.paint(canvas, Offset(-_tp.width / 2, -_tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _EmojiRainPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.emoji != emoji ||
      oldDelegate.excludeRect != excludeRect ||
      oldDelegate.emojis != emojis;
}
