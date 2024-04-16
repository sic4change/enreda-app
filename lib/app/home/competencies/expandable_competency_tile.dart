import 'package:enreda_app/app/home/competencies/competency_tile.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ExpandableCompetencyTile extends StatefulWidget {
  const ExpandableCompetencyTile({
    Key? key,
    required this.competency,
    this.status = StringConst.BADGE_CERTIFIED
  }) : super(key: key);
  final Competency competency;
  final String status;

  @override
  State<ExpandableCompetencyTile> createState() =>
      _ExpandableCompetencyTileState();
}

class _ExpandableCompetencyTileState extends State<ExpandableCompetencyTile> {
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
    final imageSize = 20.0;

    return InkWell(
      onTap: () {
        controller.toggle();
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: Responsive.isMobile(context) ? 135.0 : 220.0,
                margin: Responsive.isMobile(context) ? EdgeInsets.only(bottom: imageSize) : EdgeInsets.only(
                    top: 4.0, left: 4.0, right: 4.0, bottom: imageSize),
                padding: Responsive.isMobile(context) ? EdgeInsets.all(8.0) : EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ]),
                child: ExpandablePanel(
                  controller: controller,
                  header: CompetencyTile(
                    competency: widget.competency,
                    status: widget.status,
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      widget.competency.description,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: Responsive.isMobile(context) ? 8.0 : 14.0,
                      ),
                    ),
                  ),
                  collapsed: Container(),
                  theme: ExpandableThemeData(
                    hasIcon: false,
                  ),
                ),
              ),
              Positioned(
                  bottom: (imageSize / 2) - 5,
                  left: 1,
                  right: 1,
                  child: Container(
                      width: imageSize + 10.0,
                      height: imageSize + 10.0,
                      padding: EdgeInsets.all(imageSize / 2),
                      decoration: BoxDecoration(
                          border: Border.all(color: Constants.lightGray, width: 1),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child: Image.asset(
                        imagePath,
                        color: Constants.turquoise,
                      ))),
            ],
          ),
        ],
      ),
    );
  }
}
