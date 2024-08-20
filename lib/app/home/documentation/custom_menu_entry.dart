import 'package:flutter/material.dart';

import '../../../../values/values.dart';
import '../../../common_widgets/custom_text.dart';
import '../models/documentationParticipant.dart';
import 'menu_item.dart';

class CustomPopupMenuEntry extends PopupMenuItem<MenuItem> {
  CustomPopupMenuEntry({required Widget? child, required DocumentationParticipant this.documentationParticipant}) : super(child: child);
  final DocumentationParticipant documentationParticipant;

  @override
  double get height => 48; // Set the desired height of the entry

  @override
  bool represents(MenuItem? value) => false; // Return false if this entry represents a MenuItem

  @override
  PopupMenuItemState<MenuItem, CustomPopupMenuEntry> createState() => _CustomPopupMenuEntryState();
}

class _CustomPopupMenuEntryState extends PopupMenuItemState<MenuItem, CustomPopupMenuEntry> {

  @override
  void handleTap() {
    // Implement the logic for handling the tap event here
    super.handleTap();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        width: 180,
        alignment: Alignment.center,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
              child: CustomTextSmall(text: widget.documentationParticipant.name, color: AppColors.primary900,),
            ),
            Divider(color: AppColors.primaryText2, thickness: 0, height: 0,),
          ],
        )
    );
  }
}

class CustomPopupMenuDivider extends StatelessWidget {
  final Color color;

  CustomPopupMenuDivider({this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: color,
      margin: EdgeInsets.symmetric(vertical: 4),
    );
  }
}