import 'package:enreda_app/common_widgets/rounded_container_filter.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

class FilterTextFieldRow extends StatefulWidget {
   FilterTextFieldRow(
      {Key? key,
      required this.searchTextController,
      required this.onFieldSubmitted,
      required this.onPressed,
      required this.clearFilter,
      required this.hintText,
      })
      : super(key: key);

  final TextEditingController searchTextController;
  final void Function(String) onFieldSubmitted;
  final void Function() onPressed;
  final void Function() clearFilter;
  late String hintText;

  @override
  State<FilterTextFieldRow> createState() => _FilterTextFieldRowState();
}

class _FilterTextFieldRowState extends State<FilterTextFieldRow> {
  bool _isClearTextVisible = false;

  FocusNode _focusNode = FocusNode();

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    widget.searchTextController.addListener(() {
      if (widget.searchTextController.text.isNotEmpty && !_isClearTextVisible) {
        setStateIfMounted(() {
          _isClearTextVisible = true;
        });
      } else if (widget.searchTextController.text.isEmpty &&
          _isClearTextVisible) {
        setStateIfMounted(() {
          _isClearTextVisible = false;
        });
      }
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.hintText.isNotEmpty) {
        setStateIfMounted(() {
          widget.hintText = '';
        });
      } else if (!_focusNode.hasFocus && widget.hintText.isEmpty) {
        setStateIfMounted(() {
          widget.hintText = widget.hintText;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 15, 16, md: 15);
    return Container(
      margin: Responsive.isMobile(context)
          ? EdgeInsets.symmetric(horizontal: 10)
          : Responsive.isDesktopS(context)
          ? EdgeInsets.symmetric(horizontal: 30)
          : EdgeInsets.symmetric(horizontal: 100),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: RoundedContainerFilter(
              height: Responsive.isMobile(context) ? 40 : 45,
              padding: Responsive.isMobile(context) ? EdgeInsets.all(0) : EdgeInsets.all(8),
              margin: EdgeInsets.only(left: 5, right: 5),
              child: Row(children: [
                SpaceW16(),
                Expanded(
                  child: TextFormField(
                      onFieldSubmitted: widget.onFieldSubmitted,
                      textInputAction: TextInputAction.done,
                      textAlignVertical: TextAlignVertical.center,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        border: InputBorder.none,
                      ),
                      controller: widget.searchTextController,
                      keyboardType: TextInputType.text,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.greyAlt,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize,
                      ),
                  ),
                ),
                if (_isClearTextVisible)
                  IconButton(
                    padding: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.clear, color: Constants.darkGray),
                    onPressed: widget.clearFilter,
                  ),
                if (!_isClearTextVisible)
                IconButton(
                  padding: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.search, color: Constants.darkGray),
                  onPressed: widget.onPressed,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
