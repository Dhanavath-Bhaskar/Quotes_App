// lib/screens/shared_quote_preview_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/quote_share_home_replica.dart';

class SharedQuotePreviewScreen extends StatelessWidget {
  final String quote;
  final String author;
  final String userName;
  final String imageUrl; // Always passed, either file or remote
  final String emoji;
  final String category;
  final String language;
  final int? randomSeed;

  const SharedQuotePreviewScreen({
    Key? key,
    required this.quote,
    required this.author,
    required this.userName,
    required this.imageUrl, // now required!
    required this.emoji,
    required this.category,
    required this.language,
    this.randomSeed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Figure out: local file path or remote URL
    final bool isLocalFile = imageUrl.isNotEmpty && !imageUrl.startsWith('http');
    final String bgImage = imageUrl;

    return Scaffold(
      appBar: AppBar(title: const Text("Quote Preview")),
      body: QuoteShareHomeReplica(
        quote: quote,
        author: author,
        userName: userName,
        imageUrl: bgImage,
        category: category,
        language: language,
        randomSeed: randomSeed ?? 1,
        animationsEnabled: true,
      ),
    );
  }
}

