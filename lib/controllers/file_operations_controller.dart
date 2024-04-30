import 'package:flutter/material.dart';
import '../backend/file_manager.dart';
import '../frontend/dialogs/dialog_manager.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class FileOperationsController {
  final FileManager fileManager;

  FileOperationsController(this.fileManager);

  Future<void> handleRename(
      BuildContext context, FileSystemEntity entity) async {
    String? name = await DialogManager.showRenameDialog(context, entity);
    if (name != null &&
        name.isNotEmpty &&
        name != fileManager.getEntityName(entity)) {
      String newPath = fileManager.newNameToNewPath(entity, name);
      String newName = newPath.split(Platform.pathSeparator).last;
      if (await fileManager.pathExists(newPath)) {
        final conflictResolution =
            await DialogManager.showFileConflictDialog(context, newName);
        if (conflictResolution != null && conflictResolution.isNotEmpty) {
          fileManager.renameFile(entity, conflictResolution);
        }
      } else {
        fileManager.renameFile(entity, newName);
      }
    }
  }

  Future<void> handleCreateFile(BuildContext context) async {
    String? name =
        await DialogManager.showCreateOperationDialog(context, "File");
    if (name != null && name.isNotEmpty) {
      String filePath = path.join(fileManager.directory.path, name);
      if (await fileManager.pathExists(filePath)) {
        final conflictResolution =
            await DialogManager.showFileConflictDialog(context, name);
        if (conflictResolution != null && conflictResolution.isNotEmpty) {
          fileManager.createNewFile(conflictResolution);
        }
      } else {
        fileManager.createNewFile(name);
      }
    }
  }

  Future<void> handleCreateDirectory(BuildContext context) async {
    String? name =
        await DialogManager.showCreateOperationDialog(context, "Directory");
    if (name != null && name.isNotEmpty) {
      String filePath = path.join(fileManager.directory.path, name);
      if (await fileManager.pathExists(filePath)) {
        final conflictResolution =
            await DialogManager.showFileConflictDialog(context, name);
        if (conflictResolution != null && conflictResolution.isNotEmpty) {
          fileManager.createNewDirectory(conflictResolution);
        }
      } else {
        fileManager.createNewDirectory(name);
      }
    }
  }

  Future<void> handlePaste(BuildContext context) async {
    if (fileManager.copyFileSaved.path.isNotEmpty) {
      String conflictResolutioningPath = path.join(fileManager.directory.path,
          fileManager.getEntityNameAndExtension(fileManager.copyFileSaved));

      if (fileManager.entityExists(fileManager.copyFileSaved) || 
            await fileManager.pathExists(conflictResolutioningPath)) {
        final conflictResolution = await DialogManager.showFileConflictDialog(context,
            fileManager.getEntityNameAndExtension(fileManager.copyFileSaved));
        if (conflictResolution != null && conflictResolution.isNotEmpty) {
          fileManager.copyEntity(entityName: conflictResolution);
        }
      } else {
        fileManager.copyEntity();
      }
    }
  }

  Future<void> handleMove(BuildContext context) async {
    if (fileManager.moveFileSaved.path.isNotEmpty) {
      if (fileManager.entityExists(fileManager.moveFileSaved)) return;
      String conflictResolutioningPath =
          path.join(fileManager.directory.path,
            fileManager.getEntityNameAndExtension(fileManager.moveFileSaved));

      if (await fileManager.pathExists(conflictResolutioningPath)) {
        final conflictResolution = await DialogManager.showFileConflictDialog(context,
            fileManager.getEntityNameAndExtension(fileManager.moveFileSaved));
        if (conflictResolution != null && conflictResolution.isNotEmpty) {
          fileManager.moveEntity(entityName: conflictResolution);
        }
      } else {
        fileManager.moveEntity();
      }
    }
  }

  Future<void> handleEditFileFinish(BuildContext context, String text) async {
    final response = await DialogManager.showEditFileOperationDialog(context,
        fileManager.getEntityNameAndExtension(fileManager.textFileOpened));
    if (response != null && response.isNotEmpty) {
      await fileManager.writeContent(text);
      final textFile = fileManager.textFileOpened;
      final textFileName = fileManager.getEntityNameAndExtension(textFile);
      if (response == textFileName) {
        return;
      }
      final newPath = path.join(fileManager.directory.path, response);

      if (await fileManager.pathExists(newPath) == true) {
        final conflictResolution =
            await DialogManager.showFileConflictDialog(context, response);
        if (conflictResolution != null && conflictResolution.isNotEmpty) {
          fileManager.renameFile(textFile, response);
        }
      } else {
        fileManager.renameFile(textFile, response);
      }
    }
  }
}
