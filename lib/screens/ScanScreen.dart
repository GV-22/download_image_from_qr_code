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
  bool _isSuccessfullySaved;
  // bool _isDownloading = false;

  @override
  void didChangeDependencies() {
    if (!_isScanning) this.controller.pauseCamera();
    if (result != null) {
      downloadScannedFile()
          .then((value) => print("===========> downladed finished ======>"));
    }
    super.didChangeDependencies();
  }

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

  Future<void> downloadScannedFile() async {
    // print("==============> result.code ========> ${result.code}");
    // await downloadFile(result.code);
    // await downloadFile(
    //     "");
    const url2 =
        "https://image.freepik.com/photos-gratuite/equipement-affaires-bureau-noir-fond-noir_1387-732.jpg";
    const url =
        "https://cdnb.artstation.com/p/assets/images/images/007/341/099/large/ricardo-tilim-10-noir-office-0890-far.jpg?1505449015";

    // _isDownloading = true;
    BuildContext dctx;
    showDialog(
      context: context,
      builder: (btcx) {
        dctx = btcx;
        print("========> before alert dialog dctx $dctx========>");
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
                SizedBox(
                  height: 20,
                ),
                LinearProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );

    Provider.of<StorageProvider>(context, listen: false)
        .storeFile(url)
        .then((value) {
      setState(() {
        _isSuccessfullySaved = value;
      });
      Navigator.of(dctx).pop();
    }).catchError((onError) {
      print("==><>>>>>>>> savedfile error ${onError.toString()}");
      print("========> pop alert dialog dctx $dctx========>");
      setState(() {
        _isSuccessfullySaved = false;
      });
      Navigator.of(dctx).pop();
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      // this.controller.pauseCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  Future<void> toggleFlash() async {
    await this.controller?.toggleFlash();
    setState(() {
      _isFlashActive = !_isFlashActive;
    });
  }

  Future<void> setCameraStatus() async {
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
        borderColor: Theme.of(context).primaryColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  Widget buildIconButton(bool value, IconData activeIcon, IconData deactiveIcon,
      Function handler) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (result != null)
                FittedBox(
                  child: Column(
                    children: [
                      Text(
                        'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}',
                      ),
                      if (_isSuccessfullySaved)
                        Text(
                          "Image téléchargée avec succès",
                        )
                      else
                        Text(
                          "Échec lors du téléchargement de l'image"
                        ),
                    ],
                  ),
                )
              else
                Text('Scan a code'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildIconButton(
                    _isFlashActive,
                    Icons.flash_on,
                    Icons.flash_off,
                    toggleFlash,
                  ),
                  buildIconButton(
                    _isScanning,
                    Icons.camera_alt_outlined,
                    Icons.camera_alt_rounded,
                    setCameraStatus,
                  ),
                  IconButton(
                    icon: Icon(Icons.download_rounded),
                    onPressed: downloadScannedFile,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
