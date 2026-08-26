import 'package:flutter_test/flutter_test.dart';
import 'package:jordanian_ser_app/models/speaker.dart';
import 'package:jordanian_ser_app/services/app_state.dart';

void main() {
  group('AppState Tests', () {
    test('Initial state should have no gender and score 0', () {
      final state = AppState();
      expect(state.hasSelectedGender, isFalse);
      expect(state.gender, isNull);
      expect(state.score, equals(0));
    });

    test('Selecting male gender produces speakerId starting with M', () {
      final state = AppState();
      state.selectGender(Gender.male);
      expect(state.hasSelectedGender, isTrue);
      expect(state.gender, equals(Gender.male));
      expect(state.speakerId.startsWith('M'), isTrue);
    });

    test('Selecting female gender produces speakerId starting with F', () {
      final state = AppState();
      state.selectGender(Gender.female);
      expect(state.hasSelectedGender, isTrue);
      expect(state.gender, equals(Gender.female));
      expect(state.speakerId.startsWith('F'), isTrue);
    });

    test('Increment score increments correctly', () {
      final state = AppState();
      state.incrementScore();
      state.incrementScore();
      expect(state.score, equals(2));
    });

    test('Reset clears gender and resets score to 0', () {
      final state = AppState();
      state.selectGender(Gender.male);
      state.incrementScore();
      state.reset();
      expect(state.gender, isNull);
      expect(state.score, equals(0));
      expect(state.hasSelectedGender, isFalse);
    });
  });
}
