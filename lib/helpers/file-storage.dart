import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

import '../helpers/directories.dart';

final dio = Dio();

Future<String> downloadFile(String fileUrl, String fileName) async {
  Directory directory;
  String filePath;
  try {
    if (await _requestPermission(Permission.storage)) {
      String storageFolderPath = await getAppStorageDirectoryPath();
      directory = Directory(storageFolderPath);
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    if (await directory.exists()) {
      File saveFile = File(directory.path + "/$fileName" + ".jpeg");

      await dio.download(fileUrl, saveFile.path);

      filePath = saveFile.path;
    }
  } catch (e) {
    throw e;
  }

  return filePath;
}

Future<void> deleteFileFromDevice(filePath) async {
  // await dio.delete(fileUrl,);
  File file = File(filePath);
  try {
    await file.delete();
  } catch (e) {
    throw e;
  }
}

Future<List<File>> retrieveStoredFiles() async {
  final storagePath = await getAppStorageDirectoryPath();
  final fileList = Directory(storagePath).listSync();
  final List<File> files = [];

  for (var entity in fileList) {
    files.add(File(entity.path));
    print("==> file ==> ${entity.path}");
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
