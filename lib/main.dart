import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/auth_screens/login.dart';
import 'package:snipe59_mobile_digit/home.dart';
import 'package:snipe59_mobile_digit/url_screen.dart';

import 'splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}
