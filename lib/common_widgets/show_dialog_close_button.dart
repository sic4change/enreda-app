import 'dart:io';

import 'package:enreda_app/common_widgets/close_dialog_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> showDialogCloseButton(
  BuildContext context, {
  required Widget content,
  String? cancelActionText,
  String? defaultActionText,
  void Function(BuildContext context)? onDefaultActionPressed,
}) {
  try {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  CloseDialogButton(
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
              content,
            ],
          ),
          actions: <Widget>[
            // ignore: deprecated_member_use
            if (cancelActionText != null)
              CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop((false)),
                  child: Text(cancelActionText)),
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
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                CloseDialogButton(
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
            content,
          ],
        ),
        actions: <Widget>[
          if (cancelActionText != null)
            // ignore: deprecated_member_use
            TextButton(
                onPressed: () => Navigator.of(context).pop((false)),
                child: Text(cancelActionText)),
          // ignore: deprecated_member_use
          if (defaultActionText != null && onDefaultActionPressed != null)
            TextButton(
                onPressed: () => onDefaultActionPressed(context),
                child: Text(defaultActionText)),
        ],
      ),
    );
  } catch (e) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                CloseDialogButton(
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
            content,
          ],
        ),
        actions: <Widget>[
          if (cancelActionText != null)
            // ignore: deprecated_member_use
            TextButton(
                onPressed: () => Navigator.of(context).pop((false)),
                child: Text(cancelActionText)),
          // ignore: deprecated_member_use
          if (defaultActionText != null && onDefaultActionPressed != null)
            TextButton(
                onPressed: () => onDefaultActionPressed(context),
                child: Text(defaultActionText)),
        ],
      ),
    );
  }
}
