import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';


Widget streamBuilderForProvince (BuildContext context, Country? selectedCountry, Province? selectedProvince,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<Province>>(
      stream: database.provincesCountryStream(selectedCountry?.countryId),
      builder: (context, snapshotProvinces) {

        List<DropdownMenuItem<Province>> provinceItems = [];
        if (snapshotProvinces.hasData && selectedCountry != null) {
          provinceItems = snapshotProvinces.data!.map((Province p) =>
              DropdownMenuItem<Province>(
                value: p,
                child: Text(p.name),
              )
          ).toList();
        }

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
                validator: (value) => selectedProvince != null ?
                null : StringConst.PROVINCE_ERROR,
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
                  height: 1.4,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize,
                ),
              ),
            ]
        );
      }
  );
}