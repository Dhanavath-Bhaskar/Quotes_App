// lib/widgets/file_upload_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadWidget extends StatefulWidget {
  final String fileType; // 'images' or 'videos'
  const FileUploadWidget({Key? key, required this.fileType}) : super(key: key);

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  File? _file;
  UploadTask? _uploadTask;
  String? _downloadUrl;
  String? _error;

  Future<void> pickFile() async {
    setState(() {
      _error = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: widget.fileType == 'images'
            ? FileType.image
            : FileType.video,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _file = File(result.files.single.path!);
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error picking file: $e";
      });
    }
  }

  Future<void> uploadFile() async {
    setState(() {
      _error = null;
      _downloadUrl = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = "Not signed in";
      });
      return;
    }
    if (_file == null) {
      setState(() {
        _error = "No file selected";
      });
      return;
    }

    final uid = user.uid;
    final filename = _file!.path.split('/').last;

    final ref = FirebaseStorage.instance
        .ref('shared_media/$uid/${widget.fileType}/$filename');

    try {
      setState(() {
        _uploadTask = ref.putFile(_file!);
      });

      final snapshot = await _uploadTask!;
      final url = await snapshot.ref.getDownloadURL();

      setState(() {
        _downloadUrl = url;
      });
    } catch (e) {
      setState(() {
        _error = "Upload error: $e";
      });
    } finally {
      setState(() {
        _uploadTask = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_file != null)
              widget.fileType == 'images'
                  ? Image.file(_file!, height: 150)
                  : Icon(Icons.videocam, size: 60, color: Colors.blueAccent),
            const SizedBox(height: 12),
            if (_uploadTask != null)
              StreamBuilder<TaskSnapshot>(
                stream: _uploadTask!.snapshotEvents,
                builder: (context, snapshot) {
                  final progress = snapshot.hasData
                      ? (snapshot.data!.bytesTransferred / snapshot.data!.totalBytes) * 100
                      : 0.0;
                  return Column(
                    children: [
                      LinearProgressIndicator(value: progress / 100),
                      Text("Uploading... ${progress.toStringAsFixed(2)}%"),
                    ],
                  );
                },
              ),
            if (_downloadUrl != null)
              Column(
                children: [
                  const Text("File Uploaded!", style: TextStyle(color: Colors.green)),
                  SelectableText(_downloadUrl ?? ''),
                ],
              ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _uploadTask == null ? pickFile : null,
                  icon: const Icon(Icons.folder),
                  label: const Text('Pick File'),
                ),
                ElevatedButton.icon(
                  onPressed: (_file != null && _uploadTask == null) ? uploadFile : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
