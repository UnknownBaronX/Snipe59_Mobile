import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/widgets/simple_button.dart';
import '../constants.dart';
import 'widgets/app_text.dart';
import 'widgets/textField.dart';

class UrlScreen extends StatefulWidget {
  const UrlScreen({Key? key}) : super(key: key);

  @override
  _UrlScreenState createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> {
  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/images/mainLogo.png",
                    height: 70,
                    width: 250,
                  ),
                ],
              ),
              SizedBox(
                height: defaultPadding * 2,
              ),
              Image.asset("assets/images/onBoard2.png", fit: BoxFit.cover),
              SizedBox(
                height: defaultPadding * 2,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      txt: 'Enter your URL',
                      size: defaultPadding,
                      fontWeight: FontWeight.bold,
                      txtColor: whiteColor,
                    ),
                    SizedBox(
                      height: defaultPadding / 1.1,
                    ),
                    FieldText(
                      hint: "Enter URL",
                      textEditingController: urlController,
                      onchange: (val) {
                        urlController.text = val;
                        setState(() {});
                      },
                    ),
                    SizedBox(
                      height: defaultPadding * 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => urlController
                                  .text.isEmpty
                              ? const SizedBox()
                              : AlertDialog(
                                  content: AppText(
                                    txt:
                                        'Your want to run your app in the background',
                                    size: defaultPadding,
                                    fontWeight: FontWeight.w700,
                                    txtColor: Colors.black,
                                  ),
                                  actions: [
                                    FittedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: btn(context, false, 'No')),
                                          SizedBox(
                                            width: defaultPadding,
                                          ),
                                          InkWell(
                                              onTap: () {},
                                              child: btn(context, true, 'Yes')),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                        );
                      },
                      child: SimpleButton(
                        txt: urlController.text.isEmpty ? "Edit" : "Submit",
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget btn(BuildContext context, bool val, String txt) {
  return Container(
    width: 160,
    height: 50,
    padding: EdgeInsets.symmetric(
        vertical: defaultPadding / 2, horizontal: defaultPadding / 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: val == true ? btnColor : Colors.transparent,
      border: Border.all(color: val == true ? btnColor : titleColor, width: 1),
    ),
    child: Center(
      child: Text(
        txt,
        style: TextStyle(
          color: val == true ? whiteColor : titleColor,
          fontSize: defaultPadding * 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
