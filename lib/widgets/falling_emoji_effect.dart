// lib/widgets/falling_emoji_effect.dart

import 'dart:math';
import 'package:flutter/material.dart';

class FallingEmojiEffect extends StatefulWidget {
  final String emoji;
  final int count;
  final Duration duration;
  final int? randomSeed; // To get a repeatable pattern if needed

  const FallingEmojiEffect({
    Key? key,
    required this.emoji,
    this.count = 8, // 👈 Default reduced for more attractive, less crowded effect!
    this.duration = const Duration(seconds: 8),
    this.randomSeed,
  }) : super(key: key);

  @override
  State<FallingEmojiEffect> createState() => _FallingEmojiEffectState();
}

class _EmojiParticle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double drift;
  late double opacity;
  late double angle;
  _EmojiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.angle,
  });
}

class _FallingEmojiEffectState extends State<FallingEmojiEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_EmojiParticle> _particles;
  late Random _rnd;
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _rnd = Random(widget.randomSeed ?? DateTime.now().millisecondsSinceEpoch);
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(_tick)
     ..repeat();
    _particles = [];
  }

  void _initParticles(Size size) {
    _particles = List.generate(widget.count, (i) {
      final x = _rnd.nextDouble() * size.width;
      final y = _rnd.nextDouble() * size.height;
      final s = 28.0 + _rnd.nextDouble() * 22.0;
      final sp = 0.9 + _rnd.nextDouble() * 1.5;
      final drift = -0.7 + _rnd.nextDouble() * 1.4;
      final op = 0.7 + _rnd.nextDouble() * 0.3;
      final angle = _rnd.nextDouble() * 2 * pi;
      return _EmojiParticle(
        x: x,
        y: y,
        size: s,
        speed: sp,
        drift: drift,
        opacity: op,
        angle: angle,
      );
    });
  }

  void _tick() {
    if (_lastSize == null) return;
    final height = _lastSize!.height;
    final width = _lastSize!.width;

    setState(() {
      for (var p in _particles) {
        p.y += p.speed;
        p.x += p.drift * 0.5;
        p.angle += 0.01 + 0.02 * _rnd.nextDouble();

        // Respawn at top if out of screen
        if (p.y > height + 32) {
          p.y = -32;
          p.x = _rnd.nextDouble() * width;
          p.size = 28.0 + _rnd.nextDouble() * 22.0;
          p.speed = 0.9 + _rnd.nextDouble() * 1.5;
          p.drift = -0.7 + _rnd.nextDouble() * 1.4;
          p.opacity = 0.7 + _rnd.nextDouble() * 0.3;
          p.angle = _rnd.nextDouble() * 2 * pi;
        }
        if (p.x < -32) p.x = width + 32;
        if (p.x > width + 32) p.x = -32;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_lastSize == null || size != _lastSize) {
          _lastSize = size;
          _initParticles(size);
        }
        return IgnorePointer(
          ignoring: true, // Touch events pass through
          child: CustomPaint(
            size: size,
            painter: _EmojiPainter(widget.emoji, _particles),
          ),
        );
      },
    );
  }
}

class _EmojiPainter extends CustomPainter {
  final String emoji;
  final List<_EmojiParticle> particles;
  final TextStyle style;

  _EmojiPainter(this.emoji, this.particles)
      : style = const TextStyle(fontSize: 32);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final tp = TextPainter(
        text: TextSpan(
          text: emoji,
          style: style.copyWith(
            fontSize: p.size,
            color: Colors.white.withOpacity(p.opacity),
            shadows: [
              const Shadow(
                blurRadius: 6,
                color: Colors.black54,
                offset: Offset(2, 4),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.angle);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_EmojiPainter old) =>
      old.emoji != emoji || old.particles != particles;
}
