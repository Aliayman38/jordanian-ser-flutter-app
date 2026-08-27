import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:jordanian_ser_app/models/audio_data.dart';
import 'package:jordanian_ser_app/services/api_service.dart';

void main() {
  group('ApiService Configuration Tests', () {
    test('Default baseUrl uses ApiConstants.baseUrl without trailing slash', () {
      final service = ApiService();
      expect(service.baseUrl, equals('https://serios.eqratech.com'));
    });

    test('Custom baseUrl with trailing slash is normalized', () {
      final service = ApiService(baseUrl: 'https://serios.eqratech.com/');
      expect(service.baseUrl, equals('https://serios.eqratech.com'));
    });

    test('submitAudio fails gracefully if AudioData is empty', () async {
      final service = ApiService();
      final emptyAudio = AudioData(
        bytes: Uint8List(0),
        filename: 'empty.wav',
      );

      final result = await service.submitAudio(
        audioData: emptyAudio,
        speakerId: 'M1234',
        emotionTag: 'happy',
        referenceText: 'نص تجريبي',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('الملف الصوتي فارغ أو غير صالح.'));
    });
  });
}
