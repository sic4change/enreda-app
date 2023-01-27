import 'package:flutter/material.dart';

import '../../values/values.dart';

class EnredaVerticalDivider extends StatelessWidget {
  const EnredaVerticalDivider({
    this.thickness = 0.8,
    this.width,
    this.color = AppColors.black,
  });

  final double? width;
  final double thickness;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(thickness: thickness);
  }
}

