import 'package:enreda_app/app/home/competencies/competencies_item_builder.dart';
import 'package:enreda_app/app/home/competencies/expandable_competency_tile.dart';
import 'package:enreda_app/app/home/cupertino_scaffold.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/competencyCategory.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/pill_tooltip.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CompetenciesPageMobile extends StatelessWidget {
  const CompetenciesPageMobile({Key? key, required this.showChatNotifier})
      : super(key: key);
  final ValueNotifier<bool> showChatNotifier;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(
          top: 30, left: 10, right: 10, bottom: 50),
      child: StreamBuilder<User?>(
          stream: Provider.of<AuthBase>(context).authStateChanges(),
          builder: (context, snapshot) {
            return StreamBuilder<List<CompetencyCategory>>(
                stream: database.competenciesCategoriesStream(),
                builder: (context, snapshot) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        SpaceH20(),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: snapshot.hasData? _buildCompetenciesCategories(context, snapshot):
                          Center(child: CircularProgressIndicator(),),
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Constants.mainPadding / 2),
      padding: const EdgeInsets.all(12.0),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    StringConst.COMPETENCIES.toUpperCase(),
                    style: textTheme.bodyText1?.copyWith(
                        fontSize: 18.0,
                        color: Constants.penBlue,
                        fontWeight: FontWeight.w400),
                  ),
                  SpaceW8(),
                  PillTooltip(
                    title: StringConst.PILL_COMPETENCIES,
                    pillId: TrainingPill.WHAT_ARE_COMPETENCIES_ID,
                  )
                ],
              ),
            ),
          ),
          Divider(),
          _buildCompetenciesDefinitionPanel(context),
          Divider(),
          _buildCompetenciesLevelsPanel(context),
        ],
      ),
    );
  }

  Widget _buildCompetenciesLevelsPanel(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ExpandablePanel(
      theme: ExpandableThemeData(iconColor: Constants.penBlue),
      header: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('Niveles de cada competencia',
            textAlign: TextAlign.start,
            style: textTheme.bodyText1?.copyWith(
              color: Constants.penBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            )),
      ),
      expanded: Column(
        children: [
          Text(
            StringConst.COMPETENCIES_LEVEL_INFO,
            style: textTheme.bodyText1?.copyWith(
              color: Constants.darkGray,
            ),
          ),
          SpaceH20(),
          Column(
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
        ],
      ),
      collapsed: Container(),
    );
  }

  Widget _buildCompetenciesDefinitionPanel(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;

    return ExpandablePanel(
      theme: ExpandableThemeData(iconColor: Constants.penBlue),
      header: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('¿Qué es una competencia?',
            textAlign: TextAlign.start,
            style: textTheme.bodyText1?.copyWith(
              color: Constants.penBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            )),
      ),
      expanded: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(StringConst.COMPETENCIES_INFO,
                style: textTheme.bodyText1?.copyWith(
                  color: Constants.darkGray,
                )),
            SpaceH30(),
            Container(
              width: double.infinity,
              child: TextButton(
                onPressed: () => auth.isNullUser
                    ? _showAlertNullUser(context)
                    : CupertinoScaffold.controller.index = 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(StringConst.START_CHAT,
                          style: textTheme.bodyText1?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Constants.white,
                          )),
                      SpaceW20(),
                      Image.asset(ImagePath.CHAT_ICON, width: 44.0),
                    ],
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Constants.turquoise),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ))),
              ),
            ),
          ],
        ),
      ),
      collapsed: Container(),
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

  Widget _buildCompetenciesCategories(BuildContext context, AsyncSnapshot<List<CompetencyCategory>> snapshot) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        runSpacing: 20.0,
        spacing: 20.0,
        children: snapshot.data!.map((c) =>
            InkWell(
              onTap: () {

              },
              child: RoundedContainer(
                width: (MediaQuery.of(context).size.width/2) - 40,
                height: Responsive.isMobile(context)? 220.0: 180.0,
                shadowColor: Colors.black.withOpacity(0.4),
                child: Column(
                  children: [
                    Image.asset(
                      c.order == 1? ImagePath.COMPETENCIES_CATEGORIES_1:
                      c.order == 2? ImagePath.COMPETENCIES_CATEGORIES_2:
                      c.order == 3? ImagePath.COMPETENCIES_CATEGORIES_3:
                      ImagePath.COMPETENCIES_CATEGORIES_1,
                      width: 100.0,
                    ),
                    SpaceH20(),
                    Text(
                      c.name.toUpperCase(),
                      style: textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
        ).toList(),
      ),
    );
  }

  _showAlertNullUser(BuildContext context) async {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aún no has iniciado sesión',
            style: textTheme.bodyText1?.copyWith(
              color: Constants.grey,
              height: 1.5,
              fontWeight: FontWeight.w800,
              fontSize: fontSize + 2,
            )),
        content: Text(
            'Sólo los usuarios registrados pueden acceder al chat. ¿Deseas entrar como usuario registrado?',
            style: textTheme.bodyText1?.copyWith(
                color: Constants.grey,
                height: 1.5,
                fontWeight: FontWeight.w400,
                fontSize: fontSize)),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop((false)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Cancelar',
                    style: textTheme.bodyText1?.copyWith(
                        color: AppColors.white,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        fontSize: fontSize)),
              )),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop((false));
                context.push(StringConst.PATH_LOGIN);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Entrar',
                    style: textTheme.bodyText1?.copyWith(
                        color: AppColors.white,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        fontSize: fontSize)),
              )),
        ],
      ),
    );
  }
}
