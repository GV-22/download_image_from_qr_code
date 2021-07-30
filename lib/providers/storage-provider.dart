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

  Future<bool> storeFile(String fileUrl) async {
    final fileName = formatDateToFileName();
    final storedFile = await downloadFile(fileUrl, fileName);
    // storedFile = [filePath, fileExt]

    if (storedFile != null) {
      final String filePath = storedFile["filePath"];
      final String fileExtension = storedFile["fileExtension"];
      final double fileSize = storedFile["fileSize"];
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

  Future<void> retrieveStoredFiles() async {
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
