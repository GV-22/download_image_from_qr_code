import 'dart:ui';

import 'package:download_image_from_qr_code/config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfosScreen extends StatelessWidget {
  Future<void> _urlLauncher() async {
    final url = AppConfig.myGitHubUrl;
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Infos"),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
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
                    child: Image.asset("assets/images/app_icon.png"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    AppConfig.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
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
                        Text("Powered by",
                            style: TextStyle(color: Colors.white54)),
                        TextButton(
                          child: Text(
                            AppConfig.myName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          onPressed: _urlLauncher,
                        )
                      ],
                    ),
                    Text(
                      "Version ${AppConfig.appVersion}",
                      style: TextStyle(
                          color: Colors.white54, fontStyle: FontStyle.italic),
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
