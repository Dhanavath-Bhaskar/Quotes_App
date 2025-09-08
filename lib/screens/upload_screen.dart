import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  final String fileType; // 'images' or 'videos'
  const UploadScreen({Key? key, required this.fileType}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  XFile? _file;
  UploadTask? _uploadTask;
  String? _downloadUrl;
  String? _error;

  Future<void> _pickFile() async {
    try {
      setState(() {
        _file = null;
        _downloadUrl = null;
        _error = null;
      });

      final picker = ImagePicker();
      XFile? picked;
      if (widget.fileType == 'images') {
        picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      } else {
        picked = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
      }

      if (picked == null) return;

      setState(() => _file = picked);
    } catch (e) {
      setState(() => _error = "Pick failed: $e");
    }
  }

  Future<void> _upload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_file == null || user == null) return;

    final uid = user.uid;
    final filename = _file!.path.split('/').last;
    final ref = FirebaseStorage.instance
        .ref('shared_media/$uid/${widget.fileType}/$filename');

    try {
      setState(() {
        _uploadTask = ref.putFile(File(_file!.path));
        _error = null;
        _downloadUrl = null;
      });
      final snap = await _uploadTask!;
      final url = await snap.ref.getDownloadURL();
      setState(() {
        _downloadUrl = url;
        _uploadTask = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload complete!")),
      );
    } catch (e) {
      setState(() {
        _error = "Upload failed: $e";
        _uploadTask = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileTypeLabel = widget.fileType == 'images' ? 'Image' : 'Video';

    return Scaffold(
      appBar: AppBar(title: Text('Upload $fileTypeLabel')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_file == null)
              Text('No $fileTypeLabel selected.', style: TextStyle(color: Colors.grey)),
            if (_file != null)
              widget.fileType == 'images'
                  ? Image.file(File(_file!.path), height: 220)
                  : AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black12,
                        child: Center(child: Text('Video ready for upload!')),
                      ),
                    ),
            const SizedBox(height: 16),
            if (_uploadTask != null)
              StreamBuilder<TaskSnapshot>(
                stream: _uploadTask!.snapshotEvents,
                builder: (context, snapshot) {
                  double prog = 0;
                  if (snapshot.hasData) {
                    prog = (snapshot.data!.bytesTransferred / snapshot.data!.totalBytes)
                        .clamp(0, 1);
                  }
                  return Column(
                    children: [
                      LinearProgressIndicator(value: prog),
                      Text("Uploading... ${(prog * 100).toStringAsFixed(0)}%"),
                    ],
                  );
                },
              ),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            if (_downloadUrl != null) ...[
              const Text('File uploaded!'),
              SelectableText(_downloadUrl!),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(widget.fileType == 'images' ? Icons.image : Icons.videocam),
                  label: Text('Pick $fileTypeLabel'),
                  onPressed: _uploadTask == null ? _pickFile : null,
                ),
                const SizedBox(width: 18),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload'),
                  onPressed: _file != null && _uploadTask == null ? _upload : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
