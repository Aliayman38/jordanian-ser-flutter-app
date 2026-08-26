import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

/// Result of an upload attempt, surfaced to the UI layer.
class UploadResult {
  final bool success;
  final String? errorMessage;

  const UploadResult.ok() : success = true, errorMessage = null;
  const UploadResult.fail(this.errorMessage) : success = false;
}

/// Handles all communication with the FastAPI data-collection backend.
class ApiService {
  ApiService({String? baseUrl})
      : baseUrl = _normalizeUrl(baseUrl ?? ApiConstants.baseUrl);

  final String baseUrl;

  static String _normalizeUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

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

    final uri = Uri.parse('$baseUrl${ApiConstants.submitAudioEndpoint}');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['User-Agent'] = ApiConstants.userAgent
        ..fields['speaker_id'] = speakerId
        ..fields['emotion'] = emotionTag
        ..fields['text'] = referenceText // تم التعديل لتطابق FastAPI
        ..files.add(
          await http.MultipartFile.fromPath(
            'file', // تم التعديل لتطابق FastAPI
            audioFile.path,
            filename: audioFile.uri.pathSegments.last,
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
    } on SocketException {
      return const UploadResult.fail('تأكد من الاتصال بالإنترنت وحاول مرة ثانية.');
    } catch (e) {
      return UploadResult.fail('صار خطأ غير متوقع: $e');
    }
  }
}
