import 'package:flutter/material.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../values/strings.dart';
import '../models/file_data.dart';

class FilesPicker extends StatefulWidget {
  final BuildContext context;
  final List<FileData> filesList;
  final Future<void> Function() onTap;
  final void Function(FileData) onDeleteDocument;

  FilesPicker({
    required this.context,
    required this.filesList,
    required this.onTap,
    required this.onDeleteDocument,
  });

  @override
  _FilesPickerState createState() => _FilesPickerState();
}

class _FilesPickerState extends State<FilesPicker> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onTap,
      child: Row(
        children: [
          Icon(Icons.add),
          CustomTextBold(title: StringConst.ADD_DOC)
        ],
      ),
    );
  }
}

