import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

showToast(
  BuildContext context, {
  required String title,
  required Color color,
}) {
  ToastContext().init(context);
  Toast.show(title,
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
      backgroundColor: color);
}
