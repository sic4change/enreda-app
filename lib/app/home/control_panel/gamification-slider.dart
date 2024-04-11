import 'package:enreda_app/app/home/models/gamificationFlags.dart';
import 'package:enreda_app/services/database.dart';
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
    final database = Provider.of<Database>(context, listen: false);
    late int? maxValue;
    late double sliderValue = 0;

    return StreamBuilder<List<GamificationFlag>>(
        stream: database.gamificationFlagsStream(),
        builder: (context, gamificationSnapshot) {
          if (gamificationSnapshot.hasData) {
            maxValue = gamificationSnapshot.data!.length - 2;
            //maxValue = gamificationSnapshot.data!.length - 3;
            sliderValue = value / maxValue!;
          }

          return SliderTheme(
            data: SliderTheme.of(context).copyWith(
              disabledActiveTrackColor: AppColors.turquoise,
              disabledInactiveTrackColor: AppColors.turquoiseLight,
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
    );
  }
}