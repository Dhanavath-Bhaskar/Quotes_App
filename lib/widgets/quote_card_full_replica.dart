import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- Category Emoji Mapping ---
const Map<String, String> kCategoryEmoji = {
  'All': '🌸',
  'Creativity & Inspiration': '🎨',
  'Worry & Anxiety': '🧘‍♂️',
  'Mindfulness & Letting Go': '🍃',
  'Happiness & Joy': '😊',
  'Motivation & Achievement': '🏆',
  'Relationships & Connection': '❤️',
  'Peace & Inner Calm': '☮️',
  'Philosophy': '📚',
  'Uncategorized': '✨',
};

// --- Placeholder FallingEmojiEffect Widget ---
// Replace this with your actual effect widget
class FallingEmojiEffect extends StatelessWidget {
  final String emoji;
  final int? randomSeed;

  const FallingEmojiEffect({Key? key, required this.emoji, this.randomSeed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // You should use your real animation here.
    return IgnorePointer(
      child: Container(), // replace with animated emoji effect
    );
  }
}

// --- Main Replica Widget ---
class QuoteCardFullReplica extends StatelessWidget {
  final String quote;
  final String author;
  final String userName;
  final String imageUrl;
  final String emoji;
  final String category;
  final String language;
  final int? randomSeed;
  final Widget? centerOverlay; // For play icon etc.

  const QuoteCardFullReplica({
    Key? key,
    required this.quote,
    required this.author,
    required this.userName,
    required this.imageUrl,
    required this.emoji,
    required this.category,
    required this.language,
    this.randomSeed,
    this.centerOverlay,
  }) : super(key: key);

  // Optional: Example for a category chip row (customize as needed)
  Widget _buildCategoryChipRow(BuildContext context) {
    final cats = kCategoryEmoji.keys.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cats.map((cat) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Chip(
              label: Text(cat,
                  style: TextStyle(
                      color: cat == category ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold)),
              backgroundColor: cat == category ? Colors.teal : Colors.grey[200],
              avatar: Text(kCategoryEmoji[cat] ?? ''),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // --- 1. Background image ---
        imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: Colors.black),
                placeholder: (_, __) => Container(color: Colors.black54),
              )
            : Container(color: Colors.black),

        // --- 2. Falling emojis behind text ---
        FallingEmojiEffect(emoji: emoji, randomSeed: randomSeed),

        // --- 3. Black overlay for readability ---
        Container(color: Colors.black.withOpacity(0.4)),

        // --- 4. Top UI: category chip row & language ---
        Padding(
          padding: const EdgeInsets.only(top: 36, left: 12, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryChipRow(context),
              const SizedBox(height: 8),
              Text(
                'భాష: ${language.toUpperCase()}',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ),

        // --- 5. Main quote content in the center ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                radius: 34,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '"$quote"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(blurRadius: 3, color: Colors.black, offset: Offset(1, 1)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '- $author -',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                  ],
                ),
              ),
              if (userName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    'Uploaded by $userName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 22.0, bottom: 4),
                child: Text(
                  '$emoji  $category',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- 6. Play icon (or any overlay) ---
        if (centerOverlay != null) Center(child: centerOverlay!),
      ],
    );
  }
}
