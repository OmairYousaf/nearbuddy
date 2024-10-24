import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  }) : super(key: key);

// This size work fine on my design, maybe you need some customization depends on your design

  static bool isWeb(){
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      return true;
    }
    if (kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      return true;
    } else {
      return false;
    }
  }
 static bool isMobile() {
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
      return true;

    }
    else if (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows) {
      return false;
    }
    else {
      return false;
    }
  }
 static bool isMobileWeb() {
    // Define a threshold width for considering it as a mobile view
    const double mobileWidthThreshold = 600.0;

    // Get the screen width using MediaQuery
    double screenWidth = MediaQueryData.fromView(WidgetsBinding.instance.window).size.width;

    // Check if the screen width is below the threshold
    return screenWidth < mobileWidthThreshold;
  }
  static bool isIOS(){
    if (defaultTargetPlatform == TargetPlatform.iOS ) {
      return true;

    }else {
      return false;
    }
  }
  // This isMobile, isTablet, isDesktop helep us later
 // static bool isMobile(BuildContext context) =>
 //     MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
          MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;




  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // If our width is more than 1100 then we consider it a desktop
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop;
        }
        // If width it less then 1100 and more then 650 we consider it as tablet
        else if (constraints.maxWidth >= 650) {
          return tablet;
        }
        // Or less then that we called it mobile
        else {
          return mobile;
        }
      },
    );
  }
}