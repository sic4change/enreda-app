import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';
import '../../../common_widgets/custom_text.dart';
import '../models/documentCategory.dart';
import '../models/userEnreda.dart';
import 'document_category_tile.dart';

class ExpandableDocCategoryTile extends StatefulWidget {
  const ExpandableDocCategoryTile({
    Key? key,
    required this.documentCategory,
    required this.participantUser,
  }) : super(key: key);
  final DocumentCategory documentCategory;
  final UserEnreda participantUser;

  @override
  State<ExpandableDocCategoryTile> createState() =>
      _ExpandableDocCategoryTileState();
}

class _ExpandableDocCategoryTileState extends State<ExpandableDocCategoryTile> {
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
    List<DocumentCategory> documentCategories = [];
    documentCategories.add(widget.documentCategory);
    return InkWell(
      onTap: () {
        controller.toggle();
      },
      child: Stack(
        children: [
          Container(
            child: ExpandablePanel(
              theme:  ExpandableThemeData(
                hasIcon: false,
              ),
              controller: controller,
              header: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: AppColors.greySearch,
                      padding: Responsive.isMobile(context) ? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0) :
                      const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
                      child: CustomTextChip(text: '${(widget.documentCategory.name)}', color: AppColors.primary900),
                    ),
                    Divider(thickness: 1, height: 0, color: AppColors.grey400,),
                  ],
                ),
              ),
              expanded: DocumentCategoryTile(
                documentCategory: widget.documentCategory,
                participantUser: widget.participantUser,
              ),
              collapsed: Container(),
            ),
          ),
          Positioned(
              top: Responsive.isMobile(context) ? 5 : 15,
              right: Responsive.isMobile(context) ?  10 : 35,
              child: Row(
                children: [
                  Container(
                      width: Responsive.isMobile(context) ? 26 : 30,
                      height: Responsive.isMobile(context) ? 26 : 30,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        //border: Border.all(color: AppColors.greyBorder, width: 1),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child: Image.asset(
                        imagePath,
                        color: AppColors.primary900,
                      )),
                  SizedBox(width: 20),
                ],
              )),
        ],
      ),
    );
  }
}
