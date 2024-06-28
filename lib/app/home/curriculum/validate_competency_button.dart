import 'dart:collection';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ValidateCompetencyButton extends StatelessWidget {
  const ValidateCompetencyButton({
    Key? key,
    required this.competency,
    required this.database,
    required this.auth,
    required this.onComingBack,
  }) : super(key: key);

  final Competency competency;
  final Database database;
  final AuthBase auth;
  final VoidCallback onComingBack;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = 12;
    return TextButton(
      onPressed: () {
        Map<String, int> ratings = {};
        Map<String, bool> questionsMap = {competency.trickQuestion!: false};
        competency.testQuestions.forEach((element) {
          questionsMap[element] = true;
        });
        List<String> shuffledKeys = questionsMap.keys.toList()..shuffle();
        LinkedHashMap<String, bool> shuffledQuestionsMap =
        new LinkedHashMap.fromIterable(shuffledKeys,
            key: (k) => k, value: (k) => questionsMap[k]!);

        showCustomDialog(
          context,
          content: SingleChildScrollView(
            child: Column(
              children: [
                SpaceH20(),
                Text(StringConst.EVALUATE_COMPETENCY + "${competency.name}",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Constants.chatDarkGray),),
                SpaceH20(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: shuffledQuestionsMap.keys
                      .map((testQuestion) {
                    if (shuffledQuestionsMap[testQuestion] == true){
                      ratings[testQuestion] = 1;
                    } else {
                      ratings[testQuestion] = 4;
                    }
                    return Column(
                      children: [
                        Text(
                          testQuestion,
                          style: textTheme.bodySmall?.copyWith(
                              color: Constants.chatDarkGray),
                        ),
                        SpaceH8(),
                        RatingBar.builder(
                          initialRating: 1,
                          minRating: 1,
                          direction: Axis.horizontal,
                          itemCount: 4,
                          itemPadding:
                          EdgeInsets.symmetric(
                              horizontal: 4.0),
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return Icon(
                                  Icons.sentiment_very_dissatisfied_sharp,
                                  color: Colors.redAccent,
                                );
                              case 1:
                                return Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  color: Colors.amber,
                                );
                              case 2:
                                return Icon(
                                  Icons.sentiment_satisfied_alt,
                                  color: Colors.lightGreen,
                                );
                              case 3:
                                return Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: Colors.green,
                                );
                              default: return Container();
                            }
                          },
                          onRatingUpdate: (rating) {
                            if (shuffledQuestionsMap[testQuestion] == true){
                              ratings[testQuestion] =
                                  rating.toInt();
                            } else {
                              ratings[testQuestion] =
                                  5 - rating.toInt();
                            }

                            print(ratings.values.reduce(
                                    (value, element) =>
                                value + element));
                          },
                        ),
                        SpaceH30(),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          defaultActionText: 'Ok',
          onDefaultActionPressed: (context) {
            if (ratings.values.reduce(
                    (value, element) =>
                value + element) >=
                12) {
              Navigator.pop(context);
              showCustomDialog(context,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpaceH16(),
                      Text(
                          '¡Enhorabuena! Has evaluado la competencia ${competency.name}'),
                      SpaceH16(),
                      Image.network(
                        competency.badgesImages[
                        StringConst
                            .BADGE_VALIDATED]!,
                        height: 200.0,
                        width: 200.0,
                      )
                    ],
                  ),
                  defaultActionText: 'Aceptar',
                  onDefaultActionPressed: (con) async {
                    Navigator.of(con).pop(true);
                    onComingBack();
                  });
              database.userStream(auth.currentUser!.email).first.then((users) {
                final userEnreda = users[0];
                userEnreda.competencies[
                competency.id!] =
                    StringConst.BADGE_VALIDATED;
                database.setUserEnreda(userEnreda);
              });
            } else {
              Navigator.pop(context);
              showAlertDialog(context,
                  title: '¡Lo sentimos!',
                  content:
                  'No has conseguido evaluar la competencia ${competency.name}, te animamos a que lo intentes de nuevo.',
                  defaultActionText: 'Aceptar');
            }
          },
        );
      },
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(
            Constants.penBlue),
          backgroundColor:
          MaterialStateProperty.all(
              Constants.white)),
      child: Text('EVALUAR', style: textTheme.bodySmall
          ?.copyWith(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: Constants.penBlue)),
    );
  }
}
