import 'package:enreda_app/app/home/competencies/competencies_item_builder.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/competencies/expandable_competency_tile.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CompetenciesPageWeb extends StatelessWidget {
  const CompetenciesPageWeb({Key? key, required this.showChatNotifier})
      : super(key: key);
  final ValueNotifier<bool> showChatNotifier;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(
          top: 30, left: 50, right: 50, bottom: 50),
      child: StreamBuilder<User?>(
          stream: Provider.of<AuthBase>(context).authStateChanges(),
          builder: (context, snapshot) {
            return StreamBuilder<List<Competency>>(
                stream: database.competenciesStream(),
                builder: (context, snapshot) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompetenciesInfo(context),
                      SpaceW30(),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _buildCompetenciesContainer(context, snapshot),
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }

  Widget _buildCompetenciesInfo(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: Constants.sidebarWidth,
      child: SingleChildScrollView(
        controller: ScrollController(),
        padding: EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: 44.0, top: 44.0, right: 44.0, bottom: 0.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: Offset(0, 1), //(x,y)
                      blurRadius: 4.0,
                      spreadRadius: 1.0),
                ],
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Constants.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué es una competencia?',
                    style: textTheme.bodyText1?.copyWith(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Constants.darkGray),
                  ),
                  SpaceH20(),
                  Text(
                    StringConst.COMPETENCIES_INFO,
                    style: textTheme.bodyText1
                        ?.copyWith(color: Constants.darkGray),
                  ),
                  SpaceH30(),
                  _buildChatButton(context),
                  SpaceH20(),
                  Center(
                      child: Image.asset(
                    ImagePath.COMPETENCIES,
                    width: 340.0,
                  )),
                ],
              ),
            ),
            SpaceH30(),
            Container(
              padding: EdgeInsets.all(48.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: Offset(0, 1), //(x,y)
                      blurRadius: 4.0,
                      spreadRadius: 1.0),
                ],
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Constants.white,
              ),
              child: Column(
                children: [
                  Text(
                    'Niveles de cada competencia',
                    style: textTheme.bodyText1?.copyWith(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Constants.darkGray),
                  ),
                  SpaceH20(),
                  Text(
                    StringConst.COMPETENCIES_LEVEL_INFO,
                    style: textTheme.bodyText1
                        ?.copyWith(color: Constants.darkGray),
                  ),
                  SpaceH20(),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildBadgeInfo(
                                  context: context,
                                  title: 'NO OBTENIDA',
                                  badgeUrl: ImagePath.EMPTY_BADGE_SAMPLE,
                                  description: ''),
                            ),
                            Expanded(
                              child: _buildBadgeInfo(
                                  context: context,
                                  title: 'IDENTIFICADA',
                                  badgeUrl: ImagePath.IDENTIFIED_BADGE_SAMPLE,
                                  description: 'A través del chat'),
                            ),
                          ],
                        ),
                        SpaceH20(),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBadgeInfo(
                                  context: context,
                                  title: 'EVALUADA',
                                  badgeUrl: ImagePath.VALIDATED_BADGE_SAMPLE,
                                  description: 'A través de los microtests'),
                            ),
                            Expanded(
                              child: _buildBadgeInfo(
                                  context: context,
                                  title: 'CERTIFICADA',
                                  badgeUrl: ImagePath.CERTIFIED_BADGE_SAMPLE,
                                  description: 'Con referencias externas'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () => auth.isNullUser
            ? _showAlertNullUser(context)
            : showChatNotifier.value = !showChatNotifier.value,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                StringConst.START_CHAT,
                style: textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Constants.white,
                ),
              ),
              SpaceW20(),
              Image.asset(ImagePath.CHAT_ICON, width: 44.0),
            ],
          ),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Constants.turquoise),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ))),
      ),
    );
  }

  Widget _buildBadgeInfo(
      {required BuildContext context,
      required String title,
      required String badgeUrl,
      required String description}) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Constants.darkGray),
        ),
        Image.asset(
          badgeUrl,
          filterQuality: FilterQuality.high,
          width: 160.0,
        ),
        Text(
          description,
          textAlign: TextAlign.center,
          style: textTheme.bodyText1?.copyWith(
              fontWeight: FontWeight.w500, color: Constants.darkGray),
        ),
      ],
    );
  }

  Widget _buildCompetenciesContainer(
      BuildContext context, AsyncSnapshot<List<Competency>> snapshot) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: Offset(0, 1), //(x,y)
              blurRadius: 4.0,
              spreadRadius: 1.0),
        ],
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Constants.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                StringConst.COMPETENCIES.toUpperCase(),
                style: textTheme.bodyText1?.copyWith(
                  color: Constants.penBlue,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CompetenciesItemBuilder<Competency>(
              user: null,
              snapshot: snapshot,
              itemBuilder: (context, competency) {
                return ExpandableCompetencyTile(competency: competency);
              },
            ),
          ],
        ),
      ),
    );
  }

  _showAlertNullUser(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Aún no has iniciado sesión',
        content:
            'Sólo los usuarios registrados pueden acceder al chat. ¿Deseas entrar como usuario registrado?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Entrar');
    if (didRequestSignOut == true) {
      context.push(StringConst.PATH_LOGIN);
    }
  }
}
