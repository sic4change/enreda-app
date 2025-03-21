import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common_widgets/precached_avatar.dart';

class CompetencyTile extends StatelessWidget {
  const CompetencyTile({Key? key, required this.competency, this.status = StringConst.BADGE_CERTIFIED, this.mini = false}) : super(key: key);
  final Competency competency;
  final String status;
  final bool mini;

  @override
  Widget build(BuildContext context) {
    var containerWidth = Responsive.isMobile(context) || Responsive.isTablet(context) ? 135.0: 220.0;
    var containerHeight = Responsive.isMobile(context) || Responsive.isTablet(context) ? 160.0: 250.0;
    var imageWidth = Responsive.isMobile(context) || Responsive.isTablet(context) ? 120.0: 180.0;
    var textContainerHeight = Responsive.isMobile(context) || Responsive.isTablet(context) ? 40.0: 50.0;
    var fontSize = Responsive.isMobile(context) || Responsive.isTablet(context) ? 11.0: 16.0;
    final textTheme = Theme.of(context).textTheme;

    if (mini){
      containerWidth /= 1.6;
      containerHeight /= 1.6;
      imageWidth /= 1.6;
      textContainerHeight /= 1.9;
      fontSize /= 1.6;
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      child: Column(
        children: [
          Container(
            height: textContainerHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  competency.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: textTheme.bodyText1?.copyWith(
                      overflow: TextOverflow.ellipsis,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Constants.darkGray),
                ),
              ],
            ),
          ),
          if (competency.badgesImages[status] != null)
            !kIsWeb ? CachedNetworkImage(
                width: imageWidth,
                progressIndicatorBuilder:
                    (context, url, downloadProgress) => Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                alignment: Alignment.center,
                imageUrl: competency.badgesImages[status]!)
          : PrecacheCompetencyCard(
              imageUrl: competency.badgesImages[status]!,
              imageWidth: imageWidth,
            )
        ],
      ),
    );
  }
}
