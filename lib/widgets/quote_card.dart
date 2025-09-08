import 'dart:io';
import 'package:flutter/material.dart';
import 'falling_emoji_effect.dart';

class QuoteCard extends StatelessWidget {
  final String quote;
  final String author;
  final String userName;
  final String? imageUrl;
  final String emoji;
  final bool showFallingEmoji;
  final String? language;

  const QuoteCard({
    Key? key,
    required this.quote,
    required this.author,
    required this.userName,
    required this.imageUrl,
    required this.emoji,
    this.showFallingEmoji = true,
    this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 380;

    Widget _buildImage() {
      if (imageUrl != null && imageUrl!.isNotEmpty) {
        if (imageUrl!.startsWith('http')) {
          return Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey.shade300),
          );
        } else if (File(imageUrl!).existsSync()) {
          return Image.file(
            File(imageUrl!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey.shade300),
          );
        }
      }
      return Container(color: Colors.grey.shade300);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: cardHeight,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            Container(color: Colors.black.withOpacity(0.4)),
            if (showFallingEmoji)
              IgnorePointer(child: FallingEmojiEffect(emoji: emoji))
            else
              Positioned.fill(child: _StaticEmojiOverlay(emoji: emoji)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // QUOTE
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Text(
                      '"$quote"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.23,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // AUTHOR
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    child: Text(
                      '- $author -',
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // UPLOADER
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child: Text(
                      'Uploaded by $userName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 1)],
                      ),
                    ),
                  ),
                  if (language != null && language!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: Text(
                          'Language: ${language!.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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

class _StaticEmojiOverlay extends StatelessWidget {
  final String emoji;
  const _StaticEmojiOverlay({Key? key, required this.emoji}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 18, left: 20, child: Text(emoji, style: const TextStyle(fontSize: 34))),
        Positioned(top: 56, right: 36, child: Text(emoji, style: const TextStyle(fontSize: 28))),
        Positioned(bottom: 22, left: 32, child: Text(emoji, style: const TextStyle(fontSize: 28))),
        Positioned(bottom: 18, right: 28, child: Text(emoji, style: const TextStyle(fontSize: 36))),
        Positioned(top: 90, left: 90, child: Text(emoji, style: const TextStyle(fontSize: 24))),
        Positioned(bottom: 100, right: 70, child: Text(emoji, style: const TextStyle(fontSize: 20))),
        Positioned(top: 120, right: 120, child: Text(emoji, style: const TextStyle(fontSize: 22))),
      ],
    );
  }
}
