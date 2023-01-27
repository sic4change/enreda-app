import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

class CompetencyDescription extends StatelessWidget {
  const CompetencyDescription(
      {Key? key, required this.competency, required this.status})
      : super(key: key);

  final Competency competency;
  final String status;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: Text(
            competency.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Constants.darkGray),
          ),
        ),
        if (competency.badgesImages[StringConst.BADGE_EMPTY] != null)
          Image.network(
            competency.badgesImages[status]!,
            height: 260.0,
            width: 260.0,
            filterQuality: FilterQuality.high,
          ),
        Text(competency.description, textAlign: TextAlign.center, style: textTheme.bodyText1,),
      ],
    );
  }
}
