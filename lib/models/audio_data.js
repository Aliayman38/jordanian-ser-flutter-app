export class AudioData {
  constructor({ bytes, filename, mimeType = 'audio/wav', durationMs = 0 }) {
    this.bytes = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
    this.filename = filename;
    this.mimeType = mimeType;
    this.durationMs = durationMs;
  }

  get isEmpty() {
    return this.bytes.length === 0;
  }

  get sizeInBytes() {
    return this.bytes.length;
  }
}
