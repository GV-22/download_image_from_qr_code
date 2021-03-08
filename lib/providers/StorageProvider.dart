import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import '../helpers/utils.dart';
import '../helpers/file-storage.dart';

class SavedFile {
  final String fileName;
  final String filePath;

  SavedFile(this.fileName, this.filePath);
}

class StorageProvider with ChangeNotifier {
  List<SavedFile> _savedFiles = [];

  List<SavedFile> get savedFiles {
    return [..._savedFiles];
  }

  SavedFile findFileByName(String fileName){
    return _savedFiles.firstWhere((f) => f.fileName == fileName);
  }

  Future<bool> storeFile(String fileUrl) async {
    final fileName = formatDateToFileName();
    final storedFilePath = await downloadFile(fileUrl, fileName);

    if (storedFilePath != null) {
      _savedFiles.insert(0, SavedFile(fileName, storedFilePath));

      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> retrieveAndStoredFiles() async {
    if(_savedFiles.isNotEmpty) return;
    final files = await retrieveStoredFiles();
    List<SavedFile> tmp = [];

    files.forEach((file) {
      tmp.insert(
        0,
        SavedFile(
          basename(file.path),
          file.path,
        ),
      );
    });

    _savedFiles = tmp;

    notifyListeners();
  }

  Future<bool> deleteFile(String fileName)  async {
    try {
      final file = findFileByName(fileName);
      await deleteFileFromDevice(file.filePath);

      _savedFiles.removeWhere((f) => f.fileName == file.fileName);
      notifyListeners();

      return true;
    } catch (_) {
      return false;
    }
  }
}
