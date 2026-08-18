import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hold_to_record_button.dart';

enum _RecordingStage { idle, recording, uploading }

/// Shows the target Jordanian prompt for the chosen emotion, records audio
/// via press-and-hold, and uploads it to the FastAPI backend.
class RecordingScreen extends StatefulWidget {
  final EmotionData emotion;
  const RecordingScreen({super.key, required this.emotion});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();

  late final String _prompt =
      widget.emotion.promptFor(Random().nextInt(1000));

  _RecordingStage _stage = _RecordingStage.idle;
  String? _lastError;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _lastError = null;
      _stage = _RecordingStage.recording;
    });
    try {
      await _audioService.startRecording();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _RecordingStage.idle;
        _lastError = e.toString();
      });
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    if (_stage != _RecordingStage.recording) return;
    setState(() => _stage = _RecordingStage.uploading);

    final file = await _audioService.stopRecording();
    if (file == null) {
      if (!mounted) return;
      setState(() {
        _stage = _RecordingStage.idle;
        _lastError = 'ما انسجل الصوت، جرب مرة ثانية.';
      });
      return;
    }

    final appState = context.read<AppState>();
    final result = await _apiService.submitAudio(
      audioFile: file,
      speakerId: appState.speakerId,
      emotionTag: widget.emotion.apiTag,
      referenceText: _prompt,
    );

    // Best-effort local cleanup; failure here shouldn't block the UX.
    unawaited(file.delete().catchError((_) => file));

    if (!mounted) return;

    if (result.success) {
      appState.incrementScore();
      setState(() => _stage = _RecordingStage.idle);
      await _showSuccessDialog();
    } else {
      setState(() {
        _stage = _RecordingStage.idle;
        _lastError = result.errorMessage ?? 'صار خطأ غير متوقع.';
      });
    }
  }

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                'فجرت المايك يا غالي!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تم رفع تسجيلك بنجاح، شكراً لمساهمتك!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // close dialog
                    Navigator.of(context).pop(); // back to emotions menu
                  },
                  child: const Text('جولة ثانية 🔁'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _statusText {
    switch (_stage) {
      case _RecordingStage.idle:
        return 'اضغط واستمر بالضغط عشان تسجل';
      case _RecordingStage.recording:
        return 'بسجل الآن... ارفع إصبعك للإيقاف';
      case _RecordingStage.uploading:
        return 'جاري رفع التسجيل...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotion = widget.emotion;

    return Scaffold(
      appBar: AppBar(
        title: Text('${emotion.emoji} ${emotion.labelArabic}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              _PromptCard(prompt: _prompt, emotion: emotion),
              if (_lastError != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: _lastError!),
              ],
              const Spacer(),
              if (_stage == _RecordingStage.uploading)
                const CircularProgressIndicator()
              else
                HoldToRecordButton(
                  color: emotion.color,
                  isBusy: _stage == _RecordingStage.uploading,
                  onRecordStart: _startRecording,
                  onRecordStop: _stopRecordingAndUpload,
                ),
              const SizedBox(height: 20),
              Text(
                _statusText,
                style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final String prompt;
  final EmotionData emotion;
  const _PromptCard({required this.prompt, required this.emotion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: emotion.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: emotion.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقرأ النص التالي بصوت ${emotion.labelArabic}:',
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),
          Text(
            prompt,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.6,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small helper so we can fire-and-forget a Future without a lint warning.
void unawaited(Future<void> future) {}
