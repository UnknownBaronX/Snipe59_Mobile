// ignore_for_file: deprecated_member_use

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
                         initialUrlRequest:
                        URLRequest(url: WebUri('https://www.ea.com/en-en/fifa/ultimate-team/web-app/')),
          
                        onWebViewCreated: (InAppWebViewController controller) {
                          webView = controller;
                          webView.addJavaScriptHandler(
                            handlerName: "getProfiles",
                            callback: (List<dynamic> payload) {
                              return profileList;
                            },
                          );
                          webView.addJavaScriptHandler(
                            handlerName: "displaySettings",
                            callback: (List<dynamic> payload) {
                              developer.log("On affiche les settings",
                                  name: "Snipe 59");
                              displaySettings = true;
                              setState(() {
                                _refreshKey = UniqueKey();
                              });
                            },
                          );
                          webView.addJavaScriptHandler(
                            handlerName: "addFilterName",
                            callback: (List<dynamic> payload) {
                              var filterName = payload[0];
                              developer.log("On ajoute le filtre " + filterName,
                                  name: "Snipe 59");
                              List<String>? filterList =
                                  sharedPref.getStringList("filters");
                              filterList ??= List.empty(growable: true);
                              if (!filterList.contains(filterName)) {
                                filterList.add(filterName);
                              }
                              sharedPref.setStringList("filters", filterList);
                            },
                          );
                          webView.addJavaScriptHandler(
                            handlerName: "deleteFilterName",
                            callback: (List<dynamic> payload) {
                              var filterName = payload[0];
                              developer.log("On delete le filtre " + filterName,
                                  name: "Snipe 59");
                              List<String>? filterList =
                                  sharedPref.getStringList("filters");
                              filterList ??= List.empty(growable: true);
                              if (filterList.contains(filterName)) {
                                filterList.remove(filterName);
                              }
                              sharedPref.setStringList("filters", filterList);
                            },
                          );
                          webView.addJavaScriptHandler(
                            handlerName: "injectScript",
                            callback: (List<dynamic> payload) {
                              developer.log("Injected script",
                                  name: "Snipe 59");
                                webView.injectJavascriptFileFromAsset(
                              assetFilePath: "assets/js/jquery-3.5.1.min.js");
                               webView.injectJavascriptFileFromAsset(
                              assetFilePath: "assets/js/script.js");
                          webView.injectJavascriptFileFromAsset(
                              assetFilePath: "assets/js/hook.js");
                         
                          webView.injectCSSFileFromAsset(
                              assetFilePath: "assets/css/main.css");
                          developer.log("Injected script finished",
                                  name: "Snipe 59");
                            
                          
                            },
                          );
                        },
                                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                                  //create alert popup


                          },
                        onTitleChanged: (controller, title) {},
                        onReceivedServerTrustAuthRequest:
                            (InAppWebViewController controller,
                                URLAuthenticationChallenge challenge) async {
                          return ServerTrustAuthResponse(
                              action: ServerTrustAuthResponseAction.PROCEED);
                        },
                        onLoadError: (controller, url, code, message) {
                          //reload current url
                          controller.loadUrl(urlRequest: URLRequest(url: WebUri(url.toString())));

                        },
                        
                        onLoadStop: (controller, url) {
                          controller.injectJavascriptFileFromAsset(
                              assetFilePath: "assets/js/initScript.js");
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var url = navigationAction.request.url;
                          if (url.toString().contains("futbin") ||
                              url.toString().contains("discord")) {
                            return NavigationActionPolicy.CANCEL;
                          }
                          return NavigationActionPolicy.ALLOW;
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
