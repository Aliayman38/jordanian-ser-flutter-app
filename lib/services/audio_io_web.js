export class AudioIOWeb {
  async readAsBytes(blobOrFile) {
    if (blobOrFile instanceof Uint8Array) {
      return blobOrFile;
    }
    const arrayBuffer = await blobOrFile.arrayBuffer();
    return new Uint8Array(arrayBuffer);
  }

  createBlob(bytes, mimeType = 'audio/wav') {
    return new Blob([bytes], { type: mimeType });
  }

  createObjectUrl(blobOrBytes, mimeType = 'audio/wav') {
    const blob = blobOrBytes instanceof Blob ? blobOrBytes : this.createBlob(blobOrBytes, mimeType);
    return URL.createObjectURL(blob);
  }

  revokeObjectUrl(url) {
    if (url) {
      URL.revokeObjectURL(url);
    }
  }
}

export default AudioIOWeb;