import 'package:enreda_app/app/home/models/activity.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/multi_select_list_button.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';

Widget streamBuilderDropdownProfessionActivities (BuildContext context, Choice? selectedProfession, List<String> activitiesIds,  Set<Activity> selectedActivities,) {
  final database = Provider.of<Database>(context, listen: false);
  Set<List<MultiSelectDialogItem<Activity>>> activitiesSet = {};
  List<MultiSelectDialogItem<Activity>> activitiesItems = [];
  List<Activity> activities = [];
  Activity activity;
  if (selectedProfession != null && activitiesIds.isNotEmpty)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [
        for (var activityId in activitiesIds) ...[
          Center(
              child: StreamBuilder<Activity>(
                  stream: database.activityStreamProfessionId(activityId),
                  builder: (context, snapshotActivity){
                    if (snapshotActivity.hasData) {
                      activity = snapshotActivity.data!;
                      final index1 = activities.indexWhere((element) =>
                      element.id == activity.id);
                      if (index1 == -1) activities.add(activity);
                    }
                    if (activities.length == activitiesIds.length ) {
                      activitiesItems = activities.map((Activity activity) =>
                          MultiSelectDialogItem<Activity>(
                              activity,
                              activity.name,
                              selectedProfession.name
                          ))
                          .toList();
                    }
                    if (activitiesItems.length > 0) activitiesSet.add(activitiesItems);
                    if (activitiesSet.length == 1)
                      return MultiSelectListDialog<Activity>(
                        itemsSet: activitiesSet,
                        initialSelectedValuesSet: selectedActivities,
                      );
                    return Container();
                  })
          )
        ]
      ],
    );
  return AlertDialog(
    content: Text(StringConst.FORM_ACTIVITIES_EMPTY),
    actions: <Widget>[
      ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(StringConst.FORM_ACCEPT, style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold))
      ),
    ],
  );
}



