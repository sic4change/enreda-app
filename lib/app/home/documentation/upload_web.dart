import 'package:enreda_app/app/home/models/personalDocument.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/services/database.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

Future uploadDocument (BuildContext context, UserEnreda user, PersonalDocument document) async {
  PlatformFile? pickedFile;
  final database = Provider.of<Database>(context, listen: false);
  var result;
  result = await FilePickerWeb.platform.pickFiles();

  if(result == null) return;
  pickedFile = result.files.first;
  Uint8List fileBytes = pickedFile!.bytes!;
  String fileName = pickedFile.name;

  await database.uploadPersonalDocument(
    user,
    fileBytes,
    fileName,
    document,
    user.personalDocuments.indexOf(document),
  );
}
