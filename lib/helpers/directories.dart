import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../constants.dart';

Future<String> getAppStorageDirectoryPath() async {
  Directory directory = await getExternalStorageDirectory();
  String newPath = "";
  print("=====================> directory $directory");
  List<String> paths = directory.path.split("/");
  for (int x = 1; x < paths.length; x++) {
    String folder = paths[x];
    if (folder != "Android") {
      newPath += "/" + folder;
    } else {
      break;
    }
  }

  return "$newPath/$storageFolderName";
}
