import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/auth_screens/login.dart';

import '../constants.dart';
import '../widgets/app_text.dart';
import '../widgets/simple_button.dart';
import '../widgets/textField.dart';
import 'forgot_password.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: EdgeInsets.all(defaultPadding / 1.5),
        child: SingleChildScrollView(
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
                    txt: "SignUp",
                    txtColor: titleColor,
                    fontWeight: FontWeight.bold,
                    size: 25,
                  ),
                ],
              ),
              SizedBox(
                height: defaultPadding * 2,
              ),
              FieldText(
                hint: "Name",trailing: false,
              ),
              SizedBox(
                height: defaultPadding / 2,
              ),
              FieldText(
                hint: "Username, Email & Phone Number",trailing: false,
              ),
              SizedBox(
                height: defaultPadding / 2,
              ),
              FieldText(
                hint: "Password",trailing: false,
              ),
              SizedBox(
                height: defaultPadding / 2,
              ),
              FieldText(
                hint: "Confirm Password",trailing: false,
              ),
              SizedBox(
                height: defaultPadding * 2,
              ),
              SimpleButton(txt: "SignUp"),
              SizedBox(
                height: defaultPadding,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    txt: "Already have an account? ",
                    txtColor: whiteColor,
                    size: 12,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                    child: AppText(
                      txt: "Login",
                      txtColor: titleColor,
                      size: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
