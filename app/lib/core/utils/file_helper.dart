import 'file_helper_stub.dart'
    if (dart.library.js_interop) 'file_helper_web.dart'
    if (dart.library.io) 'file_helper_native.dart';

abstract class FileHelper {
  static Future<void> saveAndShare(String content, String fileName) =>
      saveAndShareImpl(content, fileName);
}
