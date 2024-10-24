import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/helper/shared_preferences.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../constants/colors.dart';
import '../../constants/image_paths.dart';
import '../../helper/utils.dart';
import '../../models/user_model.dart';
import '../main_screen/main_screen.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String email;
  final UserModel user;
   const VerifyOTPScreen({Key? key, required this.email,required this.user }) : super(key: key);

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  bool _isResendEnabled = false;
  int _resendSeconds = 30;
  late Timer _resendTimer;

  @override
  void initState() {
    super.initState();

    // Send OTP when the screen loads
    sendOTP();

    // Start timer for resending OTP after 30 seconds
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    super.dispose();
  }

  Future<void> sendOTP() async {
    bool result=await ApiService().sendOTP(widget.email);
    if(!result){
      sendOTP();
    }
  }

  Future<void> verifyOTP(otp) async {
    bool result=await ApiService().verifyOTP(email: widget.email,otp: otp);
    if(result){
      CustomSnackBar.showSuccessSnackBar(context, "Verified!");
      Navigator.of(context).pop();
      bool result=  await SharedPrefs().saveToSharedPreferences(
          SharedPrefs().PREFS_NAME_ISLOGGED, true.toString());
      Log.log("${result}Logged");
      if (kIsWeb) {
        Box box = Hive.box(Utils().databaseName);
        box.put("user", widget.user.toJson());

        Navigator.pushNamed(context, '/mainpage',);
      }else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(userModel: widget.user),
          ),
        );
      }
    }else{
      CustomSnackBar.showErrorSnackBar(context, "Invalid OTP!");
      Navigator.of(context).pop();
    }
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
        /*  if (_resendAttempts > 0) {
            _isResendEnabled = true;
            _resendAttempts--;
            _resendSeconds = 30;
          } else {
            _isResendEnabled = false;
            timer.cancel();
          }*/
          _isResendEnabled=true;
        }
      });
    });
  }

  void _resendOTP() {
    if (_isResendEnabled) {
      sendOTP();
      setState(() {
        _isResendEnabled = false;
        _resendSeconds = 30;
      });
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: Stack(
          children: [

            Container(

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
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                constraints: kIsWeb ? BoxConstraints(maxWidth: 800) : null, // Add constraints for web layout


                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: kIsWeb?CrossAxisAlignment.center:CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      ImagesPaths.lightLogo,
                      width: 150,
                      height: 100,
                    ),
                    const SizedBox(height: 20,),
                    Text("OTP Verification",style: TextStyle(color: kWhiteColor,fontSize: 22,fontWeight: FontWeight.bold),),
                    Text("We have sent an OTP on your email ${widget.email}",style: TextStyle(color: kWhiteColor,fontSize: 15,fontWeight: FontWeight.w300),),
                    const SizedBox(height: 20,),
                    PinCodeTextField(
                      appContext: context,
                      mainAxisAlignment:kIsWeb? MainAxisAlignment.spaceEvenly:MainAxisAlignment.spaceBetween,
                      pastedTextStyle:  TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,

                      obscureText: true,
                      obscuringCharacter:'●',
                      blinkWhenObscuring: true,
                      animationType: AnimationType.fade,
                      validator: (v) {
                        return null;

                        // if (v!.length < 3) {
                        //   return "I'm from validator";
                        // } else {
                        //   return null;
                        // }
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius:kIsWeb?BorderRadius.circular(5): BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 50,
                        activeColor: kPrimaryColor,
                        inactiveColor: kWhiteColor,
                        selectedColor: kWhiteColor,
                        selectedFillColor: kWhiteColor,
                        inactiveFillColor: kWhiteColor,
                        activeFillColor: kWhiteColor,
                      ),
                      cursorColor: kBlackLight,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      keyboardType: TextInputType.number,
                      boxShadows:  const [

                      ],
                      onCompleted: (v) {
                        CustomDialogs.showLoadingAnimation(context);
                        verifyOTP(v);
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                      beforeTextPaste: (text) {
                        return true;
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: (){
                          _resendOTP();
                        }, child: Text("Resend",style: TextStyle(color:_isResendEnabled ? Colors.white : kPrimaryColor, ),)),
                        Expanded(child: SizedBox()),
                        Text((_resendSeconds<10)?'00:0$_resendSeconds':'00:$_resendSeconds',style: TextStyle(color: kWhiteColor, ),)
                      ],
                    ),
                    const SizedBox(height: 100,),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
