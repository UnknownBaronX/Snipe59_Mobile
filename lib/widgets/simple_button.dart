import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/constants.dart';

import 'app_text.dart';

class SimpleButton extends StatefulWidget {
  String txt;
  SimpleButton({Key? key, required this.txt}) : super(key: key);

  @override
  State<SimpleButton> createState() => _SimpleButtonState();
}

class _SimpleButtonState extends State<SimpleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(

      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(defaultPadding / 2),
      ),
      child: Center(
          child: AppText(
        txt: widget.txt,
        txtColor: whiteColor,
        fontWeight: FontWeight.bold,
        size: 15,
      )),
    );
  }
}
