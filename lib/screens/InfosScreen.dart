import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class InfosScreen extends StatelessWidget {
  Future<void> _urlLauncher(BuildContext context, url, errorMsg) async {
    if (await canLaunch(url) != null) {
      print("canLaunch $url==>");

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
      "Salut! Je te recommande cette aplication pour télécharger" +
          "directement des images depuis ton ordinateur vers ton téléphone" +
          "juste en scannat le QR Code. Voici le lien https://fake.difqc.app.example",
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _buildIconCard(BuildContext context, IconData icon, Function handler) {
    return Card(
      child: IconButton(icon: Icon(icon), onPressed: handler),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            alignment: Alignment.center,
            child: ListTile(
              leading: CircleAvatar(
                child: Text("LOGO"),
                radius: 100,
              ),
              title: Text(appName),
              subtitle: Text("Version: 1.0.0"),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Un produit de: "),
                  Text("<informat-pro />"),
                ],
              ),
              Text("Contactez-nous"),
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
                    Icons.phone_android,
                    () async {
                      await _urlLauncher(
                        context,
                        whatsappUrl,
                        "Erreur lors de l'ouverture de Whatsapp. Assurez-vous que Whatsapp" +
                            "soit installée sur votre téléphone.",
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
