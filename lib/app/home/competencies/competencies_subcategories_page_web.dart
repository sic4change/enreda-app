import 'package:enreda_app/app/home/competencies/competencies_item_builder_horizontal.dart';
import 'package:enreda_app/app/home/competencies/expanded_competency_tile.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/competencyCategory.dart';
import 'package:enreda_app/app/home/models/competencySubCategory.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompetenciesSubcategoriesPageWeb extends StatelessWidget {
  const CompetenciesSubcategoriesPageWeb({
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBackPressed,
                child: Icon(Icons.arrow_back, color: AppColors.primaryColor,),
              ),
              SpaceW8(),
              Text(
                competencyCategory.name.toUpperCase(),
                style: textTheme.titleMedium,
              ),
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
                                      var scrollJump = Responsive.isDesktopS(context) ? 350 : 410;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SpaceH40(),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  subCategory.name.toUpperCase(),
                                                  style: textTheme.bodyLarge?.copyWith(
                                                      fontSize: 20.0
                                                  ),
                                                ),
                                              ),
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
                                            ],
                                          ),
                                          SpaceH40(),
                                          Container(
                                            height: 464.0,
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
      ),
    );
  }
}
