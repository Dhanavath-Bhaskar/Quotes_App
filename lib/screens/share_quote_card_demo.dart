// lib/screens/share_quote_card_demo.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/quote_share_home_replica.dart';

class ShareQuoteCardDemo extends StatefulWidget {
  const ShareQuoteCardDemo({Key? key}) : super(key: key);

  @override
  State<ShareQuoteCardDemo> createState() => _ShareQuoteCardDemoState();
}

class _ShareQuoteCardDemoState extends State<ShareQuoteCardDemo> {
  final GlobalKey _shareKey = GlobalKey();

  // Example data for the card
  final String imageUrl =
      'https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg'; // or file path!
  final String quote = 'Peace comes from within. Do not seek it without.';
  final String author = 'Buddha';
  final String userName = 'Anonymous';
  final String emoji = '🧘‍♂️';
  final String category = 'Mindfulness & Letting Go';
  final bool animationsEnabled = false;
  final String language = 'en';

  Future<void> _shareQuoteCard() async {
    // 1️⃣ Precache image before rendering
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        await precacheImage(CachedNetworkImageProvider(imageUrl), context);
      } else if (File(imageUrl).existsSync()) {
        await precacheImage(FileImage(File(imageUrl)), context);
      }
    }

    await Future.delayed(const Duration(milliseconds: 80));

    // 2️⃣ Capture widget as image
    try {
      final boundary =
          _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('RenderBoundary is null');
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('byteData is null');
      final pngBytes = byteData.buffer.asUint8List();

      // 3️⃣ Save to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_quote_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      // 4️⃣ Share with share_plus
      await Share.shareXFiles([XFile(file.path)], text: '"$quote"\n- $author');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing card: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Quote Card Demo')),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 320,
              height: 480,
              child: RepaintBoundary(
                key: _shareKey,
                child: QuoteShareHomeReplica(
                  quote: quote,
                  author: author,
                  userName: userName,
                  imageUrl: imageUrl,
                  category: category,
                  animationsEnabled: animationsEnabled,
                  language: language,
                  randomSeed: 1, // <-- Fix: add a required randomSeed value
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share this card'),
              onPressed: _shareQuoteCard,
            ),
          ],
        ),
      ),
    );
  }
}
