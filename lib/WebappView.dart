import 'dart:convert';
import 'dart:developer' as developer;
import 'package:wakelock/wakelock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipe59/SettingsView.dart';

import 'client/ProfileBloc.dart';
import 'entity/Profile.dart';

typedef void OnProfileSaved();
typedef void OnHideSettings();

class WebAppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    return WebAppViewPage();
  }
}

class WebAppViewPage extends StatefulWidget {
  @override
  _WebAppPageState createState() {
    return _WebAppPageState();
  }
}

class _WebAppPageState extends State<WebAppViewPage> {
  late InAppWebViewController webView;
  bool jsInjected = false;
  bool loadFull = false;
  bool displaySettings = false;
  Key _refreshKey = UniqueKey();

  late List<Profile> profileList;
  late SharedPreferences sharedPref;

  @override
  void initState() {}

  Future<bool> loadSharedPreferences() async {
    sharedPref = await SharedPreferences.getInstance();
    String? profiles = sharedPref.getString("profiles");
    if (profiles != null) {
      Iterable l = json.decode(profiles);
      profileList =
          List<Profile>.from(l.map((model) => Profile.fromJson(model)));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: FutureBuilder<bool>(
          future: loadSharedPreferences(),
          builder: (buildContext, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return Theme(
                  data: ThemeData.dark(),
                  child: Stack(
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(
                            url: Uri.parse('https://www.ea.com/fifa/ultimate-team/web-app/')),
                        onWebViewCreated: (InAppWebViewController controller) {
                          webView = controller;
                          
                        },
                        onTitleChanged: (controller, title) {},
                        onReceivedServerTrustAuthRequest:
                            (InAppWebViewController controller,
                                URLAuthenticationChallenge challenge) async {
                          return ServerTrustAuthResponse(
                              action: ServerTrustAuthResponseAction.PROCEED);
                        },
                        onLoadStop: (controller, url) {
                          
                        },
                       
                        onConsoleMessage: (InAppWebViewController controller,
                            ConsoleMessage consoleMessage) {},
                        initialOptions: InAppWebViewGroupOptions(
                            android: AndroidInAppWebViewOptions(
                                domStorageEnabled: true,
                                useHybridComposition: true),
                            crossPlatform: InAppWebViewOptions(
                              useShouldOverrideUrlLoading: true,
                              javaScriptEnabled: true,
                            )),
                      ),
                      Center(
                          key: _refreshKey,
                          child: displaySettings
                              ? BlocProvider(
                                  create: (_) => ProfileBloc(
                                      sharedPreferences: sharedPref),
                                  child: SettingsView(
                                      onSave: _onProfileSaved, onHide: _onHide),
                                )
                              : Container()),
                    ],
                  ),
                );
              }
              // Return your home here
              return Container(color: Colors.red);
            } else {
              // Return loading screen while reading preferences
              return Center(child: CircularProgressIndicator());
            }
          },
        ))); // This trailing comma makes auto-formatting nicer for build methods.
  }

  void _onProfileSaved() {
    loadSharedPreferences().then((value) => {
          webView.evaluateJavascript(source: """
          window.dispatchEvent(new CustomEvent("ReloadProfileEvent"));
            """),
        });
  }

  void _onHide() {
    displaySettings = false;
    setState(() {
      _refreshKey = UniqueKey();
    });
  }
}
