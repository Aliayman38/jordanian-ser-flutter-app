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
    this.audioContext = null;
    this.source = null;
    this.processor = null;
    this.zeroGain = null;
    this.pcmChunks = [];
    this.stream = null;
    this.isRecording = false;
    this.mediaRecorder = null;
    this.audioChunks = [];
    this.recordingStartTime = 0;
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

  // إيقاظ الـ AudioContext مبكراً استجابةً للمس لتفادي قيود المتصفحات
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
      // Safari لا يدعم query('microphone')
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
      this.pcmChunks = [];
      this.audioChunks = [];
      this.recordingStartTime = Date.now();

      // 1. طلب الوصول إلى الميكروفون
      try {
        this.stream = await navigator.mediaDevices.getUserMedia({
          audio: {
            channelCount: 1,
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
          },
        });
      } catch (e) {
        if (e.name === 'OverconstrainedError') {
          this.stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        } else {
          throw e;
        }
      }

      // 2. إنشاء وتفعيل محرك الصوت المباشر (Direct Web Audio PCM)
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (!this.audioContext || this.audioContext.state === 'closed') {
        this.audioContext = new AudioCtx();
      }
      if (this.audioContext.state === 'suspended') {
        await this.audioContext.resume();
      }

      // 3. التقاط عينات الصوت النقية PCM مباشرة لتفادي EncodingError في Safari
      this.source = this.audioContext.createMediaStreamSource(this.stream);
      // استخدام ScriptProcessor بحجم بافر 4096 عينة لضمان الأداء وثبات التجميع
      this.processor = this.audioContext.createScriptProcessor(4096, 1, 1);

      this.processor.onaudioprocess = (e) => {
        if (!this.isRecording) return;
        const inputData = e.inputBuffer.getChannelData(0);
        this.pcmChunks.push(new Float32Array(inputData));
      };

      // تمرير الصوت عبر zeroGainNode لتفعيل المعالجة في المتصفح دون تشغيل صدى للمستخدم
      this.zeroGain = this.audioContext.createGain();
      this.zeroGain.gain.value = 0;

      this.source.connect(this.processor);
      this.processor.connect(this.zeroGain);
      this.zeroGain.connect(this.audioContext.destination);

      // 4. تشغيل MediaRecorder كنسخة احتياطية متوازية
      try {
        if (typeof MediaRecorder !== 'undefined') {
          const mimeCandidates = ['audio/webm', 'audio/mp4', ''];
          let supportedMime = '';
          for (const m of mimeCandidates) {
            if (!m || (MediaRecorder.isTypeSupported && MediaRecorder.isTypeSupported(m))) {
              supportedMime = m;
              break;
            }
          }
          const options = supportedMime ? { mimeType: supportedMime } : {};
          this.mediaRecorder = new MediaRecorder(this.stream, options);
          this.mediaRecorder.ondataavailable = (event) => {
            if (event.data && event.data.size > 0) {
              this.audioChunks.push(event.data);
            }
          };
          this.mediaRecorder.start();
        }
      } catch (recErr) {
        console.warn('MediaRecorder fallback setup failed, relying on PCM stream:', recErr);
      }

      this.isRecording = true;
    } catch (err) {
      this.isRecording = false;
      this._cleanupAudioNodes();
      if (this.stream) {
        this.stream.getTracks().forEach((track) => track.stop());
        this.stream = null;
      }
      throw this.classifyError(err);
    }
  }

  _cleanupAudioNodes() {
    try {
      if (this.processor) {
        this.processor.onaudioprocess = null;
        this.processor.disconnect();
        this.processor = null;
      }
      if (this.source) {
        this.source.disconnect();
        this.source = null;
      }
      if (this.zeroGain) {
        this.zeroGain.disconnect();
        this.zeroGain = null;
      }
    } catch (e) {
      console.warn('Error cleaning up audio nodes:', e);
    }
  }

  async stopRecording() {
    if (!this.stream && this.pcmChunks.length === 0 && this.audioChunks.length === 0) {
      this.isRecording = false;
      return AudioData.empty();
    }

    this.isRecording = false;
    this._cleanupAudioNodes();

    // إيقاف مسارات المايكروفون
    if (this.stream) {
      this.stream.getTracks().forEach((track) => track.stop());
      this.stream = null;
    }

    // إيقاف الـ MediaRecorder الاحتياطي بهدوء
    try {
      if (this.mediaRecorder && this.mediaRecorder.state !== 'inactive') {
        this.mediaRecorder.stop();
      }
    } catch (e) {}

    // 1. المسار الأساسي المباشر: تحويل مصفوفات PCM النقية إلى WAV
    // هذا المسار سريع جداً ولا يستدعي decodeAudioData، فلا يمكن أن يرمي EncodingError إطلاقاً!
    if (this.pcmChunks.length > 0) {
      try {
        let totalSamples = 0;
        for (let i = 0; i < this.pcmChunks.length; i++) {
          totalSamples += this.pcmChunks[i].length;
        }

        if (totalSamples === 0) {
          return AudioData.empty();
        }

        const mergedPcm = new Float32Array(totalSamples);
        let offset = 0;
        for (let i = 0; i < this.pcmChunks.length; i++) {
          mergedPcm.set(this.pcmChunks[i], offset);
          offset += this.pcmChunks[i].length;
        }

        this.pcmChunks = [];

        const inputSampleRate = this.audioContext ? this.audioContext.sampleRate : 44100;
        const targetSampleRate = 16000;

        // إعادة تشكيل العينات (Linear Resampling) إلى 16000Hz أحادي
        const pcm16k = this._resamplePcm(mergedPcm, inputSampleRate, targetSampleRate);

        // ترميز عينات الـ PCM إلى ملف WAV قياسي 16-bit Mono
        const wavBytes = this._encodeWAV(pcm16k, targetSampleRate);
        const durationMs = Math.round((pcm16k.length / targetSampleRate) * 1000);

        return new AudioData({
          bytes: wavBytes,
          filename: `rec_${Date.now()}.wav`,
          mimeType: 'audio/wav',
          durationMs,
        });
      } catch (pcmErr) {
        console.error('PCM conversion error, checking fallback:', pcmErr);
      }
    }

    // 2. مسار احتياطي في حال عدم التقاط PCM: فحص كتل MediaRecorder
    if (this.audioChunks.length > 0) {
      try {
        const rawBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
        if (rawBlob.size > 0) {
          const wavData = await this._decodeBlobFallback(rawBlob);
          if (wavData && !wavData.isEmpty) {
            return wavData;
          }
        }
      } catch (blobErr) {
        console.warn('Fallback blob decoding also failed:', blobErr);
      }
    }

    return AudioData.empty();
  }

  async _decodeBlobFallback(blob) {
    try {
      const arrayBuffer = await blob.arrayBuffer();
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (!AudioCtx) return AudioData.empty();

      const ctx = this.audioContext && this.audioContext.state !== 'closed'
        ? this.audioContext
        : new AudioCtx();

      if (ctx.state === 'suspended') {
        try { await ctx.resume(); } catch (e) {}
      }

      const bufferClone = arrayBuffer.slice(0);
      let decoded;
      try {
        decoded = await ctx.decodeAudioData(arrayBuffer);
      } catch (e) {
        decoded = await new Promise((res, rej) => {
          ctx.decodeAudioData(bufferClone, res, rej);
        });
      }

      if (!decoded || decoded.length === 0) return AudioData.empty();

      const pcm16k = this._resamplePcm(
        decoded.getChannelData(0),
        decoded.sampleRate,
        16000
      );
      const wavBytes = this._encodeWAV(pcm16k, 16000);

      return new AudioData({
        bytes: wavBytes,
        filename: `rec_${Date.now()}.wav`,
        mimeType: 'audio/wav',
        durationMs: Math.round(decoded.duration * 1000),
      });
    } catch (e) {
      console.warn('Blob fallback decodeAudioData failed safely:', e);
      return AudioData.empty();
    }
  }

  /**
   * إعادة تشكيل العينات (Linear Interpolation Resampling) من أي تردد إلى 16000Hz
   */
  _resamplePcm(samples, sourceSampleRate, targetSampleRate = 16000) {
    if (sourceSampleRate === targetSampleRate) {
      return samples;
    }

    const ratio = sourceSampleRate / targetSampleRate;
    const newLength = Math.max(1, Math.round(samples.length / ratio));
    const result = new Float32Array(newLength);

    for (let i = 0; i < newLength; i++) {
      const srcIndex = i * ratio;
      const indexFloor = Math.floor(srcIndex);
      const indexCeil = Math.min(indexFloor + 1, samples.length - 1);
      const fraction = srcIndex - indexFloor;
      result[i] = (1 - fraction) * samples[indexFloor] + fraction * samples[indexCeil];
    }

    return result;
  }

  _encodeWAV(samples, sampleRate = 16000) {
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
    this.isRecording = false;
    this._cleanupAudioNodes();
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
