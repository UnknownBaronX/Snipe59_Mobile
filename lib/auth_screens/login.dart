import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/auth_screens/forgot_password.dart';
import 'package:snipe59_mobile_digit/auth_screens/signup.dart';
import 'package:snipe59_mobile_digit/constants.dart';
import 'package:snipe59_mobile_digit/widgets/app_text.dart';
import 'package:snipe59_mobile_digit/widgets/simple_button.dart';
import 'package:snipe59_mobile_digit/widgets/textField.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
                    txt: "Login",
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
                hint: "UserName, Email & Phone Number",
              ),
              SizedBox(
                height: defaultPadding / 2,
              ),
              FieldText(
                hint: "Password",
              ),
              SizedBox(
                height: defaultPadding / 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPassword(),
                        ),
                      );
                    },
                    child: AppText(
                      txt: "Forgot Password?",
                      txtColor: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: defaultPadding,
              ),
              SimpleButton(txt: "Login"),
              SizedBox(
                height: defaultPadding * 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: defaultPadding / 2.5),
                    height: 5,
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, btnColor],
                      ),
                    ),
                  ),
                  AppText(
                    txt: "Or Sign Up With",
                    txtColor: whiteColor,
                    size: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: defaultPadding / 2.5),
                    height: 5,
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          btnColor,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: defaultPadding * 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  roundIcon("assets/images/Google.png"),
                  roundIcon("assets/images/Facbook.png"),
                  roundIcon("assets/images/Apple.png"),
                ],
              ),
              SizedBox(
                height: defaultPadding * 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    txt: "Don't have an account? ",
                    txtColor: whiteColor,
                    size: 12,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUp(),
                        ),
                      );
                    },
                    child: AppText(
                      txt: "Create Account",
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

  Widget roundIcon(String path) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2.5),
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: whiteColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          path,
          height: 30,
          width: 30,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
