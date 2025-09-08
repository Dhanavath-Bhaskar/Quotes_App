// lib/utils/save_to_shared_media.dart

import 'package:qns/utils/shared_image_store.dart';

Future<void> saveToSharedMedia({
  required String quote,
  required String author,
  required String userName,
  required String backgroundImagePath, // local file path, only BG image, no overlays!
  required String category,
  required String language,
  required String emoji,
  String? originalBgUrl,
}) async {
  await SharedImageStore.add({
    'quote': quote,
    'author': author,
    'userName': userName,
    'imagePath': backgroundImagePath, // <-- FIXED: always this string key
    'category': category,
    'emoji': emoji,
    'imageUrl': originalBgUrl ?? '', // fallback to '' if not set
    'sharedAt': DateTime.now().toIso8601String(),
    'language': language,
  });
}
