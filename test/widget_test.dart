import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jordanian_ser_app/main.dart';
import 'package:jordanian_ser_app/models/emotion.dart';
import 'package:jordanian_ser_app/widgets/audio_visualizer_wave.dart';
import 'package:jordanian_ser_app/widgets/emotion_card.dart';
import 'package:jordanian_ser_app/widgets/hold_to_record_button.dart';
import 'package:jordanian_ser_app/widgets/responsive_container.dart';

void main() {
  group('JordanianSERApp Widget Tests', () {
    testWidgets('JordanianSERApp builds successfully and shows title & options',
        (WidgetTester tester) async {
      await tester.pumpWidget(const JordanianSERApp());

      // Verify app starts on GenderSelectionScreen with expected Arabic text & badge
      expect(find.text('المشروع الوطني للذكاء الاصطناعي الأردني'), findsOneWidget);
      expect(find.text('تحدي الصوت الأردني'), findsOneWidget);
      expect(find.text('شاب'), findsOneWidget);
      expect(find.text('صبية'), findsOneWidget);
    });

    testWidgets('Selecting gender shows contributor ID preview and enables Start button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const JordanianSERApp());

      // Initial state: start button is not present
      expect(find.text('ابدأ التحدي 🚀'), findsNothing);

      // Tap on male option 'شاب'
      await tester.tap(find.text('شاب'));
      await tester.pumpAndSettle();

      // Contributor ID badge and Start button should now be visible
      expect(find.textContaining('معرّف المساهم: M'), findsOneWidget);
      expect(find.text('ابدأ التحدي 🚀'), findsOneWidget);

      // Tap Start Challenge to navigate to Emotions Menu
      await tester.tap(find.text('ابدأ التحدي 🚀'));
      await tester.pumpAndSettle();

      // Verify on Emotions Menu
      expect(find.text('اختر الشعور'), findsOneWidget);
      expect(find.text('معصب'), findsOneWidget);
      expect(find.text('فرحان'), findsOneWidget);
      expect(find.text('زعلان'), findsOneWidget);
      expect(find.text('طبيعي'), findsOneWidget);
    });

    testWidgets('ResponsiveContainer wraps content cleanly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Text('محتوى تجريبي'),
            ),
          ),
        ),
      );

      expect(find.text('محتوى تجريبي'), findsOneWidget);
    });

    testWidgets('AudioVisualizerWave renders waveform bars',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioVisualizerWave(
              isRecording: true,
              color: Colors.teal,
            ),
          ),
        ),
      );

      expect(find.byType(AudioVisualizerWave), findsOneWidget);
    });

    testWidgets('HoldToRecordButton supports mode toggling and rendering',
        (WidgetTester tester) async {
      bool started = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoldToRecordButton(
              color: Colors.red,
              mode: RecordingMode.tapToToggle,
              onRecordStart: () => started = true,
              onRecordStop: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HoldToRecordButton), findsOneWidget);

      // Tap to start in tapToToggle mode
      await tester.tap(find.byType(HoldToRecordButton));
      await tester.pump();
      expect(started, isTrue);
    });

    testWidgets('EmotionCard displays emoji, label, and prompt count',
        (WidgetTester tester) async {
      final happyData = EmotionData.all[EmotionType.happy]!;
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmotionCard(
              data: happyData,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('فرحان'), findsOneWidget);
      expect(find.text(happyData.emoji), findsOneWidget);
      expect(find.text('${happyData.prompts.length} جمل'), findsOneWidget);

      await tester.tap(find.byType(EmotionCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
