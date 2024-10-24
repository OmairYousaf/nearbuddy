// ignore_for_file: unnecessary_import

import 'dart:ui';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/helper/utils.dart';

buildElevatedSocialMediaButton(
    {required String icon,
    required Color backgroundColor,
    required String title,
    required Color textColor,
    required VoidCallback onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0.5),
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              semanticsLabel: 'My SVG Image',
              width: 30,
              height: 30,
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                    color: textColor, fontFamily: 'Roboto', fontSize: 15),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget buildDateFormField({
  required Function() onTap,
  required DateTime date,
  required bool showHint,
  required String hintText,
}) {
  return GestureDetector(
    onTap: () => onTap(),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: kWhiteColor,
          border: Border.all(color: kWhiteColor, width: 1)),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.calendar,
            color: showHint ? const Color(0xFF000000) : const Color(0xFFCCCCCC),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            showHint ? Utils().getDate(date) : 'Your Birthdate',
            style: showHint
                ? const TextStyle(color: Color(0xFF000000), fontSize: 18)
                : const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
          ),
        ],
      ),
    ),
  );
}

TextFormField buildTextIconFormField({
  required BuildContext context,
  required String hint,
  required TextInputType textInputType,
  required TextEditingController textEditingController,
  required double fontSize,
  required IconData icon,
  Function(String)? onChanged,
  double? iconSize,
  int type = 0,
  double radius = 15,
  int? maxLength,
  bool? obscureText,
  Color? iconColor,
  Color? fillColor,
}) {
  return TextFormField(
    obscureText: obscureText ?? false,
    maxLength: maxLength,
    controller: textEditingController,
    textInputAction: TextInputAction.next, // Mov
    keyboardType: textInputType,
    onChanged: onChanged,
    inputFormatters: (type != 0)
        ? <TextInputFormatter>[
            CurrencyTextInputFormatter(
              // locale: 'ko',
              decimalDigits: 0,
              symbol: 'Rs ',
            ),
          ]
        : null,
    decoration: InputDecoration(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      hintText: hint,
      counterText: "",
      prefixIcon: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? const Color(0xFFCCCCCC),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFCCCCCC),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFD4DBE7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: kPrimaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFD4DBE7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      filled: true,
      fillColor: fillColor ?? kWhiteColor,
    ),
  );
}

buildSearchTextField({
  Function(String)? onChanged,
  Widget? suffixIcon,
  required TextEditingController textEditingController,
}) {
  return TextFormField(
    controller: textEditingController,
    textInputAction: TextInputAction.next, // Mov
    keyboardType: TextInputType.text,
    onChanged: onChanged,

    decoration: InputDecoration(
      suffixIcon: suffixIcon,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      hintText: "Search via username",
      counterText: "",
      prefixIcon: const Icon(
        FontAwesomeIcons.magnifyingGlass,
        color: Color(0xFFCCCCCC),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFCCCCCC),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFF7F7F7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFF7F7F7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFF7F7F7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
    ),
  );
}

buildTextIconButton({
  required String label,
  required Widget icon,
  required VoidCallback onPressed,
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  return TextButton.icon(
    onPressed: onPressed,
    icon: icon,
    label: Text(label),
    style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
  );
}

TextFormField buildTextAreaIconButton({
  required BuildContext context,
  required String hint,
  required TextEditingController textEditingController,
  required IconData icon,
  Color? iconColor,
  Color? fillColor,
  int? maxLines,
  int? minLines,
  Function(String)? onChanged,
}) {
  return TextFormField(
    obscureText: false,
    keyboardType: TextInputType.multiline,
    minLines: minLines,
    maxLines: maxLines,
    onChanged: onChanged,
    controller: textEditingController,
    decoration: InputDecoration(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      hintText: hint,
      counterText: "",
      prefix: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      prefixIcon: null, // Remove the default prefixIcon
      hintStyle: const TextStyle(
        color: Color(0xFFCCCCCC),
        fontWeight: FontWeight.w400,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFD4DBE7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: kPrimaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFD4DBE7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      fillColor: fillColor ?? kWhiteColor,
    ),
  );
}

buildPasswordTextForm({
  required TextEditingController passwordController,
  required bool flagVisibility,
  required VoidCallback onPressed,
}) {
  return Container(
    decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: TextField(
      controller: passwordController,
      obscureText: !flagVisibility,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: 'Password',
        hintText: 'Enter your password',
        suffixIcon: IconButton(
            icon: Icon(
              flagVisibility
                  ? FontAwesomeIcons.solidEye
                  : FontAwesomeIcons.solidEyeSlash,
            ),
            onPressed: onPressed),
      ),
    ),
  );
}

buildEmailTextForm({
  required TextEditingController emailController,
}) {
  return Container(
    decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        border: InputBorder.none,
        labelText: 'Email',
        hintText: 'Enter your email address',
      ),
    ),
  );
}
