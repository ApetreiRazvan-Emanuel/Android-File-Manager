import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../backend/file_manager.dart';
import '../../list_items/file_widget.dart';
import '../../list_items/directory_widget.dart';
import "../../../../controllers/file_operations_controller.dart";
import 'dart:io';

class FilesListView extends StatelessWidget {
  FilesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) =>
          showContextMenu(context, details.globalPosition),
      onLongPressStart: (details) =>
          showContextMenu(context, details.globalPosition),
      child: Consumer<FileManager>(
        builder: (context, fileManager, child) {
          return ListView.builder(
            itemCount: fileManager.showFiles.length,
            itemBuilder: (context, index) {
              FileSystemEntity entity = fileManager.showFiles[index];
              if (entity is Directory) {
                return DirectoryWidget(entity: entity);
              } else if (entity is File) {
                return TextFileWidget(entity: entity);
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }

  void showContextMenu(BuildContext context, Offset position) {
    final fileManager = Provider.of<FileManager>(context, listen: false);

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 'newFile',
          child: Text('New File'),
          onTap: () {
            FileOperationsController(fileManager).handleCreateFile(context);
          },
        ),
        PopupMenuItem(
          value: 'newFolder',
          child: Text('New Folder'),
          onTap: () {
            FileOperationsController(fileManager).handleCreateDirectory(context);
          },
        ),
        PopupMenuItem(
          value: 'paste',
          child: Text('Paste'),
          onTap: () {
            FileOperationsController(fileManager).handlePaste(context);
          },
        ),
        PopupMenuItem(
          value: 'move',
          child: Text('Move'),
          onTap: () {
            FileOperationsController(fileManager).handleMove(context);
          },
        ),
      ],
    );
  }
}
