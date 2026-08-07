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

Widget selectSpecificInterestsDialog(
    BuildContext context,
    Set<Interest> selectedInterests,
    Set<SpecificInterest> selectedSpecificInterests,
    List<SpecificInterest> allSpecificInterests) {
  Set<List<MultiSelectDialogItem<SpecificInterest>>> specificInterestSet = {};

  // Sort interest groups so the "Otros" section appears last
  final sortedInterests = List<Interest>.from(selectedInterests);
  sortedInterests.sort((a, b) {
    final aIsOtros = a.name.trim().toLowerCase() == 'otros';
    final bIsOtros = b.name.trim().toLowerCase() == 'otros';
    if (aIsOtros && !bIsOtros) return 1;
    if (!aIsOtros && bIsOtros) return -1;
    return a.name.compareTo(b.name);
  });

  sortedInterests.forEach((i) {
    final specificInterestsByInterest = allSpecificInterests
        .where((sp) => i.interestId == sp.interestId)
        .toList();

    // Skip interests that have no specific sub-interests (e.g. "sin clasificar")
    if (specificInterestsByInterest.isEmpty) return;

    // Sort items within each group: alphabetical first, "Otros" item last
    specificInterestsByInterest.sort((a, b) {
      final aIsOtros = a.name.trim().toLowerCase() == 'otros';
      final bIsOtros = b.name.trim().toLowerCase() == 'otros';
      if (aIsOtros && !bIsOtros) return 1;
      if (!aIsOtros && bIsOtros) return -1;
      return a.name.compareTo(b.name);
    });

    final specificInterestsItems = specificInterestsByInterest
        .map((SpecificInterest specificInterest) =>
            MultiSelectDialogItem<SpecificInterest>(
                specificInterest,
                specificInterest.name,
                sortedInterests
                    .firstWhere(
                        (i) => i.interestId == specificInterest.interestId)
                    .name))
        .toList();

    specificInterestSet.add(specificInterestsItems);
  });

  if (specificInterestSet.isNotEmpty) {
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
