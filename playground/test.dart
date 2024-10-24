/*
import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/components/customDialogs.dart';
import 'package:nearby_buddy_app/components/customSnackBars.dart';
import 'package:nearby_buddy_app/constants/iconPaths.dart';
import 'package:nearby_buddy_app/constants/imagePaths.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nearby_buddy_app/helper/sharedPrefs.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/models/userModel.dart';
import 'package:nearby_buddy_app/routes/apiService.dart';
import 'package:nearby_buddy_app/screens/register/completeProfileScreen.dart';
import 'package:nearby_buddy_app/screens/register/verifyOtpScreen.dart';
import '../../components/controls.dart';
import '../../constants/colors.dart';
import '../../responsive.dart';
import '../mainScreen/MainScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
  List<String> _imagePaths = [
    ImagesPaths.IMAGE1,
    ImagesPaths.IMAGE2,
    ImagesPaths.IMAGE3,
  ];
  Timer? _timer;
  bool _hidePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _imageIndex = (_imageIndex + 1) % _imagePaths.length;
      });
    });
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
            ? _buildMobileBackground()
            : _buildWebBackground(),
      ),
    );
  }

  _buildDecoration() {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kPurple,
              kPrimaryColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Image.asset(ImagesPaths.BUBBLE1)),
            Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(ImagesPaths.BUBBLE2)),
          ],
        ));
  }

  _buildMobileBackground() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(flex: 2, child: _buildDecoration()),
              Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),

                  )),
            ],
          ),
          SingleChildScrollView(
            child: Align(
                alignment: Alignment.center,
                child: _buildLoginButtons(isWeb: false)),
          )
        ],
      ),
    );
  }

  _buildWebBackground() {
    return Responsive(
        mobile: _buildSubWebView(isSmallerView: true),
        tablet: _buildSubWebView(isSmallerView: true),
        desktop: _buildSubWebView(isSmallerView: false));
  }

  _buildSubWebView({required bool isSmallerView}) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(Color(0x73c982c2), BlendMode.screen),
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: AssetImage(ImagesPaths.IMAGE3),
              image: AssetImage(_imagePaths[_imageIndex]),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: _buildLoginButtons(isWeb: true),
          ),
        ),
      ],
    );
  }

  _buildLoginButtons({required bool isWeb}) {
    return Column(
      children: [
        SizedBox(height: 10,),
        Image.asset(
          ImagesPaths.LIGHT_LOGO,
          width: 150,
          height: 100,
        ),
        Text(
          "Find People with mutual interest ",
          style: TextStyle(
            color: kWhiteColor,
            fontSize: 16,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 25, color: Color(0x33B6B6B6), offset: Offset(0, -8))
              ],
              color: kWhiteColor,
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF8F8F8),
                  hintText: 'Email',
                  enabledBorder: const OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide:
                    const BorderSide(color: Color(0xFFF8F8F8), width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF8F8F8),
                  hintText: 'Password',
                  enabledBorder: const OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide:
                    const BorderSide(color: Color(0xFFF8F8F8), width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  authUser(context, LoginType.MANUAL);
                },
                child: Text('Continue'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: kGrey,
                        height: 36,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Or Continue',
                        style: TextStyle(fontSize: 16.0,color: kGreyDark,),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: kGrey,
                        height: 36,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),


              buildElevatedSocialMediaButton(
                  icon: IconPaths.GOOGLE,
                  backgroundColor: Color(0xFFF5F5F5),
                  title: "via Google",
                  textColor: Colors.black,
                  onTap: () {
                    authUser(context,LoginType.GOOGLE);
                  }),
              buildElevatedSocialMediaButton(
                  icon: IconPaths.FACEBOOK,
                  backgroundColor: Color(0xFF1877F2),
                  title: "via Facebook",
                  textColor: Colors.white,
                  onTap: () {
                    authUser(context, LoginType.FACEBOOK);

                  }),
              buildElevatedSocialMediaButton(
                  icon: IconPaths.APPLE,
                  backgroundColor: Color(0xFF000000),
                  title: "via Apple",
                  textColor: Colors.white,
                  onTap: () {}),
              SizedBox(
                height: 10,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 12),
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
            ],
          ),
        ),
      ],
    );
  }

  void authUser(BuildContext context,LoginType loginType) async {
    CustomDialogs.showLoadingAnimation(context);
    UserCredential logInUser;

    if (loginType==LoginType.GOOGLE) {
      logInUser = await authUsersGoogle(context);

      if (logInUser.user != null) {
        // Check is already sign up

        String? name = logInUser.user?.displayName;
        String? id = logInUser.user?.uid;
        String? email = logInUser.user?.email;

        await callLoginApi(
            email: email!,
            password: id!.substring(2, 8),
            loginType: loginType,
            fullname: name!);
      } else {
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, "Error while signing up");
      }
    } else if(loginType==LoginType.FACEBOOK){
      dynamic loginInUser=await authUsersFacebook(context);
      if (loginInUser['name'] != null) {
        // Check is already sign up

        String? name = loginInUser['name'];
        String? id = loginInUser['name'];
        String? email = loginInUser['email'];

        await callLoginApi(
            email: email!,
            password: id!,
            loginType: loginType,
            fullname: name!);
      } else {
        Navigator.of(context).pop();
        CustomSnackBar.showErrorSnackBar(context, "Error while signing up");
      }

    }else if(loginType==LoginType.APPLE){
      final appleProvider = AppleAuthProvider();
      logInUser = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      loginType = LoginType.APPLE;
    }
    else {

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
      bool loginApiCall = await ApiService().loginUser(
        email: email,
        password: password,
        loginType: loginType,
      );

      if (loginApiCall) {
        Navigator.of(context).pop();
        UserModel userModel = UserModel.fromJson(
          await SharedPrefs.loadFromSharedPreferences(
              SharedPrefs().PREFS_LOGIN_USER_DATA),
        );
        if (checksEmailNotVerfied(userModel) && loginType == LoginType.MANUAL) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VerifyOTPScreen(
                email: email,
                user: userModel,
              ),
            ),
          );
        } else if (checksDetails(userModel)) {
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
        } else {
          bool result=  await SharedPrefs().saveToSharedPreferences(
              SharedPrefs().PREFS_NAME_ISLOGGED, true.toString());
          Log.log(result.toString()+"Logged");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScreen(userModel: userModel),
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
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
    } catch (e) {}
  }

  bool isValidInput() {
    // Check if email and password are not empty
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      CustomSnackBar.showErrorSnackBar(
          context, "Please enter email and password");
      return false;
    }

    // Check if email is valid
    bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text);
    if (!isValidEmail) {
      CustomSnackBar.showErrorSnackBar(context, "Please enter valid email");
      return false;
    }

    return true;
  }

  bool checksEmailNotVerfied(UserModel userModel) {
    try {
      print("CHECKK"+userModel.toString());
      return !userModel.emailVerified;
    } catch (E) {
      return false;
    }
  }

  bool checksDetails(UserModel userModel) {
    print("CHECKK"+userModel.toString());
    if (userModel.birthday.isNotEmpty &&
        userModel.gender.isNotEmpty &&
        userModel.image != 'placeholder_user.png' &&
        userModel.location.isNotEmpty &&
        userModel.selectedInterests != 0) {
      print("CHECKK"+userModel.birthday.isNotEmpty.toString());
      print("CHECKK"+userModel.gender.isNotEmpty.toString());
      return false;
    } else{
      print("CHECKK"+userModel.birthday.isNotEmpty.toString());
      return true;
    }

  }

  authUsersFacebook(BuildContext context) async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      final userData = await FacebookAuth.instance.getUserData();
      return userData;
    }
  }
}
*/
