import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './GalleryScreen.dart';
import './ScanScreen.dart';
import 'InfosScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final List<Widget>_pages = [
    GalleryScreen(),
    ScanScreen(),
    InfosScreen()
  ];

  int _selectedPageIndex = 1;


  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        items: [
          TabItem(icon: Icons.photo_library_outlined, title: "Gallerie"),
          TabItem(icon: Icons.qr_code_scanner_outlined, title: "Scan"),
          TabItem(icon: Icons.info_outline, title: "Infos"),
        ],
        activeColor: Theme.of(context).accentColor,
        initialActiveIndex: 1,
        onTap:_selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        // backgroundColor: Color.fromRGBO(33, 97, 140, 1),
      ),
    );
  }
}
