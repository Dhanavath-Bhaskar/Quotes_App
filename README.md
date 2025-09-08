# Quotes\_App — Daily Q (Flutter)

**Daily Q** is a Flutter app for Android, iOS, and Web that serves **10,000+ inspirational quotes across 100 categories**. Translate on the fly, enjoy **category-themed background music**, create **shareable images**, generate **MP4 videos with music**, and **record animated scenes with falling emojis**. Save favorites, receive daily quote notifications, and sync with Firebase.

> Repo: `Quotes_App`

---

## ✨ Features

* **Daily quote display** with local notification (08:00 by default)
* **Massive library**: 10,000+ quotes across 100 categories (local JSON + Firestore)
* **Smart search**: by text, author, or category keyword
* **Multi-language translation** (100+ languages) with caching
* **Category music engine** (looped tracks; play/pause, seek)
* **Share quotes as image** (Pixabay backgrounds + clean typography)
* **Create quote videos** (720×1280 MP4 with music via FFmpegKit; fade-out)
* **Record with falling emojis** (great for Reels/Shorts/Stories)
* **Favorite quotes** with Firestore sync per user
* **Quote history / Shared Media** (generated images & videos)
* **Author-wise & Category-based quotes**
* **Home screen widget (Android)** and **scheduled daily updates**
* **Firebase Cloud Firestore backend**
* **Open-source** (see License; FFmpegKit note below)

---

## 📸 App Screenshots

## 📸 App Screenshots

<div align="center">

<!-- Row 1 -->
<img src="assets/screenshots/home_screen.png"        alt="Home"                      width="260" />
<img src="assets/screenshots/favorites_screen.png"   alt="Favorites"                 width="260" />
<img src="assets/screenshots/fav_screen.png"         alt="Favorite Item"             width="260" />
<img src="assets/screenshots/favdet_screen.png"      alt="Favorite Detail"           width="260" />

<!-- Row 2 -->
<img src="assets/screenshots/record_screen.png"      alt="Record (Falling Emojis)"   width="260" />
<img src="assets/screenshots/videos_screen.png"      alt="Videos"                    width="260" />
<img src="assets/screenshots/images_screen.png"      alt="Shared Images"             width="260" />
<img src="assets/screenshots/re_screen.png"          alt="Recorded Preview"          width="260" />

<!-- Row 3 -->
<img src="assets/screenshots/act_screen.png"         alt="Action Category"           width="260" />
<img src="assets/screenshots/adventure_screen.png"   alt="Adventure Category"        width="260" />
<img src="assets/screenshots/belief_screen.png"      alt="Belief Category"           width="260" />
<img src="assets/screenshots/charity_screen.png"     alt="Charity Category"          width="260" />

<!-- Row 4 -->
<img src="assets/screenshots/beliefvideo_screen.png" alt="Belief Video"              width="260" />
<img src="assets/screenshots/quodet_screen.png"      alt="Quote Detail (alt)"        width="260" />
<img src="assets/screenshots/quote_detail.png"       alt="Quote Detail"              width="260" />
<img src="assets/screenshots/balance.png"            alt="Balance"                   width="260" />

</div>


---

## 🛠 Tech Stack

* Flutter UI (Carousel, RepaintBoundary capture)
* **FFmpegKit (new GPL)** for video (H.264 + AAC @ 30fps, fade out)
* **just\_audio** for music playback/loop
* **Firebase Auth + Cloud Firestore**
* **Pixabay API** for background photos (mapped per category)
* **GoogleTranslationService** wrapper for instant translations
* **rxdart** for combined position/duration streams

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK **3.13.0+**
* Android Studio / Xcode / VS Code
* Git
* Firebase project (Android, iOS, Web apps added)
* API keys:

  * **Pixabay** (required)
  * **Translate** (if your `GoogleTranslationService` requires a Google Cloud key)

### Clone the repository

```bash
git clone https://github.com/Dhanavath-Bhaskar/Quotes_App.git
cd Quotes_App
```

