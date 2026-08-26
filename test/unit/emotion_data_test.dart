import 'package:flutter_test/flutter_test.dart';
import 'package:jordanian_ser_app/models/emotion.dart';

void main() {
  group('EmotionData Tests', () {
    test('All 4 core emotion categories are configured', () {
      expect(EmotionData.all.length, equals(4));
      expect(EmotionData.all.containsKey(EmotionType.angry), isTrue);
      expect(EmotionData.all.containsKey(EmotionType.happy), isTrue);
      expect(EmotionData.all.containsKey(EmotionType.sad), isTrue);
      expect(EmotionData.all.containsKey(EmotionType.neutral), isTrue);
    });

    test('Each emotion has at least 4 authentic prompts', () {
      for (final entry in EmotionData.all.entries) {
        final data = entry.value;
        expect(data.prompts.length, greaterThanOrEqualTo(4));
        expect(data.labelArabic.isNotEmpty, isTrue);
        expect(data.subtitleArabic.isNotEmpty, isTrue);
        expect(data.emoji.isNotEmpty, isTrue);
        expect(data.apiTag.isNotEmpty, isTrue);
      }
    });

    test('promptFor rotates and cycles within bounds', () {
      final happy = EmotionData.all[EmotionType.happy]!;
      final count = happy.prompts.length;
      expect(happy.promptFor(0), equals(happy.prompts[0]));
      expect(happy.promptFor(count), equals(happy.prompts[0]));
      expect(happy.promptFor(count + 1), equals(happy.prompts[1]));
    });
  });
}
