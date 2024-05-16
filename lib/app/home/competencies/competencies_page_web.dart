import 'package:enreda_app/app/home/competencies/competencies_subcategories_page_web.dart';
import 'package:enreda_app/app/home/models/competencyCategory.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/pill_tooltip.dart';
import 'package:enreda_app/common_widgets/main_container.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CompetenciesPageWeb extends StatefulWidget {
  const CompetenciesPageWeb({Key? key, required this.showChatNotifier})
      : super(key: key);
  final ValueNotifier<bool> showChatNotifier;

  @override
  State<CompetenciesPageWeb> createState() => _CompetenciesPageWebState();
}

class _CompetenciesPageWebState extends State<CompetenciesPageWeb> {
  Widget bodyWidget = Container();
  bool showingSubCategoriesPage = false;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(
          top: 30, left: 50, right: 50, bottom: 50),
      child: StreamBuilder<User?>(
          stream: Provider.of<AuthBase>(context).authStateChanges(),
          builder: (context, snapshot) {
            return StreamBuilder<List<CompetencyCategory>>(
                stream: database.competenciesCategoriesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !showingSubCategoriesPage)
                    bodyWidget = _competenciesCategoriesWidget(context, snapshot.data!);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompetenciesInfo(context),
                      SpaceW30(),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: MainContainer(
                              child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 30),
                                        child: Container(
                                          height: 34,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                StringConst.COMPETENCIES.toUpperCase(),
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: Constants.penBlue,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SpaceW8(),
                                              Container(
                                                width: 34,
                                                child: PillTooltip(
                                                  title: StringConst.PILL_COMPETENCIES,
                                                  pillId: TrainingPill.WHAT_ARE_COMPETENCIES_ID,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (snapshot.hasData)
                                        bodyWidget,
                                      if (!snapshot.hasData)
                                        Center(child: CircularProgressIndicator(),),
                                    ],
                                  )
                              )
                          ),
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
            MainContainer(
              padding: EdgeInsets.only(
                  left: 44.0, top: 44.0, right: 44.0, bottom: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringConst.COMPETENCY_DEFINITION,
                    style: textTheme.bodySmall?.copyWith(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Constants.darkGray),
                  ),
                  SpaceH20(),
                  Text(
                    StringConst.COMPETENCIES_INFO,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: Constants.darkGray),
                  ),
                  SpaceH30(),
                  _buildChatButton(context),
                  SpaceH20(),
                  Center(
                      child: Image.asset(
                    ImagePath.COMPETENCIES_ILLUSTRATION,
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
                    StringConst.COMPETENCY_LEVELS,
                    style: textTheme.bodySmall?.copyWith(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Constants.darkGray),
                  ),
                  SpaceH20(),
                  Text(
                    StringConst.COMPETENCIES_LEVEL_INFO,
                    style: textTheme.bodyMedium
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
                                  title: StringConst.COMPETENCY_NOT_OBTAINED,
                                  badgeUrl: ImagePath.EMPTY_BADGE_SAMPLE,
                                  description: ''),
                            ),
                            Expanded(
                              child: _buildBadgeInfo(
                                  context: context,
                                  title: StringConst.COMPETENCY_IDENTIFIED,
                                  badgeUrl: ImagePath.IDENTIFIED_BADGE_SAMPLE,
                                  description: StringConst.COMPETENCY_CHAT),
                            ),
                          ],
                        ),
                        SpaceH20(),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBadgeInfo(
                                  context: context,
                                  title: StringConst.COMPETENCY_EVALUATED,
                                  badgeUrl: ImagePath.VALIDATED_BADGE_SAMPLE,
                                  description: StringConst.COMPETENCY_MICRO_TESTS),
                            ),
                            Expanded(
                              child: _buildBadgeInfo(
                                  context: context,
                                  title: StringConst.COMPETENCY_CERTIFIED,
                                  badgeUrl: ImagePath.CERTIFIED_BADGE_SAMPLE,
                                  description: StringConst.COMPETENCY_REFERENCES),
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
            : widget.showChatNotifier.value = !widget.showChatNotifier.value,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                StringConst.START_CHAT,
                style: textTheme.bodySmall?.copyWith(
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
          style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500, color: Constants.darkGray),
        ),
      ],
    );
  }

  _showAlertNullUser(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: StringConst.NOT_LOGIN,
        content: StringConst.ASK_LOGIN,
        cancelActionText: StringConst.CANCEL,
        defaultActionText: StringConst.ENTER);
    if (didRequestSignOut == true) {
      context.push(StringConst.PATH_LOGIN);
    }
  }

  Widget _competenciesCategoriesWidget(BuildContext context, List<CompetencyCategory> competenciesCategories) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: competenciesCategories.map((c) =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => setState(() {
                    showingSubCategoriesPage = true;
                    bodyWidget = CompetenciesSubcategoriesPageWeb(
                      showChatNotifier: widget.showChatNotifier,
                      competencyCategory: c,
                      onBackPressed: () => setState(() {
                        bodyWidget = _competenciesCategoriesWidget(context, competenciesCategories);
                      }),
                    );
                  }),
                  child: MainContainer(
                    shadowColor: Colors.black.withOpacity(0.4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: Responsive.isDesktopS(context)? 7: 5,
                          child: Text(
                            c.name.toUpperCase(),
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: Responsive.isDesktopS(context)? 16.0: 20.0,
                            ),
                          ),
                        ),
                        SpaceW8(),
                        Expanded(
                          flex: Responsive.isDesktopS(context)? 3: 5,
                          child: Image.asset(
                            c.order == 1? ImagePath.COMPETENCIES_CATEGORIES_1:
                            c.order == 2? ImagePath.COMPETENCIES_CATEGORIES_2:
                            c.order == 3? ImagePath.COMPETENCIES_CATEGORIES_3:
                            ImagePath.COMPETENCIES_CATEGORIES_1,
                            height: 150,
                            width: 150,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SpaceH20(),
              ],
            )
        ).toList(),
      ),
    );
  }
}
