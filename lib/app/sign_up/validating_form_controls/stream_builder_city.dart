import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

/// Uses LocationCache to avoid repeated Firestore reads for cities.
/// Falls back to individual province query but caches the result.
Widget streamBuilderForCity(BuildContext context, String? selectedProvinceId, City? selectedCity,
    functionToWriteBackThings, genericType) {
  final database = Provider.of<Database>(context, listen: false);
  final TextTheme textTheme = Theme.of(context).textTheme;
  final double fontSize = responsiveSize(context, 14, 16, md: 15);

  return FutureBuilder<List<City>>(
    future: selectedProvinceId != null && selectedProvinceId.isNotEmpty
        ? LocationCache.instance.getCitiesForProvince(database, selectedProvinceId)
        : Future.value([]),
    builder: (context, snapshotCities) {
      List<DropdownMenuItem<City>> cityItems = [];
      if (snapshotCities.hasData && snapshotCities.data!.isNotEmpty) {
        cityItems = snapshotCities.data!.map((City city) {
          if (selectedCity == null && city.cityId == genericType?.city) {
            selectedCity = city;
          }
          return DropdownMenuItem<City>(
            value: city,
            child: Text(city.name, overflow: TextOverflow.ellipsis),
          );
        }).toList();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              StringConst.FORM_CITY,
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          DropdownButtonFormField(
            value: selectedCity,
            items: cityItems,
            onChanged: (value) => functionToWriteBackThings(value),
            validator: (value) => selectedCity != null ? null : StringConst.CITY_ERROR,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              errorStyle: TextStyle(height: 0.01),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(color: AppColors.greyUltraLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(color: AppColors.greyUltraLight, width: 1.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(color: AppColors.greyUltraLight, width: 1.0),
              ),
            ),
            style: textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
            ),
          ),
        ],
      );
    },
  );
}