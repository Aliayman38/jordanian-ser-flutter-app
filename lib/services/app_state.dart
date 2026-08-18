import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/speaker.dart';

/// Lightweight app-wide state: selected gender + contribution score.
///
/// Kept deliberately simple (ChangeNotifier + Provider) since the app has
/// a single linear flow and does not need a heavier state-management stack.
class AppState extends ChangeNotifier {
  Gender? _gender;
  int _score = 0;
  final Random _rng = Random();

  Gender? get gender => _gender;
  int get score => _score;
  bool get hasSelectedGender => _gender != null;

  /// Stable-ish per-session speaker id: gender prefix + random 4-digit suffix,
  /// generated once per app session so all uploads in a session share it.
  late final int _sessionSuffix = 1000 + _rng.nextInt(9000);

  String get speakerId {
    final prefix = _gender == Gender.male ? 'M' : 'F';
    return '$prefix$_sessionSuffix';
  }

  void selectGender(Gender gender) {
    _gender = gender;
    notifyListeners();
  }

  void incrementScore() {
    _score += 1;
    notifyListeners();
  }

  void reset() {
    _gender = null;
    _score = 0;
    notifyListeners();
  }
}
