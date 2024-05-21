
import 'package:enreda_app/app/home/contact/menu_item.dart';
import 'package:enreda_app/app/home/contact/menu_items.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth.dart';

void onSelected(BuildContext context, MenuItem item) async {
  switch (item) {
    case MenuItems.itemAccount:
      WebHome.controller.selectIndex(2);
      //WebHome.selectedIndex.value = 2;
      break;
    case MenuItems.itemSignOut:
      _confirmSignOut(context);
      break;
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
      CustomTextSmall(text: item.text),
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
      CustomTextSmall(text: item.text),
    ],
  ),
);

Future<void> _confirmSignOut(BuildContext context) async {
  final auth = Provider.of<AuthBase>(context, listen: false);
  final didRequestSignOut = await showAlertDialog(context,
      title: StringConst.SIGN_OUT,
      content: '¿Estás seguro que quieres cerrar sesión?',
      cancelActionText: 'Cancelar',
      defaultActionText: 'Cerrar');
  if (didRequestSignOut == true) {
    await auth.signOut();
    GoRouter.of(context).go(StringConst.PATH_HOME);
  }
}