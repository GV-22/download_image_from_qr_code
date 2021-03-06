import 'package:flutter/material.dart';


import './screens/FileOverViewScreen.dart';
import './screens/MainScreen.dart';


Map<String, Widget Function(BuildContext)>routes (BuildContext ctx) {
  return {
    "/" : (ctx) => MainScreen(),
    "/file-overview": (ctx) =>FileOverViewScreen(),
  };
}