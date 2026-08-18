import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Thin wrapper around the `record` package configured for SER data
/// collection: mono, 16kHz, 16-bit PCM WAV — a common format for speech
/// model pipelines (matches typical wav2vec2 / whisper front-ends).
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();

  static const RecordConfig _config = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: 16000,
    numChannels: 1,
    bitRate: 256000,
  );

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  /// Checks (and, if needed, requests) microphone permission.
  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Starts recording to a fresh temp WAV file. Returns the file path used.
  Future<String> startRecording() async {
    final granted = await hasPermission();
    if (!granted) {
      throw const RecordingPermissionException(
        'صلاحية الميكروفون مرفوضة. فعّلها من إعدادات الجهاز.',
      );
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/ser_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(_config, path: path);
    _isRecording = true;
    return path;
  }

  /// Stops the current recording and returns the resulting [File], or
  /// `null` if nothing was recorded.
  Future<File?> stopRecording() async {
    final path = await _recorder.stop();
    _isRecording = false;
    if (path == null) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  /// Cancels an in-progress recording and discards the file.
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.cancel();
      _isRecording = false;
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}

class RecordingPermissionException implements Exception {
  final String message;
  const RecordingPermissionException(this.message);

  @override
  String toString() => message;
}
