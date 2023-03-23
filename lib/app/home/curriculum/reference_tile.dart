import 'package:enreda_app/app/home/curriculum/experience_form.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/delete_button.dart';
import 'package:enreda_app/common_widgets/edit_button.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReferenceTile extends StatelessWidget {
  const ReferenceTile({Key? key, required this.certificationRequest})
      : super(key: key);
  final CertificationRequest certificationRequest;

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 15, md: 14);
    return Row(
      children: [
        if (certificationRequest.referenced == true)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CustomTextBold(title: '${certificationRequest.certifierName}'),
            SpaceH4(),
            RichText(
              text: TextSpan(
                  text: '${certificationRequest.certifierPosition.toUpperCase()} -',
                  style: textTheme.bodyText1?.copyWith(
                    color: AppColors.greyAlt,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: ' ${certificationRequest.certifierCompany}',
                      style: textTheme.bodyText1?.copyWith(
                        color: AppColors.greyAlt,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ]),
            ),
            CustomTextSmall(text: '${certificationRequest.email}'),
            certificationRequest.phone != "" ? CustomTextSmall(text: '${certificationRequest.phone}') : Container(),
          ],
        ),
        SpaceH8(),
      ],
    );
  }
}
