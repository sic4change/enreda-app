import 'package:enreda_app/app/home/models/scope.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';

Widget streamBuilderForScope (BuildContext context, Scope? selectedScope,  functionToWriteBackThings ) {
  return Builder(
      builder: (context){
        final scopes = LocationCache.instance.scopes;
        List<DropdownMenuItem<Scope>> scopeItems = scopes.map((Scope scope) => DropdownMenuItem<Scope>(
            value: scope,
            child: Text(scope.label),
          ))
              .toList();

        return DropdownButtonFormField<Scope>(
          hint: Text(StringConst.FORM_SCOPE),
          isExpanded: true,
          value: selectedScope,
          items: scopeItems,
          validator: (value) => selectedScope != null ? null : StringConst.FORM_SCOPE_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
        );
      });
}