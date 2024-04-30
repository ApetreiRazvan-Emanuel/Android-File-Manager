import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../backend/file_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

class PathSelectionPage extends StatefulWidget {
  @override
  _PathSelectionPageState createState() => _PathSelectionPageState();
}

class _PathSelectionPageState extends State<PathSelectionPage> {
  final TextEditingController _controller = TextEditingController();
  String _buttonText = 'Confirm';
  bool _isValidPath = true;
  bool _isCheckingPath = false;

  Future<void> _checkPathAndUpdate(String path) async {
    if (_isCheckingPath) return;

    setState(() {
      _isCheckingPath = true;
    });

    bool exists = await Directory(path).exists();

    setState(() {
      _isValidPath = exists;
      _buttonText = exists ? 'Confirm' : 'Invalid directory';
      _isCheckingPath = false;
    });
  }

  Future<void> _getApplicationDocumentsDirectory() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    _controller.text = documentsDirectory.path;
  }

  @override
  Widget build(BuildContext context) {
    final fileManager = Provider.of<FileManager>(context, listen: false);
    return FutureBuilder<void>(
        future: _getApplicationDocumentsDirectory(),
        builder: (context, snapshot) {
          return Scaffold(
              // appBar: AppBar(title: Text('Select Starting Path')),
              body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: AlertDialog(
                  title: Text('Select Starting Path'),
                  content: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Starting Path'),
                    onChanged: (path) {
                      _checkPathAndUpdate(path);
                    },
                    onEditingComplete: (!_isCheckingPath && _isValidPath)
                        ? () {
                            fileManager.updateDirectory(_controller.text);
                            context.go('/home');
                          }
                        : null,
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: Text("Documents"),
                        onPressed: () async {
                          Directory d =
                              await getApplicationDocumentsDirectory();
                          fileManager.updateDirectory(d.path);
                          context.go('/home');
                        }),
                    TextButton(
                      child: Text(_buttonText),
                      onPressed: (!_isCheckingPath && _isValidPath)
                          ? () {
                              fileManager.updateDirectory(_controller.text);
                              context.go('/home');
                            }
                          : null,
                    ),
                  ]),
            ),
          ));
        });
  }
}
