// lib/services/pixabay_queries.dart

/// The same exact map your HomeScreen used for selecting background images.
/// Key = quote category (e.g. “Creativity & Inspiration”), Value = search term
/// (e.g. “creative art”).
const Map<String, String> pixabayCategoryToQuery = {
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
  // (You can add more if you like.)
};
