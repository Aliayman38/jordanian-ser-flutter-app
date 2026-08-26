import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_visualizer_wave.dart';
import '../widgets/hold_to_record_button.dart';
import '../widgets/responsive_container.dart';

enum _RecordingStage { idle, recording, uploading }

/// Interactive recording screen: rotating Jordanian prompts, live frequency visualizer,
/// elapsed timer, dual hold/tap modes, minimum duration protection, and gamified celebration.
class RecordingScreen extends StatefulWidget {
  final EmotionData emotion;
  const RecordingScreen({super.key, required this.emotion});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();

  late int _promptIndex;
  _RecordingStage _stage = _RecordingStage.idle;
  RecordingMode _recordingMode = RecordingMode.hold;
  String? _lastError;
  String? _infoTip;

  Timer? _timer;
  int _elapsedMilliseconds = 0;
  DateTime? _recordStartTime;

  @override
  void initState() {
    super.initState();
    _promptIndex = Random().nextInt(widget.emotion.prompts.length);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  String get _currentPrompt => widget.emotion.promptFor(_promptIndex);

  void _shufflePrompt() {
    if (_stage == _RecordingStage.recording) return;
    setState(() {
      _promptIndex = (_promptIndex + 1) % widget.emotion.prompts.length;
      _lastError = null;
      _infoTip = null;
    });
  }

  void _startTimer() {
    _elapsedMilliseconds = 0;
    _recordStartTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _elapsedMilliseconds =
              DateTime.now().difference(_recordStartTime!).inMilliseconds;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String get _formattedTimer {
    final totalSeconds = _elapsedMilliseconds ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _startRecording() async {
    setState(() {
      _lastError = null;
      _infoTip = null;
      _stage = _RecordingStage.recording;
    });
    _startTimer();

    try {
      await _audioService.startRecording();
    } catch (e) {
      _stopTimer();
      if (!mounted) return;
      setState(() {
        _stage = _RecordingStage.idle;
        _lastError = e.toString();
      });
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    if (_stage != _RecordingStage.recording) return;
    _stopTimer();

    final recordDurationMs = _elapsedMilliseconds;

    // Minimum duration guard: at least 1000ms (1.0 second)
    if (recordDurationMs < 1000) {
      final file = await _audioService.stopRecording();
      if (file != null) {
        unawaited(file.delete().catchError((_) => file));
      }
      if (!mounted) return;
      setState(() {
        _stage = _RecordingStage.idle;
        _infoTip = 'التسجيل قصير جداً (أقل من ثانية). يرجى التحدث بوضوح وإعادة المحاولة.';
      });
      return;
    }

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
      referenceText: _currentPrompt,
    );

    // Best-effort local cleanup
    unawaited(file.delete().catchError((_) => file));

    if (!mounted) return;

    if (result.success) {
      appState.incrementScore();
      setState(() {
        _stage = _RecordingStage.idle;
        _elapsedMilliseconds = 0;
      });
      await _showSuccessDialog();
    } else {
      setState(() {
        _stage = _RecordingStage.idle;
        _lastError = result.errorMessage ?? 'صار خطأ غير متوقع في رفع الصوت.';
      });
    }
  }

  Future<void> _showSuccessDialog() {
    final appState = context.read<AppState>();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.amberGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.glowShadow(AppTheme.accentOrange, opacity: 0.35),
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 40)),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'فجرت المايك يا غالي! 🇯🇴',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'تم رفع تسجيلك بنجاح للمشروع الوطني، شكراً لمساهمتك القيمة!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              // Score bump pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'مجموع مساهماتك الآن: ${appState.score}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        'تسجيل جملة ثانية',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _shufflePrompt();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text(
                        'العودة لقائمة المشاعر',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
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
        return _recordingMode == RecordingMode.hold
            ? 'اضغط واستمر بالضغط على المايك للتسجيل'
            : 'اضغط على المايك للبدء، واضغط مرة أخرى للإيقاف';
      case _RecordingStage.recording:
        return _recordingMode == RecordingMode.hold
            ? '🎙️ جاري التسجيل... ارفع إصبعك للإرسال'
            : '🎙️ جاري التسجيل... اضغط لإيقاف التسجيل والإرسال';
      case _RecordingStage.uploading:
        return '🚀 جاري رفع المقطع الصوتي ومعالجته...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotion = widget.emotion;
    final isRecording = _stage == _RecordingStage.recording;
    final isUploading = _stage == _RecordingStage.uploading;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emotion.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              emotion.labelArabic,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            // Mode Selector Pill Switcher
            _RecordingModeSelector(
              currentMode: _recordingMode,
              isBusy: isRecording || isUploading,
              onModeChanged: (mode) {
                setState(() => _recordingMode = mode);
              },
            ),

            const SizedBox(height: 14),

            // Target Jordanian Prompt Card with Shuffle Button
            _PromptCard(
              prompt: _currentPrompt,
              emotion: emotion,
              onShuffle: isRecording || isUploading ? null : _shufflePrompt,
              promptNumber: _promptIndex + 1,
              totalPrompts: emotion.prompts.length,
            ),

            if (_lastError != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _lastError!),
            ],

            if (_infoTip != null) ...[
              const SizedBox(height: 12),
              _InfoBanner(message: _infoTip!),
            ],

            const SizedBox(height: 16),

            // Timer & Audio Frequency Waveform Visualizer
            if (isRecording) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formattedTimer,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Waveform Visualizer
            AudioVisualizerWave(
              isRecording: isRecording,
              color: emotion.color,
              secondaryColor: emotion.darkColor,
            ),

            const SizedBox(height: 18),

            // Hold / Tap Record Button
            if (isUploading)
              const Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(strokeWidth: 3.5),
                  ),
                  SizedBox(height: 16),
                ],
              )
            else
              HoldToRecordButton(
                color: emotion.color,
                isRecording: isRecording,
                isBusy: isUploading,
                mode: _recordingMode,
                onRecordStart: _startRecording,
                onRecordStop: _stopRecordingAndUpload,
              ),

            const SizedBox(height: 16),

            // Status instruction text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _statusText,
                key: ValueKey(_statusText),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isRecording ? FontWeight.w700 : FontWeight.w500,
                  color: isRecording ? AppTheme.textDark : AppTheme.textMuted,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RecordingModeSelector extends StatelessWidget {
  final RecordingMode currentMode;
  final bool isBusy;
  final ValueChanged<RecordingMode> onModeChanged;

  const _RecordingModeSelector({
    required this.currentMode,
    required this.isBusy,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeItem(
            label: 'اضغط واستمر 👆',
            isSelected: currentMode == RecordingMode.hold,
            onTap: isBusy ? null : () => onModeChanged(RecordingMode.hold),
          ),
          const SizedBox(width: 4),
          _ModeItem(
            label: 'ضغطة للبدء والإيقاف ⏯️',
            isSelected: currentMode == RecordingMode.tapToToggle,
            onTap: isBusy ? null : () => onModeChanged(RecordingMode.tapToToggle),
          ),
        ],
      ),
    );
  }
}

class _ModeItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ModeItem({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final String prompt;
  final EmotionData emotion;
  final VoidCallback? onShuffle;
  final int promptNumber;
  final int totalPrompts;

  const _PromptCard({
    required this.prompt,
    required this.emotion,
    required this.onShuffle,
    required this.promptNumber,
    required this.totalPrompts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: emotion.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: emotion.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: emotion.color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with prompt indicator & shuffle button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: emotion.color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'جملة $promptNumber من $totalPrompts',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: emotion.darkColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'بنبرة ${emotion.labelArabic}:',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),

              // Shuffle prompt button
              if (onShuffle != null)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: emotion.darkColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  icon: const Icon(Icons.shuffle_rounded, size: 16),
                  label: const Text(
                    'جملة ثانية',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  onPressed: onShuffle,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Animated prompt text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              prompt,
              key: ValueKey(prompt),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                height: 1.55,
                color: AppTheme.textDark,
              ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small helper so we can fire-and-forget a Future without a lint warning.
void unawaited(Future<void> future) {}
