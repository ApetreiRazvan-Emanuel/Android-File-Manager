// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class EditFileDialog extends StatelessWidget {
  final String fileName;
  final TextEditingController _editFileController;

  EditFileDialog({Key? key, required this.fileName})
      : _editFileController = TextEditingController(text: fileName),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Save Changes?'),
      content: TextField(
        controller: _editFileController,
        decoration: InputDecoration(
          hintText: "File name",
        ),
        autofocus: true,
        onEditingComplete: () =>
            Navigator.of(context).pop(_editFileController.text),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Submit'),
          onPressed: () => Navigator.of(context).pop(_editFileController.text),
        ),
      ],
    );
  }
}
