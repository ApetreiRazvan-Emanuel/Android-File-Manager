// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:io';
import '../../backend/file_manager.dart';
import 'package:provider/provider.dart';
import '../dialogs/dialog_manager.dart';
import "../../controllers/file_operations_controller.dart";

abstract class FileListWidget extends StatelessWidget {
  final FileSystemEntity entity;

  FileListWidget({Key? key, required this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget buildFileStatWidget();

  void showContextMenu(BuildContext context, Offset position) {
    final fileManager = Provider.of<FileManager>(context, listen: false);
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
          onTap: () {
            try {
              Provider.of<FileManager>(context, listen: false).deleteEntity(entity);
            } on FileSystemException catch (e) {
              DialogManager.showErrorDialog(context,
                  'Failed to delete ${entity.path}. Reason: ${e.message}');
            }
          },
        ),
        PopupMenuItem(
          value: 'rename',
          child: Text('Rename'),
          onTap: () {
            FileOperationsController(fileManager).handleRename(context, entity);
          },
        ),
        PopupMenuItem(
          value: 'move',
          child: Text('Move'),
          onTap: () async {
            fileManager.moveFileSaved = await fileManager.pathToEntity(entity.path);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("File saved to clipboard!"),
              ),
            );
          },
        ),
        PopupMenuItem(
          value: 'copy',
          child: Text('Copy'),
          onTap: () async {
            fileManager.copyFileSaved = await fileManager.pathToEntity(entity.path);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("File saved to clipboard!"),
              ),
            );
          },
        ),
      ],
    ).then((value) {
    });
  }
}
