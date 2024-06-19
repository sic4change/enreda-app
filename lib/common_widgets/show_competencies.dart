import 'dart:collection';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<dynamic> showCompetencies(
  BuildContext context, {
  required Map<String, int> userCompetencies,
  required void Function(BuildContext context) onDismiss,
}) async {
  final database = Provider.of<Database>(context, listen: false);
  final auth = Provider.of<AuthBase>(context, listen: false);
  final textTheme = Theme.of(context).textTheme;

  int competenciesSelected = 0;
  final List<Competency> recommendedCompetencies = [];
  final users = await database.userStream(auth.currentUser!.email).first;
  final userEnreda = users[0];

  var sortedKeys = userCompetencies.keys.toList(growable: false)
    ..sort((k2, k1) => userCompetencies[k1]!.compareTo(userCompetencies[k2]!));
  LinkedHashMap<String, int> sortedCompetencies =
      new LinkedHashMap.fromIterable(sortedKeys,
          key: (k) => k, value: (k) => userCompetencies[k]!);

  for (var i = 0; i < 5 && i < sortedCompetencies.length; i++) {
    final competency = await database
        .competencyStream(sortedCompetencies.keys.toList()[i])
        .first;
    recommendedCompetencies.add(competency);
  }

  final recommendedCompetenciesSet =
      recommendedCompetencies.map((c) => c.id).toSet();
  final myCompetenciesSet = userEnreda.competencies.keys.toSet();
  if (myCompetenciesSet.containsAll(recommendedCompetenciesSet)) {
    showCustomDialog(context,
        content: Text(
          'Ya has conseguido las competencias recomendadas para esta experiencia. Sigue introduciendo experiencias para identificar nuevas competencias',
          style: textTheme.bodySmall,
        ),
        defaultActionText: 'Ok',
        onDefaultActionPressed: onDismiss);
  } else {
    showCustomDialog(context,
        dismissible: false,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SpaceH12(),
            Text(
              '¡Con esta experiencia desarrollaste las siguientes competencias! Selecciona hasta 3 para añadirla/s a tu perfil:',
              style: textTheme.bodySmall?.copyWith(fontSize: 18.0),
            ),
            SpaceH12(),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: recommendedCompetencies
                      .map(
                        (competency) => InkWell(
                          onTap: () {
                            if (userEnreda.competencies
                                .containsKey(competency.id)) return;

                            if (competency.selected.value) {
                              competency.selected.value = false;
                              competenciesSelected--;
                            } else if (!competency.selected.value &&
                                competenciesSelected < 3) {
                              competency.selected.value = true;
                              competenciesSelected++;
                            } else {
                              showAlertDialog(context,
                                  title: 'Error',
                                  content: 'No puedes seleccionar más de 3',
                                  defaultActionText: 'Ok');
                            }
                          },
                          child: ValueListenableBuilder<bool>(
                              valueListenable: competency.selected,
                              builder: (context, isSelected, child) {
                                final status = userEnreda.competencies
                                        .containsKey(competency.id)
                                    ? userEnreda.competencies[competency.id]
                                    : isSelected
                                        ? StringConst.BADGE_IDENTIFIED
                                        : StringConst.BADGE_EMPTY;

                                return Column(
                                  children: [
                                    if (competency.badgesImages[status] != null)
                                      Image.network(
                                        competency.badgesImages[status]!,
                                        height: 200.0,
                                        width: 200.0,
                                      ),
                                    /*
                            SpaceH12(),
                            Text(competency.name, style: TextStyle(fontSize: 16.0),),
                             */
                                    SpaceH12(),
                                    Text(
                                      '${userCompetencies[competency.id]} puntos',
                                      style: textTheme.bodySmall?.copyWith(fontSize: 14.0),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        defaultActionText: 'Ok', onDefaultActionPressed: (context) {
      if (competenciesSelected > 0) {
        database.userStream(auth.currentUser!.email).first.then((users) {
          final userEnreda = users[0];
          recommendedCompetencies.forEach((competency) {
            if (competency.selected.value) {
              userEnreda.competencies[competency.id!] =
                  StringConst.BADGE_IDENTIFIED;
            }
          });
          database.setUserEnreda(userEnreda);
          onDismiss(context);
          if (competenciesSelected > 0)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(StringConst.EXPERIENCE_ADDED),
            ));
        });
      } else {
        showAlertDialog(context,
            title: 'No hay competencias seleccionadas',
            content:
                'Selecciona al menos una competencia para poder añadirla a tu CV',
            defaultActionText: 'Ok');
      }
    });
  }
}
