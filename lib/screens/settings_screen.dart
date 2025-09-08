import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qns/constant.dart' hide supportedLangs;
import 'package:qns/screens/home_screen.dart' show supportedLangs;
import 'package:qns/services/local_notification_service.dart';
import 'package:qns/theme/theme_notifier.dart';
import 'package:qns/providers/settings_provider.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _clearCache(BuildContext context) async {
    final tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared')),
      );
    }
  }

  Future<void> _showAlarmPermissionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Alarms & Reminders'),
        content: const Text(
          'To receive daily notifications, please:\n\n'
          '1. Open device Settings.\n'
          '2. Go to Apps > qns.\n'
          '3. Tap Alarms & reminders.\n'
          '4. Turn ON the permission for "Allow setting alarms and reminders".\n\n'
          'Some devices/emulators may not show this option. Please test on a real device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    final Map<int, String> accentOptions = {
      0xFFE91E63: 'Pink',
      0xFF009688: 'Teal',
      0xFFFFC107: 'Amber',
      0xFF3F51B5: 'Indigo',
      0xFFFF5722: 'Deep Orange',
    };
    const bool showEmojiInDropdown = true;

    if (settings.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Toggle
            SwitchListTile(
              title: const Text('Enable daily notifications', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Get a daily rich quote notification'),
              value: settings.notificationsEnabled,
              onChanged: (val) async {
                settings.notificationsEnabled = val;
                if (val) {
                  try {
                    await LocalNotificationService.scheduleDailyQuoteNotification(
                      hour: settings.notificationTime.hour,
                      minute: settings.notificationTime.minute,
                      category: settings.defaultCategory,
                      context: context,
                    );
                  } on PlatformException catch (e) {
                    if (e.code == 'exact_alarms_not_permitted') {
                      await _showAlarmPermissionDialog(context);
                    }
                  }
                } else {
                  await LocalNotificationService.cancelAll();
                }
              },
            ),
            const SizedBox(height: 16),

            // Notification Time
            ListTile(
              title: const Text('Notification time', style: TextStyle(fontSize: 18)),
              subtitle: Text('Current: ${settings.notificationTime.format(context)}'),
              trailing: ElevatedButton(
                child: const Text('Change'),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settings.notificationTime,
                  );
                  if (picked != null) {
                    await settings.setNotificationTime(picked);
                    if (settings.notificationsEnabled) {
                      try {
                        await LocalNotificationService.scheduleDailyQuoteNotification(
                          hour: picked.hour,
                          minute: picked.minute,
                          category: settings.defaultCategory,
                          context: context,
                        );
                      } on PlatformException catch (e) {
                        if (e.code == 'exact_alarms_not_permitted') {
                          await _showAlarmPermissionDialog(context);
                        }
                      }
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Default Category
            const Text('Default Category:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: settings.defaultCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: kAllQuoteCategories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            if (showEmojiInDropdown && (kCategoryEmoji[cat]?.isNotEmpty ?? false))
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(kCategoryEmoji[cat]!, style: const TextStyle(fontSize: 18)),
                              ),
                            Text(cat),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (cat) {
                if (cat == null) return;
                settings.defaultCategory = cat;
              },
            ),
            const SizedBox(height: 24),

            // Audio toggle
            SwitchListTile(
              title: const Text('Play background audio', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Toggle background music on/off'),
              value: settings.audioEnabled,
              onChanged: (val) => settings.audioEnabled = val,
            ),
            const SizedBox(height: 16),

            // Dark Mode
            SwitchListTile(
              title: const Text('Dark mode', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Toggle light/dark theme'),
              value: settings.isDarkMode,
              onChanged: (val) {
                settings.isDarkMode = val;
                themeNotifier.isDark = val;
              },
            ),
            const SizedBox(height: 16),

            // Show Newest First
            SwitchListTile(
              title: Text(settings.showNewestFirst ? 'Show newest first' : 'Show oldest first', style: const TextStyle(fontSize: 18)),
              subtitle: const Text('Sort favorites and shared media by date'),
              value: settings.showNewestFirst,
              onChanged: (val) => settings.showNewestFirst = val,
            ),
            const SizedBox(height: 24),

            // Background Animations
            SwitchListTile(
              title: const Text('Enable background animations', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Toggle animated Pixabay background'),
              value: settings.animationsEnabled,
              onChanged: (val) => settings.animationsEnabled = val,
            ),
            const SizedBox(height: 24),

            // Language
            const Text('Preferred Language:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: settings.preferredLanguage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: supportedLangs.map((lang) =>
                DropdownMenuItem(
                  value: lang['code'],
                  child: Text('${lang['name']} (${lang['code']})'),
                ),
              ).toList(),
              onChanged: (lang) {
                if (lang == null) return;
                settings.preferredLanguage = lang;
              },
            ),
            const SizedBox(height: 24),

            // Accent Color
            const Text('Accent Color:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: settings.accentColor,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: accentOptions.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Row(
                    children: [
                      Container(width: 24, height: 24, color: Color(e.key)),
                      const SizedBox(width: 8),
                      Text(e.value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (c) {
                if (c == null) return;
                settings.accentColor = c;
                themeNotifier.accentColor = c;
              },
            ),
            const SizedBox(height: 32),

            // Cache Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Clear cache'),
                onPressed: () => _clearCache(context),
              ),
            ),
            const SizedBox(height: 20),

            // Test Notification
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.notifications_active),
                label: const Text('Test Daily Notification'),
                onPressed: () async {
                  try {
                    await LocalNotificationService.showImmediateQuoteNotification(
                      category: settings.defaultCategory,
                    );
                  } on PlatformException catch (e) {
                    if (e.code == 'exact_alarms_not_permitted') {
                      await _showAlarmPermissionDialog(context);
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
