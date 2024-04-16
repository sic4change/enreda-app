
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

Future downloadDocument (String urlDocument, String documentName) async {
  final ref = FirebaseStorage.instance.refFromURL(urlDocument);
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/${ref.name}');
  await ref.writeToFile(file);
}