import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuoteShareHomeReplica extends StatelessWidget {
  final String quote;
  final String author;
  final String? imageUrl;
  final String? userName;
  final String? category;
  final String? language;
  final int? randomSeed;
  final bool? animationsEnabled;

  const QuoteShareHomeReplica({
    Key? key,
    required this.quote,
    required this.author,
    this.imageUrl,
    this.userName,
    this.category,
    this.language,
    this.randomSeed,
    this.animationsEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (ctx, _) => Container(color: Colors.grey.shade300),
              errorWidget: (ctx, _, __) => Container(color: Colors.black12),
            )
          else
            Container(color: Colors.black),
          Container(
            color: Colors.black.withOpacity(0.40),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '"$quote"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 16),
                Text(
                  '- $author -',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.none, // <- NO underline
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                if (userName != null && userName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    userName!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none, // <- NO underline
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
