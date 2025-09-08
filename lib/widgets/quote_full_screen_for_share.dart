import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuoteFullScreenForShare extends StatelessWidget {
  final String quote, author, imageUrl, category, language;
  final Color? categoryColor;

  const QuoteFullScreenForShare({
    Key? key,
    required this.quote,
    required this.author,
    required this.imageUrl,
    required this.category,
    required this.language,
    this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the device size to ensure full coverage, no black bars
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            placeholder: (ctx, _) => Container(color: Colors.black12),
            errorWidget: (ctx, _, __) => Container(color: Colors.black26),
          ),
          // Optional dark overlay for better text contrast
          Container(color: Colors.black.withOpacity(0.34)),
          // Main quote and details
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quote
                  Text(
                    '"$quote"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      decoration: TextDecoration.none, // No underline!
                      shadows: [Shadow(offset: Offset(1, 2), blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  SizedBox(height: 32),
                  // Author
                  Text(
                    '- $author -',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.none, // No underline!
                    ),
                  ),
                  SizedBox(height: 22),
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade700.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: categoryColor ?? Colors.amberAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        decoration: TextDecoration.none, // No underline!
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Language
                  Text(
                    "Language: ${language.toUpperCase()}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.none, // No underline!
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

