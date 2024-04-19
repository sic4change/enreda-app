import 'package:enreda_app/app/home/models/personalDocument.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/services/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:io';

Future<Uint8List?> pickAndReadFileBytes() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  if (result != null) {
    PlatformFile? pickedFile = result.files.single;
    if (pickedFile != null && pickedFile.path != null) {
      File file = File(pickedFile.path!);
      Uint8List fileBytes;
      try {
        fileBytes = await file.readAsBytes();
        return fileBytes;
      } catch (e) {
        // Handle the error of reading the file
        print('An error occurred while reading the file bytes: $e');
      }
    }
  }
  return null; // In case of cancellation or failure, return null
}


Future uploadDocument (BuildContext context, UserEnreda user, PersonalDocument document) async {
  Uint8List? fileBytes = await pickAndReadFileBytes();
  final database = Provider.of<Database>(context, listen: false);

  if (fileBytes != null) {
    await database.uploadPersonalDocument(
      user,
      fileBytes,
      document.name,
      document,
      user.personalDocuments.indexOf(document),
    );
  } else {
    print('error');
  }

}