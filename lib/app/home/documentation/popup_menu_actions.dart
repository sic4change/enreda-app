import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/custom_text.dart';
import '../../../../services/database.dart';
import '../../../../utils/functions.dart';
import '../../../../values/strings.dart';
import '../../../../values/values.dart';
import '../../../common_widgets/show_alert_dialog.dart';
import '../models/documentationParticipant.dart';
import '../models/personalDocumentType.dart';
import '../models/userEnreda.dart';
import 'edit_documents_form.dart';
import 'menu_item.dart';
import 'menu_items.dart';
import 'package:enreda_app/app/home/documentation/download_mobile.dart'
 if (dart.library.html) 'package:enreda_app/app/home/documentation/download_web.dart' as my_controls;

void onSelected(
    BuildContext context,
    MenuItem item,
    PersonalDocumentType documentSubCategory,
    UserEnreda participantUser,
    DocumentationParticipant documentParticipant) async {
  if (item.text == MenuItems.openDocument(context).text) {
    openFile(documentParticipant);
  } else if (item.text == MenuItems.downloadDocument(context).text) {
    my_controls.downloadDocument(documentParticipant.urlDocument!, documentParticipant.nameDocument!);
  } else if (item.text == MenuItems.editDocument(context).text) {
    showDialog(
        context: context,
        builder: (context){
          return EditDocumentsForm(
            documentationParticipant: documentParticipant,
            participantUser: participantUser,);
        }
    );
  } else if (item.text == MenuItems.deleteDocument(context).text) {
    _confirmDeleteDocumentationParticipant(context, documentParticipant);
  }
}

PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
  value: item,
  child: Row(
    children: [
      SizedBox(
          width: 20,
          height: 20,
          child: Image.asset(item.imagePath)),
      const SizedBox(width: 12),
      CustomTextSmall(text: item.text, color: AppColors.primary900,),
    ],
  ),
);

PopupMenuItem<MenuItem> buildItemTitle(MenuItem item) => PopupMenuItem<MenuItem>(
  value: item,
  child: Row(
    children: [
      SizedBox(
          width: 20,
          height: 20,
          child: Image.asset(item.imagePath)),
      const SizedBox(width: 12),
      CustomTextSmall(text: item.text, color: AppColors.primary900,),
    ],
  ),
);

PopupMenuItem<MenuItem> buildItemRed(MenuItem item) => PopupMenuItem<MenuItem>(
  value: item,
  child: Row(
    children: [
      SizedBox(
          width: 20,
          height: 20,
          child: Image.asset(item.imagePath)),
      const SizedBox(width: 12),
      CustomTextSmall(text: item.text, color: AppColors.red050,),
    ],
  ),
);

Future<void> _deleteResource(BuildContext context, DocumentationParticipant document) async {
  try {
    final database = Provider.of<Database>(context, listen: false);
    await database.deleteDocumentationParticipant(document);
  } catch (e) {
    print(e.toString());
  }
}

Future<void> _confirmDeleteDocumentationParticipant(BuildContext context, DocumentationParticipant document) async {
  final didRequestSignOut = await showAlertDialog(context,
      title: 'Eliminar documento: ${document.name} ',
      content: StringConst.DELETE_DOCUMENT,
      cancelActionText: 'Cancelar',
      defaultActionText: 'Aceptar');
  if (didRequestSignOut == true) {
    _deleteResource(context, document);
  }
}