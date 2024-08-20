import 'package:flutter/material.dart';
import '../../../../values/values.dart';

Widget UserProfilePicture(BuildContext context, String profilePic) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(60)),
            child:
            profilePic == "" ?
            Container(
              color:  Colors.transparent,
              height: 25,
              width: 25,
              child: Image.asset(ImagePath.USER_DEFAULT),
            ) :
            Image.network(
              profilePic,
              width: 25,
              height: 25,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    ],
  );
}