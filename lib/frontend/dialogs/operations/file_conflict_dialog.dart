// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class FileConflictDialog extends StatelessWidget {
  final String fileName;
  final TextEditingController _conflictController;

  FileConflictDialog({Key? key, required this.fileName})
      : _conflictController = TextEditingController(text: fileName),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('A file with the name "$fileName" already exists.'),
          TextField(
            controller: _conflictController,
            decoration: InputDecoration(
              labelText: 'New name',
              hintText: 'Enter a new name or leave as is to replace',
            ),
            autofocus: true,
            onEditingComplete: () =>
                Navigator.of(context).pop(_conflictController.text),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Replace'),
          onPressed: () => Navigator.of(context).pop(_conflictController.text),
        ),
      ],
    );
  }
}
