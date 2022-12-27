import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
  child: Container(
    color: const Color(0xff111823), //<-- SEE HERe

    child: Column(
      children: <Widget>[
         DrawerHeader(
            child: Stack(
              children: [],
            ),
            decoration: BoxDecoration(
              color: const Color(0xff111823),
              image: DecorationImage(
                image: AssetImage("assets/RT.png"),
                fit: BoxFit.scaleDown  ,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.discord, color: Colors.lightBlue,),
            title: Text("Join Discord!"),
            textColor: Colors.white,
            onTap: () async {
              _launchInBrowser(Uri.parse("https://discord.gg/futstarz"));
            },
          ),
          //section line



          Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ListTile(
            leading: Icon(Icons.info, color: Colors.white),
            title: Text("Version: 1.0.0"),
            textColor: Colors.white,
   
          )
        ),
      ),
          Divider(),

        
        //drawer stuffs
      ],
    ),
  ),
);
  } 

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
