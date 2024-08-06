import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import 'multi_select_list_button.dart';

Widget selectSpecificInterestsDialog (
    BuildContext context,
    Set<Interest> selectedInterests,
    Set<SpecificInterest> selectedSpecificInterests,
    List<SpecificInterest> allSpecificInterests
    ) {

  Set<List<MultiSelectDialogItem<SpecificInterest>>> specificInterestSet = {};

  selectedInterests.forEach((i) {
    final specificInterestsByInterest = allSpecificInterests.where((sp) => i.interestId == sp.interestId).toSet();

    final specificInterestsItems = specificInterestsByInterest.map((SpecificInterest specificInterest) =>
        MultiSelectDialogItem<SpecificInterest>(
            specificInterest,
            specificInterest.name,
            selectedInterests.firstWhere((i) => i.interestId == specificInterest.interestId).name
        )).toList();

    specificInterestSet.add(specificInterestsItems);
  });


  if (selectedInterests.isNotEmpty) {
    return MultiSelectListDialog<SpecificInterest>(
      itemsSet: specificInterestSet,
      initialSelectedValuesSet: selectedSpecificInterests,
    );
  }
  return AlertDialog(
    content: Text(StringConst.FORM_INTEREST_EMPTY),
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