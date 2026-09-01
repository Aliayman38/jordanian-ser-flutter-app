import { AudioData } from '../models/audio_data';
import * as audio_io from './audio_io';

export class RecordingPermissionException extends Error {
  constructor(message) {
    super(message);
    this.name = 'RecordingPermissionException';
    this.message = message;
  }

  toString() {
    return this.message;
  }
}

function writeString(view, offset, string) {
  for (let i = 0; i < string.length; i++) {
    view.setUint8(offset + i, string.charCodeAt(i));
  }
}

function floatTo16BitPCM(output, offset, input) {
  for (let i = 0; i < input.length; i++, offset += 2) {
    const s = Math.max(-1, Math.min(1, input[i]));
    output.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7fff, true);
  }
}

function encodeWAV(samples, sampleRate = 16000, numChannels = 1) {
  const buffer = new ArrayBuffer(44 + samples.length * 2);
  const view = new DataView(buffer);

  writeString(view, 0, 'RIFF');
  view.setUint32(4, 36 + samples.length * 2, true);
  writeString(view, 8, 'WAVE');
  writeString(view, 12, 'fmt ');
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, numChannels, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * numChannels * 2, true);
  view.setUint16(32, numChannels * 2, true);
  view.setUint16(34, 16, true);
  writeString(view, 36, 'data');
  view.setUint32(40, samples.length * 2, true);

  floatTo16BitPCM(view, 44, samples);

  return new Uint8Array(buffer);
}

export class AudioService {
  constructor() {
    this._isRecording = false;
    this._mediaStream = null;
    this._audioContext = null;
    this._processor = null;
    this._sourceNode = null;
    this._audioChunks = [];
    this._currentBlobUrl = null;
  }

  get isRecording() {
    return this._isRecording;
  }

  async hasPermission() {
    try {
      if (navigator?.permissions?.query) {
        const result = await navigator.permissions.query({ name: 'microphone' });
        if (result.state === 'granted') return true;
        if (result.state === 'denied') return false;
      }
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      stream.getTracks().forEach((track) => track.stop());
      return true;
    } catch (_) {
      return false;
    }
  }

  async startRecording() {
    const granted = await this.hasPermission();
    if (!granted) {
      throw new RecordingPermissionException(
        'صلاحية الميكروفون مرفوضة. يرجى السماح بالوصول للميكروفون من إعدادات المتصفح أو الجهاز.'
      );
    }

    const path = await audio_io.getTempAudioPath();

    this._mediaStream = await navigator.mediaDevices.getUserMedia({
      audio: {
        channelCount: 1,
        sampleRate: 16000,
        echoCancellation: true,
        noiseSuppression: true,
      },
    });

    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    this._audioContext = new AudioContextClass({ sampleRate: 16000 });
    this._sourceNode = this._audioContext.createMediaStreamSource(this._mediaStream);
    this._processor = this._audioContext.createScriptProcessor(4096, 1, 1);

    this._audioChunks = [];

    this._processor.onaudioprocess = (e) => {
      if (!this._isRecording) return;
      const channelData = e.inputBuffer.getChannelData(0);
      this._audioChunks.push(new Float32Array(channelData));
    };

    this._sourceNode.connect(this._processor);
    this._processor.connect(this._audioContext.destination);

    this._isRecording = true;
    return path;
  }

  async stopRecording() {
    if (!this._isRecording && !this._mediaStream) return null;

    this._isRecording = false;

    if (this._processor && this._sourceNode) {
      this._processor.disconnect();
      this._sourceNode.disconnect();
    }

    if (this._mediaStream) {
      this._mediaStream.getTracks().forEach((track) => track.stop());
      this._mediaStream = null;
    }

    if (this._audioContext && this._audioContext.state !== 'closed') {
      await this._audioContext.close();
      this._audioContext = null;
    }

    let totalLength = 0;
    for (const chunk of this._audioChunks) {
      totalLength += chunk.length;
    }

    if (totalLength === 0) return null;

    const mergedSamples = new Float32Array(totalLength);
    let offset = 0;
    for (const chunk of this._audioChunks) {
      mergedSamples.set(chunk, offset);
      offset += chunk.length;
    }

    const wavBytes = encodeWAV(mergedSamples, 16000, 1);
    const blob = new Blob([wavBytes], { type: 'audio/wav' });
    this._currentBlobUrl = URL.createObjectURL(blob);

    const bytes = await audio_io.readAudioBytes(this._currentBlobUrl);
    if (!bytes || bytes.length === 0) return null;

    const filename = `ser_${Date.now()}.wav`;
    return new AudioData({
      bytes,
      filename,
      mimeType: 'audio/wav',
    });
  }

  async discardAudio(pathOrUrl) {
    if (pathOrUrl) {
      await audio_io.deleteAudioFile(pathOrUrl);
    }
  }

  async cancelRecording() {
    if (this._isRecording) {
      this._isRecording = false;

      if (this._processor && this._sourceNode) {
        this._processor.disconnect();
        this._sourceNode.disconnect();
      }

      if (this._mediaStream) {
        this._mediaStream.getTracks().forEach((track) => track.stop());
        this._mediaStream = null;
      }

      if (this._audioContext && this._audioContext.state !== 'closed') {
        await this._audioContext.close();
        this._audioContext = null;
      }

      this._audioChunks = [];
    }
  }

  dispose() {
    this.cancelRecording();
    if (this._currentBlobUrl) {
      URL.revokeObjectURL(this._currentBlobUrl);
      this._currentBlobUrl = null;
    }
  }
}
