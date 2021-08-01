import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../config.dart';

Future<String> getAppStorageDirectoryPath() async {
  Directory directory = await getExternalStorageDirectory();
  String newPath = "";
  // print("=====================> directory $directory");
  List<String> paths = directory.path.split("/");
  for (int x = 1; x < paths.length; x++) {
    String folder = paths[x];
    if (folder != "Android") {
      newPath += "/" + folder;
    } else {
      break;
    }
  }
  return "$newPath/${AppConfig.storageFolderName}";
//   Directory root = await getTemporaryDirectory(); // this is using path_provider
//   print("------- root ${root.path}");

//   return "${root.path}/$storageFolderName";
}
