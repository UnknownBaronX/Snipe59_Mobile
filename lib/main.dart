import 'dart:io';

import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'NavBar.dart';
import 'package:snipe59/PricesView.dart';
import 'package:snipe59/Snipe59View.dart';
import 'package:snipe59/client/FutsovereignBloc.dart';
import 'package:snipe59/client/FutsovereignClient.dart';
import 'package:snipe59/client/FutsovereignEvent.dart';
import 'package:snipe59/client/FutsovereignState.dart';
import 'package:snipe59/client/Snipe59Bloc.dart';
import 'package:snipe59/client/Snipe59Client.dart';
import 'package:snipe59/client/Snipe59Repository.dart';
import 'package:snipe59/entity/FutsovereignItem.dart';
import 'dart:developer' as developer;

import 'client/FutsovereignRepository.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FutsovereignRepository futsovereignRepository = FutsovereignRepository(
    FutsovereignClient(),
  );

  final Snipe59Repository snipe59repository = Snipe59Repository(
    Snipe59Client(),
  );
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(MyApp(
      futsovereignRepository: futsovereignRepository,
      snipe59Repository: snipe59repository));
}

class MyApp extends StatelessWidget {
  const MyApp(
      {Key? key,
      required this.futsovereignRepository,
      required this.snipe59Repository})
      : super(key: key);
  final FutsovereignRepository futsovereignRepository;
  final Snipe59Repository snipe59Repository;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snipe 59 Mobile',
      theme: ThemeData(
          iconTheme: IconThemeData(color: Colors.white),
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1D1B28)),
      home: MyHomePage(
        repository: futsovereignRepository,
        snipe59Repository: snipe59Repository,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {Key? key, required this.repository, required this.snipe59Repository})
      : super(key: key);
  final FutsovereignRepository repository;
  final Snipe59Repository snipe59Repository;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const  Color(0xff111823),
      ),
      drawer: NavBar(),
      extendBodyBehindAppBar: false,
      bottomNavigationBar: CircleNavBar(
        iconDurationMillSec: 0,
        tabDurationMillSec: 0,
        activeIcons: [
          Image.asset(
            "assets/tp-128.png",
          ),
          Image.asset(
            "assets/tp-128.png",
          ),
          Image.asset(
            "assets/RT.png",
          ),
        ],
        inactiveIcons: const [
          Text("Prices PS/XB"),
          Text("Prices PC"),
          Text("Snipe 59"),
        ],
        color: Colors.white,
        height: 60,
        circleWidth: 60,
        activeIndex: tabIndex,
        onTab: (v) {
          tabIndex = v;
          pageController.jumpToPage(tabIndex);
        },
        shadowColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        left: false,
        top: true,
        right: false,
        bottom: true,
        child: PageView(
          controller: pageController,
          onPageChanged: (v) {
            tabIndex = v;
          },
          children: [
            BlocProvider(
              create: (_) => FutsovereignBloc(
                  futsovereignRepository: this.widget.repository),
              child: PricesView(
                console: "ps",
              ),
            ),
            BlocProvider(
              create: (_) => FutsovereignBloc(
                  futsovereignRepository: this.widget.repository),
              child: PricesView(
                console: "pc",
              ),
            ),
            BlocProvider(
              create: (_) => Snipe59Bloc(
                  snipe59Repository: this.widget.snipe59Repository,
                  futsovereignRepository: this.widget.repository),
              child: Snipe59View(),
            ),
          ],
        ),
      ),
    );
  }
}
