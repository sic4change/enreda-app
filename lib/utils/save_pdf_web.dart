import 'dart:convert';

import 'package:universal_html/html.dart';

Future<void> savePDF(List<int> bytes, String fileName) async {
  AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
    ..setAttribute('download', 'myCV.pdf')
    ..click();
}