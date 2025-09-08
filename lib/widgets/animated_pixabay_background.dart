// lib/widgets/animated_pixabay_background.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ─── CONFIGURE YOUR PIXABAY KEY HERE ────────────────────────────────────────
/// (Be sure this matches exactly the same key you used in the gallery file below.)
const String _pixabayApiKey = '50180577-5f0d84f67bd57fb18ae937c93';

const Map<String, String> _pixabayQueries = {
  'All': 'nature',
  'Creativity & Inspiration': 'creative art',
  'Worry & Anxiety': 'anxiety relief',
  'Mindfulness & Letting Go': 'mindfulness meditation',
  'Happiness & Joy': 'happy moments',
  'Motivation & Achievement': 'motivation success',
  'Relationships & Connection': 'relationship love',
  'Peace & Inner Calm': 'peaceful scenery',
  'Philosophy': 'philosophy books',
  'Uncategorized': 'abstract art',
  'Falling Flowers': 'cherry blossom',
};

Future<List<String>> _fetchCategoryImages(String category) async {
  final queryTerm =
      _pixabayQueries[category] ?? _pixabayQueries['Uncategorized']!;
  final encoded = Uri.encodeQueryComponent(queryTerm);
  final uri = Uri.parse(
    'https://pixabay.com/api/'
    '?key=$_pixabayApiKey'
    '&q=$encoded'
    '&image_type=photo'
    '&per_page=20'
    '&orientation=horizontal',
  );

  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw Exception('Pixabay request failed (${response.statusCode})');
  }

  final Map<String, dynamic> jsonBody = json.decode(response.body);
  final hits = (jsonBody['hits'] as List<dynamic>);
  if (hits.isEmpty) {
    throw Exception('No images found for "$category"');
  }

  return hits
      .map((h) => (h as Map<String, dynamic>)['largeImageURL'] as String)
      .toList();
}

class AnimatedPixabayBackground extends StatefulWidget {
  final String category;
  final int intervalSeconds;
  final BoxFit fit;

  const AnimatedPixabayBackground({
    Key? key,
    required this.category,
    this.intervalSeconds = 5,
    this.fit = BoxFit.cover,
    required imageUrl,
  }) : super(key: key);

  @override
  State<AnimatedPixabayBackground> createState() =>
      _AnimatedPixabayBackgroundState();
}

class _AnimatedPixabayBackgroundState extends State<AnimatedPixabayBackground>
    with SingleTickerProviderStateMixin {
  List<String> _urls = [];
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadImagesForCategory(widget.category);
  }

  @override
  void didUpdateWidget(covariant AnimatedPixabayBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _timer?.cancel();
      setState(() {
        _loading = true;
        _error = null;
        _urls = [];
        _currentIndex = 0;
      });
      _loadImagesForCategory(widget.category);
    }
  }

  Future<void> _loadImagesForCategory(String category) async {
    try {
      final urls = await _fetchCategoryImages(category);
      if (!mounted) return;
      setState(() {
        _urls = urls;
        _loading = false;
      });

      _timer = Timer.periodic(Duration(seconds: widget.intervalSeconds), (_) {
        if (!mounted || _urls.isEmpty) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % _urls.length;
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Container(color: Colors.grey.shade800);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: SizedBox.expand(
        key: ValueKey<int>(_currentIndex),
        child: Image.network(
          _urls[_currentIndex],
          fit: widget.fit,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (ctx, err, stack) {
            return Container(color: Colors.grey.shade900);
          },
        ),
      ),
    );
  }
}
