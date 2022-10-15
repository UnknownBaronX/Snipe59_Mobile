import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  String? txt;
  FontWeight? fontWeight;
  double? size;
  Color? txtColor;
  AppText(
      {Key? key, required this.txt, this.fontWeight, this.size, this.txtColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      txt!,
      style: TextStyle(
          color: txtColor,
          fontSize: size,
          fontFamily: "Montserrat",
          fontWeight: fontWeight),
    );
  }
}
