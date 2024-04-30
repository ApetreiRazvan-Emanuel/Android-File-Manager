import 'package:flutter/material.dart';
import 'base_list_widget.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../backend/file_manager.dart';
import 'package:provider/provider.dart';

class TextFileWidget extends FileListWidget {
  TextFileWidget({Key? key, required FileSystemEntity entity})
      : super(key: key, entity: entity);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final fileManager = Provider.of<FileManager>(context, listen: false);
          fileManager.textFileOpened = entity as File;
          context.go('/view_txt_file');
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
            leading: Icon(Icons.description),
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
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final modified = snapshot.data!.modified;
          final size = snapshot.data!.size;
          final dateString = DateFormat('yyyy-MM-dd HH:mm').format(modified);
          final sizeString = '${(size / 1024).toStringAsFixed(2)} KB';
          return Text('$dateString - $sizeString');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // return CircularProgressIndicator();
          return Container();
        }
      },
    );
  }
}
