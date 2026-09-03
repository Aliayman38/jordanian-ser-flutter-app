import { AudioData } from '../models/audio_data.js';

export class AudioServiceError extends Error {
  constructor(message, { code = 'UNKNOWN', actionHint = '' } = {}) {
    super(message);
    this.name = 'AudioServiceError';
    this.code = code;
    this.actionHint = actionHint;
  }
}

export class AudioService {
  constructor() {
    this.mediaRecorder = null;
    this.audioChunks = [];
    this.stream = null;
    this.isRecording = false;
    this.selectedMimeType = '';
    this.audioContext = null;
  }

  static isAppleDevice() {
    if (typeof navigator === 'undefined') return false;
    const ua = navigator.userAgent || '';
    const platform = navigator.platform || '';
    const maxTouchPoints = navigator.maxTouchPoints || 0;
    return (
      /iPad|iPhone|iPod/.test(ua) ||
      (platform === 'MacIntel' && maxTouchPoints > 1) ||
      /Macintosh/.test(ua) ||
      (typeof CSS !== 'undefined' && CSS.supports && CSS.supports('-webkit-touch-callout', 'none'))
    );
  }

  // إيقاظ الـ AudioContext مبكراً استجابةً لنقر المستخدم لتفادي قيود Safari
  unlockAudioContext() {
    try {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (!AudioCtx) return;
      if (!this.audioContext || this.audioContext.state === 'closed') {
        this.audioContext = new AudioCtx();
      }
      if (this.audioContext.state === 'suspended') {
        this.audioContext.resume().catch(() => {});
      }
    } catch (e) {
      console.warn('Could not unlock AudioContext:', e);
    }
  }

  // فحص وتحديد أفضل صيغة مدعومة للمتصفح الحالي مع مراعاة Safari
  _resolveSupportedMimeType() {
    if (typeof MediaRecorder === 'undefined') return '';

    const isApple = AudioService.isAppleDevice();
    const candidates = isApple
      ? [
          'audio/mp4;codecs=mp4a',
          'audio/mp4',
          'audio/aac',
          'audio/webm;codecs=opus',
          'audio/webm',
        ]
      : [
          'audio/webm;codecs=opus',
          'audio/webm',
          'audio/mp4;codecs=mp4a',
          'audio/mp4',
          'audio/aac',
        ];

    for (const mime of candidates) {
      if (MediaRecorder.isTypeSupported && MediaRecorder.isTypeSupported(mime)) {
        return mime;
      }
    }
    return '';
  }

