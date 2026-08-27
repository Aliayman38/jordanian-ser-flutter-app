import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/audio_data.dart';

/// Result of an upload attempt, surfaced to the UI layer.
class UploadResult {
  final bool success;
  final String? errorMessage;

  const UploadResult.ok() : success = true, errorMessage = null;
  const UploadResult.fail(this.errorMessage) : success = false;
}

/// Handles all communication with the FastAPI data-collection backend
/// across Web, Android, iOS, and Desktop platforms.
class ApiService {
  ApiService({String? baseUrl})
      : baseUrl = _normalizeUrl(baseUrl ?? ApiConstants.baseUrl);

  final String baseUrl;

  static String _normalizeUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Uploads recorded WAV audio bytes plus metadata to `/api/submit-audio`.
  Future<UploadResult> submitAudio({
    required AudioData audioData,
    required String speakerId,
    required String emotionTag,
    required String referenceText,
  }) async {
    if (audioData.isEmpty) {
      return const UploadResult.fail('الملف الصوتي فارغ أو غير صالح.');
    }

    final uri = Uri.parse('$baseUrl${ApiConstants.submitAudioEndpoint}');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['User-Agent'] = ApiConstants.userAgent
        ..fields['speaker_id'] = speakerId
        ..fields['emotion'] = emotionTag
        ..fields['text'] = referenceText
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            audioData.bytes,
            filename: audioData.filename,
          ),
        );

      final streamedResponse = await request.send().timeout(
            ApiConstants.uploadTimeout,
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return const UploadResult.ok();
      }
      return UploadResult.fail(
        'فشل الرفع (رمز الخطأ: ${response.statusCode}).',
      );
    } on http.ClientException {
      return const UploadResult.fail('تعذر الاتصال بالخادم. تأكد من اتصالك بالإنترنت وصحة الرابط.');
    } catch (e) {
      return UploadResult.fail('صار خطأ غير متوقع: $e');
    }
  }
}
