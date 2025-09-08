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
    this.imageUrl,
    required this.emoji,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image if provided
        if (imageUrl != null && imageUrl!.isNotEmpty)
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        Container(color: Colors.black.withOpacity(0.4)),
        // Quote content
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '"$quote"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    shadows: [
                      Shadow(blurRadius: 3, color: Colors.black, offset: Offset(2, 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '- $author -',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                  ),
                ),
                if (userName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Uploaded by $userName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    language.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
