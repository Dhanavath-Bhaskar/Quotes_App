import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SharedQuoteCard extends StatelessWidget {
  final Map<String, dynamic> media;
  final List<dynamic>?
  pixabayImagesForCategory; // List of pixabay images for this category, can be null
  final String emoji;
  final Widget emojiEffect; // Pass your FallingEmojiEffect
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const SharedQuoteCard({
    Key? key,
    required this.media,
    this.pixabayImagesForCategory,
    required this.emoji,
    required this.emojiEffect,
    this.onShare,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Try uploaded image
    String? imageUrl = media['imageUrl'];
    // 2. Fallback to pixabay image by index (if needed)
    if ((imageUrl == null || imageUrl.isEmpty) &&
        pixabayImagesForCategory != null &&
        pixabayImagesForCategory!.isNotEmpty) {
      // Use hash of quote to pick a stable image
      int idx =
          media['quote'].hashCode.abs() % pixabayImagesForCategory!.length;
      imageUrl = pixabayImagesForCategory![idx]['largeImageURL'];
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background image
          imageUrl != null && imageUrl.isNotEmpty
              ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
                placeholder:
                    (context, url) =>
                        Container(color: Colors.grey.shade300, height: 220),
                errorWidget:
                    (context, url, error) =>
                        Container(color: Colors.grey.shade200, height: 220),
              )
              : Container(color: Colors.grey.shade200, height: 220),
          // Semi-transparent overlay
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.black.withOpacity(0.4),
          ),
          // Falling emoji effect (make sure widget is unique for category)
          emojiEffect,
          // Main quote text and author
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '"${media['quote']}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '- ${media['author']} -',
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (media['userName'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Uploaded by ${media['userName']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Share and Delete buttons (top right)
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onShare != null)
                  IconButton(
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: onShare,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
