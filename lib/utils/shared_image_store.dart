import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class SharedImageStore {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shared_images.json');
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

    final imagePath = m['imagePath'];
    final str = await file.readAsString();
    if (str.isEmpty) return;
    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(json.decode(str));
    // Remove the entry that matches the imagePath
    list.removeWhere((e) => e['imagePath']?.toString() == imagePath);

    await file.writeAsString(json.encode(list));

    // Optionally delete the image file from disk
    if (imagePath != null && imagePath.isNotEmpty) {
      final imgFile = File(imagePath);
      if (await imgFile.exists()) {
        try { await imgFile.delete(); } catch (_) {}
      }
    }
  }
}