### Install dependencies

```bash
flutter pub get
```

### Configure Firebase (all platforms)

1. Install CLIs:

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. From project root:

   ```bash
   flutterfire configure
   ```

   This adds:

   * **Android:** `android/app/google-services.json`
   * **iOS:** `ios/Runner/GoogleService-Info.plist`
   * **Web:** injected config; add `firebase-messaging-sw.js` if using web push

3. Ensure Firebase initialization in `main.dart`.

### API Keys & Constants

Create **`lib/constant.dart`** (the app imports it as `consts`):

```dart
// lib/constant.dart
library consts;

// Get your key: https://pixabay.com/api/docs/
const String pixabayKey = 'YOUR_PIXABAY_API_KEY';

// Optional: if GoogleTranslationService needs it
// const String googleTranslateKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
```

If needed, update translator init:

```dart
_googleTranslator = GoogleTranslationService(apiKey: 'YOUR_GOOGLE_TRANSLATE_API_KEY');
```

### Assets

* **Seed quotes**: `assets/quotes_seed.json`
* **Audio**: `assets/audio/` — files must match keys in `_categoryAudio`
* **Screenshots** (optional): `assets/screenshots/`

Declare in **pubspec.yaml**:

```yaml
flutter:
  assets:
    - assets/quotes_seed.json
    - assets/audio/
    - assets/screenshots/
```

---

## 🔧 Platform Notes

### Android

* **minSdkVersion**: **24+** recommended for FFmpegKit (new gpl)

  ```gradle
  // android/app/build.gradle
  defaultConfig {
      minSdkVersion 24
  }
  ```
* **Permissions**:

  ```xml
  <!-- android/app/src/main/AndroidManifest.xml -->
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  ```

  Request runtime `POST_NOTIFICATIONS` on Android 13+.

### iOS

Add to **Info.plist**:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save your generated quote images and videos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Access to save and share media.</string>
```

### Web

* Ensure Firebase web config is present (`flutterfire configure`).
* For push, add `firebase-messaging-sw.js` and set FCM web keys.

---

## ▶️ Run

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

---

## 🧩 Project Structure (key parts)

```
lib/
  screens/
    home_screen.dart                 # Carousel, emoji rain, share/record
    quote_detail_screen.dart
    favorites_screen.dart
    settings_screen.dart
    shared_media_screen.dart
    record_screen.dart
  services/
    google_translation_service.dart
    local_notification_service.dart
    push_notification_service.dart
  widgets/
    non_intrusive_emoji_rain.dart
    quote_share_full_detail_card.dart
    app_drawer.dart
  utils/
    shared_image_store.dart
  constant.dart                      # <- your API keys
assets/
  audio/
  quotes_seed.json
  screenshots/
```

---

## 🧪 Troubleshooting

* **“Failed to generate video!”**
  Check FFmpegKit setup, `minSdkVersion >= 24`, and verify audio/image paths.
* **No backgrounds**
  Verify `consts.pixabayKey`, network access, and category→query mapping.
* **Translations missing**
  Provide a valid key and confirm `GoogleTranslationService` implementation.
* **Audio not playing**
  Confirm asset declarations and exact filenames in `_categoryAudio`.
* **Android 13 notifications**
  Request runtime `POST_NOTIFICATIONS`.

---

## 🔐 Permissions

* **Photos/Storage** – Save & share generated media
* **Network** – Pixabay, translations, Firebase sync
* **Notifications** – Daily quote reminders
* **Audio** – Music in creations

---

## 📜 License

* Source code: **MIT** (you can change this)
* **Important:** Uses **`ffmpeg_kit_flutter_new_gpl`** (GPL).
  If you **distribute** the app, comply with **GPL** (e.g., provide full source under GPL-compatible terms).
  Prefer permissive terms? Switch to an **LGPL/min** FFmpegKit variant and adjust features accordingly.

---

## 🏷️ Store Short Description (≤80 chars)

Create & share quote images/videos with music, emojis, translation & favorites.

---

