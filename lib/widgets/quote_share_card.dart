import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuoteShareCard extends StatelessWidget {
  final String imageUrl;
  final String quote;
  final String author;
  final String emoji;
  final int emojiCount;
  final String? userName;

  const QuoteShareCard({
    super.key,
    required this.imageUrl,
    required this.quote,
    required this.author,
    required this.emoji,
    this.userName,
    this.emojiCount = 16,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random(quote.hashCode ^ author.hashCode);
    // Change aspect ratio to match your HomeScreen
    return AspectRatio(
      aspectRatio: size.width / size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          // Emoji scatter background
          ...List.generate(emojiCount, (i) {
            final left = random.nextDouble() * 0.85;
            final top = random.nextDouble() * 0.7 + 0.08;
            final sz = 28.0 + random.nextDouble() * 30.0;
            return Positioned(
              left: left * size.width,
              top: top * size.height,
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: sz,
                  color: Colors.white.withOpacity(0.85),
                  shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                ),
              ),
            );
          }),
          // Quote text and author
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '"$quote"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '- $author -',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  if (userName != null && userName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Uploaded by $userName',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
