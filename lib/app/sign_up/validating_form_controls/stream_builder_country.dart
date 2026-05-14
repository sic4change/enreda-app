import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

/// Uses LocationCache to get countries.
/// Assumes LocationCache.warmUp() has already been called by a parent FutureBuilder.
Widget streamBuilderForCountry(BuildContext context, Country? selectedCountry,
    functionToWriteBackThings, genericType, String title) {
  final TextTheme textTheme = Theme.of(context).textTheme;
  final double fontSize = responsiveSize(context, 14, 16, md: 15);

  return Builder(
    builder: (context) {
      final countries = LocationCache.instance.countries;
      List<DropdownMenuItem<Country>> countryItems = countries.map((Country country) {
        if (selectedCountry == null && country.countryId == genericType?.country) {
          selectedCountry = country;
        }
        return DropdownMenuItem<Country>(
          value: country,
          child: Text(country.name),
        );
      }).toList();

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
          DropdownButtonFormField(
            value: selectedCountry,
            items: countryItems,
            onChanged: (value) => functionToWriteBackThings(value),
            validator: (value) => selectedCountry != null ? null : StringConst.COUNTRY_ERROR,
            decoration: InputDecoration(
              fillColor: AppColors.white,
              filled: true,
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

