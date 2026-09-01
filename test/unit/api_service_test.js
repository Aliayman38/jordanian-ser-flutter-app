import { AudioData } from '../models/audio_data';
import { ApiService } from '../services/api_service';

describe('ApiService Configuration Tests', () => {
  test('Default baseUrl uses ApiConstants.baseUrl without trailing slash', () => {
    const service = new ApiService();
    expect(service.baseUrl).toBe('https://serios.eqratech.com');
  });

  test('Custom baseUrl with trailing slash is normalized', () => {
    const service = new ApiService('https://serios.eqratech.com/');
    expect(service.baseUrl).toBe('https://serios.eqratech.com');
  });

  test('submitAudio fails gracefully if AudioData is empty', async () => {
    const service = new ApiService();
    const emptyAudio = new AudioData({
      bytes: new Uint8Array(0),
      filename: 'empty.wav',
    });

    const result = await service.submitAudio({
      audioData: emptyAudio,
      speakerId: 'M1234',
      emotionTag: 'happy',
      referenceText: 'نص تجريبي',
    });

    expect(result.success).toBe(false);
    expect(result.errorMessage).toBe('الملف الصوتي فارغ أو غير صالح.');
  });
});