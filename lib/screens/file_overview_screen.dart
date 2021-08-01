import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../providers/storage-provider.dart';

class FileOverViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fileName = ModalRoute.of(context).settings.arguments as String;
    final storage = Provider.of<StorageProvider>(context, listen: false);
    final file = storage.findFileByName(fileName);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(file.fileName),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: GridTile(
              child: Image.file(File(file.filePath), fit: BoxFit.contain),
              footer: Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildBottomIcon(context, Icons.share_outlined, () async {
                      await _onShare(context, file.filePath);
                    }),
                    buildBottomIcon(
                      context,
                      Icons.delete_outline,
                      () => _confirmDelete(context, fileName),
                    ),
                    buildBottomIcon(
                      context,
                      Icons.info_outline,
                      () => _showFileDetails(context, file),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomIcon(
    BuildContext context,
    IconData icon,
    Function handler,
  ) {
    return IconButton(
      icon: Icon(icon),
      // color: Colors.black,
      onPressed: handler,
    );
  }

  void _showFileDetails(context, SavedFile file) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("File name", style: _textStyle()),
            SizedBox(height: 5),
            Text(file.fileName),
            SizedBox(height: 10),
            Text("Location", style: _textStyle()),
            SizedBox(height: 5),
            Text(file.filePath),
            SizedBox(height: 10),
            Text("Size", style: _textStyle()),
            SizedBox(height: 5),
            Text("${file.fileSize} Mb"),
          ],
        ),
      ),
    );
  }

  TextStyle _textStyle() {
    return TextStyle(fontWeight: FontWeight.bold);
  }

  void _showSnackBar(BuildContext context, String content,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content, style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 2),
        backgroundColor: isError
            ? Theme.of(context).errorColor
            : Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _onShare(BuildContext context, filePath) async {
    final RenderBox box = context.findRenderObject() as RenderBox;

    await Share.shareFiles(
      [filePath],
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _confirmDelete(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (btcx) {
        return AlertDialog(
          title: Text(
            "Confirmation",
            style: TextStyle(
              color: Theme.of(context).errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text("Do you want to delete this image ?"),
          actions: [
            TextButton(
              child: Text("Yes"),
              onPressed: () => _deleteFile(context, fileName),
            ),
            TextButton(
              onPressed: () => Navigator.of(btcx).pop(),
              child: Text("No"),
            )
          ],
        );
      },
    );
  }

  Future<void> _deleteFile(BuildContext context, String fileName) async {
    try {
      await Provider.of<StorageProvider>(context, listen: false)
          .deleteFile(fileName);
      Navigator.of(context).pop();
      _showSnackBar(context, "Image successfully deleted.");
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar(
          context, "Oops! some error occured while deleting the image.");
    }
  }
}
