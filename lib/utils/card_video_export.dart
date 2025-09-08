import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/ffmpeg_kit.dart';

Future<String?> recordCardWidgetToVideo({
  required GlobalKey repaintBoundaryKey,
  required String audioAssetPath, // e.g. assets/audio/motivation.mp3
  int durationSeconds = 6,
  int fps = 30,
  required BuildContext context,
}) async {
  final tempDir = await getTemporaryDirectory();
  final framesDir = Directory('${tempDir.path}/frames');
  if (framesDir.existsSync()) framesDir.deleteSync(recursive: true);
  framesDir.createSync();

  // Copy audio asset to temp directory
  final audioBytes = await DefaultAssetBundle.of(context).load(audioAssetPath);
  final audioPath = '${tempDir.path}/audio.mp3';
  await File(audioPath).writeAsBytes(audioBytes.buffer.asUint8List());

  final totalFrames = durationSeconds * fps;

  // Render frames
  for (int i = 0; i < totalFrames; i++) {
    final double t = i / totalFrames; // progress [0,1]
    // Optional: update animation progress here if you control animation by progress (not needed if animation runs itself)
    await Future.delayed(Duration(milliseconds: (1000 ~/ fps)));

    final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final frameFile = File('${framesDir.path}/frame_${i.toString().padLeft(4, '0')}.png');
    await frameFile.writeAsBytes(pngBytes);
  }

  // Use FFmpeg to generate the video from PNG frames and audio
  final videoPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';
  // This command assumes all frames are named frame_0000.png, frame_0001.png, etc.
  final cmd = '''
    -framerate $fps -i "${framesDir.path}/frame_%04d.png" -i "$audioPath"
    -c:v libx264 -pix_fmt yuv420p -vf "scale=720:1280" -shortest -c:a aac -b:a 128k "$videoPath"
  ''';

  final session = await FFmpegKit.execute(cmd);
  final rc = await session.getReturnCode();
  if (rc == null || !rc.isValueSuccess() || !File(videoPath).existsSync()) {
    return null;
  }
  // Optionally delete framesDir and audio file to clean up
  framesDir.deleteSync(recursive: true);
  File(audioPath).deleteSync();
  return videoPath;
}
