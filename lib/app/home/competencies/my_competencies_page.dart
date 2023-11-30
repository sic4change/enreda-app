import 'package:enreda_app/app/home/competencies/competencies_item_builder.dart';
import 'package:enreda_app/app/home/competencies/expandable_competency_tile.dart';
import 'package:enreda_app/app/home/curriculum/validate_competency_button.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'certificate_competency_page.dart';

class MyCompetenciesPage extends StatefulWidget {
  @override
  State<MyCompetenciesPage> createState() => _MyCompetenciesPageState();
}

class _MyCompetenciesPageState extends State<MyCompetenciesPage> {

  @override
  void initState() {
    super.initState();
  }

  String? codeDialog;
  String? valueText;


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme
        .of(context)
        .textTheme;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            top: kIsWeb ? 32 : 20, left: 10, right: 10),
        child: StreamBuilder<User?>(
            stream: Provider.of<AuthBase>(context).authStateChanges(),
            builder: (context, snapshot) {
              return StreamBuilder<List<UserEnreda>>(
                  stream: database.userStream(auth.currentUser?.email ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      UserEnreda? user =
                      snapshot.data != null && snapshot.data!.isNotEmpty
                          ? snapshot.data!.first
                          : null;
                      return StreamBuilder<List<Competency>>(
                          stream: database.competenciesStream(),
                          builder: (context, snapshot) {
                            return CompetenciesItemBuilder<Competency>(
                              user: user,
                              snapshot: snapshot,
                              fitSmallerLayout: true,
                              emptyMessage:
                              'Todavía no hemos identificado ninguna competencia, ¡chatea con nuestro asistente para identificarlas!',
                              itemBuilder: (context, competency) {
                                final status =
                                    user?.competencies[competency.id] ??
                                        StringConst.BADGE_EMPTY;

                                return Container(
                                  child: Column(
                                    children: [
                                      ExpandableCompetencyTile(
                                        competency: competency,
                                        status: status,
                                      ),
                                      if (status ==
                                          StringConst.BADGE_IDENTIFIED)
                                        ValidateCompetencyButton(
                                            competency: competency,
                                            database: database,
                                            auth: auth),
                                      if (status ==
                                          StringConst.BADGE_VALIDATED ||
                                          status == StringConst.BADGE_CERTIFIED)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              status ==
                                                  StringConst.BADGE_VALIDATED
                                                  ? 'EVALUADA'
                                                  : 'CERTIFICADA',
                                              style: textTheme.bodyText1
                                                  ?.copyWith(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                  Constants.turquoise)),
                                        ),

                                      if (status == StringConst.BADGE_VALIDATED)
                                        TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CompetencyDetailPage(competency: competency, user: user!)),
                                              );
                                            },
                                            child: Text('CERTIFICAR',
                                                style: textTheme.bodyText1
                                                ?.copyWith(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                Constants.salmonDark))
                                        ),
                                      if (status == StringConst.BADGE_PROCESSING)
                                        Text('EN PROCESO',
                                            style: textTheme.bodyText1
                                                ?.copyWith(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                Constants.grey)),
                                    ],
                                  ),
                                );
                              },
                            );
                          });
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  });
            }),
      ),
    );
  }
}
