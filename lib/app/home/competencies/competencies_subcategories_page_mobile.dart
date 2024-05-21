import 'package:enreda_app/app/home/competencies/competencies_item_builder_horizontal.dart';
import 'package:enreda_app/app/home/competencies/expanded_competency_tile.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/competencyCategory.dart';
import 'package:enreda_app/app/home/models/competencySubCategory.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompetenciesSubcategoriesPageMobile extends StatelessWidget {
  const CompetenciesSubcategoriesPageMobile({
    Key? key,
    required this.showChatNotifier,
    required this.competencyCategory,
    this.onBackPressed,
  })
      : super(key: key);
  final ValueNotifier<bool> showChatNotifier;
  final CompetencyCategory competencyCategory;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onBackPressed,
              child: Icon(Icons.arrow_back, color: AppColors.primaryColor,),
            ),
            SpaceW8(),
            Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: CustomTextBoldTitle(title: competencyCategory.name.toUpperCase(),
                  color: AppColors.black400,))
          ],
        ),
        StreamBuilder<User?>(
            stream: Provider.of<AuthBase>(context).authStateChanges(),
            builder: (context, snapshot) {
              return StreamBuilder<List<CompetencySubCategory>>(
                  stream: database.competenciesSubCategoriesByCategoryStream(competencyCategory.competencyCategoryId),
                  builder: (context, snapshotSubCategories) {
                    if (snapshotSubCategories.hasData) {
                      return SingleChildScrollView(
                        child: Column(
                          children: snapshotSubCategories.data!.map((subCategory) => StreamBuilder<List<Competency>>(
                              stream: database.competenciesBySubCategoryStream(competencyCategory.competencyCategoryId, subCategory.competencySubCategoryId),
                              builder: (context, snapshotCompetencies) {
                                if (snapshotCompetencies.hasData) {
                                  final controller = ScrollController();
                                  var scrollJump = MediaQuery.of(context).size.width * 0.96;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SpaceH12(),
                                      Row(
                                        children: [
                                          CustomTextBoldTitle(title: subCategory.name.toUpperCase()),
                                          Spacer(),
                                          InkWell(
                                            onTap: () {
                                              if (controller.position.pixels >=
                                                  controller.position.minScrollExtent)
                                                controller.animateTo(
                                                    controller.position.pixels - scrollJump,
                                                    duration: Duration(milliseconds: 500),
                                                    curve: Curves.ease);
                                            },
                                            child: Image.asset(
                                              ImagePath.ARROW_BACK,
                                              width: 24.0,
                                            ),
                                          ),
                                          SpaceW12(),
                                          InkWell(
                                            onTap: () {
                                              if (controller.position.pixels <=
                                                  controller.position.maxScrollExtent)
                                                controller.animateTo(
                                                    controller.position.pixels + scrollJump,
                                                    duration: Duration(milliseconds: 500),
                                                    curve: Curves.ease);
                                            },
                                            child: Image.asset(
                                              ImagePath.ARROW_FORWARD,
                                              width: 24.0,
                                            ),
                                          ),
                                          SpaceW4(),
                                        ],
                                      ),
                                      Container(
                                        height: Responsive.isMobile(context) ? 340.0 : 420.0,
                                        child: CompetenciesItemBuilderHorizontal<Competency>(
                                          scrollController: controller,
                                          snapshot: snapshotCompetencies,
                                          itemBuilder: (context, competency) {
                                            return ExpandedCompetencyTile(competency: competency);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              }),).toList(),

                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }
              );
            }),
      ],
    );
  }
}
