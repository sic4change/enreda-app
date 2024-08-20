import 'package:flutter/cupertino.dart';

import '../../../../values/strings.dart';
import '../../../../values/values.dart';
import 'menu_item.dart';

class MenuItems {
  static List<MenuItem> getItemOpen(BuildContext context) {
    return [openDocument(context)];
  }

  static List<MenuItem> getItemDownload(BuildContext context) {
    return [downloadDocument(context),];
  }

  static List<MenuItem> getItemEdit(BuildContext context) {
    return [editDocument(context),];
  }

  static List<MenuItem> getItemDelete(BuildContext context) {
    return [deleteDocument(context)];
  }


  static openDocument(BuildContext context) {
    return MenuItem(
      text: StringConst.OPEN,
      imagePath: ImagePath.ICON_EYE,
    );
  }

  static downloadDocument(BuildContext context) {
    return MenuItem(
      text: StringConst.DOWNLOAD_PDF,
      imagePath: ImagePath.ICON_CLOUD,
    );
  }

  static editDocument(BuildContext context) {
    return MenuItem(
      text: StringConst.EDIT,
      imagePath: ImagePath.ICON_EDIT,
    );
  }

  static deleteDocument(BuildContext context) {
    return MenuItem(
      text: StringConst.DELETE,
      imagePath: ImagePath.ICON_TRASH,
    );
  }
}