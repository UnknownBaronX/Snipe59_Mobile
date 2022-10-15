import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/widgets/simple_button.dart';

import '../constants.dart';
import '../widgets/app_text.dart';
import '../widgets/textField.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: defaultPadding * 5,
            ),
            Image.asset(
              "assets/images/mainLogo.png",
              height: 70,
              width: 250,
            ),
            SizedBox(
              height: defaultPadding * 3,
            ),
            Row(
              children: [
                AppText(
                  txt: "Forgot Password",
                  txtColor: titleColor,
                  fontWeight: FontWeight.bold,
                  size: 25,
                ),
              ],
            ),
            SizedBox(
              height: defaultPadding * 1.5,
            ),
            AppText(
              txt:
                  "Please enter the email address associated with your account.",
              txtColor: whiteColor,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(
              height: defaultPadding,
            ),
            FieldText(
              hint: "Username, Email & Phone Number",
            ),
            SizedBox(
              height: defaultPadding,
            ),
            SimpleButton(txt: "Submit")
          ],
        ),
      ),
    );
  }
}
