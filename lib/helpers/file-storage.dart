import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

import '../helpers/directories.dart';

final dio = Dio();

Future<Map<String, dynamic>> downloadFile(
    String fileUrl, String fileName) async {
  String fileExt = await getFileExtension(fileUrl);

  try {
    Directory directory = await _getAppDir();
    File saveFile = File("${directory.path}/$fileName" + fileExt);
    await dio.download(fileUrl, saveFile.path);
    
    return {
      "filePath": saveFile.path,
      "fileExtension": fileExt,
      "fileSize": getFileSize(saveFile),
    };
  } catch (e) {
    throw e;
  }
}

double getFileSize(File file) {
  final bytes = file.readAsBytesSync().lengthInBytes;
  final sizeInMb = bytes / pow(1024, 2);

  final result = double.parse(sizeInMb.toStringAsFixed(2));
  
  return result;
}

Future<String> getFileExtension(String fileUrl) async {
  try {
    Response response = await Dio().get(fileUrl);

    final contentType = response.headers['content-type'][0];
    switch (contentType) {
      case "image/jpg":
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
  try {
    final Directory directory = await _getAppDir();
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

Future<Directory> _getAppDir() async {
  final bool hasPermission = await _requestPermission(Permission.storage);
  // print("------------------------------ hasPermission $hasPermission");
  if (!hasPermission) throw "User denied access to storage";

  // final storagePath = await getAppStorageDirectoryPath();
  final storagePath = await getAppStorageDirectoryPath();
  final directory = Directory(storagePath);

  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  return directory;
}

Future<List<File>> retrieveFiles() async {
  final directory = await _getAppDir();
  final fileList = directory.listSync();
  final List<File> files = [];

  for (var entity in fileList) {
    files.add(File(entity.path));
  }

  return files;
}

Future<bool> _requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    bool ispermanetelydenied = await permission.isPermanentlyDenied;
    if (ispermanetelydenied) {
      await openAppSettings();
    } else {
      final PermissionStatus result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }
  return false;
}
