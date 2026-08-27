import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List?> readAudioBytes(String pathOrBlobUrl) async {
  try {
    if (pathOrBlobUrl.startsWith('blob:') || pathOrBlobUrl.startsWith('http')) {
      final response = await http.get(Uri.parse(pathOrBlobUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    }
  } catch (_) {}
  return null;
}

Future<void> deleteAudioFile(String pathOrBlobUrl) async {
  // Browser memory blobs are automatically garbage collected.
}

Future<String> getTempAudioPath() async {
  // On Flutter web, record package creates a blob URL and does not require a local file path.
  return '';
}
