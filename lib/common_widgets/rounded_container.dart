import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  const RoundedContainer({
    super.key,
    this.child,
    this.contentPadding = const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
    this.margin = const EdgeInsets.only(left: Sizes.kDefaultPaddingDouble, right: Sizes.kDefaultPaddingDouble, bottom: Sizes.kDefaultPaddingDouble),
    this.width,
    this.height,
    this.borderColor = AppColors.primary020,
    this.color = AppColors.altWhite,
    this.borderWith = 1.0,
    this.radius = Sizes.kDefaultPaddingDouble,
  });

  final Widget? child;
  final EdgeInsets? contentPadding, margin;
  final double? width, height, borderWith;
  final Color borderColor;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: contentPadding,
        margin: margin,
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Responsive.isMobile(context) ? Colors.transparent : color,
          borderRadius: Responsive.isMobile(context) ? BorderRadius.zero : BorderRadius.circular(radius),
          border: Responsive.isMobile(context) ? null : Border.all(color: borderColor, width: borderWith!,),
        ),
        child: child);
  }
}
