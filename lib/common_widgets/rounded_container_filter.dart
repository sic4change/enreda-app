import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class RoundedContainerFilter extends StatelessWidget {
  const RoundedContainerFilter(
      {Key? key,
      required this.child,
      this.height,
      this.margin,
      this.padding =
          const EdgeInsets.only(left: 20.0, top: 0.0, right: 8.0, bottom: 0.0)})
      : super(key: key);
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
          color: AppColors.primary030,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
