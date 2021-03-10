import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/StorageProvider.dart';
import '../widgets/GalleryItem.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    _retrieve();

    super.initState();
  }

  Future<void> _retrieve() async {
    try {
      Provider.of<StorageProvider>(context, listen: false)
          .retrieveAndStoredFiles()
          .then((_) => setState(() {
                _isLoading = false;
              }));
    } finally {
      setState(() {});
    }
  }

  Future<void> _deleteAll() async {
    try {
      Provider.of<StorageProvider>(context, listen: false)
          .deleteAllSavedFiles()
          .then(
            (_) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Images supprimées",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          );
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageProvider>(context);
    final savedFiles = storage.savedFiles;

    return Scaffold(
      appBar: AppBar(
        title: Text("Images sauvegardées"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever_outlined),
            onPressed: _deleteAll,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).pushNamed("/infos"),
          ),
        ],
      ),
      body: savedFiles.isEmpty
          ? Container(
              width: double.infinity,
              // color: Theme.of(context).primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LottieBuilder.asset(
                    "assets/lotties/empty-black-lottie-folder.json",
                    height: 150,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Vous n'avez aucune image sauvegardée.",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            )
          : _isLoading
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LottieBuilder.asset(
                        "assets/lotties/search-file.json",
                        height: 150,
                      ),
                      SizedBox(height: 20),
                      Text("Chargement des fichiers. Veuillez patienter.")
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _retrieve,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 8,
                      right: 5,
                      bottom: 10,
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: 1 / 1,
                        maxCrossAxisExtent: 90,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                      itemCount: savedFiles.length,
                      itemBuilder: (bctx, index) {
                        final file = File(savedFiles[index].filePath);
                        return GalleryItem(file);
                      },
                    ),
                  ),
                ),
    );
  }
}
