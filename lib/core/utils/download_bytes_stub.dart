import 'dart:typed_data';

Future<void> downloadBytes(Uint8List bytes, {required String filename, required String mimeType}) async {
  // Non-web platforms: intentionally no-op (implement via share_plus/path_provider later if needed).
}

