import { ApiConstants } from '../constants/api_constants.js';
import { AudioData } from '../models/audio_data.js';

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
    return url && url.endsWith('/') ? url.substring(0, url.length - 1) : (url || '');
  }

  async submitAudio({ audioData, speakerId, emotionTag, referenceText }) {
    if (!audioData || audioData.isEmpty) {
      return UploadResult.fail('الملف الصوتي فارغ أو غير صالح.');
    }

    const endpoint = ApiConstants.submitAudioEndpoint || '/api/submit-audio';
    const url = `${this.baseUrl}${endpoint}`;

    try {
      const formData = new FormData();
      formData.append('speaker_id', String(speakerId || 'speaker_unknown'));
      formData.append('emotion', String(emotionTag || 'neutral'));
      formData.append('text', String(referenceText || ''));

      const blob = new Blob([audioData.bytes], { type: 'audio/wav' });
      formData.append('file', blob, audioData.filename || 'recording.wav');

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), ApiConstants.uploadTimeout || 35000);

      const response = await fetch(url, {
        method: 'POST',
        body: formData,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (response.ok) {
        return UploadResult.ok();
      }

      const errorText = await response.text();
      console.error('API Error Response:', response.status, errorText);
      return UploadResult.fail(`فشل الرفع من الخادم (رمز: ${response.status})`);
    } catch (e) {
      console.error('API Fetch Exception:', e);
      if (e.name === 'AbortError') {
        return UploadResult.fail('انتهت مهلة الاتصال بالخادم. حاول مجدداً.');
      }
      return UploadResult.fail('تعذر الاتصال بالخادم. تأكد من عمل السيرفر والإنترنت.');
    }
  }
}

export default ApiService;