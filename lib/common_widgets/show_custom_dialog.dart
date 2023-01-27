import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> showCustomDialog(
  BuildContext context, {
  required Widget content,
  bool dismissible = true,
  String? cancelActionText,
  String? defaultActionText,
  void Function(BuildContext context)? onDefaultActionPressed,
}) {
  final textTheme = Theme.of(context).textTheme;

  try {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        barrierDismissible: dismissible,
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: content,
          actions: <Widget>[
            // ignore: deprecated_member_use
            if (cancelActionText != null)
              CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop((false)),
                  child: Text(cancelActionText, style: textTheme.bodyText1,)),
            // ignore: deprecated_member_use
            if (defaultActionText != null && onDefaultActionPressed != null)
            CupertinoDialogAction(
                onPressed: () => onDefaultActionPressed(context),
                child: Text(defaultActionText)),

          ],
        ),
      );
    }
    return showDialog(
      barrierDismissible: dismissible,
      context: context,
      builder: (context) => AlertDialog(
        content: content,
        actions: <Widget>[
          if (cancelActionText != null)
          // ignore: deprecated_member_use
            TextButton(
                onPressed: () => Navigator.of(context).pop((false)),
                child: Text(cancelActionText, style: textTheme.bodyText1,)),
          // ignore: deprecated_member_use
          if (defaultActionText != null && onDefaultActionPressed != null)
          TextButton(
              onPressed: () => onDefaultActionPressed(context),
              child: Text(defaultActionText)
          ),
        ],
      ),
    );
  } catch(e) {
    return showDialog(
      barrierDismissible: dismissible,
      context: context,
      builder: (context) => AlertDialog(
        content: content,
        actions: <Widget>[
          if (cancelActionText != null)
          // ignore: deprecated_member_use
            TextButton(
                onPressed: () => Navigator.of(context).pop((false)),
                child: Text(cancelActionText, style: textTheme.bodyText1,)),
          // ignore: deprecated_member_use
          if (defaultActionText != null && onDefaultActionPressed != null)
          TextButton(
              onPressed: () => onDefaultActionPressed(context),
              child: Text(defaultActionText)
          ),
        ],
      ),
    );
  }


}