  // فحص تشخيصي شامل لحالة الميكروفون
  async checkPermission() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      return { supported: false, granted: false, reason: 'unsupported' };
    }
    try {
      if (navigator.permissions && navigator.permissions.query) {
        const status = await navigator.permissions.query({ name: 'microphone' });
        return {
          supported: true,
          granted: status.state === 'granted',
          state: status.state,
        };
      }
    } catch (e) {
      // متصفح Safari لا يدعم permissions.query('microphone')
    }
    return { supported: true, granted: null, state: 'prompt' };
  }

  classifyError(err) {
    const isApple = AudioService.isAppleDevice();
    const isSecure = typeof window !== 'undefined'
      ? (window.isSecureContext ?? (window.location.protocol === 'https:' || window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'))
      : true;

    if (!isSecure) {
      return new AudioServiceError(
        'متصفحك يحجب الميكروفون لأن الاتصال غير آمن (HTTP).',
        {
          code: 'INSECURE_CONTEXT',
          actionHint: isApple
            ? 'أجهزة Apple و Safari تتطلب فتح الرابط عبر https:// آمن أو عبر نفق مشفر لتشغيل الميكروفون.'
            : 'يرجى فتح الموقع عبر رابط https:// مشفر.',
        }
      );
    }

    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      return new AudioServiceError(
        'المتصفح لا يدعم الوصول للميكروفون أو تم حظره تماماً.',
        {
          code: 'NOT_SUPPORTED',
          actionHint: isApple
            ? 'تأكد من فتح الرابط في متصفح Safari وتحديث نظام iOS.'
            : 'يرجى استخدام متصفح حديث يدعم التسجيل مثل Chrome أو Firefox.',
        }
      );
    }

    const errName = err?.name || '';
    const errMsg = err?.message || '';

    if (errName === 'NotAllowedError' || errName === 'PermissionDeniedError') {
      return new AudioServiceError(
        'تم رفض إذن استخدام الميكروفون!',
        {
          code: 'PERMISSION_DENIED',
          actionHint: isApple
            ? 'في أجهزة آبل: افتح إعدادات الآيفون > Safari > الميكروفون > اختر (سماح)، أو اضغط على أيقونة (aA) بجانب العنوان.'
            : 'اضغط على علامة القفل بجانب رابط الموقع في المتصفح وفعّل إذن "الميكروفون".',
        }
      );
    }

    if (errName === 'NotFoundError' || errName === 'DevicesNotFoundError') {
      return new AudioServiceError(
        'لم يتم العثور على ميكروفون متصل بالجهاز!',
        {
          code: 'NO_MIC',
          actionHint: 'يرجى توصيل سماعة أو ميكروفون والتأكد من تعريفه في إعدادات الصوت بالنظام.',
        }
      );
    }

    if (errName === 'NotReadableError' || errName === 'TrackStartError') {
      return new AudioServiceError(
        'تعذر تشغيل الميكروفون لأنه قيد الاستخدام من تطبيق آخر أو مكالمة جارية.',
        {
          code: 'MIC_BUSY',
          actionHint: 'أغلق المكالمات أو أي تطبيقات أخرى تسجل الصوت حالياً، ثم أعد المحاولة.',
        }
      );
    }

    if (errName === 'OverconstrainedError') {
      return new AudioServiceError(
        'خصائص الصوت المطلوبة غير متوفرة في الميكروفون المتصل.',
        {
          code: 'OVERCONSTRAINED',
          actionHint: 'يرجى تجربة ميكروفون أو سماعة أخرى.',
        }
      );
    }

    return new AudioServiceError(
      errMsg || 'تعذر بدء تسجيل الصوت.',
      {
        code: 'UNKNOWN',
        actionHint: 'أعد تحديث الصفحة وحاول مرة أخرى.',
      }
    );
  }

  async startRecording() {
    this.unlockAudioContext();

    // 1. التحقق من توفر API الصوت ومستوى الأمان
    const isApple = AudioService.isAppleDevice();
    const isSecure = typeof window !== 'undefined'
      ? (window.isSecureContext ?? (window.location.protocol === 'https:' || window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'))
      : true;

    if (!isSecure) {
      this.isRecording = false;
      throw this.classifyError(new Error('Insecure context'));
    }

    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      this.isRecording = false;
      throw this.classifyError(new Error('No mediaDevices'));
    }

    try {
      this.audioChunks = [];

      // 2. محاولة الحصول على الـ Stream مع إعدادات متوافقة مع Safari وباقي المتصفحات
      let streamPromise = navigator.mediaDevices.getUserMedia({
        audio: {
          channelCount: 1,
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      });

      // إذا فشلت القيود الصارمة في بعض الأجهزة القديمة، المحاولة بـ audio: true
      try {
        this.stream = await streamPromise;
      } catch (e) {
        if (e.name === 'OverconstrainedError') {
          this.stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        } else {
          throw e;
        }
      }

      // 3. تحديد الصيغة المتوافقة
      this.selectedMimeType = this._resolveSupportedMimeType();
      const options = this.selectedMimeType ? { mimeType: this.selectedMimeType } : {};

      try {
        this.mediaRecorder = new MediaRecorder(this.stream, options);
      } catch (recErr) {
        // في حال فشل صيغة معينة، المحاولة بالافتراضي
        this.mediaRecorder = new MediaRecorder(this.stream);
      }

      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data && event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      };

      // ملاحظة مهمة جداً لـ Apple / Safari:
      // استخدام timeslice (مثل start(100)) مع صيغة MP4 على Safari ينتج أجزاء تالفة تفتقر للهيدرز.
      // لذلك نطلق التسجيل بدون timeslice في Apple ليتم إخراج ملف MP4 موحد سليم عند stop().
      if (isApple) {
        this.mediaRecorder.start();
      } else {
        this.mediaRecorder.start(250);
      }

      this.isRecording = true;
    } catch (err) {
      this.isRecording = false;
      if (this.stream) {
        this.stream.getTracks().forEach((track) => track.stop());
        this.stream = null;
      }
      throw this.classifyError(err);
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

          // تحويل الصوت إلى 16kHz Mono WAV متوافق 100% مع الباك إند وجميع أجهزة آبل
          const wavData = await this._convertToWav16kMono(rawBlob);

          if (this.stream) {
            this.stream.getTracks().forEach((track) => track.stop());
            this.stream = null;
          }
          this.isRecording = false;
          resolve(wavData);
        } catch (e) {
          this.isRecording = false;
          if (this.stream) {
            this.stream.getTracks().forEach((track) => track.stop());
            this.stream = null;
          }
          console.error('Audio processing error (iOS/Android/Desktop):', e);
          reject(e);
        }
      };

      try {
        // تجنب طلب requestData على Safari لتفادي رمي InvalidStateError
        if (!AudioService.isAppleDevice() && this.mediaRecorder.state === 'recording') {
          this.mediaRecorder.requestData();
        }
      } catch (e) {
        // تجاهل أي خطأ عابر
      }

      try {
        this.mediaRecorder.stop();
      } catch (e) {
        this.isRecording = false;
        resolve(AudioData.empty());
      }
    });
  }

  /**
   * تحويل الصوت إلى 16,000Hz أحادي Mono WAV بطريقة آمنة ومتوافقة بالكامل مع Safari
   * دون استخدام OfflineAudioContext بترددات غير مدعومة.
   */
  async _convertToWav16kMono(blob) {
    const arrayBuffer = await blob.arrayBuffer();
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) {
      throw new Error('متصفحك لا يدعم معالجة الصوت الرقمي (Web Audio API).');
    }

    const ctx = this.audioContext && this.audioContext.state !== 'closed'
      ? this.audioContext
      : new AudioCtx();

    if (ctx.state === 'suspended') {
      try {
        await ctx.resume();
      } catch (e) {}
    }

    // فك تشفير الصوت مع مراعاة فصل الـ ArrayBuffer في WebKit
    let decodedAudio;
    const bufferClone = arrayBuffer.slice(0);
    try {
      decodedAudio = await ctx.decodeAudioData(arrayBuffer);
    } catch (err) {
      decodedAudio = await new Promise((res, rej) => {
        ctx.decodeAudioData(bufferClone, res, rej);
      });
    }

    if (!decodedAudio || decodedAudio.length === 0) {
      throw new Error('الملف الصوتي المسجل فارغ أو لم يتم التقاط صوت.');
    }

    // إعادة أخذ العينات (Resampling) إلى 16000Hz بنقاء تام عبر جافاسكريبت مباشرة
    const targetSampleRate = 16000;
    const pcm16k = this._resampleTo16kMono(decodedAudio, targetSampleRate);

    // التحقق من أن الصوت يحتوي على بيانات حقيقية وليس صمتاً تاماً
    let maxVal = 0;
    for (let i = 0; i < pcm16k.length; i++) {
      const abs = Math.abs(pcm16k[i]);
      if (abs > maxVal) maxVal = abs;
    }
    if (maxVal === 0 && pcm16k.length > targetSampleRate) {
      console.warn('Audio is completely silent, but proceeding.');
    }

    const wavBytes = this._encodeWAV(pcm16k, targetSampleRate);

    return new AudioData({
      bytes: wavBytes,
      filename: `rec_${Date.now()}.wav`,
      mimeType: 'audio/wav',
      durationMs: Math.round(decodedAudio.duration * 1000),
    });
  }

  /**
   * إعادة تشكيل العينات (Linear Interpolation Resampling) وتحويلها إلى أحادي Mono
   * تعمل 100% دون الاعتماد على ميزات المتصفح المقيدة في Safari
   */
  _resampleTo16kMono(audioBuffer, targetSampleRate = 16000) {
    const sourceSampleRate = audioBuffer.sampleRate;
    const numChannels = audioBuffer.numberOfChannels;
    const length = audioBuffer.length;

    // دمج القنوات إلى مصفوفة واحدة Mono
    let monoSamples;
    if (numChannels === 1) {
      monoSamples = audioBuffer.getChannelData(0);
    } else {
      monoSamples = new Float32Array(length);
      const ch0 = audioBuffer.getChannelData(0);
      const ch1 = audioBuffer.getChannelData(1);
      for (let i = 0; i < length; i++) {
        monoSamples[i] = (ch0[i] + ch1[i]) * 0.5;
      }
    }

    if (sourceSampleRate === targetSampleRate) {
      return monoSamples;
    }

    // استيفاء خطي دقيق (Linear Interpolation) للتردد 16000Hz
    const ratio = sourceSampleRate / targetSampleRate;
    const newLength = Math.max(1, Math.round(length / ratio));
    const result = new Float32Array(newLength);

    for (let i = 0; i < newLength; i++) {
      const srcIndex = i * ratio;
      const indexFloor = Math.floor(srcIndex);
      const indexCeil = Math.min(indexFloor + 1, length - 1);
      const fraction = srcIndex - indexFloor;
      result[i] = (1 - fraction) * monoSamples[indexFloor] + fraction * monoSamples[indexCeil];
    }

    return result;
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
    view.setUint32(28, sampleRate * 2, true);  // ByteRate (16000 * 1 * 2)
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
    if (this.audioContext && this.audioContext.state !== 'closed') {
      try {
        this.audioContext.close();
      } catch (e) {}
      this.audioContext = null;
    }
  }
}

export default AudioService;