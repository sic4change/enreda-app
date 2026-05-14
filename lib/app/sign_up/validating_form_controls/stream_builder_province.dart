import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

/// Uses LocationCache to get provinces for a given country.
/// Assumes LocationCache.warmUp() has already been called by a parent FutureBuilder.
Widget streamBuilderForProvince(BuildContext context, String? selectedCountryId,
    Province? selectedProvince, functionToWriteBackThings, genericType) {
  final TextTheme textTheme = Theme.of(context).textTheme;
  final double fontSize = responsiveSize(context, 14, 16, md: 15);

  return Builder(
    builder: (context) {
      final List<Province> provinceList = (selectedCountryId != null && selectedCountryId.isNotEmpty)
          ? LocationCache.instance.provincesForCountry(selectedCountryId)
          : LocationCache.instance.provinces;

      List<DropdownMenuItem<Province>> provinceItems = provinceList.map((Province province) {
        if (selectedProvince == null && province.provinceId == genericType?.province) {
          selectedProvince = province;
        }
        return DropdownMenuItem<Province>(
          value: province,
          child: Text(province.name, overflow: TextOverflow.ellipsis),
        );
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              StringConst.FORM_PROVINCE,
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          DropdownButtonFormField(
            value: selectedProvince,
            items: provinceItems,
            onChanged: (value) => functionToWriteBackThings(value),
            validator: (value) => selectedProvince != null ? null : StringConst.PROVINCE_ERROR,
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