import 'package:enreda_app/utils/functions.dart';
import 'package:flutter/material.dart';
import '../../../values/values.dart';
import '../values/strings.dart';


Widget buildStoresButtons(double buttonWidth, double buttonHeight) {
  return Wrap(
    children: [
      InkWell(
        onTap: () => openUrlLink(StringConst.URL_APPSTORE),
        child: Image.asset(
          ImagePath.APP_STORE_BUTTON,
          width: buttonWidth,
          height: buttonHeight,
          fit: BoxFit.fill,
        ),
      ),
      InkWell(
        onTap: () => openUrlLink(StringConst.URL_GOOGLE_PLAY),
        child: Image.asset(
          ImagePath.PLAY_STORE_BUTTON,
          width: buttonWidth,
          height: buttonHeight,
          fit: BoxFit.fill,
        ),
      ),
    ],
  );
}