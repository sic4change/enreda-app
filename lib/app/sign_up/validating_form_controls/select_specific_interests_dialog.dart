import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/const.dart';
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
    backgroundColor: AppColors.primary050,
    content: Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomTextSmall(text: StringConst.FORM_INTEREST_EMPTY),
    ),
    actions: <Widget>[
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.turquoise,
          ),
          onPressed: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextSmall(text: StringConst.FORM_ACCEPT),
          )),
    ],
  );
}