import 'package:enreda_app/utils/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BackgroundWeb extends StatelessWidget {

  BackgroundWeb({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            color: Constants.turquoise,
            height: 260,
          ),
        Expanded(
          child: Container(color: Constants.white,),
        )
      ],
    );
  }
}