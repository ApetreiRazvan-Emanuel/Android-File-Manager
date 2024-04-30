// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'operations/rename_dialog.dart';
import 'operations/create_dialog.dart';
import 'operations/edit_file_dialog.dart';
import 'operations/file_conflict_dialog.dart';
import 'dart:io';

class DialogManager {
  static Future<String?> showRenameDialog(
      BuildContext context, FileSystemEntity entity) {
    String initialName = entity.path.split(Platform.pathSeparator).last;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return RenameDialog(initialName: initialName);
        });
  }

  static Future<String?> showCreateOperationDialog(
      BuildContext context, String fileType) {

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateDialog(fileType: fileType);
      },
    );
  }

  static Future<String?> showEditFileOperationDialog(
      BuildContext context, String fileName) {

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditFileDialog(fileName: fileName);
      },
    );
  }

  static Future<String?> showFileConflictDialog(
      BuildContext context, String fileName) async {

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return FileConflictDialog(fileName: fileName);
      },
    );
  }

  static void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
