import 'package:flutter/material.dart';
import '../../../values/values.dart';

class CustomPadding extends StatelessWidget {

  CustomPadding({ required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
        child: child
    );
  }
}