import 'package:flutter/material.dart';


import 'screens/scan_screen.dart';
import 'screens/file_overview_screen.dart';
import 'screens/infos_screen.dart';
import 'screens/gallery_screen.dart';


Map<String, Widget Function(BuildContext)>routes (BuildContext ctx) {
  return {
    "/" : (ctx) => ScanScreen(),
    "/file-overview": (ctx) =>FileOverViewScreen(),
    "/infos": (ctx) => InfosScreen(),
    "/gallery": (ctx) => GalleryScreen(),
  };
}