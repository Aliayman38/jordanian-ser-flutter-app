import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<Uint8List?> readAudioBytes(String pathOrBlobUrl) async {
  try {
    final file = File(pathOrBlobUrl);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
  } catch (_) {}
  return null;
}

Future<void> deleteAudioFile(String pathOrBlobUrl) async {
  try {
    final file = File(pathOrBlobUrl);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {}
}

Future<String> getTempAudioPath() async {
  final dir = await getTemporaryDirectory();
  return '${dir.path}/ser_${DateTime.now().millisecondsSinceEpoch}.wav';
}
