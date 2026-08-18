import 'dart:io';
import 'package:http/http.dart' as http;

/// Result of an upload attempt, surfaced to the UI layer.
class UploadResult {
  final bool success;
  final String? errorMessage;

  const UploadResult.ok() : success = true, errorMessage = null;
  const UploadResult.fail(this.errorMessage) : success = false;
}

/// Handles all communication with the FastAPI data-collection backend.
class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl;

  /// TODO: point this at your deployed FastAPI instance.
  /// Kept as a plain field (not const) so it can be overridden per-build
  /// (e.g. via --dart-define) without touching this file.
  static const String _defaultBaseUrl = 'https://your-fastapi-server.com';

  final String baseUrl;

  static const String _userAgent = 'JordanianSERApp/iOS';

  /// Uploads a recorded WAV file plus metadata to `/api/submit-audio`.
  ///
  /// [audioFile] must be a valid, existing WAV file on disk.
  Future<UploadResult> submitAudio({
    required File audioFile,
    required String speakerId,
    required String emotionTag,
    required String referenceText,
  }) async {
    if (!await audioFile.exists()) {
      return const UploadResult.fail('الملف الصوتي غير موجود.');
    }

    final uri = Uri.parse('$baseUrl/api/submit-audio');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['User-Agent'] = _userAgent
        ..fields['speaker_id'] = speakerId
        ..fields['emotion'] = emotionTag
        ..fields['reference_text'] = referenceText
        ..files.add(
          await http.MultipartFile.fromPath(
            'audio_file',
            audioFile.path,
            filename: audioFile.uri.pathSegments.last,
          ),
        );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return const UploadResult.ok();
      }
      return UploadResult.fail(
        'فشل الرفع (رمز الخطأ: ${response.statusCode}).',
      );
    } on SocketException {
      return const UploadResult.fail('تأكد من الاتصال بالإنترنت وحاول مرة ثانية.');
    } catch (e) {
      return UploadResult.fail('صار خطأ غير متوقع: $e');
    }
  }
}
