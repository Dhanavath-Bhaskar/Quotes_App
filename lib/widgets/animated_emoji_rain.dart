import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedEmojiRain extends StatefulWidget {
  final String emoji;
  final int count;
  final int? seed;
  final Duration duration;

  const AnimatedEmojiRain({
    Key? key,
    required this.emoji,
    this.count = 24,
    this.seed,
    this.duration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<AnimatedEmojiRain> createState() => _AnimatedEmojiRainState();
}

class _EmojiParticle {
  final double startX;
  final double speed;
  final double size;
  final double delay;
  final double rotation;
  _EmojiParticle(this.startX, this.speed, this.size, this.delay, this.rotation);
}

class _AnimatedEmojiRainState extends State<AnimatedEmojiRain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_EmojiParticle> _particles;
  late Random _rnd;

  @override
  void initState() {
    super.initState();
    _rnd = Random(widget.seed ?? 1234);
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _particles = List.generate(widget.count, (i) {
      return _EmojiParticle(
        _rnd.nextDouble(), // X (fraction)
        0.6 + _rnd.nextDouble() * 0.6, // Speed multiplier
        26 + _rnd.nextDouble() * 22, // Size
        _rnd.nextDouble(), // Delay fraction
        _rnd.nextDouble() * pi * 2, // Random rotation
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxW = constraints.maxWidth;
      final maxH = constraints.maxHeight;
      return AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _controller.value;
          return Stack(
            children: [
              for (var p in _particles)
                Positioned(
                  left: p.startX * (maxW - p.size),
                  top: (((t + p.delay) % 1.0) * maxH * p.speed) % (maxH + p.size) - p.size,
                  child: Transform.rotate(
                    angle: p.rotation + t * 1.5,
                    child: Text(
                      widget.emoji,
                      style: TextStyle(fontSize: p.size),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });
  }
}
