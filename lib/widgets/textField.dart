import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/constants.dart';

class FieldText extends StatelessWidget {
  String hint;
  TextEditingController? textEditingController;
  void Function(String text)? onchange;
   bool? trailing=false ;
   Color? color;

  FieldText({Key? key, required this.hint, this.textEditingController,this.onchange,this.trailing,this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(defaultPadding / 2),
      ),
      child: TextFormField(
        controller: textEditingController,
        onChanged: onchange,

        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(defaultPadding / 2),
          hintText: hint,

          suffixIcon: trailing!?const Icon(Icons.search):const Icon(Icons.add,color: Colors.transparent,),
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
