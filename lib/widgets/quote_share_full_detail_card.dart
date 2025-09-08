import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuoteShareFullDetailCard extends StatelessWidget {
  final String quote;
  final String author;
  final String imageUrl;
  // Removed: final String? emoji;
  final String? category;
  final String? language;
  final Color? categoryColor;

  const QuoteShareFullDetailCard({
    Key? key,
    required this.quote,
    required this.author,
    required this.imageUrl,
    // Removed: this.emoji,
    this.category,
    this.language,
    this.categoryColor,
  }) : super(key: key);

  Widget _buildImage(BuildContext context) {
    // Use a placeholder asset if the URL is empty or invalid.
    if (imageUrl.trim().isEmpty) {
      return Image.asset(
        'assets/placeholder_bg.jpg',
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (ctx, _) => Container(color: Colors.grey.shade300),
      errorWidget: (ctx, _, __) => Image.asset(
        'assets/placeholder_bg.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(context),
          Container(color: Colors.black.withOpacity(0.42)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      quote.trim().isNotEmpty ? '"$quote"' : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 27,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        decoration: TextDecoration.none,
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
                  author.trim().isNotEmpty ? '- $author -' : '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (category != null && category!.trim().isNotEmpty)
                      Text(
                        category!,
                        style: TextStyle(
                          color: categoryColor ?? Colors.amberAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none,
                          shadows: const [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (language != null &&
                    language!.trim().isNotEmpty &&
                    language!.toLowerCase() != 'en')
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Language: ${language!.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.none,
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
