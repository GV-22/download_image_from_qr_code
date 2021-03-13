import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './providers/StorageProvider.dart';
import './routes.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    // systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: Colors.white, // status bar color
    statusBarBrightness: Brightness.dark, //status bar brigtness
    statusBarIconBrightness: Brightness.dark, //status barIcon Brightness
    // systemNavigationBarDividerColor:
    //     Colors.greenAccent, //Navigation bar divider color
    // systemNavigationBarIconBrightness: Brightness.light, //navigation bar icon
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => StorageProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Download Image From QR Code',
        theme: ThemeData(
          primaryColor: Colors.black,
          accentColor: Color.fromRGBO(247, 253, 255, 1),
          // accentColor: Color.fromRGBO(204, 210, 160, 1),
          // accentColor: Color.fromRGBO(0, 0, 255, 1),
          // accentColor: Colors.blue,
        ),
        routes: routes(context),
      ),
    );
  }
}
