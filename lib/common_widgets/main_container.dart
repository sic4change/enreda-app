import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({
    Key? key,
    required this.child,
    this.height,
    this.width,
    this.margin,
    this.padding = const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
    this.shadowColor,
  }) : super(key: key);

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double? height, width;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: shadowColor ?? Colors.black.withOpacity(0.15),
              offset: Offset(0, 1), //(x,y)
              blurRadius: 4.0,
              spreadRadius: 1.0),
        ],
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Constants.white,
      ),
      child: child,
      );
  }
}
