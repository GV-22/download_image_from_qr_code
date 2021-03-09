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
    final RenderBox box = context.findRenderObject() as RenderBox;

    await Share.shareFiles(
      [filePath],
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _confirmDete(BuildContext context, String fileName) {
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
          content: Text("Voulez-vous supprimer cette image ?"),
          // backgroundColor: Theme.of(context).primaryColor,
          // contentTextStyle: TextStyle(color: Theme.of(context).accentColor),
          actions: [
            TextButton(
              child: Text("Oui"),
              onPressed: () {
                Provider.of<StorageProvider>(context, listen: false)
                    .deleteFile(fileName)
                    .then((_) {
                  Navigator.of(btcx).pop();
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
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(btcx).pop(),
              child: Text("Non"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileName = ModalRoute.of(context).settings.arguments as String;
    final storage = Provider.of<StorageProvider>(context, listen: false);
    final file = storage.findFileByName(fileName);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.black12,
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
                    buildBottomIcon(
                      context,
                      Icons.delete_outline,
                      () => _confirmDete(context, fileName),
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
}
