import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/StorageProvider.dart';
import '../widgets/GalleryItem.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    try {
      Provider.of<StorageProvider>(context, listen: false)
          .retrieveAndStoredFiles();
    } finally {
      setState(() {});
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageProvider>(context, listen: false);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        childAspectRatio: 1 / 1,
        maxCrossAxisExtent: 90,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: storage.savedFiles.length,
      itemBuilder: (bctx, index) {
        final file = File(storage.savedFiles[index].filePath);
        return GalleryItem(file);
      },
    );
  }
}
