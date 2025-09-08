// lib/utils/shared_media_manager.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

/// Uploads [localFile] (either image or video) to Firebase Storage
/// under `shared_media/{uid}/{type}/{timestamp}.{ext}` and then writes
/// a Firestore document in `users/{uid}/sharedMedia`.
class SharedMediaManager {
  SharedMediaManager._();
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;
  static final _firestore = FirebaseFirestore.instance;

  /// Call with type = 'image' or 'video'.
  static Future<void> saveAndUpload({
    required File localFile,
    required String type,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');

    final uid = user.uid;
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = p.extension(localFile.path).replaceFirst('.', '');
    final storagePath = 'shared_media/$uid/$type/$ts.$ext';

    // 1) Upload to Storage
    final ref = _storage.ref().child(storagePath);
    await ref.putFile(localFile);

    // 2) Get download URL
    final url = await ref.getDownloadURL();

    // 3) Write metadata to Firestore
    await _firestore.collection('users').doc(uid).collection('sharedMedia').add(
      {
        'type': type, // 'image' or 'video'
        'url': url,
        'storagePath': storagePath,
        'uploadedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Convenience for images:
  static Future<void> saveAndUploadImage(File localImage) =>
      saveAndUpload(localFile: localImage, type: 'image');

  /// Convenience for videos:
  static Future<void> saveAndUploadVideo(File localVideo) =>
      saveAndUpload(localFile: localVideo, type: 'video');
}
