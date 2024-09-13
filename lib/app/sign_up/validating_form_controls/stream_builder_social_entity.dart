import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilderForSocialEntity (BuildContext context, SocialEntity? selectedSocialEntity, functionToWriteBackThings, genericType, String title, bool? validated) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<SocialEntity>>(
      stream: database.socialEntitiesStream(),
      builder: (context, snapshotSocialEntities){

        List<DropdownMenuItem<SocialEntity>> socialEntityItems = [];
        if (snapshotSocialEntities.hasData) {
          final socialEntities = [SocialEntity(name: "Ninguna")].followedBy(snapshotSocialEntities.data!);
          socialEntityItems = socialEntities.map((SocialEntity socialEntity) {
            if (selectedSocialEntity == null && socialEntity.socialEntityId == genericType?.assignedEntityId) {
              selectedSocialEntity = socialEntity;
            }
            return DropdownMenuItem<SocialEntity>(
              value: socialEntity,
              child: Text(socialEntity.name),
            );
          })
              .toList();
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
                isDense: true,
                isExpanded: true,
                value: selectedSocialEntity,
                items: socialEntityItems,
                onChanged: (value) => functionToWriteBackThings(value),
                validator: (value) {
                  if (selectedSocialEntity != null) {
                    return null;
                  } else if (validated == false) {
                    return null;
                  } else {
                    return StringConst.FORM_FIELD_ERROR;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Ninguna',
                  labelStyle: textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: AppColors.white,
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
      });
}