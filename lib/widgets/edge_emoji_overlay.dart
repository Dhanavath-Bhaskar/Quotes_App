import 'dart:math';
import 'package:flutter/material.dart';

class EdgeEmojiOverlay extends StatelessWidget {
  final String emoji;
  final int emojiCount;
  final int? seed;
  final Rect excludeRect; // Rectangle where the text is (don’t paint here)

  const EdgeEmojiOverlay({
    Key? key,
    required this.emoji,
    required this.excludeRect,
    this.emojiCount = 14,
    this.seed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _EdgeEmojiPainter(
            emoji: emoji,
            emojiCount: emojiCount,
            excludeRect: excludeRect,
            seed: seed,
          ),
        );
      },
    );
  }
}

class _EdgeEmojiPainter extends CustomPainter {
  final String emoji;
  final int emojiCount;
  final Rect excludeRect;
  final int? seed;
  final TextPainter _tp = TextPainter(textDirection: TextDirection.ltr);
  late final Random rnd;

  _EdgeEmojiPainter({
    required this.emoji,
    required this.emojiCount,
    required this.excludeRect,
    this.seed,
  }) {
    rnd = Random(seed ?? 42);
  }

  @override
  void paint(Canvas canvas, Size size) {
    int drawn = 0;
    int tries = 0;
    while (drawn < emojiCount && tries < emojiCount * 5) {
      tries++;
      // Random position
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final sz = 28.0 + rnd.nextDouble() * 22.0;

      final rect = Rect.fromCenter(center: Offset(dx, dy), width: sz, height: sz);
      if (!excludeRect.overlaps(rect)) {
        _tp.text = TextSpan(
          text: emoji,
          style: TextStyle(fontSize: sz, shadows: [
            Shadow(color: Colors.black.withOpacity(0.28), blurRadius: 2),
          ]),
        );
        _tp.layout();
        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(rnd.nextDouble() * 2 * pi);
        _tp.paint(canvas, Offset(-_tp.width / 2, -_tp.height / 2));
        canvas.restore();
        drawn++;
      }
    }
  }

  @override
  bool shouldRepaint(_EdgeEmojiPainter old) =>
      old.emoji != emoji ||
      old.emojiCount != emojiCount ||
      old.excludeRect != excludeRect;
}
