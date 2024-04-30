import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../backend/file_manager.dart';
import 'top_view.dart';
import 'files_list_widget.dart';

class FileManagerHome extends StatefulWidget {
  @override
  _FileManagerHomeState createState() => _FileManagerHomeState();
}

class _FileManagerHomeState extends State<FileManagerHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fileManager = Provider.of<FileManager>(context, listen: false);

    fileManager.fetchFiles();

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('File Manager'),
      // ),
      body: Column(
        children: [
          TopView(),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey,
          ),
          Expanded(
            child: FilesListView(),
          ),
        ],
      ),
    );
  }
}
