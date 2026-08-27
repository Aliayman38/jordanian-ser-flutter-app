import 'dart:typed_data';

Future<Uint8List?> readAudioBytes(String pathOrBlobUrl) =>
    throw UnsupportedError('Platform not supported');

Future<void> deleteAudioFile(String pathOrBlobUrl) =>
    throw UnsupportedError('Platform not supported');

Future<String> getTempAudioPath() =>
    throw UnsupportedError('Platform not supported');
