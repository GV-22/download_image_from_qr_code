import 'dart:io';
import 'package:path/path.dart';

import 'package:flutter/material.dart';

class GalleryItem extends StatelessWidget {
  final File file;

  GalleryItem(this.file);

  @override
  Widget build(BuildContext context) {
    final baseName = basename(file.path);
    return GestureDetector(
      key: Key(baseName),
      child: Image.file(
        file,
        fit: BoxFit.cover,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          "/file-overview",
          arguments: baseName,
        );
      },
    );
  }
}
