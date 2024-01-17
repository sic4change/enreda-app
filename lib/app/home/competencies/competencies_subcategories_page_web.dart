import 'package:enreda_app/app/home/competencies/competencies_item_builder.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/competencies/expandable_competency_tile.dart';
import 'package:enreda_app/app/home/models/competencyCategory.dart';
import 'package:enreda_app/app/home/models/competencySubCategory.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/pill_tooltip.dart';
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

class CompetenciesSubcategoriesPageWeb extends StatelessWidget {
  const CompetenciesSubcategoriesPageWeb({
    Key? key,
    required this.showChatNotifier,
    required this.competencyCategory,
  })
      : super(key: key);
  final ValueNotifier<bool> showChatNotifier;
  final CompetencyCategory competencyCategory;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            competencyCategory.name.toUpperCase(),
            style: textTheme.titleMedium,
          ),
          StreamBuilder<User?>(
                stream: Provider.of<AuthBase>(context).authStateChanges(),
                builder: (context, snapshot) {
                  return StreamBuilder<List<CompetencySubCategory>>(
                      stream: database.competenciesSubCategoriesByCategoryStream(competencyCategory.id!),
                      builder: (context, snapshotSubCategories) {
                        if (snapshotSubCategories.hasData) {
                          return SingleChildScrollView(
                            child: Column(
                              children: snapshotSubCategories.data!.map((subCategory) => StreamBuilder<List<Competency>>(
                                  stream: database.competenciesBySubCategoryStream(competencyCategory.id!, subCategory.competencySubCategoryId!),
                                  builder: (context, snapshotCompetencies) {
                                    if (snapshotCompetencies.hasData) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SpaceH40(),
                                          Text(
                                            subCategory.name.toUpperCase(),
                                            style: textTheme.bodyLarge?.copyWith(
                                                fontSize: 20.0
                                            ),
                                          ),
                                          SpaceH40(),
                                          CompetenciesItemBuilder<Competency>(
                                            user: null,
                                            snapshot: snapshotCompetencies,
                                            itemBuilder: (context, competency) {
                                              return ExpandableCompetencyTile(competency: competency);
                                              },
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
