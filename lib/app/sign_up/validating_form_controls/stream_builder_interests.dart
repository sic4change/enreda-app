import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/multi_select_button.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:flutter/material.dart';

Widget streamBuilderDropdownInterests (BuildContext context, Set<Interest> selectedInterests) {
  return Builder(
      builder: (context){
        final rawInterests = List<Interest>.from(LocationCache.instance.interests);

        // Sort: normal interests first (alphabetical), then "Otros", then "Sin clasificar"
        int _sortOrder(Interest i) {
          final name = i.name.trim().toLowerCase();
          if (name == 'sin clasificar') return 2;
          if (name == 'otros') return 1;
          return 0;
        }

        rawInterests.sort((a, b) {
          final orderDiff = _sortOrder(a).compareTo(_sortOrder(b));
          if (orderDiff != 0) return orderDiff;
          return a.name.compareTo(b.name);
        });

        List<MultiSelectDialogItem<Interest>> interestItems = rawInterests.map((Interest interest) =>
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