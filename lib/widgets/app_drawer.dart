// lib/widgets/app_drawer.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:qns/screens/sign_in_screen.dart';
import 'package:qns/screens/favorites_screen.dart';
import 'package:qns/screens/settings_screen.dart';
import 'package:qns/screens/shared_media_screen.dart';
import 'package:qns/screens/upload_screen.dart'; // <--- ADD THIS IMPORT

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _pickAndUploadPhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final uid = user.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child(uid)
          .child('$uid.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
      await user.reload();
      if (mounted) setState(() {});
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _onAvatarTap(String? photoUrl) async {
    if (photoUrl == null) {
      await _pickAndUploadPhoto();
      return;
    }
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.5,
            child: Column(
              children: [
                Expanded(child: Image.network(photoUrl, fit: BoxFit.contain)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Change Photo'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _pickAndUploadPhoto();
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _editDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final controller = TextEditingController(text: user.displayName ?? '');
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Name'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isEmpty) return;
                  Navigator.of(ctx).pop();
                  try {
                    await user.updateDisplayName(newName);
                    await user.reload();
                    if (mounted) setState(() {});
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Name update failed: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _signOut() async {
    Navigator.of(context).pop();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  /// Show media upload type chooser, then open UploadScreen.
  void _showUploadMediaChooser() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Upload Video'),
            onTap: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UploadScreen(fileType: 'videos'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Upload Image'),
            onTap: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UploadScreen(fileType: 'images'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Guest';
    final photoUrl = user?.photoURL;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            accountName: GestureDetector(
              onTap: _editDisplayName,
              child: Text(displayName, style: const TextStyle(fontSize: 18)),
            ),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: GestureDetector(
              onTap: _uploading ? null : () => _onAvatarTap(photoUrl),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child:
                    photoUrl == null
                        ? (_uploading
                            ? const CircularProgressIndicator()
                            : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.deepPurple,
                            ))
                        : null,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Name'),
            onTap: _editDisplayName,
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_shared),
            title: const Text('Shared Media'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SharedMediaScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Upload Media'),
            onTap: _showUploadMediaChooser,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}
