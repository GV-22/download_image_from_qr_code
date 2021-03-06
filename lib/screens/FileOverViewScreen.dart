import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/StorageProvider.dart';

class FileOverViewScreen extends StatelessWidget {
  Widget buildBottomIcon(
    BuildContext context,
    IconData icon,
    Function handler,
  ) {
    return IconButton(
      icon: Icon(icon),
      color: Colors.white,
      onPressed: handler,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileName = ModalRoute.of(context).settings.arguments as String;
    final storage = Provider.of<StorageProvider>(context, listen: false);
    final file = storage.findFileByName(fileName);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: GridTile(
              child: Image.file(
                File(file.filePath),
                fit: BoxFit.cover,
              ),
              footer: Container(
                // color: Colors.red,
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildBottomIcon(context, Icons.share_outlined, (){}),
                    buildBottomIcon(context, Icons.info_outline, (){}),
                    buildBottomIcon(context, Icons.delete_outline, (){}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
