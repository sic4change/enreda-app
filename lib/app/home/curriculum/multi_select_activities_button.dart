import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

import '../../../utils/adaptive.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label, this.title);

  final V value;
  final String label;
  final String title;
}

class MultiSelectActivitiesDialog<V> extends StatefulWidget {
  MultiSelectActivitiesDialog({
    Key? key,
    this.itemsSet,
    this.initialSelectedValuesSet,
    required this.onTextChanged,
  }) : super(key: key);

  final Set<List<MultiSelectDialogItem<V>>>? itemsSet;
  final Set<V>? initialSelectedValuesSet;
  final Function(String text) onTextChanged;

  @override
  State<StatefulWidget> createState() => _MultiSelectActivitiesDialogState<V>();
}

class _MultiSelectActivitiesDialogState<V> extends State<MultiSelectActivitiesDialog<V>> {
  final selectedValuesSet = Set<V>();

  late Widget? otherWidget;
  bool isOtherChecked = false;
  final _otherController = TextEditingController(text: "");

  void initState() {
    super.initState();
    if (widget.initialSelectedValuesSet != null) {
      for (var itemValue in widget.initialSelectedValuesSet!) {
        selectedValuesSet.add(itemValue);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);

    otherWidget = Text("Otras",
      style: textTheme.button?.copyWith(
        height: 1.5,
        color: AppColors.greyDark,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      ),);
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked == false && this.selectedValuesSet.where((e) => e  == itemValue).length > 0) {
        this.selectedValuesSet.removeWhere((e) => e  == itemValue);
        print(selectedValuesSet);
      }
      else
        this.selectedValuesSet.add(itemValue);
    });
  }

  void _onSubmitTap() {
    Navigator.of(context, rootNavigator: true).pop(this.selectedValuesSet);
    if (_otherController.text.isNotEmpty)
      widget.onTextChanged(_otherController.text);
    setState(() {
      this.selectedValuesSet;
    });
    print(this.selectedValuesSet);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);

    return AlertDialog(
      title: Text(StringConst.FORM_SELECT, style: textTheme.bodyText2?.copyWith(
        height: 1.5,
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
      ),),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: Column(
              children: <Widget> [
                for (List<MultiSelectDialogItem<V>> items in widget.itemsSet!)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                        child: Text(items[0].title, style: textTheme.bodyText1?.copyWith(
                          height: 1.5,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: fontSize,
                        ),),
                      ),
                      ListBody(
                        children: items.map(_buildItem).toList(),
                      ),
                    ],
                  ),
                Theme(
                  data: ThemeData(),
                  child: CheckboxListTile(
                      activeColor: AppColors.primaryColor,
                      value: isOtherChecked,
                      title: otherWidget,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) {
                        setState(() {
                          isOtherChecked = !isOtherChecked;
                          if (isOtherChecked) {
                            otherWidget = TextFormField(
                              controller: _otherController,
                              style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: "Escribe tu respuesta...",
                                hintStyle: textTheme.caption,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor),
                                ),
                              ),
                            );
                          } else {
                            otherWidget = Text("Otras",
                              style: textTheme.button?.copyWith(
                                height: 1.5,
                                color: AppColors.greyDark,
                                fontWeight: FontWeight.w400,
                                fontSize: fontSize,
                              ),);
                            _otherController.text = "";
                          }
                        });
                      }, //=> _onItemCheckedChange(item.value, checked!),
                  ),
                ),
              ]
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(StringConst.FORM_ACCEPT, style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold)),
          ),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final bool checked = selectedValuesSet.where((e) => e  == item.value).length > 0;
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return CheckboxListTile(
      value: checked,
      title: Text(item.label,
        style: textTheme.button?.copyWith(
          height: 1.5,
          color: AppColors.greyDark,
          fontWeight: FontWeight.w400,
          fontSize: fontSize,
        ), ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked!),
    );
  }
}