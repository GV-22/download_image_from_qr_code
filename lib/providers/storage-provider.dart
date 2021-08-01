import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import '../helpers/utils.dart';
import '../helpers/file-storage.dart';

class SavedFile {
  final String fileName;
  final String filePath;
  final double fileSize;

  SavedFile({this.fileName, this.filePath, this.fileSize});
}

class StorageProvider with ChangeNotifier {
  List<SavedFile> _savedFiles = [];

  List<SavedFile> get savedFiles {
    return [..._savedFiles];
  }

  SavedFile findFileByName(String fileName) {
    final file = _savedFiles.firstWhere((f) => f.fileName == fileName,
        orElse: () => null);
    if (file == null) throw "Unknown file with name $fileName";
    return file;
  }

  Future<bool> saveFile(String fileUrl) async {
    final fileName = formatDateToFileName();
    final savedFile = await downloadFile(fileUrl, fileName);
    // savedFile = [filePath, fileExt]

    if (savedFile != null) {
      final String filePath = savedFile["filePath"];
      final String fileExtension = savedFile["fileExtension"];
      final double fileSize = savedFile["fileSize"];
      _savedFiles.insert(
        0,
        SavedFile(
            fileName: fileName + fileExtension,
            filePath: filePath,
            fileSize: fileSize),
      );

      notifyListeners();
      return true;
    }

    return false;
  }

  void setSavedFiled(List<SavedFile> files) {
    _savedFiles = files;
    notifyListeners();
  }

  Future<void> retrieveSavedFiles() async {
    // if (_savedFiles.isNotEmpty) return;

    final files = await retrieveFiles();
    // print("--------------- files from folders $files");
    List<SavedFile> tmp = [];

    for (var file in files) {
      tmp.insert(
        0,
        SavedFile(
            fileName: basename(file.path),
            filePath: file.path,
            fileSize: getFileSize(file)),
      );
    }
    setSavedFiled(tmp);
  }

  Future<bool> deleteFile(String fileName) async {
    try {
      final file = findFileByName(fileName);
      await deleteFileFromDevice(file.filePath);

      _savedFiles.removeWhere((f) => f.fileName == file.fileName);
      notifyListeners();

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> deleteAllSavedFiles() async {
    try {
      await deleteAllFiles();
      _savedFiles = [];
      notifyListeners();
      return true;
    } catch (e) {
      throw e.toString();
    }
  }
}
