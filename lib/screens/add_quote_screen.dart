import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constant.dart' as constants; // kQuoteKey, kAuthorKey, kCategory
import '../quotes.dart'; // quotesList

class AddQuoteScreen extends StatefulWidget {
  const AddQuoteScreen({Key? key}) : super(key: key);

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quoteController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isUploading = false;
  String _userName = 'Anonymous';
  String _userPhoto = '';
  String _searchText = '';

  late Future<void> _initFuture;
  late List<String> _allQuotes;
  late List<String> _allAuthors;
  late List<String> _allCategories;

  List<Map<String, String>> get _filteredQuotes {
    if (_searchText.trim().isEmpty) return quotesList;
    final lower = _searchText.trim().toLowerCase();
    return quotesList.where((q) =>
      (q[constants.kQuoteKey]?.toLowerCase().contains(lower) ?? false) ||
      (q[constants.kAuthorKey]?.toLowerCase().contains(lower) ?? false) ||
      (q[constants.kCategory]?.toLowerCase().contains(lower) ?? false)
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    _allQuotes = quotesList.map((q) => q[constants.kQuoteKey])
      .whereType<String>().toSet().toList()..sort();
    _allAuthors = quotesList.map((q) => q[constants.kAuthorKey])
      .whereType<String>().toSet().toList()..sort();
    _allCategories = quotesList.map((q) => q[constants.kCategory])
      .whereType<String>().toSet().toList()..sort();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!
        : 'Anonymous';
      _userPhoto = user?.photoURL ?? '';
    });
  }

  // --- Ensure user is signed in (Anonymous Auth for seamless upload) ---
  Future<void> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    _initializeData();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields.')),
      );
      return;
    }

    await ensureSignedIn();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to upload.')),
      );
      return;
    }
    setState(() => _isUploading = true);

    try {
      await FirebaseFirestore.instance.collection('quotes').add({
        constants.kQuoteKey: _quoteController.text.trim(),
        constants.kAuthorKey: _authorController.text.trim(),
        constants.kCategory: _categoryController.text.trim(),
        'userName': _userName,
        'userPhoto': _userPhoto,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).pop(); // Go back to home screen after upload
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _fillFromExisting(Map<String, String> item) {
    _quoteController.text = item[constants.kQuoteKey] ?? '';
    _authorController.text = item[constants.kAuthorKey] ?? '';
    _categoryController.text = item[constants.kCategory] ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Add New Quote')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Uploading as: $_userName',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_userPhoto.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(_userPhoto),
                          radius: 26,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Quote autocomplete
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue txt) {
                        if (txt.text.isEmpty) return const Iterable<String>.empty();
                        return _allQuotes.where(
                          (q) => q.toLowerCase().contains(txt.text.toLowerCase()),
                        );
                      },
                      onSelected: (sel) => _quoteController.text = sel,
                      fieldViewBuilder: (ctx, ctl, fn, submit) {
                        return TextFormField(
                          controller: _quoteController,
                          focusNode: fn,
                          decoration: const InputDecoration(labelText: 'Quote'),
                          maxLines: 3,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter a quote' : null,
                          onSaved: (v) => _quoteController.text = v!.trim(),
                          onFieldSubmitted: (_) => submit(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Author autocomplete
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue txt) {
                        if (txt.text.isEmpty) return const Iterable<String>.empty();
                        return _allAuthors.where(
                          (a) => a.toLowerCase().contains(txt.text.toLowerCase()),
                        );
                      },
                      onSelected: (sel) => _authorController.text = sel,
                      fieldViewBuilder: (ctx, ctl, fn, submit) {
                        return TextFormField(
                          controller: _authorController,
                          focusNode: fn,
                          decoration: const InputDecoration(labelText: 'Author'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter an author' : null,
                          onSaved: (v) => _authorController.text = v!.trim(),
                          onFieldSubmitted: (_) => submit(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Category autocomplete
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue txt) {
                        if (txt.text.isEmpty) return const Iterable<String>.empty();
                        return _allCategories.where(
                          (c) => c.toLowerCase().contains(txt.text.toLowerCase()),
                        );
                      },
                      onSelected: (sel) => _categoryController.text = sel,
                      fieldViewBuilder: (ctx, ctl, fn, submit) {
                        return TextFormField(
                          controller: _categoryController,
                          focusNode: fn,
                          decoration: const InputDecoration(labelText: 'Category'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter a category' : null,
                          onSaved: (v) => _categoryController.text = v!.trim(),
                          onFieldSubmitted: (_) => submit(),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    _isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.upload),
                            label: const Text('Upload Quote'),
                            onPressed: _submit,
                          ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Or search & tap an existing quote to pre-fill:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search author, category, or quote...',
                      ),
                      onChanged: (txt) => setState(() => _searchText = txt),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 250,
                      child: _filteredQuotes.isEmpty
                          ? const Center(child: Text('No results found.'))
                          : ListView.builder(
                              itemCount: _filteredQuotes.length > 30 ? 30 : _filteredQuotes.length,
                              itemBuilder: (ctx, i) {
                                final item = _filteredQuotes[i];
                                return ListTile(
                                  title: Text(
                                    item[constants.kQuoteKey] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text('${item[constants.kAuthorKey] ?? ''} • ${item[constants.kCategory] ?? ''}'),
                                  onTap: () => _fillFromExisting(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
