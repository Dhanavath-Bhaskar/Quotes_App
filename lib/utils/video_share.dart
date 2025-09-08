import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qns/utils/shared_video_store.dart';

String _wrapText(String input, int maxChars) {
  final words = input.split(' ');
  final lines = <String>[];
  var current = '';
  for (var w in words) {
    final candidate = current.isEmpty ? w : '$current $w';
    if (candidate.length <= maxChars) {
      current = candidate;
    } else {
      lines.add(current);
      current = w;
    }
  }
  if (current.isNotEmpty) lines.add(current);
  return lines.join('\n');
}

Future<String> writeTextToTempFile(String text, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, filename));
  await file.writeAsString(text);
  return file.path;
}

Future<File> generateVideo({
  required String imagePath,
  required String audioAsset,
  required String fontAsset,
  required String quote,
  required String author,
  int wrapWidth = 30,
}) async {
  try {
    final tmp = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    // Write audio asset to file
    final audioData = await rootBundle.load(audioAsset);
    final audioFile = File(p.join(tmp.path, 'audio_$ts.mp3'))
      ..writeAsBytesSync(audioData.buffer.asUint8List());

    // Write font asset to file
    final fontData = await rootBundle.load(fontAsset);
    final fontFile = File(p.join(tmp.path, 'font_$ts.ttf'))
      ..writeAsBytesSync(fontData.buffer.asUint8List());

    // Prepare and save text to files
    final wrapped = _wrapText(quote, wrapWidth);
    final quoteTxtPath = await writeTextToTempFile(wrapped, 'quote_$ts.txt');
    final authorTxtPath = await writeTextToTempFile(author, 'author_$ts.txt');

    final output = p.join(tmp.path, 'video_$ts.mp4');
    final args = [
      '-y',
      '-loop', '1',
      '-i', imagePath,
      '-i', audioFile.path,
      '-vf',
        "scale=720:1280,"
        "drawtext=fontfile='${fontFile.path}':textfile='${quoteTxtPath}':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:x=(w-text_w)/2:y=h/4,"
        "drawtext=fontfile='${fontFile.path}':textfile='${authorTxtPath}':fontcolor=cyan:fontsize=36:box=1:boxcolor=black@0.5:x=(w-text_w)/2:y=(h*2/3)",
      '-c:v', 'libx264',
      '-preset', 'ultrafast',
      '-pix_fmt', 'yuv420p',
      '-c:a', 'aac',
      '-b:a', '192k',
      '-shortest',
      output,
    ];

    print('FFmpeg args: $args'); // <-- DEBUG: print the full command

    final session = await FFmpegKit.executeWithArguments(args);
    final rc = await session.getReturnCode();
    final logs = await session.getAllLogsAsString();

    if (!ReturnCode.isSuccess(rc)) {
      print('==== FFmpeg COMMAND FAILURE LOGS ====');
      print(logs); // <-- DEBUG: print the full error output
      print('=====================================');
      throw Exception('FFmpeg failed: $logs');
    }

    final outputFile = File(output);
    if (!await outputFile.exists()) {
      throw Exception('FFmpeg output file not found');
    }

    return outputFile;
  } catch (e) {
    rethrow;
  }
}

Future<String> _uploadToStorage(File file, String subDir) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final name = p.basename(file.path);
  final ref = FirebaseStorage.instance.ref('shared_media/$subDir/$uid/$name');
  await ref.putFile(file);
  return await ref.getDownloadURL();
}

Future<File?> createAndShareVideo({
  required String imagePath,
  required String audioAsset,
  required String fontAsset,
  required String quote,
  required String author,
  required String userName,
  required String category,
  required String language,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  try {
    final vidFile = await generateVideo(
      imagePath: imagePath,
      audioAsset: audioAsset,
      fontAsset: fontAsset,
      quote: quote,
      author: author,
    );

    final shareText = '"$quote" — $author\n(Shared by $userName)';
    await Share.shareXFiles(
      [XFile(vidFile.path)],
      text: shareText,
      subject: 'Quote from $userName',
    );

    final downloadUrl = await _uploadToStorage(vidFile, 'videos');

    await FirebaseFirestore.instance.collection('shared_videos').add({
      'quote': quote,
      'author': author,
      'userName': userName,
      'videoUrl': downloadUrl,
      'category': category,
      'language': language,
      'sharedAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sharedMedia')
        .add({
          'type': 'video',
          'url': downloadUrl,
          'quote': quote,
          'author': author,
          'userName': userName,
          'category': category,
          'language': language,
          'uploadedAt': FieldValue.serverTimestamp(),
        });

    // Local store for quick access (optional)
    await SharedVideoStore.save({
      'quote': quote,
      'author': author,
      'userName': userName,
      'videoPath': vidFile.path,
      'category': category,
      'language': language,
      'sharedAt': DateTime.now().toIso8601String(),
    });

    return vidFile;
  } catch (e, st) {
    print('createAndShareVideo ERROR: $e\n$st');
    return null;
  }
}
