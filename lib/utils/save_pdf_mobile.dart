import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> savePDF(List<int> bytes, String fileName) async {

  final directory = Platform.isIOS
      ? await getApplicationSupportDirectory()
      : await getExternalStorageDirectory();
  final path = directory?.path;
  final file = File('$path/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$path/$fileName');
}