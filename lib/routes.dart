import 'package:flutter/material.dart';


import './screens/ScanScreen.dart';
import './screens/FileOverViewScreen.dart';
import './screens/InfosScreen.dart';
import './screens/GalleryScreen.dart';


Map<String, Widget Function(BuildContext)>routes (BuildContext ctx) {
  return {
    "/" : (ctx) => ScanScreen(),
    "/file-overview": (ctx) =>FileOverViewScreen(),
    "/infos": (ctx) => InfosScreen(),
    "/gallery": (ctx) => GalleryScreen(),
  };
}