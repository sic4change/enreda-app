import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class ReferenceTile extends StatelessWidget {
  const ReferenceTile({Key? key, required this.certificationRequest})
      : super(key: key);
  final CertificationRequest certificationRequest;

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 13, 14, md: 14);
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
                  style: textTheme.bodySmall?.copyWith(),
                  children: [
                    TextSpan(
                      text: ' ${certificationRequest.certifierCompany}',
                      style: textTheme.bodySmall?.copyWith(),
                    )
                  ]),
            ),
            SpaceH4(),
            Row(
              children: [
                Icon(
                  Icons.mail,
                  color: AppColors.greyDark,
                  size: 12.0,
                ),
                SpaceW4(),
                Text(
                  '${certificationRequest.email}',
                  style: textTheme.bodySmall?.copyWith(
                  ),
                ),
              ],
            ),
            SpaceH4(),
            certificationRequest.phone != "" ? Row(
              children: [
                Icon(
                  Icons.phone,
                  color: AppColors.greyDark,
                  size: 12.0,
                ),
                SpaceW4(),
                Text(
                  '${certificationRequest.phone}',
                  style: textTheme.bodySmall?.copyWith(
                  ),
                ),
              ],
            ) : Container(),
          ]
        ),
        SpaceH8(),
      ],
    );
  }
}
