// lib/widgets/non_intrusive_emoji_rain.dart

import 'dart:math';
import 'package:flutter/material.dart';

class NonIntrusiveEmojiRain extends StatefulWidget {
  final String emoji;
  final int? randomSeed; // For deterministic pattern
  final int count;
  final Duration duration;
  final double? progress; // Optional: set [0.0 - 1.0] for frame-by-frame control

  const NonIntrusiveEmojiRain({
    Key? key,
    required this.emoji,
    this.randomSeed,
    this.count = 24,
    this.duration = const Duration(seconds: 30),
    this.progress, // If null, animates live; if set, shows fixed "moment"
  }) : super(key: key);

  @override
  State<NonIntrusiveEmojiRain> createState() => _NonIntrusiveEmojiRainState();
}

class _EmojiParticle {
  double x, y, size, speed, delay;
  _EmojiParticle(this.x, this.y, this.size, this.speed, this.delay);
}

class _NonIntrusiveEmojiRainState extends State<NonIntrusiveEmojiRain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_EmojiParticle> _particles;
  late Random _rnd;

  @override
  void initState() {
    super.initState();
    _rnd = Random(widget.randomSeed ?? 0);

    // Controller only used for live animation (when progress is not set)
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.progress == null) {
      _controller.repeat();
    }

    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(widget.count, (_) {
      final x = _rnd.nextDouble();
      final y = _rnd.nextDouble();
      final size = 36.0 + _rnd.nextDouble() * 24;
      final speed = 0.12 + _rnd.nextDouble() * 0.18;
      final delay = _rnd.nextDouble();
      return _EmojiParticle(x, y, size, speed, delay);
    });
  }

  @override
  void didUpdateWidget(covariant NonIntrusiveEmojiRain oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If animation mode changed, update controller
    if (widget.progress == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.progress != null && _controller.isAnimating) {
      _controller.stop();
    }
    // Re-generate particles if count or seed changed
    if (oldWidget.randomSeed != widget.randomSeed ||
        oldWidget.count != widget.count) {
      _rnd = Random(widget.randomSeed ?? 0);
      _initParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _currentT() {
    // If progress is passed, use it; else use controller's value (live)
    if (widget.progress != null) return widget.progress!.clamp(0.0, 1.0);
    return _controller.value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final paintRain = (double t) {
          return Stack(
            children: _particles.map((p) {
              // Each emoji's Y position advances with (t + p.delay), wraps at 1.0
              final y = ((t + p.delay) % 1.0) * constraints.maxHeight;
              final x = p.x * constraints.maxWidth;
              return Positioned(
                left: x,
                top: y,
                child: Text(
                  widget.emoji,
                  style: TextStyle(
                    fontSize: p.size,
                    shadows: const [
                      Shadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        };

        if (widget.progress != null) {
          // Frame mode: show one "moment"
          return paintRain(_currentT());
        }

        // Live animated mode
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => paintRain(_currentT()),
        );
      },
    );
  }
}
