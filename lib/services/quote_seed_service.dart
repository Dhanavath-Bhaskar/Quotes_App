import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class QuoteSeedService {
  static Future<Map<String, String>> getRandomQuote() async {
    final jsonStr = await rootBundle.loadString('assets/quotes_seed.json');
    final List quotes = json.decode(jsonStr);
    if (quotes.isEmpty) {
      return {
        'quote': 'No quotes available.',
        'author': '-',
        'category': 'Uncategorized',
      };
    }
    final random = Random();
    final quoteObj = quotes[random.nextInt(quotes.length)];
    return {
      'quote': quoteObj['quote'] ?? '',
      'author': quoteObj['author'] ?? '-',
      'category': quoteObj['category'] ?? 'Uncategorized',
    };
  }
}
