import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:developer' as dev;

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);
  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final AudioPlayer _ap = AudioPlayer();
  late final CollectionReference _favCol;
  List<Map<String, dynamic>> _docs = [];

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    dev.log("DebugScreen.initState – currentUser = $user");
    if (user != null) {
      _favCol = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites');
      // Listen once so we can print:
      _favCol.snapshots().listen((snap) {
        dev.log(
          "DebugScreen – favorites snapshot: ${snap.docs.map((d) => d.data()).toList()}",
        );
        setState(() {
          _docs =
              snap.docs.map((d) => d.data()! as Map<String, dynamic>).toList();
        });
      });
    }

    // Try playing one asset immediately:
    () async {
      try {
        const asset = 'assets/audio/nature.mp3';
        dev.log("🔔 DebugScreen – setAsset($asset)");
        await _ap.setAsset(asset);
        _ap.setLoopMode(LoopMode.one);
        await _ap.play();
        dev.log("🔔 DebugScreen – now playing $asset");
      } catch (e) {
        dev.log("❌ DebugScreen – audio failed: $e");
      }
    }();
  }

  @override
  void dispose() {
    _ap.dispose();
    super.dispose();
  }

  void _addDummyFavorite() async {
    final dummyId = "dummy123";
    try {
      await _favCol.doc(dummyId).set({
        "quote": "Hello from Debug",
        "author": "Debugger",
        "category": "All",
        "imageUrl": "https://picsum.photos/200",
        "createdAt": FieldValue.serverTimestamp(),
      });
      dev.log("🔔 DebugScreen – wrote dummy favorite");
    } catch (e) {
      dev.log("❌ DebugScreen – write failure: $e");
    }
  }

  void _deleteDummyFavorite() async {
    try {
      await _favCol.doc("dummy123").delete();
      dev.log("🔔 DebugScreen – deleted dummy favorite");
    } catch (e) {
      dev.log("❌ DebugScreen – delete failure: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debug Screen")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _addDummyFavorite,
              child: const Text("Add Dummy Favorite"),
            ),
            ElevatedButton(
              onPressed: _deleteDummyFavorite,
              child: const Text("Delete Dummy Favorite"),
            ),
            const SizedBox(height: 20),
            const Text("Snapshot contents:"),
            Expanded(
              child: ListView.builder(
                itemCount: _docs.length,
                itemBuilder: (_, i) {
                  final d = _docs[i];
                  return ListTile(
                    title: Text(d["quote"] ?? "<no quote>"),
                    subtitle: Text(d["author"] ?? "<no author>"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
