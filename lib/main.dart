import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewPlusController _controller;

  double _height = 1000;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewPlus(
          initialUrl: 'asset/popup.html',
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onPageFinished: (url) {
            _controller.getHeight().then((double height) {
              print("Height: " + height.toString());
              setState(() {
                _height = height;
              });
            });
          },
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
