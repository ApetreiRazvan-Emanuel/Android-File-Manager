// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CreateDialog extends StatelessWidget {
  final String fileType;
  final TextEditingController _createController = TextEditingController();

  CreateDialog({Key? key, required this.fileType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create $fileType'),
      content: TextField(
        controller: _createController,
        decoration: InputDecoration(
          hintText: "Enter $fileType name",
        ),
        autofocus: true,
        onEditingComplete: () =>
            Navigator.of(context).pop(_createController.text),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Create'),
          onPressed: () => Navigator.of(context).pop(_createController.text),
        ),
      ],
    );
  }
}
