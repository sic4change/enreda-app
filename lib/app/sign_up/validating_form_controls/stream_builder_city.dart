import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';


Widget streamBuilderForCity (BuildContext context, Country? selectedCountry, Province? selectedProvince, City? selectedCity,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<City>>(
      stream: database.citiesProvinceStream(selectedProvince?.provinceId),
      builder: (context, snapshotCities){

        List<DropdownMenuItem<City>> cityItems = [];
        if (snapshotCities.hasData && selectedProvince != null) {
          cityItems = snapshotCities.data!.map((City c) =>
              DropdownMenuItem<City>(
                value: c,
                child: Text(c.name),
              )
          ).toList();
        }
        return DropdownButtonFormField<City>(
          hint: Text(StringConst.FORM_CITY),
          isExpanded: true,
          value: selectedCity,
          items: cityItems,
          validator: (value) => selectedCity != null ?
          null : StringConst.CITY_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
          iconDisabledColor: AppColors.greyDark,
          iconEnabledColor: AppColors.primaryColor,
          decoration: InputDecoration(
            labelStyle: textTheme.button?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
            ),
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
          ),
          style: textTheme.button?.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: AppColors.greyDark,
            fontSize: fontSize,
          ),
        );
      });
}