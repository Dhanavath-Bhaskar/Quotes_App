import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

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
};

Future<List<String>> _fetchImagesForCategory(String category) async {
  final term = _pixabayQueries[category] ?? category;
  final encoded = Uri.encodeQueryComponent(term);
  final uri = Uri.parse(
    'https://pixabay.com/api/'
    '?key=$_pixabayApiKey'
    '&q=$encoded'
    '&image_type=photo'
    '&orientation=horizontal'
    '&per_page=30'
    '&lang=en',
  );
  debugPrint('▶️ Fetching images for "$category": $uri');

  final response = await http.get(uri);
  debugPrint('▶️ Pixabay replied: ${response.statusCode}');
  if (response.statusCode != 200) {
    throw Exception('Pixabay request failed (${response.statusCode})');
  }

  final Map<String, dynamic> body = json.decode(response.body);
  final hits = (body['hits'] as List<dynamic>?);
  debugPrint('▶️ Found ${hits?.length ?? 0} images for "$category"');

  if (hits == null || hits.isEmpty) {
    return [];
  }
  return hits
      .map((h) => (h as Map<String, dynamic>)['largeImageURL'] as String)
      .toList();
}

class FlowerGalleryScreen extends StatefulWidget {
  final String category;

  const FlowerGalleryScreen({Key? key, required this.category})
    : super(key: key);

  @override
  State<FlowerGalleryScreen> createState() => _FlowerGalleryScreenState();
}

class _FlowerGalleryScreenState extends State<FlowerGalleryScreen> {
  late Future<List<String>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = _fetchImagesForCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Gallery'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<String>>(
        future: _imagesFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Failed to load images:\n${snap.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          final urls = snap.data ?? [];
          if (urls.isEmpty) {
            return const Center(child: Text('No images found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: urls.length,
            itemBuilder: (ctx, i) {
              final imageUrl = urls[i];
              return GestureDetector(
                onTap:
                    () => Navigator.of(
                      context,
                    ).pop(imageUrl), // <--- return image!
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (_, __) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.error)),
                        ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
