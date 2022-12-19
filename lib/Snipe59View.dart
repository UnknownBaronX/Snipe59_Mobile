import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipe59/client/ProfileBloc.dart';
import 'package:snipe59/client/Snipe59Bloc.dart';
import 'package:snipe59/client/Snipe59Event.dart';
import 'package:snipe59/client/Snipe59State.dart';

import 'WebappView.dart';

class Snipe59View extends StatefulWidget {
  const Snipe59View({Key? key}) : super(key: key);

  @override
  State<Snipe59View> createState() => _Snipe59ViewState();
}

class _Snipe59ViewState extends State<Snipe59View> {
  late Snipe59Bloc _snipe59bloc;
  late SharedPreferences _preferences;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSharedPref();
    developer.log("InitState", name: "Snipe59 view");
    _snipe59bloc = context.read<Snipe59Bloc>();
    _snipe59bloc.add(ResetLicence());
  }

  void loadSharedPref() async {
    _preferences = await SharedPreferences.getInstance();
    _textController.text = _preferences.getString("licence") != null
        ? _preferences.getString("licence").toString()
        : "";
  }

  void _onClearTapped() {
    _textController.text = '';
  }

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: const Color(0xFF1D1B28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 200,
              width: 300,
              child: Image.asset("assets/RT.png"),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: 325,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Snipe 59",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      '''Enter your licence key to launch Web-app,
                       or use key: FREE''',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: 260,
                    height: 60,
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                          labelText: "Your licence key",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: () => {
                      _snipe59bloc.add(
                          FetchLicence(licence: _textController.text.trim()))
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 250,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF8A2387),
                                Color(0xFFE94057),
                                Color(0xFFF27121),
                              ])),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 30, top: 30),
                    child: BlocConsumer<Snipe59Bloc, Snipe59State>(
                        listener: (context, state) {
                      if (state is Snipe59StateSuccess) {
                        _preferences.setString(
                            "licence", _textController.text.trim().toString());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (_) => ProfileBloc(
                                    sharedPreferences: _preferences),
                                child: WebAppView(),
                              ),
                            ));
                      }
                    }, builder: (context, state) {
                      if (state is Snipe59StateSuccess) {
                        return Text(
                          "Licence valid, webapp launching",
                          style: TextStyle(color: Colors.green),
                        );
                      } else if (state is Snipe59StateError) {
                        if (state.code == 404)
                          return Text(
                            "Licence not found",
                            style: TextStyle(color: Colors.redAccent),
                          );
                        else if (state.code == 500)
                          return Text(
                            "Autobuyer offline. Please look within our discord for more information.",
                            //centered text
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.redAccent),
                          );
                        else if (state.code == -1)
                          return Text(
                            "Licence invalid",
                            style: TextStyle(color: Colors.redAccent),
                          );

                        return Container();
                      }
                      return Container();
                    }),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
