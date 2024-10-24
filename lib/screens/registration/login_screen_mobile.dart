import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import 'package:nearby_buddy_app/screens/registration/components/login_btn_widget.dart';

import '../../constants/colors.dart';
import '../../constants/image_paths.dart';

class LoginScreenMobile extends StatelessWidget {
  final VoidCallback snapOutKeyboard;
  final TextEditingController emailController;
  final bool isLoading;
  final bool showPasswordField;
  final bool hidePassword;
  final Function()? togglePasswordVisibility;
  final String labelText;
  final TextEditingController passwordController;
  final Function(LoginType) onSocialMediaBtnClick;
  final VoidCallback onForwardBtnClick;

  const LoginScreenMobile(
      {Key? key,
      required this.snapOutKeyboard,
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
    return _buildMobileBackground();
  }

  _buildMobileBackground() {
    return GestureDetector(
      onTap: () => snapOutKeyboard(),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(flex: kIsWeb?2:1, child: _buildDecoration()),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20.0),
                )),
              ],
            ),
            SingleChildScrollView(
              child: Align(
                alignment: Alignment.center,
                child: LoginBtnWidget(
                    emailController: emailController,
                    isLoading: isLoading,
                    showPasswordField: showPasswordField,
                    hidePassword: hidePassword,
                    togglePasswordVisibility: togglePasswordVisibility,
                    labelText: labelText,
                    passwordController: passwordController,
                    onSocialMediaBtnClick: onSocialMediaBtnClick,
                    onForwardBtnClick: onForwardBtnClick),
              ),
            )
          ],
        ),
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
                child: Image.asset(ImagesPaths.bubble1)),
            Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(ImagesPaths.bubble2)),
          ],
        ));
  }
}
