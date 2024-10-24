import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SocialMediaButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final   Color backgroundColor;
   const SocialMediaButton({Key? key, required this.onPressed,required this.iconPath, required this.backgroundColor}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
          backgroundColor: backgroundColor,
          elevation: 0.2),
      onPressed: onPressed,
      child: SvgPicture.asset(
        iconPath,
        semanticsLabel: 'My SVG Image',
        width: 30,
        height: 30,
      ),
    );
  }
}
