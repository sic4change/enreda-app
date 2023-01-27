import 'package:enreda_app/utils/const.dart';
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
    return Padding(
      padding: EdgeInsets.only(left: Constants.mainPadding, right: Constants.mainPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Constants.textDark
              ),
            ),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
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
