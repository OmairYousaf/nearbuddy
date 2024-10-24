import 'dart:async';

import 'package:flutter/material.dart';

import 'package:nearby_buddy_app/constants/image_paths.dart';
import 'package:slide_action/slide_action.dart';

import '../../helper/shared_preferences.dart';
import '../registration/login_screen.dart';

class SlideOnBoardingScreen extends StatefulWidget {
  const SlideOnBoardingScreen({super.key});

  @override
  _SlideOnBoardingScreenState createState() => _SlideOnBoardingScreenState();
}

class _SlideOnBoardingScreenState extends State<SlideOnBoardingScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();
  final ScrollController _scrollController4 = ScrollController(); // for making it
  double _scrollOffset = 0.0;
  double _scrollOffset2 = 0.0;
  double _scrollOffset3 = 0.0;
  Timer? _scrollTimer;
  List<String> interestsImages = [
    ImagesPaths.int1,
    ImagesPaths.int2,
    ImagesPaths.int3,
    ImagesPaths.int4,
    ImagesPaths.int5,
  ];
  List<String> images = [
    ImagesPaths.pot,
    ImagesPaths.pot2,
    ImagesPaths.pot3,
    ImagesPaths.pot4,
    ImagesPaths.pot5,
    ImagesPaths.pot6,
  ];
  @override
  void initState() {
    super.initState();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!_scrollController.position.activity!.isScrolling) {
        _scrollOffset += 3.0;
        if (_scrollOffset >= _scrollController.position.maxScrollExtent) {
          _scrollOffset = 0.0;
          _scrollController.jumpTo(_scrollOffset);
        }
        _scrollController.animateTo(
          _scrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      }
      if (!_scrollController1.position.activity!.isScrolling) {
        _scrollOffset2 -= 8.0; // Change increment to decrement
        if (_scrollOffset2 <= 0.0) {
          // Change condition to check if offset is less than or equal to zero
          _scrollOffset2 = _scrollController1.position.maxScrollExtent;
          _scrollController1.jumpTo(_scrollOffset2);
        }
        _scrollController1.animateTo(
          _scrollOffset2,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      }
      if (!_scrollController2.position.activity!.isScrolling) {
        _scrollOffset += 5.0;
        if (_scrollOffset >= _scrollController2.position.maxScrollExtent) {
          _scrollOffset = 0.0;
          _scrollController2.jumpTo(_scrollOffset);
        }
        _scrollController2.animateTo(
          _scrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      }

      if (!_scrollController3.position.activity!.isScrolling) {
        _scrollOffset3 -= 8.0; // Change increment to decrement
        if (_scrollOffset3 <= 0.0) {
          // Change condition to check if offset is less than or equal to zero
          _scrollOffset3 = _scrollController3.position.maxScrollExtent;
          _scrollController3.jumpTo(_scrollOffset3);
        }
        _scrollController3.animateTo(
          _scrollOffset3,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _scrollController2.dispose();

    _scrollController3.dispose();

    _scrollController4.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildImagesScrolls(),
          Align(
            alignment: Alignment.bottomCenter,
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white
                  ],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Text(
                      "Discover and Connect with Nearby People",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Explore the Realm of New Connections, Connect with Like-minded.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: /*SlideAction(
                        borderRadius: 25,
                        sliderButtonIconSize: 32,
                        elevation: 0,
                        onSubmit: () async {
                          //save in preference
                          bool result = await SharedPrefs().saveValue(
                              SharedPrefs().PREFS_NAME_ONBOARD, true);
                          if (result) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          }
                        },
                        innerColor: Colors.white,
                        outerColor: kPrimaryColor,
                        text: 'Join Now',
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        reversed: true,
                        submittedIcon: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1,
                        ),
                        sliderButtonIcon:
                            const Icon(Icons.keyboard_double_arrow_right),
                        sliderRotate: false,
                      )*/
                            SlideAction(
                          trackBuilder: (context, state) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "Slide to Continue",
                                ),
                              ),
                            );
                          },
                          thumbBuilder: (context, state) {
                            return Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.keyboard_double_arrow_right,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          action: () async {
                            //save in preference
                            bool result = await SharedPrefs().saveValue(
                                SharedPrefs().PREFS_NAME_ONBOARD, true);
                            if (result) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            }
                          },
                        ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildImagesScrolls() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Expanded(
            child: Transform.rotate(
              angle: 94,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.topLeft,
                      colors: [
                        Colors.purple,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.purple
                      ],
                      stops: [
                        0.0,
                        0.1,
                        0.9,
                        1.0
                      ], // 10% purple, 80% transparent, 10% purple
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        100, // Set a large itemCount for repeating effect
                    itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10.0), // Set the desired border radius value
                          child: Image.asset(
                            images[index % images.length],
                            fit: BoxFit
                                .cover, // Set the desired fit mode for the image
                            // Set the desired height of the image
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Transform.rotate(
              angle: 94,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.topLeft,
                      colors: [
                        Colors.purple,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.purple
                      ],
                      stops: [
                        0.0,
                        0.1,
                        0.9,
                        1.0
                      ], // 10% purple, 80% transparent, 10% purple
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: ListView.builder(
                    controller: _scrollController1,
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        100, // Set a large itemCount for repeating effect
                    itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10.0), // Set the desired border radius value
                          child: Image.asset(
                            interestsImages[index % interestsImages.length],
                            fit: BoxFit
                                .cover, // Set the desired fit mode for the image
                            // Set the desired height of the image
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Transform.rotate(
                angle: 94,
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.topLeft,
                      colors: [
                        Colors.purple,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.purple
                      ],
                      stops: [
                        0.0,
                        0.1,
                        0.9,
                        1.0
                      ], // 10% purple, 80% transparent, 10% purple
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: ListView.builder(
                    controller: _scrollController2,
                    scrollDirection: Axis.horizontal,
                    itemCount: 100,
                    itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10.0), // Set the desired border radius value
                          child: Image.asset(
                            images[index % images.length],
                            fit: BoxFit
                                .cover, // Set the desired fit mode for the image
                            // Set the desired height of the image
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Transform.rotate(
              angle: 94,
              child: ShaderMask(
                shaderCallback: (Rect rect) {
                  return const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.topLeft,
                    colors: [
                      Colors.purple,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.purple
                    ],
                    stops: [
                      0.0,
                      0.1,
                      0.9,
                      1.0
                    ], // 10% purple, 80% transparent, 10% purple
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstOut,
                child: ListView.builder(
                  controller: _scrollController3,
                  scrollDirection: Axis.horizontal,
                  itemCount: 100,
                  itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            10.0), // Set the desired border radius value
                        child: Image.asset(
                          interestsImages[index % interestsImages.length],
                          fit: BoxFit
                              .cover, // Set the desired fit mode for the image
                          // Set the desired height of the image
                        ),
                      )),
                ),
              ),
            ),
          ),
          Expanded(
            child: Transform.rotate(
              angle: 94,
              child: ListView.builder(
                controller: _scrollController4,
                scrollDirection: Axis.horizontal,
                itemCount: 100,
                itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          10.0), // Set the desired border radius value
                      child: Image.asset(
                        interestsImages[index % interestsImages.length],
                        fit: BoxFit
                            .cover, // Set the desired fit mode for the image
                        // Set the desired height of the image
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../constants/colors.dart';
import '../../constants/image_paths.dart';
import '../../helper/shared_preferences.dart';
import '../register/login_screen.dart';

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
  List<String> _title = [
    'Find Friends Nearby',
    'Connect with Like-Minded People',
    'Local Event Updates',
  ];
  List<String> _subtitle = [
    'Discover and connect with new friends to help you build meaningful relationships in your local community.',
    'Connect with like-minded people in your area using our powerful app, designed to help you discover people who share your interests and passions',
    'Stay up-to-date with the latest local events happening in your area feature, designed to keep you informed and connected with the community around you.'
  ];
  List<String> _images = [
    ImagesPaths.image1,
    ImagesPaths.image2,
    ImagesPaths.image3,
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
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
        _opacity = 0;
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _opacity = 1;
          });
        });
        if (_currentIndex == 3) {
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

          Positioned.fill(
            child:ColorFiltered(
              colorFilter: ColorFilter.mode(kBlackLight.withOpacity(0.6), BlendMode.darken),
              child: FadeInImage(
                fit: BoxFit.cover,
                placeholder: AssetImage(ImagesPaths.image3),
                image: AssetImage(_images[_currentIndex]),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _title.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: SizedBox()),
                            Text(
                              _title[_currentIndex],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: kWhiteColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'),
                            ),
                            Text(
                              _subtitle[_currentIndex],
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  color: kWhiteColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Poppins'),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      },
                      onPageChanged: (value) {
                        _currentIndex = value;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), // <-- Radius
                      ),
                    ),
                    onPressed: () async {
                      //save in preference
                      bool result = await SharedPrefs()
                          .saveValue(SharedPrefs().PREFS_NAME_ONBOARD, true);
                      if (result) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      }
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
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontSize: 11),
                      children: [
                        TextSpan(
                          text:
                              'Data collected during signup process will not be used for any commercial purposes. ',
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
                              decoration: TextDecoration.underline),
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
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int index = 0; index < _title.length; index++)
                          DotIndicator(isSelected: index == _currentIndex),
                      ],
                    ),
                  ),
                  const SizedBox(height: 75)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  final bool isSelected;

  const DotIndicator({Key? key, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 10.0,
        width: 10.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}
*/
