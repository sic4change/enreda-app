import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget showBackIconButton(BuildContext context, Color color) {
  try {
    if (kIsWeb) {
      return IconButton(
          icon: Icon(Icons.arrow_back, color: color,),
          onPressed: () {
            Navigator.of(context).pop();
          });
    }
    if (Platform.isIOS) {
      return IconButton(
          icon: Icon(CupertinoIcons.back, color: color,),
          onPressed: () {
            Navigator.of(context).pop();
          });
    }
    if (Platform.isAndroid) {
      return IconButton(
          icon: Icon(Icons.arrow_back, color: color,),
          onPressed: () {
            Navigator.of(context).pop();
          });
    }
  } catch (e) {
    return IconButton(
        icon: Icon(Icons.arrow_back, color: color,),
        onPressed: () {
          Navigator.of(context).pop();
        });
  }
  return CircularProgressIndicator();
}