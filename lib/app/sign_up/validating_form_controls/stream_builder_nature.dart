import 'package:enreda_app/app/home/models/nature.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

Widget streamBuilderDropdownNature (BuildContext context, Nature? selectedNature,  functionToWriteBackThings ) {
  return Builder(
      builder: (context){
        final natures = LocationCache.instance.natures;
        List<DropdownMenuItem<Nature>> natureItems = natures.map((Nature nature) =>
              DropdownMenuItem<Nature>(
                value: nature,
                child: Text(nature.label),
              ))
              .toList();

        return DropdownButtonFormField<Nature>(
          hint: Text(StringConst.FORM_NATURE),
          isExpanded: true,
          value: selectedNature,
          items: natureItems,
          validator: (value) => selectedNature != null ? null : StringConst.FORM_NATURE_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
        );
      });
}