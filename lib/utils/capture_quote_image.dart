import 'dart:io';
import 'package:flutter/material.dart';

class QuoteShareView extends StatelessWidget {
  final String quote;
  final String author;
  final String userName;
  final String? imageUrl;
  final String emoji;
  final String language;

  const QuoteShareView({
    Key? key,
    required this.quote,
    required this.author,
    required this.userName,
    required this.imageUrl,
    required this.emoji,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Match your main HomeScreen quote card style!
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 600,
        width: 360,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              (imageUrl!.startsWith('http')
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : File(imageUrl!).existsSync()
                      ? Image.file(File(imageUrl!), fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade300))
            else
              Container(color: Colors.grey.shade300),
            Container(color: Colors.black.withOpacity(0.4)),
            // Emojis or effects, add here if needed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '"$quote"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      shadows: [
                        Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '- $author -',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.tealAccent,
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Uploaded by $userName',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    language.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            // Add emoji overlay if you want
            Positioned(
              bottom: 28,
              right: 28,
              child: Text(emoji, style: const TextStyle(fontSize: 36)),
            ),
            Positioned(
              top: 18,
              left: 20,
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ],
        ),
      ),
    );
  }
}
