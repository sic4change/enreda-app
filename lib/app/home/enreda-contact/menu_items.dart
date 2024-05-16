import 'package:enreda_app/app/home/enreda-contact/menu_item.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';

class MenuItems {

  static const List<MenuItem> itemsOne = [
    itemAccount,
  ];

  static const List<MenuItem> itemsTwo = [
    itemSignOut,
  ];

  static const itemAccount = MenuItem(
    text: StringConst.MY_ACCOUNT,
    imagePath: ImagePath.USER_DEFAULT,
  );

  static const itemSignOut = MenuItem(
    text: StringConst.SIGN_OUT,
    imagePath: ImagePath.ARROW_BACK,
  );

}