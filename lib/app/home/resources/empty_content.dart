import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    Key? key,
    this.title = 'Nada por ahora',
    this.message = 'Sin elementos que mostrar aún'
  }) : super(key: key);
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    double fontSize = Responsive.isMobile(context) ? 16 : 18;
    return Padding(
      padding: EdgeInsets.only(left: Constants.mainPadding, right: Constants.mainPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Constants.textDark
              ),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.normal,
                color: Constants.salmonLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
