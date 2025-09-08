import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchImageUrlForCategory(String category) async {
  const apiKey = '50180577-5f0d84f67bd57fb18ae937c93';
  final uri = Uri.parse(
      'https://pixabay.com/api/?key=$apiKey&q=${Uri.encodeComponent(category)}&image_type=photo&per_page=3');
  final res = await http.get(uri);
  if (res.statusCode == 200) {
    final hits = json.decode(res.body)['hits'];
    if (hits != null && hits.isNotEmpty) {
      return hits[0]['webformatURL'];
    }
  }
  return '';
}
