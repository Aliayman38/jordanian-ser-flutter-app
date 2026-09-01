import * as FileSystem from 'expo-file-system';

export async function readAudioBytes(pathOrBlobUrl) {
  try {
    const fileInfo = await FileSystem.getInfoAsync(pathOrBlobUrl);
    if (fileInfo.exists) {
      const base64 = await FileSystem.readAsStringAsync(pathOrBlobUrl, {
        encoding: FileSystem.EncodingType.Base64,
      });
      const binaryString = atob(base64);
      const len = binaryString.length;
      const bytes = new Uint8Array(len);
      for (let i = 0; i < len; i++) {
        bytes[i] = binaryString.charCodeAt(i);
      }
      return bytes;
    }
  } catch (_) {}
  return null;
}

export async function deleteAudioFile(pathOrBlobUrl) {
  try {
    const fileInfo = await FileSystem.getInfoAsync(pathOrBlobUrl);
    if (fileInfo.exists) {
      await FileSystem.deleteAsync(pathOrBlobUrl, { idempotent: true });
    }
  } catch (_) {}
}

export async function getTempAudioPath() {
  const dir = FileSystem.cacheDirectory;
  return `${dir}ser_${Date.now()}.wav`;
}
