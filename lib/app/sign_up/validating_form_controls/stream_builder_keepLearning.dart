import 'package:enreda_app/app/home/models/keepLearningOptions.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:flutter/material.dart';
import 'multi_select_button.dart';

Widget streamBuilderDropdownKeepLearningOptions (BuildContext context, Set<KeepLearningOption> selectedKeepLearningOptions) {
  return Builder(
      builder: (context){
        final keepLearningOptions = LocationCache.instance.keepLearningOptions;
        List<MultiSelectDialogItem<KeepLearningOption>> options = keepLearningOptions.map( (KeepLearningOption option) =>
              MultiSelectDialogItem<KeepLearningOption>(
                option,
                option.title,
              ))
              .toList();

        return MultiSelectDialog<KeepLearningOption>(
          items: options,
          initialSelectedValues: selectedKeepLearningOptions,
        );
      });
}