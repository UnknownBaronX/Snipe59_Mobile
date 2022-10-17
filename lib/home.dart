import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/widgets/app_text.dart';

import 'constants.dart';
import 'widgets/drawer.dart';
import 'widgets/textField.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Image.asset(
          "assets/images/mainLogo.png",
          height: 50,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_sharp,
            ),
          ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
              ),
            );
          },)
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding / 2),
          child: Column(
            children: [
              SizedBox(
                height: defaultPadding,
              ),
              FieldText(
                hint: "Search...",
                trailing: false,
                color: drawerColor,
              ),
              SizedBox(
                height: defaultPadding ,
              ),
              fieldRow("Buy Price", "100"),
              SizedBox(
                height: defaultPadding / 2,
              ),
              fieldRow("No.of Cards to buy", "10"),
              SizedBox(
                height: defaultPadding / 2,
              ),
              fieldRow("Reset Price", "100"),
              SizedBox(
                height: defaultPadding / 2,
              ),
              fieldRow("Follow up actions", "List on Transfer"),
              SizedBox(
                height: defaultPadding / 2,
              ),
              fieldRow("List Duration", "1H"),
              SizedBox(
                height: defaultPadding / 2,
              ),
              checkRow("Select card on list"),
              checkRow("Select cheapest card on list"),
            ],
          ),
        ),
      ),
    );
  }

  Widget checkRow(String txt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //SizedBox
        AppText(
          txt: txt,
          size: defaultPadding,
          txtColor: whiteColor,
          fontWeight: FontWeight.bold,
        ), //Text
        //SizedBox
        /** Checkbox Widget **/
        Checkbox(
          checkColor: bgColor,
          value: value,
          activeColor: btnColor,
          onChanged: (bool? val) {
            setState(() {
              value = val!;
            });
          },
        ), //Checkbox
      ], //<Widget>[]
    );
  }

  Widget fieldRow(String title, String fieldText) {
    return Row(
      children: [
        Expanded(
            child: AppText(
          txt: title,
          txtColor: whiteColor,
          fontWeight: FontWeight.bold,
        )),
        Expanded(
          child: FieldText(
            hint: fieldText,
            trailing: false,
            color: drawerColor,
          ),
        )
      ],
    );
  }
}
