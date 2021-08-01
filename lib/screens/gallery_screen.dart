import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/storage-provider.dart';
import '../widgets/gallery_item.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    // print("init ==> ");
    _retrieve();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageProvider>(context);
    final files = storage.savedFiles;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text("Saved Images")),
        actions: [
          if (files.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever_outlined),
              onPressed: _confirmDelete,
            ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).pushNamed("/infos"),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : Padding(
              padding: EdgeInsets.zero,
              child: files.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LottieBuilder.asset(
                            "assets/lotties/empty-black-lottie-folder.json",
                            height: 150,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "You don't have saved image yet.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _retrieve,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            childAspectRatio: 1 / 1,
                            maxCrossAxisExtent: 90,
                            crossAxisSpacing: 3,
                            mainAxisSpacing: 3,
                          ),
                          itemCount: files.length,
                          itemBuilder: (bctx, index) {
                            final file = File(files[index].filePath);
                            return GalleryItem(file);
                          },
                        ),
                      ),
                    ),
            ),
    );
  }

  Future<void> _retrieve() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<StorageProvider>(context, listen: false)
          .retrieveSavedFiles();
    } catch (e) {
      print("error _retrieve ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmDelete() {
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
          content:
              Text("Delete all saved images ?"),
          actions: [
            TextButton(child: Text("Yes"), onPressed: _deleteImages),
            TextButton(
              onPressed: () => Navigator.of(btcx).pop(),
              child: Text("No"),
            )
          ],
        );
      },
    );
  }

  Future<void> _deleteImages() async {
    try {
      await Provider.of<StorageProvider>(context, listen: false)
          .deleteAllSavedFiles();
      _snackBar("All saved images have been successfully deleted.");
    } catch (e) {
      _snackBar("Oops! An error occured while deleting image. Please try again.",
          isError: true);
    } finally {
      Navigator.of(context).pop();
    }
  }

  void _snackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: isError
            ? Theme.of(context).errorColor
            : Theme.of(context).primaryColor,
      ),
    );
  }
}
