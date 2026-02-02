import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndShareImpl(String content, String fileName) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(content);

  final xFile = XFile(file.path, mimeType: 'application/json');
  // ignore: deprecated_member_use
  await Share.shareXFiles([xFile], text: 'Long Distance Diary Backup Data');
}
