import 'package:flutter/material.dart';
import '../../../values/values.dart';

class CustomPaddingTitle extends StatelessWidget {

  CustomPaddingTitle({ required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: Borders.kDefaultPaddingDouble, bottom: Borders.kDefaultPaddingDouble),
        child: child
    );
  }
}