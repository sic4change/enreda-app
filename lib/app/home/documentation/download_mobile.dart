import 'dart:io';
import 'package:dio/dio.dart';

Future<void> downloadDocument(String url, String filename) async {
  Dio dio = Dio();
  try {
    Directory publicDownloadDir = Directory("/storage/emulated/0/Download");
    String savePath = "${publicDownloadDir.path}/$filename";

    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print((received / total * 100).toStringAsFixed(0) + "%");
        }
      },
    );

    print("File is saved to $savePath");
  } catch (e) {
    print("Error: $e");
  }
}