import 'package:enreda_app/app/home/competencies/competency_tile.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ExpandedCompetencyTile extends StatefulWidget {
  const ExpandedCompetencyTile(
      {Key? key,
      required this.competency,
      this.status = StringConst.BADGE_CERTIFIED})
      : super(key: key);
  final Competency competency;
  final String status;

  @override
  State<ExpandedCompetencyTile> createState() => _ExpandedCompetencyTileState();
}

class _ExpandedCompetencyTileState extends State<ExpandedCompetencyTile> {
  final controller = ExpandableController();
  String imagePath = ImagePath.ARROW_DOWN;

  @override
  void initState() {
    controller.addListener(() {
      setState(() {
        imagePath =
            controller.expanded ? ImagePath.ARROW_UP : ImagePath.ARROW_DOWN;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: Responsive.isMobile(context) ? 315.0 : 464.0,
      width: Responsive.isMobile(context) ? 150.0 : 260.0,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: AppColors.altWhite,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: AppColors.blue050,
          ) ,
          ),
      child: Column(
        children: [
          CompetencyTile(
            competency: widget.competency,
            status: widget.status,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.competency.description,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: Responsive.isMobile(context) ? 10.0 : 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
