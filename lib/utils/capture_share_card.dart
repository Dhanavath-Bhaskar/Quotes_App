import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qns/utils/shared_image_store.dart';

Future<File?> captureAndSaveShareCard(GlobalKey cardKey, Map<String, String> meta) async {
  try {
    final boundary = cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final pngBytes = byteData.buffer.asUint8List();
    final docs = await getApplicationDocumentsDirectory();
    final file = File('${docs.path}/shared_card_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes);

    // Save to your SharedImageStore
    await SharedImageStore.add({
      'quote': meta['quote'] ?? '',
      'author': meta['author'] ?? '',
      'userName': meta['userName'] ?? '',
      'imagePath': file.path,
      'category': meta['category'] ?? '',
      'emoji': meta['emoji'] ?? '',
      'imageUrl': meta['imageUrl'] ?? '',
      'sharedAt': DateTime.now().toIso8601String(),
      'language': meta['language'] ?? 'en',
    });
    return file;
  } catch (e) {
    print('Error capturing card: $e');
    return null;
  }
}
