import 'package:enreda_app/app/home/curriculum/tooltip_video/training_tooltip_video.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PillTooltip extends StatefulWidget {

  const PillTooltip({
    Key? key,
    required this.title,
    required this.pillId,
    
  }) : super(key: key);
  
  final String title, pillId;

  @override
  _PillTooltipState createState() => _PillTooltipState();
}

class _PillTooltipState extends State<PillTooltip> {
  late OverlayEntry _overlayEntry;

  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(builder: (context) {
      RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);
      double y = position.dy;
      double x = position.dx;

      if (x + 300 > MediaQuery.of(context).size.width) x -= 260;
      if (y + 300 > MediaQuery.of(context).size.height) y -= 180;

      return Positioned(
        // Position the tooltip relative to the widget
        top: Responsive.isMobile(context)? (MediaQuery.of(context).size.height * 0.5) - 150
          : y - 20,
        /*top: Responsive.isMobile(context) ? 100
            : Responsive.isTablet(context) || Responsive.isDesktopS(context) ? 200
                : MediaQuery.of(context).size.height * 0.32,*/
        left: Responsive.isMobile(context)? (MediaQuery.of(context).size.width * 0.5) - 150
            : x - 20,
        /*right: x - 20,Responsive.isMobile(context) ? 20
            : Responsive.isTablet(context) || Responsive.isDesktopS(context) ? 50
                : MediaQuery.of(context).size.width * 0.25,*/
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
                        title: widget.title,
                        color: AppColors.greenDark,
                      ),
                    ),
                    _buildTrainingTooltipVideo(context),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  hoverColor: Colors.transparent,
                    onPressed: () {
                      _overlayEntry.remove();
                    },
                    icon: Icon(Icons.close), iconSize: 20,
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
    _overlayEntry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: key,
      onTap: () {
        if (Responsive.isMobile(context)) {
          showDialog(context: context, useRootNavigator: false, builder: (dialogContext) =>
              Dialog(
                backgroundColor: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTrainingTooltipVideo(dialogContext),
                  ],
                          ),));
        } else {
          if (_overlayEntry.mounted) {
            _overlayEntry.remove();
          } else {
            Overlay.of(context).insert(_overlayEntry);
          }
        }
      },
      child: Icon(Icons.info_outline, size: 24, color: AppColors.primaryColor,),
    );
  }

  Widget _buildTrainingTooltipVideo(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<TrainingPill>(
        stream: database.trainingPillStreamById(widget.pillId),
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

