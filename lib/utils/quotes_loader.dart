import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuotesLoader {
  static List<Map<String, String>>? _quotes;

  static Future<List<Map<String, String>>> load() async {
    if (_quotes != null) return _quotes!;
    final jsonStr = await rootBundle.loadString('assets/quotes_seed.json');
    final raw = json.decode(jsonStr) as List;
    _quotes = raw
        .map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())))
        .toList();
    return _quotes!;
  }
}
