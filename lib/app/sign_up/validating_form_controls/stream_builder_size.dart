import 'package:enreda_app/app/home/models/size.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

Widget streamBuilderForSizeOrg (BuildContext context, SizeOrg? selectedSizeOrg,  functionToWriteBackThings ) {
  return Builder(
      builder: (context){
        final sizeOrgs = LocationCache.instance.sizeOrgs;
        List<DropdownMenuItem<SizeOrg>> sizeOrgItems = sizeOrgs.map((SizeOrg sizeOrg) =>
              DropdownMenuItem<SizeOrg>(
                value: sizeOrg,
                child: Text(sizeOrg.label),
              ))
              .toList();

        return DropdownButtonFormField<SizeOrg>(
          hint: Text(StringConst.FORM_SIZE),
          isExpanded: true,
          value: selectedSizeOrg,
          items: sizeOrgItems,
          validator: (value) => selectedSizeOrg != null ? null : StringConst.FORM_SIZE_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
        );
      });
}