import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/screens/registration/onboarding_screen.dart';


import '../../constants/image_paths.dart';
import '../../helper/shared_preferences.dart';
import '../../helper/utils.dart';
import '../../models/user_model.dart';
import '../main_screen/main_screen.dart';
import '../registration/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 5), () async {
      if (mounted) {
        //to make sure this does not runs before context is null
        bool hasSkipped =
        await SharedPrefs().hasValue(SharedPrefs().PREFS_NAME_ONBOARD);
        Log.log(hasSkipped);
        if (hasSkipped) {
          bool isLogged=
              await SharedPrefs().hasValue(SharedPrefs().PREFS_NAME_ISLOGGED);
          Log.log("${isLogged}IsLogged");
          if(isLogged){
            UserModel userModel = UserModel.fromJson(
                await SharedPrefs.loadFromSharedPreferences(
                    SharedPrefs().PREFS_LOGIN_USER_DATA));

            Log.log(userModel.toString());
           try{
             Navigator.pushReplacement(
               context,
               MaterialPageRoute(builder: (context) => MainScreen(userModel: userModel,)),
             );
           }catch(e){
             Log.log(e.toString());
           }
          }else{
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }

        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
          );
        }
      }
    });

    //<- Creates a widget that displays an image.

    return splash();
  }

  splash() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
               kPrimaryDark,
               kPrimaryColor,
              ],
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(ImagesPaths.background), fit: BoxFit.cover),
          ),
        ),
        Center(
          child: Container(
              child: Image.asset(
                ImagesPaths.lightLogo,
                width: 150,
                height: 150,
              )),
        )
      ],
    );
  }
}
