import 'package:record/record.dart';
import '../models/audio_data.dart';
import 'audio_io.dart' as audio_io;

/// Cross-platform wrapper around the `record` package configured for SER data
/// collection: mono, 16kHz, WAV — compatible with both Mobile (Android/iOS) and Web.
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
  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (_) {
      return false;
    }
  }

  /// Starts recording. Returns the target path or empty string on web.
  Future<String> startRecording() async {
    final granted = await hasPermission();
    if (!granted) {
      throw const RecordingPermissionException(
        'صلاحية الميكروفون مرفوضة. يرجى السماح بالوصول للميكروفون من إعدادات المتصفح أو الجهاز.',
      );
    }

    final path = await audio_io.getTempAudioPath();
    await _recorder.start(_config, path: path);
    _isRecording = true;
    return path;
  }

  /// Stops the current recording and returns the cross-platform [AudioData],
  /// or `null` if nothing was recorded.
  Future<AudioData?> stopRecording() async {
    final pathOrUrl = await _recorder.stop();
    _isRecording = false;
    if (pathOrUrl == null) return null;

    final bytes = await audio_io.readAudioBytes(pathOrUrl);
    if (bytes == null || bytes.isEmpty) return null;

    final filename = 'ser_${DateTime.now().millisecondsSinceEpoch}.wav';
    return AudioData(
      bytes: bytes,
      filename: filename,
      mimeType: 'audio/wav',
    );
  }

  /// Discards the recorded audio resource.
  Future<void> discardAudio(String? pathOrUrl) async {
    if (pathOrUrl != null && pathOrUrl.isNotEmpty) {
      await audio_io.deleteAudioFile(pathOrUrl);
    }
  }

  /// Cancels an in-progress recording and discards the stream/file.
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
