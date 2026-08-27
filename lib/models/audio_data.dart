import 'dart:typed_data';

/// Encapsulates recorded speech audio data in a cross-platform manner
/// (compatible with both Web Uint8List blobs and Native storage).
class AudioData {
  final Uint8List bytes;
  final String filename;
  final String mimeType;
  final int durationMs;

  const AudioData({
    required this.bytes,
    required this.filename,
    this.mimeType = 'audio/wav',
    this.durationMs = 0,
  });

  bool get isEmpty => bytes.isEmpty;
  int get sizeInBytes => bytes.length;
}
