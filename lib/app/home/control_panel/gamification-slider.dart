import 'package:enreda_app/app/home/models/gamificationFlags.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamificationSlider extends StatelessWidget {
  const GamificationSlider({
    super.key,
    this.height = 6.0,
    required this.value,
  });

  final double height;
  final int value;

  @override
  Widget build(BuildContext context) {
    // pulling flags from memory cache instead of a new Firestore subscription
    final flags = LocationCache.instance.gamificationFlags;
    final int maxValue = flags.isNotEmpty ? flags.length : 15; // default to 15 if cache not yet warm
    final double sliderValue = value / maxValue;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        disabledActiveTrackColor: AppColors.primary400,
        disabledInactiveTrackColor: AppColors.primary060,
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: height,
        disabledThumbColor: AppColors.yellowDark,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: height),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),),
      child: Slider(
        value: sliderValue,
        onChanged: null,
      ),
    );
  }
}