import 'dart:io';
import 'package:path/path.dart';

import 'package:flutter/material.dart';

class GalleryItem extends StatelessWidget {
  final File file;

  GalleryItem(this.file);

  void _selectGalleryItem(BuildContext context){
    print("${file.path}");
    Navigator.pushNamed(context, "/file-overview", arguments: basename(file.path));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Image.file(
        file,
        fit: BoxFit.cover,
      ),
      onTap: () =>_selectGalleryItem(context),
    );
  }
}
