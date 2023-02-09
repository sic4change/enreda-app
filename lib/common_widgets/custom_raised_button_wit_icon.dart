import 'package:flutter/material.dart';

class CustomRaisedButtonWithIcon extends StatelessWidget {

  CustomRaisedButtonWithIcon({
    required this.label,
    required this.icon,
    this.textColor,
    this.splashColor,
    this.color,
    this.onPressed,
  });

  final Color? color;
  final Color? textColor;
  final Color? splashColor;
  final Icon icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label,
      style: TextStyle(color: Colors.white),),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        disabledBackgroundColor: color,
        shadowColor: Colors.greenAccent,
        elevation: 3,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))),
      ));
  }
}
