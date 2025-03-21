import 'package:enreda_app/app/home/models/ability.dart';
import 'package:enreda_app/app/sign_up/validating_form_controls/multi_select_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';

Widget streamBuilderDropdownAbilities (BuildContext context, Set<Ability> selectedAbilities) {
  final database = Provider.of<Database>(context, listen: false);
  return StreamBuilder<List<Ability>>(
      stream: database.abilityStream(),
      builder: (context, snapshotAbilities){

        List<MultiSelectDialogItem<Ability>> abilityItems = [];
        if (snapshotAbilities.hasData) {
          abilityItems = snapshotAbilities.data!.map( (Ability ability) =>
              MultiSelectDialogItem<Ability>(
                  ability,
                  ability.name
              ))
              .toList();
        }

        return MultiSelectDialog<Ability>(
          items: abilityItems,
          initialSelectedValues: selectedAbilities,
        );
      });
}