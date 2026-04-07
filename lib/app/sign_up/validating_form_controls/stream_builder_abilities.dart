import 'package:enreda_app/app/home/models/ability.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/multi_select_button.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:flutter/material.dart';

Widget streamBuilderDropdownAbilities (BuildContext context, Set<Ability> selectedAbilities) {
  return Builder(
      builder: (context){
        final abilities = LocationCache.instance.abilities;
        List<MultiSelectDialogItem<Ability>> abilityItems = abilities.map( (Ability ability) =>
              MultiSelectDialogItem<Ability>(
                  ability,
                  ability.name
              ))
              .toList();

        return MultiSelectDialog<Ability>(
          items: abilityItems,
          initialSelectedValues: selectedAbilities,
        );
      });
}