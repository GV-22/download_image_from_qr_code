import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class InfosScreen extends StatelessWidget {
  Future<void> _urlLauncher(BuildContext context, url, errorMsg) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final RenderBox box = context.findRenderObject() as RenderBox;

    await Share.share(
      recommandAppMsg,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _buildButton(BuildContext context, String iconUrl, Function handler) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handler,
      child: Card(
        child: Container(
          height: 50,
          width: 50,
          child: Row(
            children: [
              Image.asset(
                iconUrl,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Infos"),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Image.asset(
                        "assets/images/app_icon.png",
                        // fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Download Image \n From QR Code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).accentColor),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Un produit de ",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            "<Informat-Pro />",
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildButton(
                            context,
                            "assets/images/share_outline_70.png",
                            () => _shareApp(context),
                          ),
                          _buildButton(
                            context,
                            "assets/images/whatsapp_icon_70.png",
                            () async {
                              await _urlLauncher(
                                context,
                                whatsappUrl,
                                "Erreur lors de l'ouverture de Whatsapp. Assurez-vous que Whatsapp" +
                                    "soit installée sur votre téléphone.",
                              );
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Version: 1.0.0",
                        style: TextStyle(
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
