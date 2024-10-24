import 'package:flutter/material.dart';

import '../../constants/image_paths.dart';
import '../../responsive.dart';
import '../../routes/api_service.dart';
import 'components/login_btn_widget.dart';

class LoginScreenWeb extends StatelessWidget {
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
  final imagesPaths;
  final imageIndex;
  const LoginScreenWeb(
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
        required this.onForwardBtnClick,
        required this.imagesPaths,
        required this.imageIndex,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  _buildWebBackground();
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
            colorFilter:
            const ColorFilter.mode(Color(0xFF794776), BlendMode.multiply),
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: const AssetImage(ImagesPaths.land1),
              image: AssetImage(imagesPaths[imageIndex]),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: isSmallerView?EdgeInsets.zero:const EdgeInsets.symmetric(horizontal: 400),
            child:  SingleChildScrollView(
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
          ),
        ),
      ],
    );
  }


}
