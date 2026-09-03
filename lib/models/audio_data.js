export class AudioData {
  constructor({ bytes, filename = '', mimeType = 'audio/wav', durationMs = 0 } = {}) {
    this.bytes = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes || 0);
    this.filename = filename || 'audio.wav';
    this.mimeType = mimeType;
    this.durationMs = durationMs;
  }

  static empty() {
    return new AudioData({
      bytes: new Uint8Array(0),
      filename: '',
      mimeType: 'audio/wav',
      durationMs: 0,
    });
  }

  get isEmpty() {
    return !this.bytes || this.bytes.length === 0;
  }

  get sizeInBytes() {
    return this.bytes ? this.bytes.length : 0;
  }
}

export default AudioData;

