// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class RenameDialog extends StatelessWidget {
  final String initialName;
  final TextEditingController _fileConflictController;

  RenameDialog({Key? key, required this.initialName})
      : _fileConflictController = TextEditingController(text: initialName),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rename File'),
      content: TextField(
        controller: _fileConflictController,
        decoration: InputDecoration(hintText: "Enter new name"),
        autofocus: true,
        onEditingComplete: () => Navigator.of(context).pop(_fileConflictController.text),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Rename'),
          onPressed: () => Navigator.of(context).pop(_fileConflictController.text),
        ),
      ],
    );
  }
}
