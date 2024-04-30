// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../backend/file_manager.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

class TopView extends StatelessWidget {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final fileManager = Provider.of<FileManager>(context, listen: false);

    return Column(
      children: [
        ListTile(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (fileManager.paths.length > 1) {
                fileManager.paths.removeLast();
                String oldPath = fileManager.directory.path;
                String newPath = oldPath.substring(
                    0, oldPath.lastIndexOf(Platform.pathSeparator));
                fileManager.directory = Directory(newPath);
                fileManager.fetchFiles();
              } else {
                context.go('/starting_page');
              }
            },
          ),
          title: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
            ),
            onChanged: (text) {
              fileManager.searchFiles(text);
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              fileManager.searchFiles(searchController.text);
            },
          ),
        ),
        ListTile(
          leading: Icon(Icons.folder_open),
          title: SizedBox(
              height: 50.0,
              child: Consumer<FileManager>(
                builder: (context, fileManager, child) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: fileManager.paths.length,
                    separatorBuilder: (context, index) =>
                        Icon(Icons.arrow_right),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        alignment: Alignment.center,
                        child: TextButton(
                            onPressed: () {
                              fileManager.directory = fileManager.paths[index];
                              fileManager.paths.removeRange(
                                  index + 1, fileManager.paths.length);
                              fileManager.fetchFiles();
                            },
                            child: Text(
                              fileManager
                                  .getEntityName(fileManager.paths[index]),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            )),
                      );
                    },
                  );
                },
              )),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: Icon(Icons.swap_vert),
                  tooltip: "Reverse order",
                  onPressed: () {
                    fileManager.reversed = !(fileManager.reversed);
                    fileManager.reverseFiles();
                    fileManager.notify();
                  }),
              PopupMenuButton<SortOrder>(
                tooltip: "Sort",
                onSelected: (SortOrder result) {
                  fileManager.changeSortOrder(result);
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<SortOrder>>[
                  const PopupMenuItem<SortOrder>(
                    value: SortOrder.type,
                    child: Text('Type'),
                  ),
                  const PopupMenuItem<SortOrder>(
                    value: SortOrder.name,
                    child: Text('Name'),
                  ),
                  const PopupMenuItem<SortOrder>(
                    value: SortOrder.date,
                    child: Text('Date'),
                  ),
                  const PopupMenuItem<SortOrder>(
                    value: SortOrder.size,
                    child: Text('Size'),
                  ),
                ],
                icon: Icon(Icons.filter_list),
              ),
            ],
          ),
        )
      ],
    );
  }
}
