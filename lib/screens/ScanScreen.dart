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
  void initState() {
    super.initState();
  }

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
  }

  Future<void> _downloadScannedFile() async {
    this.controller.pauseCamera();
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
                LinearProgressIndicator(),
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
      this.controller.resumeCamera();
    }).catchError((_) {
      Navigator.of(dctx).pop();
      _errorDialog(
          "Le télécharegement a échoué. \n Veuillez vérifier votre accès internet et réessayer.");
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      if (_canDownload()) {
        _downloadScannedFile();
      } else {
        _errorDialog(
            "L'url de l'image n'a pas été détecté. \n Veuillez réessayer.");
      }
      // setState(() {
      // });
    });
  }

  Future<void> _errorDialog(String content) async {
    await showDialog(
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
          content: Text(content),
          actions: [
            TextButton(
              child: Text("Ok"),
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
    if (link.startsWith("http")) return true;

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
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 230.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
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

  Widget _buildIconButton(
    bool value,
    IconData activeIcon,
    IconData deactiveIcon,
    Function handler,
  ) {
    return IconButton(
      icon: Icon(
        value ? activeIcon : deactiveIcon,
        size: 40,
      ),
      color: value ? Theme.of(context).accentColor : Colors.black,
      disabledColor: Colors.grey,
      onPressed: handler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: _buildQrView(),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            // color: Color.fromRGBO(0, 0, 0, 0.7),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIconButton(
                  _isFlashActive,
                  Icons.flash_on,
                  Icons.flash_off,
                  _toggleFlash,
                ),
                _buildIconButton(
                  _isScanning,
                  Icons.camera_alt_outlined,
                  Icons.camera_alt_rounded,
                  _setCameraStatus,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
