import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/helper/utils.dart';

import '../../constants/colors.dart';
import '../../constants/image_paths.dart';
import '../startup/slide_on_boarding_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  double _opacity = 0;
  late Timer _timer;
  final List<String> _title = [
    'Find New Friends Nearby',
    'Connect with Like-Minded People',
    'Enjoy Music with Friends',
  ];
  final List<String> _subtitle = [
    'Discover and connect with new friends to help you build meaningful relationships in your local community.',
    'Connect with like-minded people in your area using our powerful app, designed to help you discover people who share your interests and passions',
    'Stay up-to-date with the latest local events happening in your area feature, designed to keep you informed and connected with the community around you.'
  ];
  final List<String> _images = [
    ImagesPaths.onBoard3,
    ImagesPaths.onBoard2,
    ImagesPaths.onBoard1,
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _stopTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % (_images.length + 1);
        Log.log(_currentIndex);
        _opacity = 0;
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _opacity = 1;
          });
        });
        if (_currentIndex > 2) {
          _currentIndex = 0;
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        }
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_images[_currentIndex]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    kBlackLight.withOpacity(0.5), BlendMode.darken),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(seconds: 3),
            opacity: _opacity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      _title[_currentIndex],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _title.length,
                    itemBuilder: (BuildContext context, int index) {
                      return const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [],
                      );
                    },
                    onPageChanged: (value) {
                      _currentIndex = value;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < _title.length; index++)
                        _DotIndicator(isSelected: index == _currentIndex),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // <-- Radius
                    ),
                  ),
                  onPressed: () async {
                    //save in preference

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SlideOnBoardingScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Lets Explore",
                      style: TextStyle(
                        color: kWhiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                /* RichText(
                  textAlign:TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 11),
                    children: [
                      TextSpan(
                        text: 'Data collected during signup process will not be used for any commercial purposes. ',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text: 'Read our Privacy Policy',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms and Conditions.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                            decoration: TextDecoration.underline
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),*/

                const SizedBox(height: 75)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isSelected;

  const _DotIndicator({Key? key, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 6.0,
        width: 6.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}
