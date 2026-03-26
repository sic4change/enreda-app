import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

/// Uses LocationCache to avoid repeated Firestore reads for countries.
/// The country list is small (≈3 docs) but was using a live stream; now cached.
Widget streamBuilderForCountry(BuildContext context, Country? selectedCountry,
    functionToWriteBackThings, genericType, String title) {
  final database = Provider.of<Database>(context, listen: false);
  final TextTheme textTheme = Theme.of(context).textTheme;
  final double fontSize = responsiveSize(context, 14, 16, md: 15);

  return FutureBuilder<List<Country>>(
    future: LocationCache.instance.warmUp(database).then((_) => LocationCache.instance.countries),
    builder: (context, snapshotCountries) {
      List<DropdownMenuItem<Country>> countryItems = [];
      if (snapshotCountries.hasData && snapshotCountries.data!.isNotEmpty) {
        countryItems = snapshotCountries.data!.map((Country country) {
          if (selectedCountry == null && country.countryId == genericType?.country) {
            selectedCountry = country;
          }
          return DropdownMenuItem<Country>(
            value: country,
            child: Text(country.name),
          );
        }).toList();
      }

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
