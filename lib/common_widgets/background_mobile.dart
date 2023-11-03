import 'package:enreda_app/utils/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BackgroundMobile extends StatelessWidget {

  BackgroundMobile({
    Key? key, required this.backgroundHeight,
  }) : super(key: key);

  final BackgroundHeight backgroundHeight;

  @override
  Widget build(BuildContext context) {
    final height = backgroundHeight == BackgroundHeight.Small? 100.0:  backgroundHeight == BackgroundHeight.Large? 140.0: 200.0;
    return Column(
      children: <Widget>[
        Container(
            color: Constants.white,
            height: height,
          ),
        Expanded(
          child: Container(color: Constants.white,),
        )
      ],
    );
  }
}

class BackgroundMobileAccount extends StatelessWidget {

  BackgroundMobileAccount({
    Key? key, required this.backgroundHeight,
  }) : super(key: key);

  final BackgroundHeight backgroundHeight;

  @override
  Widget build(BuildContext context) {
    final height = backgroundHeight == BackgroundHeight.Small? 100.0:  backgroundHeight == BackgroundHeight.Large? 140.0: 200.0;
    return Column(
      children: <Widget>[
        Container(
          color: Constants.white,
          height: height,
        ),
        Expanded(
          child: Container(color: Constants.white,),
        )
      ],
    );
  }
}