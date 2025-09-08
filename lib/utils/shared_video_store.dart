import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class SharedVideoStore {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shared_videos.json');
  }

  static Future<void> add(Map<String, String> map) async {
    final file = await _getFile();
    List<Map<String, dynamic>> all = [];
    if (await file.exists()) {
      final str = await file.readAsString();
      if (str.isNotEmpty) all = List<Map<String, dynamic>>.from(json.decode(str));
    }
    all.insert(0, map);
    await file.writeAsString(json.encode(all));
  }

  static Future<void> save(Map<String, dynamic> data) async {
    await add(data.map((k, v) => MapEntry(k, v?.toString() ?? '')));
  }

  static Future<List<Map<String, String>>> load() async {
    final file = await _getFile();
    if (!await file.exists()) return [];
    final str = await file.readAsString();
    if (str.isEmpty) return [];
    final list = List<Map<String, dynamic>>.from(json.decode(str));
    return list.map((m) => m.map((key, value) => MapEntry(key, value?.toString() ?? ''))).toList();
  }

  static Future<void> delete(Map<String, String> m) async {
    final file = await _getFile();
    if (!await file.exists()) return;

    final videoPath = m['videoPath'];
    final thumbnail = m['thumbnail'];
    final str = await file.readAsString();
    if (str.isEmpty) return;
    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(json.decode(str));
    // Remove the entry that matches the videoPath
    list.removeWhere((e) => e['videoPath']?.toString() == videoPath);

    await file.writeAsString(json.encode(list));

    // Optionally delete the video file from disk
    if (videoPath != null && videoPath.isNotEmpty) {
      final vidFile = File(videoPath);
      if (await vidFile.exists()) {
        try { await vidFile.delete(); } catch (_) {}
      }
    }
    // Optionally delete the thumbnail file from disk
    if (thumbnail != null && thumbnail.isNotEmpty) {
      final thumbFile = File(thumbnail);
      if (await thumbFile.exists()) {
        try { await thumbFile.delete(); } catch (_) {}
      }
    }
  }
}
