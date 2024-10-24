import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/constants/colors.dart';





class CustomSnackBar {
  static void showBasicSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(

      content: Text(
        message,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      backgroundColor: kPrimaryLight,
      margin: const EdgeInsets.only(bottom: 10),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()

      ..showSnackBar(snackBar);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      backgroundColor: kErrorColor,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
  static void showWarnSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      backgroundColor: kPrimaryLight,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
  static void showSuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            message,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      backgroundColor: kSuccessColor,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showActionSnackBar(
      {required BuildContext context,
      required String message,
      required Color backgroundColor,
      required VoidCallback onPressed}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      backgroundColor: backgroundColor,
      action: SnackBarAction(
        label: "Update",
        onPressed: onPressed,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
