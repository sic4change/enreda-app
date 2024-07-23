import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class GamificationItem extends StatelessWidget {
  const GamificationItem({
    super.key,
    this.size = 140,
    this.progress = 0,
    this.progressText,
    this.imageSize = 100,
    required this.imagePath,
    required this.title,
  });

  final double size, imageSize, progress;
  final String imagePath, title;
  final String? progressText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        CircularSeekBar(
          height: !Responsive.isDesktop(context) ? size/2 : size,
          width: !Responsive.isDesktop(context) ? size/2 : size,
          startAngle: 45,
          sweepAngle: 270,
          progress: progress,
          barWidth: !Responsive.isDesktop(context) ? 5 : 10,
          progressColor: AppColors.darkYellow,
          innerThumbStrokeWidth: !Responsive.isDesktop(context) ? 5 : 10,
          innerThumbColor: AppColors.darkYellow,
          outerThumbColor: Colors.transparent,
          trackColor: AppColors.lightYellow,
          strokeCap: StrokeCap.round,
          animation: true,
          animDurationMillis: 1500,
          interactive: false,
          child: Padding(
            padding: EdgeInsets.only(top: !Responsive.isDesktop(context) ? 4.0 : 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: !Responsive.isDesktop(context) ? imageSize/2.8 : imageSize,
                  height: !Responsive.isDesktop(context) ? imageSize/2.8 : imageSize,
                ),
                if (!Responsive.isDesktop(context))
                  SpaceH4(),
                if (progressText != null)
                  Text(
                    progressText!,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primary900,
                      fontSize: !Responsive.isDesktop(context) ? textTheme.titleLarge!.fontSize!/1.8 : textTheme.titleLarge!.fontSize!,
                    ),
                  ),
                if (progressText == null)
                  SpaceH8(),
              ],
            ),
          ),
        ),
        Container(
          width: !Responsive.isDesktop(context)? (size/2) + 20:size + 40,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.primary900,
              fontSize: !Responsive.isDesktop(context)? textTheme.bodySmall!.fontSize!/1.2:textTheme.bodySmall!.fontSize!,
            ),
          ),
        ),
      ],
    );
  }
}