import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'package:universal_html/html.dart' as html;

class PDFApi {

  static Future<File?> loadFirebase(String url) async {
    try {
      final refPDF = FirebaseStorage.instance.ref().child(url);
      if (kIsWeb){
        final downloadUrl = await refPDF.getDownloadURL();
        html.AnchorElement anchorElement =  new html.AnchorElement(href: downloadUrl);
        anchorElement.download = downloadUrl;
        anchorElement.click();
      } else {
        final bytes = await refPDF.getData(0x3FFFFFFF);
        return _storeFile(url, bytes);
      }
    } catch (e) {
      print('Aqui error $e');
      return null;
    }
  }

  static Future<File> _storeFile(String url, Uint8List? bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    if (bytes != null)
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}