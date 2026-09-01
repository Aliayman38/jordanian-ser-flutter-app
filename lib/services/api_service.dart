import { ApiConstants } from '../constants/api_constants';
import { AudioData } from '../models/audio_data';

export class UploadResult {
  constructor({ success, errorMessage = null }) {
    this.success = success;
    this.errorMessage = errorMessage;
  }

  static ok() {
    return new UploadResult({ success: true, errorMessage: null });
  }

  static fail(errorMessage) {
    return new UploadResult({ success: false, errorMessage });
  }
}

export class ApiService {
  constructor(baseUrl) {
    this.baseUrl = ApiService._normalizeUrl(baseUrl || ApiConstants.baseUrl);
  }

  static _normalizeUrl(url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  async submitAudio({ audioData, speakerId, emotionTag, referenceText }) {
    if (audioData.isEmpty) {
      return UploadResult.fail('الملف الصوتي فارغ أو غير صالح.');
    }

    const url = `${this.baseUrl}${ApiConstants.submitAudioEndpoint}`;

    try {
      const formData = new FormData();
      formData.append('speaker_id', speakerId);
      formData.append('emotion', emotionTag);
      formData.append('text', referenceText);

      const blob = new Blob([audioData.bytes], { type: audioData.mimeType || 'audio/wav' });
      formData.append('file', blob, audioData.filename);

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), ApiConstants.uploadTimeout);

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'User-Agent': ApiConstants.userAgent,
        },
        body: formData,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (response.status === 200) {
        return UploadResult.ok();
      }

      return UploadResult.fail(`فشل الرفع (رمز الخطأ: ${response.status}).`);
    } catch (e) {
      if (e.name === 'TypeError' || e.message?.includes('NetworkError') || e.message?.includes('Failed to fetch')) {
        return UploadResult.fail('تعذر الاتصال بالخادم. تأكد من اتصالك بالإنترنت وصحة الرابط.');
      }
      return UploadResult.fail(`صار خطأ غير متوقع: ${e}`);
    }
  }
}
