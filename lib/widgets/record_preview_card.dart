import 'package:flutter/material.dart';

class RecordPreviewCard extends StatelessWidget {
  final String quote;
  final String author;
  final String userName;
  final String imageUrl;
  final String emoji;
  final String category;
  final String uploaderText;
  final int randomSeed;

  const RecordPreviewCard({
    Key? key,
    required this.quote,
    required this.author,
    required this.userName,
    required this.imageUrl,
    required this.emoji,
    required this.category,
    required this.uploaderText,
    required this.randomSeed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
        const SizedBox(height: 12),
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          '"$quote"',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          '- $author -',
          style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          uploaderText,
          style: const TextStyle(fontSize: 14, color: Colors.green),
        ),
      ],
    );
  }
}
