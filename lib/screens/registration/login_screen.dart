import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/constants/image_paths.dart';
import 'package:nearby_buddy_app/helper/shared_preferences.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/user_exists_model.dart';
import 'package:nearby_buddy_app/models/user_model.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import 'package:nearby_buddy_app/screens/registration/verify_otp_screen.dart';
import '../../responsive.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../main_screen/main_screen.dart';
import 'complete_profile_screen.dart';
import 'login_screen_mobile.dart';
import 'login_screen_web.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? name;
  String? id;
  String? email;
  int _imageIndex = 0;
  final List<String> _imagePaths = [
    ImagesPaths.land1,
    ImagesPaths.land2,
    ImagesPaths.land3,
  ];
  Timer? _timer;
  bool _hidePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPasswordField = false;
  bool _isLoading = false;
  String _labelText = "Login";
  void _togglePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  @override
  void initState() {
    super.initState();
    _intit();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _imageIndex = (_imageIndex + 1) % _imagePaths.length;
      });
    });
  }
  _intit() async{
    await Hive.openBox(Utils().databaseName);
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Responsive.isMobile()
            ? LoginScreenMobile(
                snapOutKeyboard: () {
                  FocusScope.of(context).unfocus();
                },
                emailController: _emailController,
                isLoading: _isLoading,
                showPasswordField: _showPasswordField,
                hidePassword: _hidePassword,
                togglePasswordVisibility: _togglePasswordVisibility,
                labelText: _labelText,
                passwordController: _passwordController,
                onSocialMediaBtnClick: (LoginType loginType) {
                  authUser(context, loginType);
                },
                onForwardBtnClick: () {
                  _showPasswordField = false;
                  setState(() {
                    _isLoading = true;
                  });
                  _checkUserExists();
                })
            : LoginScreenWeb(
                snapOutKeyboard: () {
                  FocusScope.of(context).unfocus();
                },
                emailController: _emailController,
                isLoading: _isLoading,
                showPasswordField: _showPasswordField,
                hidePassword: _hidePassword,
                togglePasswordVisibility: _togglePasswordVisibility,
                labelText: _labelText,
                passwordController: _passwordController,
                onSocialMediaBtnClick: (LoginType loginType) {
                  authUser(context, loginType);
                },
                onForwardBtnClick: () {
                  _showPasswordField = false;
                  setState(() {
                    _isLoading = true;
                  });
                  _checkUserExists();
                },
                imagesPaths: _imagePaths,
                imageIndex: _imageIndex,
              ),
      ),
    );
  }

  void authUser(BuildContext context, LoginType loginType) async {
    CustomDialogs.showLoadingAnimation(context);
    UserCredential logInUser;

    if (loginType == LoginType.google) {
      logInUser = await authUsersGoogle(context);

      if (logInUser.user != null) {
        // Check is already sign up

        String? name = logInUser.user?.displayName;
        String? id = logInUser.user?.uid;
        String? email = logInUser.user?.email;

        await callLoginApi(
            email: email!, password: id!.substring(2, 8), loginType: loginType, fullname: name!);
      } else {
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, "Error while signing up");
      }
    } else if (loginType == LoginType.facebook) {
      dynamic loginInUser = await authUsersFacebook(context);
      Log.log(loginInUser);
      if (loginInUser['name'] != null) {
        // Check is already sign up

        String? name = loginInUser['name'];
        String? id = loginInUser['name'];
        String? email = loginInUser['email'];

        await callLoginApi(email: email!, password: id!, loginType: loginType, fullname: name!);
      } else {
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, "Error while signing up");
      }
    } else if (loginType == LoginType.apple) {
      final appleProvider = AppleAuthProvider();
      logInUser = await FirebaseAuth.instance.signInWithProvider(appleProvider);

      if (logInUser.user != null) {
        // Check is already sign up

        String? name = logInUser.user?.displayName;
        String? id = logInUser.user?.uid;
        String? email = logInUser.user?.email;

        await callLoginApi(
            email: email!, password: id!.substring(2, 8), loginType: loginType, fullname: name!);
      } else {
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, "Error while signing up");
      }
    } else {
      if (isValidInput()) {
        callLoginApi(
            email: _emailController.text,
            password: _passwordController.text,
            loginType: loginType,
            fullname: "");
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  Future<UserCredential> authUsersGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  callLoginApi({
    required String email,
    required String password,
    required LoginType loginType,
    required String fullname,
  }) async {
    try {
      //Calling login API
      int result = await ApiService().loginUser(
        email: email,
        password: password,
        loginType: loginType,
      );

      // 100 means logged in 200 means error 99  means register
      // 300 means password
      bool isSuccessfullyLogged = false;
      if (result == 100) {
        isSuccessfullyLogged = true; // because status means clear
      } else if (result == 200) {
        isSuccessfullyLogged = false; //status means error due to some ..
      } else if (result == 99) {
        isSuccessfullyLogged = false;
      } else if (result == 300) {
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, 'Password field is wrong');
        return;
      }
      if (isSuccessfullyLogged) {
        Navigator.of(context).pop();//dismiss the dialog
        UserModel userModel = UserModel.fromJson(  //..when the success ful call is made the data is stored in the sharedprefs
          await SharedPrefs.loadFromSharedPreferences(SharedPrefs().PREFS_LOGIN_USER_DATA),
        );
        //AFTER KNOWING THAT LOGIN IS SUCCESSFUL WEE THEN CHECK IF THE EMAIL HAS BEEN VERIFIED
        if (checksEmailNotVerfied(userModel) && loginType == LoginType.manual) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VerifyOTPScreen(
                email: email,
                user: userModel,
              ),
            ),
          );
        } else if (checksDetails(userModel)) { //FOR SCENARIO IF THE USER HAS LOGGED BUT COULDNT UPDATE PROFILE
          if (kIsWeb) {
            Box box = Hive.box(Utils().databaseName);
            box.put("name", fullname);

            box.put("password", password);

            box.put("email", email);

            box.put("loginType", loginType.name);

            Navigator.pushNamed(
              context,
              "/registerProfile",
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CompleteProfileScreen(
                  name: fullname,
                  password: password,
                  email: email,
                  loginType: loginType,
                ),
              ),
            );
          }
        } else {
          if(kIsWeb){
            bool result = await SharedPrefs()
                .saveToSharedPreferences(SharedPrefs().PREFS_NAME_ISLOGGED, true.toString());
            Box box = Hive.box(Utils().databaseName);
            box.put("user", userModel.toJson());

            Navigator.pushNamed(context, '/mainpage',);
          }else {
            bool result = await SharedPrefs()
                .saveToSharedPreferences(SharedPrefs().PREFS_NAME_ISLOGGED, true.toString());
            Log.log("${result}Logged");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainScreen(userModel: userModel),
              ),
            );
          }
        }
      } else {
        Navigator.of(context).pop();
        if (kIsWeb) {
          Box box = Hive.box(Utils().databaseName);
          box.put("name", fullname);

          box.put("password", password);

          box.put("email", email);

          box.put("loginType", loginType.name);

          Navigator.pushNamed(
            context,
            "/registerProfile",
          );
          Navigator.pushNamed(
            context,
            "/registerProfile",
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CompleteProfileScreen(
                name: fullname,
                password: password,
                email: email,
                loginType: loginType,
              ),
            ),
          );
        }
      }
    } catch (e) {
      Log.log(e.toString());
    }
  }

  bool isValidInput() {
    // Check if email and password are not empty
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, "Please enter email and password");
      return false;
    }

    // Check if email is valid
    bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text);
    if (!isValidEmail) {
      CustomSnackBar.showErrorSnackBar(context, "Please enter valid email");
      return false;
    }

    return true;
  }

  bool checksEmailNotVerfied(UserModel userModel) {
    try {
      return !userModel.emailVerified;
    } catch (E) {
      return false;
    }
  }

  bool checksDetails(UserModel userModel) {
    if (userModel.birthday.isNotEmpty &&
        userModel.gender.isNotEmpty &&
        userModel.image != 'placeholder_user.png' &&
        userModel.location.isNotEmpty &&
        userModel.selectedInterests != 0) {
      return false;
    } else {
      return true;
    }
  }

  authUsersFacebook(BuildContext context) async {
    // check if is running on Web
    if (kIsWeb) {
      // initialiaze the facebook javascript SDK
      await FacebookAuth.i.webAndDesktopInitialize(
        appId: "1383613055761637",
        cookie: true,
        xfbml: true,
        version: "v15.0",
      );
    }
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      return userData;
    }
  }

  Future<void> _checkUserExists() async {
    bool isValidEmail =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text) &&
            (_emailController.text.isNotEmpty);
    if (isValidEmail) {
      try {
        UserExistenceResult isUserExist =
            await ApiService().checkIfUserExists(email: _emailController.text);

        if (isUserExist.userExists) {
          if (isUserExist.loginMethod == LoginType.google) {
            CustomSnackBar.showBasicSnackBar(
                context, "You have already signed up using Google!\n Please login using Google Button");
          } else if (isUserExist.loginMethod == LoginType.facebook) {
            CustomSnackBar.showBasicSnackBar(
                context, "You have already signed up using Facebook!\n Please login using Facebook Button");
          } else if (isUserExist.loginMethod == LoginType.apple) {
            CustomSnackBar.showBasicSnackBar(
                context, "User Exists! Please login using Apple Button");
          } else {
        //    CustomSnackBar.showSuccessSnackBar(context, "Email registered!");

            _labelText = "Login";
            _showPasswordField = true;
          }
        } else {
          CustomSnackBar.showErrorSnackBar(context, "Please Sign up!");
          _showPasswordField = true;
          _labelText = "Register";
        }
      } catch (e) {}
    }
    setState(() {
      _isLoading = false;
    });
  }
}
