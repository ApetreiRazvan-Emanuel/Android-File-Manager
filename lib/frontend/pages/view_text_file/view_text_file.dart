// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../backend/file_manager.dart';
import 'package:go_router/go_router.dart';
import "../../../controllers/file_operations_controller.dart";

class ViewTextFile extends StatefulWidget {
  ViewTextFile({Key? key}) : super(key: key);

  @override
  _ViewTextFileState createState() => _ViewTextFileState();
}

class _ViewTextFileState extends State<ViewTextFile> {
  final TextEditingController _controller = TextEditingController();
  bool _isEdited = false;
  late Future<void> _contentLoaded;

  @override
  void initState() {
    super.initState();
    final fileManager = Provider.of<FileManager>(context, listen: false);
    _contentLoaded = _loadFileContent(fileManager);
  }

  Future<void> _loadFileContent(FileManager fileManager) async {
    String content = await fileManager.readContent();
    _controller.text = content;
  }

  @override
  Widget build(BuildContext context) {
    final fileManager = Provider.of<FileManager>(context, listen: false);

    return FutureBuilder<void>(
      future: _contentLoaded,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildEditTextFilePage(fileManager);
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget buildEditTextFilePage(FileManager fileManager) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileManager.getEntityName(fileManager.textFileOpened)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            if (_isEdited) {
              await FileOperationsController(fileManager)
                  .handleEditFileFinish(context, _controller.text);
            }
            context.go('/home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: null,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (value) {
                  _isEdited = true;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
