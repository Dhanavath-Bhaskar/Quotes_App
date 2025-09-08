import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuoteCardForShare extends StatelessWidget {
  final String quote;
  final String author;
  final String imageUrl;
  final String? emoji;
  final String? category;
  final String? language; // Should be ISO code ("en", "te" etc.)
  final Color? categoryColor;

  const QuoteCardForShare({
    Key? key,
    required this.quote,
    required this.author,
    required this.imageUrl,
    this.emoji,
    this.category,
    this.language,
    this.categoryColor,
  }) : super(key: key);

  String getLanguageLabel() {
    if (language == null) return '';
    if (language!.trim().isEmpty) return '';
    return language!.length == 2
        ? language!.toUpperCase()
        : language!;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (ctx, _) => Container(color: Colors.grey.shade300),
            errorWidget: (ctx, _, __) => Container(color: Colors.black12),
          ),
          Container(
            color: Colors.black.withOpacity(0.42),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      '"$quote"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                        decoration: TextDecoration.none, // <- NO underline
                        shadows: [
                          Shadow(
                            offset: Offset(1, 2),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  '- $author -',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.none, // <- NO underline
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (emoji != null && emoji!.isNotEmpty)
                      Text(
                        emoji!,
                        style: const TextStyle(fontSize: 24, decoration: TextDecoration.none),
                      ),
                    if (emoji != null && emoji!.isNotEmpty) const SizedBox(width: 8),
                    if (category != null && category!.isNotEmpty)
                      Text(
                        category!,
                        style: TextStyle(
                          color: categoryColor ?? Colors.amberAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none, // <- NO underline
                          shadows: [
                            const Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (language != null && language!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      'Language: ${getLanguageLabel()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.none, // <- NO underline
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
