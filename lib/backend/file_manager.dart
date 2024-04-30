import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

enum SortOrder { type, name, date, size }

class FileManager extends ChangeNotifier {
  late Directory directory;
  List<FileSystemEntity> files = [];
  List<FileSystemEntity> showFiles = [];
  late List<Directory> paths = List.empty(growable: true);
  bool reversed = false;
  SortOrder sortOrder = SortOrder.type;
  late FileSystemEntity moveFileSaved;
  late FileSystemEntity copyFileSaved;
  late File textFileOpened;
  bool hasError = false;
  String errorMessage = "";

  FileManager({String? path}) {
    if (path != null) {
      directory = Directory(path);
    } else {
      directory = Directory("");
    }
    moveFileSaved = Directory("");
    copyFileSaved = Directory("");
    textFileOpened = File("");
  }

  void updateDirectory(String newPath) {
    directory = Directory(newPath);
    paths.clear();
    paths.add(Directory(newPath));
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  void changeSortOrder(SortOrder newOrder) {
    sortOrder = newOrder;
    sortFiles();
  }

  Future<void> fetchFiles() async {
    try {
      List<FileSystemEntity> entries = await directory.list().toList();
      files = entries.map((entry) {
        if (entry is Directory) {
          return Directory(entry.path);
        } else {
          return File(entry.path);
        }
      }).toList();
      showFiles = List.from(files);
      sortFiles();
      notifyListeners();
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
    }
  }

  Future<FileSystemEntity> pathToEntity(String path) async {
    FileSystemEntity file;
    if (await FileSystemEntity.type(path) == FileSystemEntityType.directory) {
      file = Directory(path);
    } else {
      file = File(path);
    }
    return file;
  }

  String getEntityNameAndExtension(FileSystemEntity entity) {
    return entity.path.split(Platform.pathSeparator).last;
  }

  String getEntityName(FileSystemEntity entity) {
    String name =
        entity.path.split(Platform.pathSeparator).last.split(".").first;
    if (name.isEmpty) {
      name = entity.path;
    }
    return name;
  }

  Future<bool> pathExists(String filePath) async {
    var fileSystemEntity = FileSystemEntity.typeSync(filePath);
    if (fileSystemEntity == FileSystemEntityType.notFound) {
      return false;
    } else {
      return true;
    }
  }

  String newNameToNewPath(FileSystemEntity entity, String newName) {
    String path = entity.path
        .substring(0, entity.path.lastIndexOf(Platform.pathSeparator) + 1);
    if (newName.contains(".") || !entity.path.contains(".")) {
      path = path + newName;
    } else {
      String extension = entity.path.substring(entity.path.lastIndexOf("."));
      path = path + newName + extension;
    }

    return path;
  }

  bool entityExists(FileSystemEntity entity) {
    for (FileSystemEntity file in files) {
      if (file.path == entity.path) {
        return true;
      }
    }
    return false;
  }

  Future<void> deleteEntity(FileSystemEntity entity) async {
    if (entityExists(entity)) {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await _deleteDirectory(entity as Directory);
      }
      files.removeWhere(((element) => element.path == entity.path));
      showFiles.removeWhere(((element) => element.path == entity.path));
      notifyListeners();
    }
  }

  Future<void> deleteEntityPath(String path) async {
    if (entityExists(await pathToEntity(path))) {
      FileSystemEntity entity = await pathToEntity(path);
      deleteEntity(entity);
    }
  }

