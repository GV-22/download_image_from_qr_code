import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

import '../helpers/directories.dart';

final dio = Dio();

Future<List<String>> downloadFile(String fileUrl, String fileName) async {
  Directory directory;
  String filePath;
  String fileExt = await getFileExtension(fileUrl);

  try {
    if (await _requestPermission(Permission.storage)) {
      String storageFolderPath = await getAppStorageDirectoryPath();
      directory = Directory(storageFolderPath);
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    if (await directory.exists()) {
      File saveFile = File("${directory.path}/$fileName" + fileExt);

      await dio.download(fileUrl, saveFile.path);

      filePath = saveFile.path;
    }
  } catch (e) {
    throw e;
  }

  return [filePath, fileExt];
}

Future<String> getFileExtension(String fileUrl) async {
  try {
    Response response = await Dio().get(fileUrl);
    
    final contentType = response.headers['content-type'][0];
    switch (contentType) {
      case "image/jpg":
        return ".jpeg";
        break;
      case "image/jpeg":
        return ".jpeg";
        break;
      case "image/png":
        return ".png";
        break;
      case "image/gif":
        return ".gif";
      default:
        return contentType.split("/").last;
    }
  } catch (error) {
    throw error;
  }
}

Future<void> deleteAllFiles() async {
  final Directory directory = await getAppDir();
  try {
    await directory.delete(recursive: true);
  } catch (e) {
    throw e;
  }
}

Future<void> deleteFileFromDevice(filePath) async {
  File file = File(filePath);
  try {
    await file.delete();
  } catch (e) {
    throw e;
  }
}

Future<Directory> getAppDir() async {
  final storagePath = await getAppStorageDirectoryPath();
  final directory = Directory(storagePath);

  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  return directory;
}

Future<List<File>> retrieveStoredFiles() async {
  final directory = await getAppDir();

  final fileList = directory.listSync();
  final List<File> files = [];

  for (var entity in fileList) {
    files.add(File(entity.path));
    // print("==> file ==> ${entity.path}");
  }

  return files;
}

Future<bool> _requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  }
  return false;
}
