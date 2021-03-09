import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class InfosScreen extends StatelessWidget {
  Future<void> _urlLauncher(BuildContext context, url, errorMsg) async {
    if (await canLaunch(url) != null) {
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

  Widget _buildIconCard(BuildContext context, IconData icon, Function handler) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: IconButton(
        icon: Icon(
          icon,
          color: Theme.of(context).accentColor,
        ),
        onPressed: handler,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(75),
                ),
              ),
              width: double.infinity,
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Image.asset(
                      "assets/images/qr_icon_v1-256.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    appName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              // color: Theme.of(context).accentColor,
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
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "<Informat-Pro />",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
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
                        _buildIconCard(
                          context,
                          Icons.share_outlined,
                          () async => _shareApp(context),
                        ),
                        _buildIconCard(
                          context,
                          Icons.mail_outline,
                          () async {
                            await _urlLauncher(
                              context,
                              mailUrl,
                              "Erreur lors de l'ouverture de GMail. Assurez-vous que GMail" +
                                  "soit installée sur votre téléphone.",
                            );
                          },
                        ),
                        _buildIconCard(
                          context,
                          FontAwesomeIcons.whatsapp,
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
                        color: Colors.grey,
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
    );
  }
}
