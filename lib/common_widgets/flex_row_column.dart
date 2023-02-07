import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';
import '../../../values/values.dart';

class CustomFlexRowColumn extends StatelessWidget {

  CustomFlexRowColumn({ required this.childLeft, required this.childRight  });
  final Widget childLeft;
  final Widget childRight;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Responsive.isMobile(context) || Responsive.isTablet(context) ? Axis.vertical : Axis.horizontal,
      children: [
        Expanded(
          flex: Responsive.isMobile(context) || Responsive.isTablet(context) ? 0 : 1,
          child: Padding(
              padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
              child: childLeft
          ),
        ),
        Expanded(
          flex: Responsive.isMobile(context) || Responsive.isTablet(context) ? 0 : 1,
          child: Padding(
              padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
              child: childRight
          ),
        ),
      ],
    );
  }
}