import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../providers/storage-provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  Barcode _result;
  QRViewController _controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isScanning = true;
  bool _isFlashActive = false;

  @override
  void initState() {
    _isScanning = true;
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller.pauseCamera();
    }
    _controller.resumeCamera();
    setState(() => _isScanning = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Image QR Code"),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).pushNamed("/infos"),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView()),
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
                      onPressed: () =>
                          Navigator.of(context).pushNamed("/gallery")),
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

  void _snackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(color: isError ? Colors.white : Colors.black)),
        duration: Duration(seconds: 2),
        backgroundColor: isError
            ? Theme.of(context).errorColor
            : Theme.of(context).accentColor,
      ),
    );
  }

  Future<void> _downloadScannedFile(String link) async {
    _controller.pauseCamera();
    setState(() => _isScanning = false);
    // BuildContext dctx;
    showDialog(
      context: context,
      builder: (context) {
        // dctx = btcx;
        return AlertDialog(
          title: Text("Downloading"),
          content: Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Please wait", style: TextStyle(fontSize: 12)),
                SizedBox(height: 20),
                LinearProgressIndicator(backgroundColor: Colors.black),
              ],
            ),
          ),
        );
      },
    );

    try {
      await Provider.of<StorageProvider>(context, listen: false)
          .saveFile(link);
      Navigator.of(context).pop();
      _snackBar("Image successfully saved");
      _controller.resumeCamera();
      setState(() => _isScanning = true);
    } catch (e) {
      print("e... ${e.toString()}");
      Navigator.of(context).pop();
      _snackBar("Oops! the download has failed.", isError: true);
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;

    final String link =
        "https://d1fmx1rbmqrxrr.cloudfront.net/cnet/optim/i/edit/2019/04/eso1644bsmall__w770.jpg";
    if (_canDownload(link)) {
      _downloadScannedFile(link);
    } else {
      _snackBar(
          "The scanner did not detect a image link. Please truy again.");
    }

    controller.scannedDataStream.listen((scanData) {
      _result = scanData;
      
      if (_canDownload(_result.code)) {
        _downloadScannedFile(_result.code);
      } else {
        _snackBar(
            "The scanner did not detect a image link. Please truy again.");
      }
    });
  }

  bool _canDownload(String link) {
    RegExp regEx = new RegExp(r"^.*\.(jpg|JPG|gif|GIF|png|PNG)[A-Za-z0-9?]*$");
    if (regEx.hasMatch(link)) return true;

    return false;
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    await _controller.toggleFlash();
    setState(() => _isFlashActive = !_isFlashActive);
  }

  Future<void> _setCameraStatus() async {
    if (_controller == null) return;

    if (_isScanning)
      await _controller.pauseCamera();
    else
      await _controller.resumeCamera();

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
}
