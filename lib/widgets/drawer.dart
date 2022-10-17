import 'package:flutter/material.dart';
import 'package:snipe59_mobile_digit/constants.dart';
import 'package:snipe59_mobile_digit/widgets/app_text.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            color: btnColor,
            child: Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage(
                          "assets/images/model.png",
                        ),
                        fit: BoxFit.fill)),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: drawerColor,
              child: Column(
                children: [
                  listTile("Home", Icons.home_filled),
                  listTile("Buy/Sell", Icons.shopping_cart),
                  listTile("Misc", Icons.miscellaneous_services),
                  listTile("Settings", Icons.settings),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget listTile(String text, IconData iconDta) {
    return Column(
      children: [
        ListTile(
          iconColor: whiteColor,
          title: AppText(
            txt: text,
            fontWeight: FontWeight.bold,
            txtColor: whiteColor,
          ),
          leading: Icon(iconDta),
        ),
        Divider(
          color: whiteColor,
        )
      ],
    );
  }
}
