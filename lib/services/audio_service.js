import { AudioData } from '../models/audio_data.js';

export class AudioService {
  constructor() {
    this.mediaRecorder = null;
    this.audioChunks = [];
    this.stream = null;
    this.isRecording = false;
    this.selectedMimeType = '';
  }

  // فحص وتحديد أفضل صيغة مدعومة للمتصفح الحالي (iOS / Android)
  _resolveSupportedMimeType() {
    const candidates = [
      'audio/webm;codecs=opus',
      'audio/webm',
      'audio/mp4;codecs=mp4a',
      'audio/mp4',
      'audio/aac',
    ];
    for (const mime of candidates) {
      if (typeof MediaRecorder !== 'undefined' && MediaRecorder.isTypeSupported(mime)) {
        return mime;
      }
    }
    return '';
  }

  // التحقق المسبق من وجود الصلاحيات (اختياري للفحص السريع)
  async checkPermission() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      return false;
    }
    try {
      if (navigator.permissions && navigator.permissions.query) {
        const status = await navigator.permissions.query({ name: 'microphone' });
        return status.state === 'granted';
      }
    } catch (e) {
      // بعض المتصفحات مثل Safari لا تدعم query('microphone')
    }
    return null; // غير معروف، يتطلب طلب الإذن المباشر
  }

  async startRecording() {
    // 1. التحقق من توفر الـ API في المتصفح
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      this.isRecording = false;
      throw new Error('متصفحك لا يدعم تسجيل الصوت أو أن الموقع لا يعمل عبر رابط HTTPS آمن.');
    }

    try {
      this.audioChunks = [];

      // 2. طلب الصلاحية المباشرة من المستخدم - تفشل وترمي Error فوراً إذا رفض المستخدم
      this.stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          channelCount: 1,
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      });

      // 3. تحديد الصيغة المتوافقة مع الجهاز (تلقائياً mp4 لـ Safari و webm لـ Chrome)
      this.selectedMimeType = this._resolveSupportedMimeType();
      const options = this.selectedMimeType ? { mimeType: this.selectedMimeType } : {};

      this.mediaRecorder = new MediaRecorder(this.stream, options);

      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data && event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      };

      // تجزئة التسجيل كل 100ms لحماية الداتا من الضياع في iOS
      this.mediaRecorder.start(100);
      this.isRecording = true;
    } catch (err) {
      this.isRecording = false;
      if (this.stream) {
        this.stream.getTracks().forEach((track) => track.stop());
        this.stream = null;
      }

      // رسائل واضحة ومحددة لرفض الصلاحيات
      if (err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError') {
        throw new Error('تم رفض الوصول إلى الميكروفون! يرجى منح الإذن من إعدادات المتصفح.');
      } else if (err.name === 'NotFoundError' || err.name === 'DevicesNotFoundError') {
        throw new Error('لم يتم العثور على ميكروفون متصل بالجهاز.');
      } else {
        throw new Error(err.message || 'تعذر تشغيل الميكروفون، تأكد من الصلاحيات.');
      }
    }
  }

  async stopRecording() {
    if (!this.stream && this.audioChunks.length === 0) {
      this.isRecording = false;
      return AudioData.empty();
    }

    return new Promise((resolve, reject) => {
      if (!this.mediaRecorder || this.mediaRecorder.state === 'inactive') {
        this.isRecording = false;
        resolve(AudioData.empty());
        return;
      }

      this.mediaRecorder.onstop = async () => {
        try {
          const mime = this.mediaRecorder.mimeType || this.selectedMimeType || 'audio/webm';
          const rawBlob = new Blob(this.audioChunks, { type: mime });

          if (!rawBlob || rawBlob.size === 0) {
            this.isRecording = false;
            resolve(AudioData.empty());
            return;
          }

          // تحويل الصوت إلى 16kHz Mono WAV للباك إند
          const wavData = await this._convertToWav16kMono(rawBlob);

          if (this.stream) {
            this.stream.getTracks().forEach((track) => track.stop());
            this.stream = null;
          }
          this.isRecording = false;
          resolve(wavData);
        } catch (e) {
          this.isRecording = false;
          console.error('Audio processing error on iOS/Android:', e);
          reject(e);
        }
      };

      // أمر حاسم لـ iOS: تفريغ البايتات المتبقية قبل إيقاف المسجل تماماً
      try {
        if (this.mediaRecorder.state === 'recording') {
          this.mediaRecorder.requestData();
        }
      } catch (e) {}

      this.mediaRecorder.stop();
    });
  }

  async _convertToWav16kMono(blob) {
    const arrayBuffer = await blob.arrayBuffer();
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    const ctx = new AudioCtx();

    // إيقاظ الـ AudioContext المعلق في Safari
    if (ctx.state === 'suspended') {
      await ctx.resume();
    }

    let decodedAudio;
    try {
      decodedAudio = await ctx.decodeAudioData(arrayBuffer);
    } catch (err) {
      // توافق إضافي لإصدارات Safari الأقدم
      decodedAudio = await new Promise((res, rej) => {
        ctx.decodeAudioData(arrayBuffer, res, rej);
      });
    }

    const targetSampleRate = 16000;
    const duration = decodedAudio.duration;
    const offlineCtx = new OfflineAudioContext(
      1,
      Math.max(1, Math.ceil(targetSampleRate * duration)),
      targetSampleRate
    );

    const source = offlineCtx.createBufferSource();
    source.buffer = decodedAudio;
    source.connect(offlineCtx.destination);
    source.start(0);

    const renderedBuffer = await offlineCtx.startRendering();
    await ctx.close();

    const pcmData = renderedBuffer.getChannelData(0);
    const wavBytes = this._encodeWAV(pcmData, targetSampleRate);

    return new AudioData({
      bytes: wavBytes,
      filename: `rec_${Date.now()}.wav`,
      mimeType: 'audio/wav',
    });
  }

  _encodeWAV(samples, sampleRate) {
    const buffer = new ArrayBuffer(44 + samples.length * 2);
    const view = new DataView(buffer);

    const writeString = (offset, string) => {
      for (let i = 0; i < string.length; i++) {
        view.setUint8(offset + i, string.charCodeAt(i));
      }
    };

    // RIFF Header
    writeString(0, 'RIFF');
    view.setUint32(4, 36 + samples.length * 2, true);
    writeString(8, 'WAVE');

    // fmt sub-chunk
    writeString(12, 'fmt ');
    view.setUint32(16, 16, true);
    view.setUint16(20, 1, true);              // PCM Format
    view.setUint16(22, 1, true);              // 1 Channel (Mono)
    view.setUint32(24, sampleRate, true);      // 16000 Hz
    view.setUint32(28, sampleRate * 2, true);  // ByteRate
    view.setUint16(32, 2, true);              // BlockAlign
    view.setUint16(34, 16, true);             // 16-bit

    // data sub-chunk
    writeString(36, 'data');
    view.setUint32(40, samples.length * 2, true);

    // PCM 16-bit
    let offset = 44;
    for (let i = 0; i < samples.length; i++, offset += 2) {
      const s = Math.max(-1, Math.min(1, samples[i]));
      view.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7fff, true);
    }

    return new Uint8Array(buffer);
  }

  dispose() {
    if (this.stream) {
      this.stream.getTracks().forEach((track) => track.stop());
      this.stream = null;
    }
  }
}

export default AudioService;