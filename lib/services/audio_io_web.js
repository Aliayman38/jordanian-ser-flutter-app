export async function readAudioBytes(pathOrBlobUrl) {
  try {
    if (pathOrBlobUrl.startsWith('blob:') || pathOrBlobUrl.startsWith('http')) {
      const response = await fetch(pathOrBlobUrl);
      if (response.status === 200) {
        const arrayBuffer = await response.arrayBuffer();
        return new Uint8Array(arrayBuffer);
      }
    }
  } catch (_) {}
  return null;
}

export async function deleteAudioFile(pathOrBlobUrl) {
  if (pathOrBlobUrl.startsWith('blob:')) {
    URL.revokeObjectURL(pathOrBlobUrl);
  }
}

export async function getTempAudioPath() {
  return '';
}
