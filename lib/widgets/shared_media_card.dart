// lib/widgets/shared_media_card.dart

import 'dart:io';
import 'package:flutter/material.dart';

// You may want to use CachedNetworkImage for URLs
import 'package:cached_network_image/cached_network_image.dart';

class SharedMediaCard extends StatelessWidget {
  final String quote;
  final String author;
  final String uploader;
  final String imageUrl;
  final String emoji;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final String language;

  const SharedMediaCard({
    super.key,
    required this.quote,
    required this.author,
    required this.uploader,
    required this.imageUrl,
    required this.emoji,
    this.onShare,
    this.onDelete,
    this.language = 'en',
  });

  @override
  Widget build(BuildContext context) {
    // Handle both network and file images
    ImageProvider bgImage;
    if (imageUrl.startsWith('http')) {
      bgImage = CachedNetworkImageProvider(imageUrl);
    } else if (imageUrl.isNotEmpty) {
      bgImage = FileImage(File(imageUrl));
    } else {
      bgImage = const AssetImage('assets/placeholder.png');
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          // Background image with dark overlay for text contrast
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: bgImage,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.33),
              ),
            ),
          ),
          // Emoji decorations (simple scatter example, customize as you wish)
          ..._emojiScatter(),
          // Content
          Container(
            height: 300,
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '"$quote"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black87,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '- $author -',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uploaded by $uploader',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (language.isNotEmpty)
                  Text(
                    'Lang: $language',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Share & delete buttons
          Positioned(
            right: 18,
            top: 18,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 28),
                  onPressed: onShare,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Just a demo scatter. You can randomize for more variety.
  List<Widget> _emojiScatter() {
    return [
      Positioned(top: 22, left: 18, child: Text(emoji, style: const TextStyle(fontSize: 28))),
      Positioned(top: 50, right: 50, child: Text(emoji, style: const TextStyle(fontSize: 23))),
      Positioned(bottom: 20, left: 34, child: Text(emoji, style: const TextStyle(fontSize: 20))),
      Positioned(bottom: 32, right: 28, child: Text(emoji, style: const TextStyle(fontSize: 26))),
    ];
  }
}
