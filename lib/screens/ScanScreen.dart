import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../providers/StorageProvider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isScanning = true;
  bool _isFlashActive = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }


  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
    setState(() {
      _isScanning = true;
    });
  }

  Future<void> _downloadScannedFile() async {
    this.controller.pauseCamera();
    setState(() {
      _isScanning = false;
    });
    BuildContext dctx;
    showDialog(
      context: context,
      builder: (btcx) {
        dctx = btcx;
        return AlertDialog(
          title: Text("Téléchargement"),
          content: Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Progression",
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 20),
                LinearProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              ],
            ),
          ),
        );
      },
    );

    Provider.of<StorageProvider>(context, listen: false)
        .storeFile(result.code)
        .then((_) {
      Navigator.of(dctx).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Image enregistrée",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          backgroundColor: Theme.of(context).accentColor,
        ),
      );
      setState(() {
        _isScanning = true;
      });
    }).catchError((_) {
      Navigator.of(dctx).pop();
      _errorDialog(
          "Le télécharegement a échoué.\nVeuillez vérifier votre accès internet et réessayer.");
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      this._isScanning = true;
    });
    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      if (_canDownload()) {
        _downloadScannedFile();
      } else {
        _errorDialog(
            "Le scanner n'a pas pu détecter une url d'image.\nVeuillez réessayer.");
      }
    });
  }

  Future<void> _errorDialog(String content) async {
    return await showDialog(
      context: context,
      builder: (btcx) {
        return AlertDialog(
          title: Text(
            "Erreur",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).errorColor,
            ),
          ),
          shape: Border.all(color: Theme.of(context).accentColor, width: 1.0),
          content: Text(content),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(btcx).pop();
                this.controller.resumeCamera();
              },
            )
          ],
        );
      },
    );
  }

  bool _canDownload() {
    final link = result.code;
    RegExp regEx =
        new RegExp(r"^.*\.(jpg|JPG|gif|GIF|jpeg|JPEG)[A-Za-z0-9?]*$");

    if (regEx.hasMatch(link)) return true;

    return false;
  }

  Future<void> _toggleFlash() async {
    await this.controller?.toggleFlash();
    setState(() {
      _isFlashActive = !_isFlashActive;
    });
  }

  Future<void> _setCameraStatus() async {
    if (_isScanning)
      await controller?.pauseCamera();
    else
      await controller?.resumeCamera();

    setState(() {
      _isScanning = !_isScanning;
    });
  }

  Widget _buildQrView() {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).accentColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).pushNamed("/infos"),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _buildQrView(),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.photo_library_outlined,
                      color: Theme.of(context).accentColor,
                      size: 35,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/gallery");
                    }
                  ),
                  Container(
                    height: 80,
                    width: 80,
                    child: IconButton(
                      icon: Icon(
                        _isScanning ? Icons.camera : Icons.camera_outlined,
                        color: Theme.of(context).accentColor,
                        size: 70,
                      ),
                      onPressed: _setCameraStatus,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        _isFlashActive
                            ? Icons.flash_on
                            : Icons.flash_off_outlined,
                        color: Theme.of(context).accentColor,
                        size: 35),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
