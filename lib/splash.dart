import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/auth_screens/on_boarding.dart';

import 'constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
      const Duration(
        seconds: 10,
      ),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnBoarding(),
          ),
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: const Center(
        child: Image(
          height: 100,
          width: 400,
          image: AssetImage("assets/images/mainLogo.png"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
