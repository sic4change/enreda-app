import 'package:enreda_app/app/home/curriculum/tooltip_video/training_tooltip_video.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTooltip extends StatefulWidget {

  const CustomTooltip({Key? key})
      : super(key: key);

  @override
  _CustomTooltipState createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        // Position the tooltip relative to the widget
        top: Responsive.isMobile(context) ? 100
            : Responsive.isTablet(context) || Responsive.isDesktopS(context) ? 200
                : MediaQuery.of(context).size.height * 0.32,
        right: Responsive.isMobile(context) ? 20
            : Responsive.isTablet(context) || Responsive.isDesktopS(context) ? 50
                : MediaQuery.of(context).size.width * 0.25,
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(13.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.5, 0.5],
                    colors: [
                      AppColors.yellowDark,
                      AppColors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                width: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextTitle(
                        title: StringConst.TRAINING_PILL_CV,
                        color: AppColors.greenDark,
                      ),
                    ),
                    _buildTrainingTooltipVideo(context),
                  ],
                ),
              ),
              Positioned(
                top: -7,
                right: -7,
                child: IconButton(
                  hoverColor: Colors.transparent,
                    onPressed: () {
                      _overlayEntry.remove();
                    },
                    icon: Image.asset(ImagePath.ICON_INFO, width: 40, height: 40,)
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _overlayEntry.remove();
    _overlayEntry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_overlayEntry.mounted) {
          _overlayEntry.remove();
        } else {
          Overlay.of(context).insert(_overlayEntry);
        }
      },
      child: Icon(Icons.info_outline, size: 24, color: AppColors.primaryColor,),
    );
  }

  Widget _buildTrainingTooltipVideo(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<TrainingPill>(
        stream: database.trainingPillStreamById('4nggROI8bvWlOjFq45he'),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            TrainingPill trainingPill = snapshot.data!;
            trainingPill.setTrainingPillCategoryName();
            return Container(
              key: Key('trainingPill-${trainingPill.id}'),
              child: TrainingTooltipVideo(
                trainingPill: trainingPill,
              ),
            );
          } else
          return Container();
        });
  }

}

