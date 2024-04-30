import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget streamBuilderForNation (BuildContext context, String? selectedCountry,  functionToWriteBackThings, String title ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<String>>(
      stream: database.nationsSpanishStream(),
      builder: (context, snapshotCountries){

        List<String> countries = [];
        List<DropdownMenuItem<String>> countryItems = [];
        if (snapshotCountries.hasData) {
          countries = snapshotCountries.data!;
          countryItems = countries.map((String c) =>
              DropdownMenuItem<String>(
                value: c,
                child: Text(c),
              ))
              .toList();
        }
        if(selectedCountry == null || countries.contains(selectedCountry)) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: DropdownButtonFormField(
                    value: selectedCountry,
                    items: countryItems,
                    isDense: true,
                    isExpanded: true,
                    onChanged: (value) => functionToWriteBackThings(value),
                    validator: (value) =>
                    selectedCountry != null
                        ? null
                        : StringConst.COUNTRY_ERROR,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(height: 0.01),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: AppColors.greyUltraLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: AppColors.greyUltraLight,
                          width: 1.0,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: AppColors.greyUltraLight,
                          width: 1.0,
                        ),
                      ),
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ]
          );
        }else{
          return Container();
        }
      });
}