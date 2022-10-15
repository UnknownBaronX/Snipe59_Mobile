import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/constants.dart';

class FieldText extends StatelessWidget {
  String hint;
  TextEditingController textEditingController= TextEditingController();

  FieldText({Key? key, required this.hint,this.textEditingController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(defaultPadding / 2),),
      child: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(defaultPadding / 2),
          hintText: hint,
          hintStyle: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: lightGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
        ),
      ),
    );
  }
}
