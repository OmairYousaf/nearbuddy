import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/apis_urls.dart';
import 'package:nearby_buddy_app/screens/registration/components/social_media_btns.dart';

import '../../../constants/colors.dart';
import '../../../constants/icon_paths.dart';
import '../../../constants/image_paths.dart';
import '../../../helper/utils.dart';
import '../../../routes/api_service.dart';

class LoginBtnWidget extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final bool showPasswordField;
  final bool hidePassword;
  final Function()? togglePasswordVisibility;
  final String labelText;
  final TextEditingController passwordController;
  final Function(LoginType) onSocialMediaBtnClick;
  final VoidCallback onForwardBtnClick;

  const LoginBtnWidget(
      {Key? key,

        required this.emailController,
        required this.isLoading,
        required this.showPasswordField,
        required this.hidePassword,
        required this.togglePasswordVisibility,
        required this.labelText,
        required this.passwordController,
        required this.onSocialMediaBtnClick,
        required this.onForwardBtnClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, kIsWeb ? (showPasswordField ? 100 : 200) : 100, 0, 0),
      child: Column(
        children: [

          Image.asset(
            ImagesPaths.lightLogo,
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
            padding:
            const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            margin:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                      blurRadius: 25,
                      color: Color(0x33B6B6B6),
                      offset: Offset(0, -8))
                ],
                color: kWhiteColor,
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8F8F8),
                    hintText: 'Email',
                    enabledBorder: const OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderSide:
                      BorderSide(color: Color(0xFFF8F8F8), width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: IconButton(
                        color: kWhiteColor,
                        icon: isLoading
                            ? SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            color: kWhiteColor,
                            strokeWidth: 1,
                          ),
                        )
                            : const Icon(Icons.arrow_forward),
                        onPressed:onForwardBtnClick ,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: showPasswordField,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          hintText: 'Password',
                          enabledBorder: const OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(
                                color: Color(0xFFF8F8F8), width: 0.0),
                          ),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          onSocialMediaBtnClick(LoginType.manual);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(labelText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
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
                          style: TextStyle(
                            fontSize: 12.0,
                            color: kGreyDark,
                          ),
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
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SocialMediaButton(
                        onPressed: () {
                          onSocialMediaBtnClick( LoginType.google);
                        },
                        iconPath: IconPaths.googleIcon,
                        backgroundColor: const Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SocialMediaButton(
                        onPressed: () {
                          onSocialMediaBtnClick( LoginType.facebook);
                        },
                        iconPath: IconPaths.facebookIcon,
                        backgroundColor: const Color(0xFF1877F2),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SocialMediaButton(
                        onPressed: () {
                          onSocialMediaBtnClick( LoginType.apple);
                        },
                        iconPath: IconPaths.appleIcon,
                        backgroundColor: const Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11),
                    children: [
                      const TextSpan(
                        text:
                        'Data collected during signup process will not be used for any commercial purposes. Read our',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text: ' Privacy Policy',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                          await Utils().openUrl(ApiUrls.urlPrivacyPolicy);
                          },
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,

                            decoration: TextDecoration.underline),
                      ),
                      const TextSpan(
                        text: ' and ',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),

                      ),
                      TextSpan(
                        text: 'Terms and Conditions.',
                          recognizer: TapGestureRecognizer()
                            ..onTap =  () async {
                              await Utils().openUrl(ApiUrls.urlTermsCondition);
                            },
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
      ),
    );
  }
}
