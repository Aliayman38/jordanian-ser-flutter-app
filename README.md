# Jordanian SER — Speech Emotion Data Collection App

Flutter app for crowdsourcing Jordanian Arabic emotional speech samples.

## Flow
1. **Gender Selection** → `lib/screens/gender_selection_screen.dart`
2. **Emotions Menu** (2x2 grid + live score) → `lib/screens/emotions_menu_screen.dart`
3. **Recording & Upload** (press-and-hold mic) → `lib/screens/recording_screen.dart`
4. **Success dialog** (gamified) → shown from `recording_screen.dart`

## Project structure
```
lib/
  models/       # Emotion + Gender data
  services/     # AppState (Provider), AudioService (record pkg), ApiService (http)
  screens/      # The 3 main screens
  widgets/      # EmotionCard, HoldToRecordButton
  theme/        # Centralized ThemeData
```

## Before you run it

### 1. Point the app at your FastAPI backend
Edit `lib/services/api_service.dart`:
```dart
static const String _defaultBaseUrl = 'https://your-fastapi-server.com';
```
Or pass it at build time and read it via `String.fromEnvironment`:
```bash
flutter run --dart-define=API_BASE_URL=https://your-server.com
```

### 2. Backend contract (`POST /api/submit-audio`)
Expects a `multipart/form-data` request with:
- `audio_file`: the WAV file (16kHz, mono, 16-bit PCM)
- `speaker_id`: e.g. `M4821` / `F1093`
- `emotion`: one of `angry`, `happy`, `sad`, `neutral`
- `reference_text`: the Jordanian prompt the speaker read

Header: `User-Agent: JordanianSERApp/iOS`

Returns HTTP `200` on success.

### 3. Microphone permissions

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>نحتاج صلاحية الميكروفون لتسجيل الجمل الصوتية اللي بتساهم فيها.</string>
```

### 4. Fonts (optional, recommended)
The theme references a `Tajawal` font family for nicer Arabic typography.
Add it via `google_fonts` or bundle the TTFs and declare them in `pubspec.yaml`
under `flutter > fonts`. If skipped, Flutter falls back to the system default
and everything still works.

## Install & run
```bash
flutter pub get
flutter run
```
