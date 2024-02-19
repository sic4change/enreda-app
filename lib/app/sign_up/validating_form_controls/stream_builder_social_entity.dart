import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/socialEntity.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilderForSocialEntity (BuildContext context, SocialEntity? selectedSocialEntity,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<SocialEntity>>(
      stream: database.socialEntitiesStream(),
      builder: (context, snapshotSocialEntities){

        List<DropdownMenuItem<SocialEntity>> socialEntityItems = [];
        if (snapshotSocialEntities.hasData) {
          final socialEntities = [SocialEntity(name: "Ninguna")].followedBy(snapshotSocialEntities.data!);
          socialEntityItems = socialEntities.map((SocialEntity s) =>
              DropdownMenuItem<SocialEntity>(
                value: s,
                child: Text(s.name),
              ))
              .toList();
          if(selectedSocialEntity == null || socialEntities.contains(selectedSocialEntity)){
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      StringConst.FORM_SOCIAL_ENTITY,
                      style: textTheme.button?.copyWith(
                        height: 1.5,
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    height: 55,
                    child: DropdownButtonFormField(
                      value: selectedSocialEntity,
                      items: socialEntityItems,
                      onChanged: (value) => functionToWriteBackThings(value),
                      //validator: validator,
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
                      style: textTheme.button?.copyWith(
                        height: 1.4,
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
        }
        else{
          return Container();
        }
      });
}