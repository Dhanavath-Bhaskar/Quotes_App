import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleTranslationService {
  final String apiKey;

  GoogleTranslationService({required this.apiKey});

  /// Translate [text] to [targetLang] (e.g., 'hi', 'zh', 'jw').
  /// Optionally set [sourceLang] for best accuracy.
  Future<String> translate({
    required String text,
    required String targetLang,
    String? sourceLang, // Optional, e.g. 'en'
  }) async {
    final baseUrl = 'https://translation.googleapis.com/language/translate/v2';
    final params = {
      'q': text,
      'target': targetLang,
      'key': apiKey,
      if (sourceLang != null && sourceLang.isNotEmpty) 'source': sourceLang,
      'format': 'text',
    };
    final uri = Uri.parse(baseUrl).replace(queryParameters: params);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translations = data['data']['translations'];
      if (translations != null && translations[0]['translatedText'] != null) {
        return translations[0]['translatedText'] as String;
      }
      throw Exception('Translation response is missing translated text.');
    } else {
      throw Exception('Translation failed: ${response.body}');
    }
  }

  /// Optional: List supported languages with display names in your language
  Future<List<Map<String, String>>> getSupportedLanguages({String displayLang = 'en'}) async {
    final baseUrl = 'https://translation.googleapis.com/language/translate/v2/languages';
    final params = {
      'key': apiKey,
      'target': displayLang,
    };
    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final langs = data['data']['languages'] as List<dynamic>;
      return langs
          .map((e) => {
                'code': e['language'] as String,
                'name': e['name'] as String? ?? e['language'] as String,
              })
          .toList();
    } else {
      throw Exception('Failed to fetch supported languages: ${response.body}');
    }
  }
}
