import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class CustomFlexRowColumn extends StatelessWidget {

  const CustomFlexRowColumn({
    super.key,
    required this.childLeft,
    required this.childRight,
    this.contentPadding = const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
    this.separatorSize = 0.0,
  });
  final Widget childLeft;
  final Widget childRight;
  final EdgeInsets contentPadding;
  final double separatorSize;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Responsive.isMobile(context) || Responsive.isTablet(context) ? Axis.vertical : Axis.horizontal,
      children: [
        Expanded(
          flex: Responsive.isMobile(context) || Responsive.isTablet(context) ? 0 : 1,
          child: Padding(
              padding: contentPadding,
              child: childLeft
          ),
        ),
        if (Responsive.isMobile(context) || Responsive.isTablet(context))
          SizedBox(height: separatorSize,),
        if (!Responsive.isMobile(context) && !Responsive.isTablet(context))
          SizedBox(width: separatorSize,),
        Expanded(
          flex: Responsive.isMobile(context) || Responsive.isTablet(context) ? 0 : 1,
          child: Padding(
              padding: contentPadding,
              child: childRight
          ),
        ),
      ],
    );
  }
}