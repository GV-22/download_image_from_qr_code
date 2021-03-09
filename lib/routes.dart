import 'package:flutter/material.dart';


import './screens/MainScreen.dart';
import './screens/FileOverViewScreen.dart';


Map<String, Widget Function(BuildContext)>routes (BuildContext ctx) {
  return {
    "/" : (ctx) => MainScreen(),
    "/file-overview": (ctx) =>FileOverViewScreen(),
  };
}