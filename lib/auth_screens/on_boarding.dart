import 'package:flutter/material.dart';
import 'package:flutter_onboard/flutter_onboard.dart';
import 'package:snipe59_mobile_digit/auth_screens/login.dart';
import 'package:snipe59_mobile_digit/constants.dart';

import '../widgets/simple_button.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

final List<OnBoardModel> onBoardData = [
  OnBoardModel(
    title: "Welcome to Snipe59",
    description: dummyText,
    imgUrl: 'assets/images/onBoard1.png',
  ),
  OnBoardModel(
    title: "Welcome to Snipe59",
    description: dummyText,
    imgUrl: 'assets/images/onBoard2.png',
  ),
  OnBoardModel(
    title: "Welcome to Snipe59",
    description: dummyText,
    imgUrl: 'assets/images/onBoard3.png',
  ),
];

class _OnBoardingState extends State<OnBoarding> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: OnBoard(
        onBoardData: onBoardData,
        pageController: pageController,
        titleStyles: TextStyle(
          color: titleColor,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        descriptionStyles: TextStyle(color: whiteColor, fontSize: 15),
        pageIndicatorStyle: PageIndicatorStyle(
          width: 50,
          activeColor: btnColor,
          activeSize: const Size(10, 10),
          inactiveColor: lightGrey,
          inactiveSize: const Size(8, 8),
        ),
        skipButton: const SizedBox(),
        nextButton: OnBoardConsumer(
          builder: (context, ref, child) {
            final state = ref.watch(onBoardStateProvider);
            return InkWell(
              onTap: () => _onNextTap(state),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SimpleButton(
                  txt: state.isLastPage ? "Done" : "Next",
                ),
              ),
            );
          },
        ),
        onDone: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
        },
      ),
    );
  }

  void _onNextTap(OnBoardState onBoardState) {
    if (!onBoardState.isLastPage) {
      pageController.animateToPage(
        onBoardState.page + 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutSine,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    }
  }
}
