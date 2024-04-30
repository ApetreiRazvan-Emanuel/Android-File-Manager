import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../backend/file_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'base_list_widget.dart';

class DirectoryWidget extends FileListWidget {
  DirectoryWidget({Key? key, required FileSystemEntity entity})
      : super(key: key, entity: entity);

  @override
  Widget build(BuildContext context) {
    final fileManager = Provider.of<FileManager>(context, listen: false);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Directory oldDirectory = fileManager.directory;
          fileManager.directory = entity as Directory;
          fileManager.paths.add(entity as Directory);
          await fileManager.fetchFiles();
          if (fileManager.hasError) {
            fileManager.hasError = false;
            fileManager.directory = oldDirectory;
            fileManager.paths.removeLast();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("An error has occured: ${fileManager.errorMessage}"),
              ),
            );
          }
          ;
        },
        hoverColor: Colors.grey[850],
        child: GestureDetector(
          onSecondaryTapDown: (details) {
            showContextMenu(context, details.globalPosition);
          },
          onLongPressEnd: (details) {
            showContextMenu(context, details.globalPosition);
          },
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            leading: Icon(Icons.folder),
            title: Text(entity.path.split(Platform.pathSeparator).last),
            subtitle: buildFileStatWidget(),
          ),
        ),
      ),
    );
  }

  Widget buildFileStatWidget() {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            if (snapshot.error is FileSystemException) {
              final error = snapshot.error as FileSystemException;
              if (error.osError?.errorCode == 5) {
                return Text('Failed to get details - Access denied');
              }
              return Text('Error: ${error.message}');
            }
            return Text('Error: ${snapshot.error}');
          } else {
            final modified = snapshot.data!.modified;
            final dateString = DateFormat('yyyy-MM-dd HH:mm').format(modified);
            return FutureBuilder<int>(
              future: _getFileCount(),
              builder: (context, fileCountSnapshot) {
                if (fileCountSnapshot.connectionState == ConnectionState.done) {
                  if (fileCountSnapshot.hasError) {
                    return Text('Failed to get file count');
                  }
                  return Text('$dateString - ${fileCountSnapshot.data} Files');
                } else {
                  // return CircularProgressIndicator();
                  return Container();
                }
              },
            );
          }
        } else {
          // return CircularProgressIndicator();
          return Container();
        }
      },
    );
  }

  Future<int> _getFileCount() async {
    final dir = Directory(entity.path);
    final count = await dir.list().length;
    return count;
  }
}
