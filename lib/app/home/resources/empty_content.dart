import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../../common_widgets/custom_text.dart';
import '../../../values/values.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    Key? key,
    this.title = 'Nada por ahora',
    this.message = 'Sin elementos que mostrar aún'
  }) : super(key: key);
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: Constants.mainPadding, right: Constants.mainPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomTextSmallBold(title: title!, color: AppColors.primary900,),
            CustomTextSmall(text: message!, color: AppColors.primary900,)
          ],
        ),
      ),
    );
  }
}
