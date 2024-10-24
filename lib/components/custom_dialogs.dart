import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nearby_buddy_app/constants/colors.dart';

import '../constants/lottie_paths.dart';
import '../responsive.dart';
import 'controls.dart';

class CustomDialogs {
  static Future<String?> showTextInputDialog(
      {required BuildContext context,
      required String message,
      int? maxLines,
      required String initialText,
      required String buttonLabel1,
      required Function callbackMethod1,
      required String buttonLabel2,
      required Function callbackMethod2}) async {
    String? result = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          // Set contentPadding to control padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 35,
                color: kPrimaryColor,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: "Urbanist",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                initialValue: initialText, // pass the initial value here
                autofocus: true,
                maxLines: maxLines,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onChanged: (value) {
                  result = value;
                },
                decoration: const InputDecoration(
                  hintText: 'e.g. John Doe',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0))),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 24.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () => callbackMethod1(),
                        child: Text(
                          buttonLabel1.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontFamily: "Barlow",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: kWhiteColor,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () => callbackMethod2(),
                        child: Text(
                          buttonLabel2.toUpperCase(),
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontFamily: "Barlow",
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
    return result;
  }

  static Future<String?> showDropDown({
    required BuildContext context,
    required String message,
    required String buttonLabel1,
    required List<String> dropdownValues,
    required Function(String?) callbackMethod1,
    required String buttonLabel2,
    required Function() callbackMethod2,
    String? selectedOption,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontFamily: "Urbanist",
                  ),
                ),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none,
                    ),
                    value: selectedOption,
                    onChanged: (newValue) {
                      selectedOption = newValue;
                    },
                    items: dropdownValues
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 24.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            callbackMethod1(selectedOption);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            buttonLabel1.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontFamily: "Barlow",
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: kWhiteColor,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            callbackMethod2();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            buttonLabel2.toUpperCase(),
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontFamily: "Barlow",
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        });
      },
    );
    return selectedOption;
  }

  static Future<DateTime?> showDatePickerDialog(BuildContext context) async {
    DateTime? selectedDate = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');

    return showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      Expanded(
                        child: CalendarDatePicker(
                          initialDate: selectedDate!,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          onDateChanged: (DateTime newDate) {
                            setState(() {
                              selectedDate = newDate;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: formatter.format(selectedDate!)),
                          decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate!,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (picked != null &&
                                      picked != selectedDate) {
                                    setState(() {
                                      selectedDate = picked;
                                    });
                                  }
                                },
                                child: const Icon(Icons.calendar_today),
                              ),
                              border: const OutlineInputBorder(),
                              labelText: 'Date'),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context, selectedDate);
                              },
                              child: const Text(
                                'Okay',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context, null);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  static showLoadingDialog({required BuildContext context, String text = ""}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: kWhiteColor,
            elevation: 24.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            content: Wrap(
              children: [
                Lottie.asset(LottieFiles.animationLoading),
                // ignore: unnecessary_string_interpolations
                (text.isNotEmpty) ? Text('$text') : const SizedBox(),
              ],
            ),
          )),
    );
  }

  static showTextDialog(
      {required BuildContext context,
      required String message,
      required String buttonLabel1,
      required TextEditingController sendTextController,
      required Function callbackMethod1,
      required String buttonLabel2,
      required Function callbackMethod2}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        // Set contentPadding to control padding
        content: Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              buildTextAreaIconButton(
                  context: context,
                  fillColor: const Color(0xffF7F7F7),
                  hint: "A simple short message",
                  onChanged: (v) {},
                  iconColor: const Color(0xFFCCCCCC),
                  textEditingController: sendTextController,
                  icon: FontAwesomeIcons.smile),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            child: SizedBox(
              width:
                  Responsive.isWeb() ? null : MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => callbackMethod1(),
                      child: Text(
                        buttonLabel1.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: "Barlow",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: kWhiteColor,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => callbackMethod2(),
                      child: Text(
                        buttonLabel2.toUpperCase(),
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontFamily: "Barlow",
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  static showAppDialog({
    required BuildContext context,
    required String message,
    Widget? title,
    required String buttonLabel1,
    required Function callbackMethod1,
    required String buttonLabel2,
    required Function callbackMethod2,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        // Set contentPadding to control padding
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) title,
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
            const SizedBox(height: 10), // Add some spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => callbackMethod1(),
                    child: Text(
                      buttonLabel1.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontFamily: "Barlow",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => callbackMethod2(),
                    child: Text(
                      buttonLabel2.toUpperCase(),
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontFamily: "Barlow",
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        actions: const [],
      ),
    );
  }

  static showSingleBtnAppDialog({
    required BuildContext context,
    required String message,
    required Widget title,
    required String buttonLabel1,
    required Function callbackMethod1,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontFamily: "Montserrat",
            ),
          ),
        ),
        title: title,
        backgroundColor: Colors.white,
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: kWhiteColor,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => callbackMethod1(),
                      child: Text(
                        buttonLabel1.toUpperCase(),
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontFamily: "Barlow",
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  static showLoadingAnimation(BuildContext context) {
    showDialog(
        barrierDismissible: true,
        barrierColor: Colors.white54,
        context: context,
        builder: (BuildContext context) => WillPopScope(
              onWillPop: () async => true,
              child: (Responsive.isWeb())
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: kPrimaryColor,
                      ),
                    )
                  : SizedBox(
                      width: 200,
                      height: 200,
                      child: Lottie.asset(
                        LottieFiles.animationLoading,
                        frameRate: FrameRate.max,
                      ),
                    ),
            ));
  }
}
