import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../providers/StorageProvider.dart';

class FileOverViewScreen extends StatelessWidget {
  Widget buildBottomIcon(
    BuildContext context,
    IconData icon,
    Function handler,
  ) {
    return IconButton(
      icon: Icon(icon),
      color: Colors.black,
      onPressed: handler,
    );
  }

  void _showSnackBar(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          content,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _onShare(BuildContext context, filePath) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final RenderBox box = context.findRenderObject() as RenderBox;

    await Share.shareFiles(
      [filePath],
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileName = ModalRoute.of(context).settings.arguments as String;
    final storage = Provider.of<StorageProvider>(context, listen: false);
    final file = storage.findFileByName(fileName);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: GridTile(
              child: Image.file(
                File(file.filePath),
                fit: BoxFit.contain,
              ),
              footer: Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildBottomIcon(context, Icons.share_outlined, () async {
                      await _onShare(context, file.filePath);
                    }),
                    buildBottomIcon(context, Icons.delete_outline, () {
                      storage.deleteFile(fileName).then((_) {
                        _showSnackBar(
                            context, "L'image a été supprimée avec succès.");
                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.of(context).pop();
                        });
                      }).catchError(
                        (onError) {
                          _showSnackBar(context,
                              "Une erreur s'est produite lors de la suppression.");
                        },
                      );
                    }),
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
