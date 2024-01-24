import 'package:enreda_app/utils/const.dart';
import 'package:flutter/material.dart';

TextStyle chatRoomQuestionStyle() {
  return TextStyle(
    color: Constants.chatDarkGray,
    fontSize: 14,
    fontFamily: 'OverpassRegular',
    fontWeight: FontWeight.w600,
  );
}

TextStyle chatRoomResponseStyle() {
  return TextStyle(
    color: Constants.white,
    fontSize: 14,
    fontFamily: 'OverpassRegular',
  );
}