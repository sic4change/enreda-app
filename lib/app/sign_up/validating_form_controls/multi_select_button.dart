import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

import '../../../utils/adaptive.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog({Key? key, this.items, this.initialSelectedValues}) : super(key: key);

  final List<MultiSelectDialogItem<V>>? items;
  final Set<V>? initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final pselectedValues = Set<V>();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      for (var itemValue in widget.initialSelectedValues!) {
        pselectedValues.add(itemValue);
      }
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked == false && this.pselectedValues.where((e) => e  == itemValue).length > 0) {
        this.pselectedValues.removeWhere((e) => e  == itemValue);
        print(pselectedValues);
      }
      else
        this.pselectedValues.add(itemValue);
    });
  }

  void _onSubmitTap() {
    Navigator.pop(context, pselectedValues);
    print(pselectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(StringConst.FORM_SELECT),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items!.map(_buildItem).toList(),
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
    final bool checked = pselectedValues.where((e) => e  == item.value).length > 0;
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
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked!),
    );
  }
}