import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

enum ImageSourceType { gallery, camera }
/*
* Types:

chat
request
member_added
create_event
add_schedule
splash
*
* */
enum ScreenType {splash,chat,request,memberAdded,createEvent,addSchedule,none}
class Log {
  static log(text) {
    if (kDebugMode) {
      debugPrint("NEARBY BUDDY Debugging\t $text");
    }
  }
}

class Utils {
  final ImagePicker _picker = ImagePicker();
  final String databaseName='NEARBY_BUDDY_HIVE';
  final String googleAPIKey = "AIzaSyC2SymOz9YCTFRoSwluB3xqrRibb-Nmf70";
  int calculateAge(String dateString) {
try{
  DateTime now = DateTime.now();
  List<String> dateParts = dateString.split("-");
  DateTime dob =
  DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
  int age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}catch(e){
  Log.log("COULDNT CALCULATE AGE PLEASE CHECK BIRTHDAY ${dateString}");
  return 0;
}
  }

  Future getImageFromGallery({bool allowCrop=false}) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery,     imageQuality: 100,);
    return kIsWeb ? pickedFile! : _cropImage(File(pickedFile!.path),allowCrop);
  }

  Future getImageFromCamera({bool allowCrop=false}) async {
    if(kIsWeb){
      //write the code here

    }
    else {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      return _cropImage(File(pickedFile!.path),allowCrop);
    }
    //return kIsWeb ? File(pickedFile!.path) : _cropImage(File(pickedFile!.path),allowCrop);
  }

  Future<File?> _cropImage(File imageFile,bool allowResize) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        maxHeight:allowResize?1500: 600,
        maxWidth: allowResize?1500: 600,
        compressFormat: ImageCompressFormat.png,
        aspectRatioPresets: [
          CropAspectRatioPreset.square
        ],
        //   aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: kBlack,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: !allowResize),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ]);
    return File(croppedFile!.path);
  }

  String getDate(DateTime selectedDate) {
    // String date = "${selectedDate.toLocal()}".split(' ')[0];
    String date = DateFormat('d MMM, yyyy').format(selectedDate);

    return date;
  }

  Future<DateTime> pickDate(DateTime selectedDate, BuildContext context) async {
    DateTime now = DateTime.now();

    DateTime lastDate = DateTime(now.year - 18, 12, 31);
    DateTime initialDate = DateTime(now.year - 18, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 10000000)),
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      DateTime selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
      );
      return selectedDate;
    } else {
      return DateTime.now();
    }
  }

  Future<void> openUrl(String url) async {
    Uri url0 = Uri.parse(url);
    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }







  String formatOnlineTime(String onlineTime) {
    try {
      // Initialize time zone data
      // Parse the online time string
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime onlineDateTime = dateFormat.parse(onlineTime,true);

      // Convert to local time zone (already done in the original code)
      onlineDateTime = onlineDateTime.toLocal();

      // Calculate the duration
      Duration duration = DateTime.now().difference(onlineDateTime);

      Log.log("The onlinetime is ${onlineTime} and the converted time ${onlineDateTime} and duration ${duration.inHours}");
      if (duration.inDays >= 365) {
        int years = (duration.inDays / 365).floor();
        return '$years y${years > 1 ? '' : ''}';
      } else if (duration.inDays >= 30) {
        int months = (duration.inDays / 30).floor();
        return '${months} mon${months > 1 ? '' : ''}';
      } else if (duration.inDays >= 1) {
        return '${duration.inDays} d${duration.inDays > 1 ? '' : ''}';
      } else if (duration.inHours >= 1) {
        return '${duration.inHours}h${duration.inHours > 1 ? '' : ''}';
      } else if (duration.inMinutes >= 1) {
        return '${duration.inMinutes} min${duration.inMinutes > 1 ? '' : ''}';
      } else {
        return 'moments ago';
      }
    } catch (e) {
      // If an error occurs during parsing, return the original string
      Log.log(e);
      return onlineTime;
    }
  }
}

class FileConverter {
  static String getBase64FormateFile(String? path) {
    File file = File(path!);
    List<int> fileInByte = file.readAsBytesSync();
    String fileInBase64 = base64Encode(fileInByte);
    return fileInBase64;
  }
}
