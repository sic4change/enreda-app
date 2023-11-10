import 'package:enreda_app/utils/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardButtonExpanded extends StatelessWidget {
  final String title;
  final Color color;

  CardButtonExpanded({
    Key? key,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.0),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: color,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constants.white
                      ),
                    ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
