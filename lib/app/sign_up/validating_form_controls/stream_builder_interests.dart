import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/multi_select_button.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:flutter/material.dart';

Widget streamBuilderDropdownInterests (BuildContext context, Set<Interest> selectedInterests) {
  return Builder(
      builder: (context){
        final interests = LocationCache.instance.interests;
        List<MultiSelectDialogItem<Interest>> interestItems = interests.map( (Interest interest) =>
              MultiSelectDialogItem<Interest>(
                  interest,
                  interest.name
              ))
              .toList();

        return MultiSelectDialog<Interest>(
          items: interestItems,
          initialSelectedValues: selectedInterests,
        );
      });
}