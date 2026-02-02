import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<void> saveAndShareImpl(String content, String fileName) async {
  final bytes = utf8.encode(content);
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'application/json'));
  final url = web.URL.createObjectURL(blob);
  
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  
  anchor.click();
  web.URL.revokeObjectURL(url);
}
