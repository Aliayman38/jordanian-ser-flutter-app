import { AudioData } from '../models/audio_data.js';

export class AudioService {
  constructor() {
    this.mediaRecorder = null;
    this.audioChunks = [];
    this.stream = null;
    this.isRecording = false;
  }

  async startRecording() {
    try {
      this.audioChunks = [];
      this.stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          channelCount: 1,
          sampleRate: 16000,
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      });

      this.mediaRecorder = new MediaRecorder(this.stream);

      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data && event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      };

      this.mediaRecorder.start(100);
      this.isRecording = true;
    } catch (err) {
      this.isRecording = false;
      throw new Error('يرجى السماح بالوصول إلى الميكروفون من إعدادات المتصفح.');
    }
  }

  async stopRecording() {
    if (!this.stream && this.audioChunks.length === 0) {
      return AudioData.empty();
    }

    return new Promise((resolve, reject) => {
      if (this.mediaRecorder && this.mediaRecorder.state !== 'inactive') {
        this.mediaRecorder.onstop = async () => {
          try {
            const rawBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
            const wavData = await this._convertToWav16kMono(rawBlob);

            if (this.stream) {
              this.stream.getTracks().forEach((track) => track.stop());
              this.stream = null;
            }
            this.isRecording = false;
            resolve(wavData);
          } catch (e) {
            this.isRecording = false;
            reject(e);
          }
        };

        this.mediaRecorder.stop();
      } else {
        this.isRecording = false;
        resolve(AudioData.empty());
      }
    });
  }

  async _convertToWav16kMono(blob) {
    const arrayBuffer = await blob.arrayBuffer();
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    const ctx = new AudioCtx();

    // مهم لنظام iOS Safari لفك تعليق الصوت
    if (ctx.state === 'suspended') {
      await ctx.resume();
    }

    const decodedAudio = await ctx.decodeAudioData(arrayBuffer);

    const targetSampleRate = 16000;
    const duration = decodedAudio.duration;
    const offlineCtx = new OfflineAudioContext(1, Math.ceil(targetSampleRate * duration), targetSampleRate);

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

    // RIFF identifier
    writeString(0, 'RIFF');
    view.setUint32(4, 36 + samples.length * 2, true);
    writeString(8, 'WAVE');

    // fmt sub-chunk
    writeString(12, 'fmt ');
    view.setUint32(16, 16, true); // Subchunk1Size (16 for PCM)
    view.setUint16(20, 1, true);  // AudioFormat (1 for PCM)
    view.setUint16(22, 1, true);  // NumChannels (1 = Mono)
    view.setUint32(24, sampleRate, true); // SampleRate (16000)
    view.setUint32(28, sampleRate * 2, true); // ByteRate (16000 * 1 * 2)
    view.setUint16(32, 2, true);  // BlockAlign (1 * 16/8)
    view.setUint16(34, 16, true); // BitsPerSample (16 bits)

    // data sub-chunk
    writeString(36, 'data');
    view.setUint32(40, samples.length * 2, true);

    // PCM 16-bit signed integer
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