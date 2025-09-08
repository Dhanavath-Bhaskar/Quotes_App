import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qns/widgets/quote_share_card.dart'; // update import as needed
import 'package:qns/utils/shared_image_store.dart';

Future<String?> generateShareCardImage({
  required BuildContext context,
  required String imageUrl,
  required String quote,
  required String author,
  required String emoji,
  required String? userName,
}) async {
  final boundaryKey = GlobalKey();

  // Create a widget in an Overlay to render off-screen
  final overlay = OverlayEntry(
    builder: (_) => Center(
      child: Material(
        color: Colors.transparent,
        child: RepaintBoundary(
          key: boundaryKey,
          child: SizedBox(
            width: 1080, // recommended width
            height: 1920, // recommended height
            child: QuoteShareCard(
              imageUrl: imageUrl,
              quote: quote,
              author: author,
              emoji: emoji,
              userName: userName,
              emojiCount: 24,
            ),
          ),
        ),
      ),
    ),
  );

  // Insert the overlay to render the widget
  Overlay.of(context).insert(overlay);

  await Future.delayed(const Duration(milliseconds: 350)); // allow rendering

  try {
    final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 2.5);

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final pngBytes = byteData.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes);

    // Add to SharedImageStore
    await SharedImageStore.add({'imagePath': file.path, 'imageUrl': imageUrl});

    return file.path;
  } finally {
    overlay.remove();
  }
}
