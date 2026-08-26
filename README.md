# Jordanian SER — Speech Emotion Data Collection App

Flutter app for crowdsourcing Jordanian Arabic emotional speech samples.

## Flow
1. **Gender Selection** → `lib/screens/gender_selection_screen.dart`
2. **Emotions Menu** (2x2 grid + live score) → `lib/screens/emotions_menu_screen.dart`
3. **Recording & Upload** (press-and-hold mic) → `lib/screens/recording_screen.dart`
4. **Success dialog** (gamified) → shown from `recording_screen.dart`

## Project structure
```
assets/
  audio/        # Sound effects and reference audio
  fonts/        # Custom typography (e.g. Tajawal)
  icons/        # App icons & SVGs
  images/       # Graphics & illustrations
lib/
  constants/    # ApiConstants (backend domain: https://serios.eqratech.com), AppConstants
  models/       # Emotion + Gender data
  screens/      # GenderSelection, EmotionsMenu, RecordingScreen
  services/     # AppState (Provider), AudioService (record), ApiService (http)
  theme/        # Centralized ThemeData & styling
  utils/        # PermissionHelper & utilities
  widgets/      # EmotionCard, HoldToRecordButton
test/
  unit/         # AppState & ApiService unit tests
  widget_test.dart
```

## Backend Configuration

Backend server domain:
```
https://serios.eqratech.com
```

Configured in `lib/constants/api_constants.dart`:
```dart
static const String baseUrl = 'https://serios.eqratech.com';
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
