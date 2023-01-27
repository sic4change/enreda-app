import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

class FilterTextFieldRow extends StatefulWidget {
  const FilterTextFieldRow(
      {Key? key,
      required this.searchTextController,
      required this.onFieldSubmitted,
      required this.onPressed,
      required this.clearFilter})
      : super(key: key);

  final TextEditingController searchTextController;
  final void Function(String) onFieldSubmitted;
  final void Function() onPressed;
  final void Function() clearFilter;

  @override
  State<FilterTextFieldRow> createState() => _FilterTextFieldRowState();
}

class _FilterTextFieldRowState extends State<FilterTextFieldRow> {
  bool _isClearTextVisible = false;
  String _hintText = 'Nombre del recurso, organizador, país...';

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    widget.searchTextController.addListener(() {
      if (widget.searchTextController.text.isNotEmpty && !_isClearTextVisible) {
        setState(() {
          _isClearTextVisible = true;
        });
      } else if (widget.searchTextController.text.isEmpty &&
          _isClearTextVisible) {
        setState(() {
          _isClearTextVisible = false;
        });
      }
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _hintText.isNotEmpty) {
        setState(() {
          _hintText = '';
        });
      } else if (!_focusNode.hasFocus && _hintText.isEmpty) {
        setState(() {
          _hintText = 'Nombre del recurso, organizador, país...';
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double margin = Responsive.isDesktop(context) ? 48.0 : 12.0;
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 15, 16, md: 15);
    return Row(
      children: [
        Expanded(
          child: RoundedContainer(
            height: Responsive.isMobile(context) ? 40 : 45,
            padding: const EdgeInsets.only(left: 8.0, top: 0.0, right: 8.0, bottom: 0.0),
            margin: EdgeInsets.only(left: margin, right: margin),
            child: Row(children: [
              SpaceW16(),
              Expanded(
                child: TextFormField(
                    onFieldSubmitted: widget.onFieldSubmitted,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: _hintText,
                      border: InputBorder.none,
                    ),
                    controller: widget.searchTextController,
                    keyboardType: TextInputType.text,
                    style: textTheme.bodyText1?.copyWith(
                      color: AppColors.greyAlt,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                    ),
                ),
              ),
              if (_isClearTextVisible)
                IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.clear, color: Constants.darkGray),
                  onPressed: widget.clearFilter,
                ),
              if (!_isClearTextVisible)
              IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.search, color: Constants.darkGray),
                onPressed: widget.onPressed,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