  Future<void> _deleteDirectory(Directory directory) async {
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await _deleteDirectory(entity);
      }
    }
    directory.delete();
  }

  Future<void> createNewFile(String fileName) async {
    String filePath = path.join(directory.path, fileName);
    File oldFile = File(filePath);
    await deleteEntity(oldFile);

    File createdFile = File(filePath);
    await createdFile.create();
    files.add(createdFile);
    showFiles.add(createdFile);
    notifyListeners();
  }

  Future<void> createNewDirectory(String fileName) async {
    String filePath = path.join(directory.path, fileName);
    Directory newDirectory = Directory(filePath);
    await deleteEntity(newDirectory);

    await newDirectory.create();
    files.add(newDirectory);
    showFiles.add(newDirectory);
    notifyListeners();
  }

  Future<void> renameFile(FileSystemEntity file, String newName) async {
    int fileIndex = files.indexWhere((f) => f == file);
    int showFileIndex = showFiles.indexWhere((f) => f == file);
    String path = newNameToNewPath(file, newName);

    await deleteEntityPath(path);
    FileSystemEntity renamedFile = await file.rename(path);

    files[fileIndex] = renamedFile;
    showFiles[showFileIndex] = renamedFile;
    notifyListeners();
  }

  Future<void> moveEntity({String? entityName}) async {
    if (moveFileSaved.path.isNotEmpty) {
      String entityFullname;
      if (entityName != null) {
        entityFullname = entityName;
      } else {
        entityFullname = getEntityNameAndExtension(moveFileSaved);
      }
      String movePath = path.join(directory.path, entityFullname);
      deleteEntityPath(movePath);

      FileSystemEntity renamedFile = await moveFileSaved.rename(movePath);
      files.add(renamedFile);
      showFiles.add(renamedFile);
      notifyListeners();
    }
  }

  Future<void> copyEntity({String? entityName}) async {
    if (copyFileSaved.path.isNotEmpty) {
      String entityFullname;
      if (entityName != null) {
        entityFullname = entityName;
      } else {
        entityFullname = getEntityNameAndExtension(copyFileSaved);
      }
      String copyPath = path.join(directory.path, entityFullname);
      deleteEntityPath(copyPath);

      FileSystemEntity newEntity;
      if (copyFileSaved is Directory) {
        newEntity = await _copyDirectory(
            copyFileSaved as Directory, Directory(copyPath));
      } else {
        newEntity = await (copyFileSaved as File).copy(copyPath);
      }

      files.add(newEntity);
      showFiles.add(newEntity);
      notifyListeners();
    }
  }

  Future<Directory> _copyDirectory(
      Directory source, Directory destination) async {
    Directory newDirectory = await destination.create(recursive: true);
    await for (final entity in source.list(followLinks: false)) {
      final newEntityPath =
          '${destination.path}${Platform.pathSeparator}${entity.uri.pathSegments.last}';
      if (entity is File) {
        await entity.copy(newEntityPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(newEntityPath));
      }
    }
    return newDirectory;
  }

  Future<String> readContent() async {
    return await textFileOpened.readAsString();
  }

  Future<void> writeContent(String content) async {
    await textFileOpened.writeAsString(content);
  }

  Future<int> getEntitySize(FileSystemEntity entity) async {
    if (entity is File) {
      return entity.statSync().size;
    }
    int totalSize = 0;
    Directory dir = entity as Directory;

    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    return totalSize;
  }

  void reverseFiles() {
    showFiles = showFiles.reversed.toList();
  }

  Future<void> sortFiles() async {
    Map<FileSystemEntity, int> sizeMap = {};
    if (sortOrder == SortOrder.size) {
      for (FileSystemEntity entity in showFiles) {
        sizeMap[entity] = await getEntitySize(entity);
      }
    }

    showFiles.sort((a, b) {
      if (sortOrder == SortOrder.type) {
        if(a is Directory && b is Directory || a is File && b is File) {
          return a.path.compareTo(b.path);
        }
        if (a is Directory && b is! Directory) return -1;
        if (a is! Directory && b is Directory) return 1;
        return 0;
      } else if (sortOrder == SortOrder.name) {
        return a.path.compareTo(b.path);
      } else if (sortOrder == SortOrder.date) {
        return a.statSync().modified.compareTo(b.statSync().modified);
      } else if (sortOrder == SortOrder.size) {
        return sizeMap[a]!.compareTo(sizeMap[b]!);
      }
      return 0;
    });

    if (reversed) {
      reverseFiles();
    }
    notifyListeners();
  }

  bool listEquals(List<FileSystemEntity> list1, List<FileSystemEntity> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  void searchFiles(String search) {
    List<FileSystemEntity> oldFiles = List.from(showFiles);
    showFiles = List.from(files);
    if (search.isNotEmpty) {
      showFiles.retainWhere((element) =>
          element.path.split(Platform.pathSeparator).last.contains(search));
    }
    if (!listEquals(oldFiles, showFiles)) {
      notifyListeners();
    }
  }
}
