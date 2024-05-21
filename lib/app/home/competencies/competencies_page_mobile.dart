import 'package:enreda_app/app/home/competencies/competencies_item_builder.dart';
import 'package:enreda_app/app/home/competencies/competencies_subcategories_page_mobile.dart';
import 'package:enreda_app/app/home/competencies/expandable_competency_tile.dart';
import 'package:enreda_app/app/home/cupertino_scaffold.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/competencyCategory.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/pill_tooltip.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/main_container.dart';
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

class CompetenciesPageMobile extends StatefulWidget {
  const CompetenciesPageMobile({Key? key, required this.showChatNotifier})
      : super(key: key);
  final ValueNotifier<bool> showChatNotifier;

  @override
  State<CompetenciesPageMobile> createState() => _CompetenciesPageMobileState();
}

class _CompetenciesPageMobileState extends State<CompetenciesPageMobile> {
  Widget bodyWidget = Container();
  bool showingSubCategoriesPage = false;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(
          top: 10, left: 0, right: 0, bottom: 0),
      child: StreamBuilder<User?>(
          stream: Provider.of<AuthBase>(context).authStateChanges(),
          builder: (context, snapshot) {
            return StreamBuilder<List<CompetencyCategory>>(
                stream: database.competenciesCategoriesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !showingSubCategoriesPage)
                    bodyWidget = _buildCompetenciesCategories(context, snapshot);
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        SpaceH20(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: snapshot.hasData? bodyWidget :
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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextBoldTitle(title: StringConst.COMPETENCIES),
                  SpaceW8(),
                  PillTooltip(
                    title: StringConst.PILL_COMPETENCIES,
                    pillId: TrainingPill.WHAT_ARE_COMPETENCIES_ID,
                  )
                ],
              ),
            ),
          ),
          Container(
              color: AppColors.primary030,
              child: _buildCompetenciesDefinitionPanel(context)),
          SizedBox(height: 10),
          Container(
              color: AppColors.primary030,
              child: _buildCompetenciesLevelsPanel(context)),
        ],
      ),
    );
  }

  Widget _buildCompetenciesLevelsPanel(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ExpandablePanel(
      theme: ExpandableThemeData(iconColor: AppColors.turquoiseBlue,
          expandIcon: Icons.expand_circle_down_outlined,
          collapseIcon: Icons.expand_less_outlined, iconSize: 30),
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: CustomTextBoldTitle(title: StringConst.COMPETENCY_LEVELS),
      ),
      expanded: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            Text(
              StringConst.COMPETENCIES_LEVEL_INFO,
              style: textTheme.bodySmall?.copyWith(
                color: Constants.darkGray,
              ),
            ),
            SpaceH20(),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBadgeInfo(
                        context: context,
                        title: StringConst.COMPETENCY_NOT_OBTAINED.toUpperCase(),
                        badgeUrl: ImagePath.EMPTY_BADGE_SAMPLE,
                        description: ''),
                    _buildBadgeInfo(
                        context: context,
                        title: StringConst.COMPETENCY_IDENTIFIED.toUpperCase(),
                        badgeUrl: ImagePath.IDENTIFIED_BADGE_SAMPLE,
                        description: StringConst.COMPETENCY_CHAT),
                  ],
                ),
                SpaceH20(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBadgeInfo(
                        context: context,
                        title: StringConst.COMPETENCY_EVALUATED.toUpperCase(),
                        badgeUrl: ImagePath.VALIDATED_BADGE_SAMPLE,
                        description: StringConst.COMPETENCY_MICRO_TESTS),
                    _buildBadgeInfo(
                        context: context,
                        title: StringConst.COMPETENCY_CERTIFIED.toUpperCase(),
                        badgeUrl: ImagePath.CERTIFIED_BADGE_SAMPLE,
                        description: StringConst.COMPETENCY_REFERENCES),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      collapsed: Container(),
    );
  }

  Widget _buildCompetenciesDefinitionPanel(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    return ExpandablePanel(
      theme: ExpandableThemeData(iconColor: AppColors.turquoiseBlue,
          expandIcon: Icons.expand_circle_down_outlined,
          collapseIcon: Icons.expand_less_outlined, iconSize: 30),
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: CustomTextBoldTitle(title: StringConst.COMPETENCY_DEFINITION),
      ),
      expanded: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            Text(StringConst.COMPETENCIES_INFO,
                style: textTheme.bodySmall?.copyWith(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(StringConst.START_CHAT,
                          style: textTheme.bodySmall?.copyWith(
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
                      borderRadius: BorderRadius.circular(30.0),
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
          style: textTheme.bodySmall?.copyWith(
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
              onTap: () => setState(() {
                showingSubCategoriesPage = true;
                bodyWidget = CompetenciesSubcategoriesPageMobile(
                  showChatNotifier: widget.showChatNotifier,
                  competencyCategory: c,
                  onBackPressed: () => setState(() {
                    bodyWidget = _buildCompetenciesCategories(context, snapshot);
                  }),
                );
              }),
              child: Container(
                width: double.infinity,
                height: 100.0,
                padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(
                    color: AppColors.blue050,
                  ) ,
                  color: AppColors.white,
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 180,
                          child: Text(
                            c.name.toUpperCase(),
                            style: textTheme.titleSmall?.copyWith(
                              fontSize: 12.0
                            ),
                          ),
                        ),
                        SpaceH4(),
                        CustomTextNormalSmall(title: 'Ver más')
                      ],
                    ),
                    Image.asset(
                      c.order == 1 ? ImagePath.COMPETENCIES_CATEGORIES_1:
                      c.order == 2 ? ImagePath.COMPETENCIES_CATEGORIES_2:
                      c.order == 3 ? ImagePath.COMPETENCIES_CATEGORIES_3:
                      ImagePath.COMPETENCIES_CATEGORIES_1,
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
        title: Text(StringConst.NOT_LOGIN,
            style: textTheme.bodySmall?.copyWith(
              color: Constants.grey,
              height: 1.5,
              fontWeight: FontWeight.w800,
              fontSize: fontSize + 2,
            )),
        content: Text(
            StringConst.ASK_LOGIN,
            style: textTheme.bodySmall?.copyWith(
                color: Constants.grey,
                height: 1.5,
                fontWeight: FontWeight.w400,
                fontSize: fontSize)),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop((false)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(StringConst.CANCEL,
                    style: textTheme.bodySmall?.copyWith(
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
                child: Text(StringConst.ENTER,
                    style: textTheme.bodySmall?.copyWith(
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
