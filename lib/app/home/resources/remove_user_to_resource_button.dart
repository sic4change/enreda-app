import 'package:enreda_app/common_widgets/custom_raised_button.dart';
import 'package:flutter/material.dart';

class RemoveUserToResourceButton extends CustomRaisedButton {
  RemoveUserToResourceButton({
    VoidCallback? onPressed,
  }) : super(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.fact_check, color: Colors.black,),
              Expanded(
                child: Center(
                  child: Text(
                    'NO ME INTERESA PARTICIPAR',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                ),
              ),
              Opacity(
                opacity: 0.0,
                child: Icon(Icons.fact_check, color: Colors.black,),
              ),
            ],
          ),
          color: Colors.white,
          borderColor: Colors.black,
          onPressed: onPressed,
        );
}
