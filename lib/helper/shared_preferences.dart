import 'dart:convert';

import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/interest_chip_model.dart';

class SharedPrefs {



  final String PREFS_NAME_ONBOARD = "ONBOARDING";
  final String PREFS_LOGIN_USER_DATA = "LOGIN";
  final String PREFS_NAME_ISLOGGED = "ISLOGGED";
  final String PREFS_NAME_INTEREST_CHIPS = "interestChips";

  Future<dynamic> getValue(key) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userPref = prefs.getString(key);

      return jsonDecode(userPref!);
    } catch (e) {
      Log.log(e.toString());
      return "";
    }
  }


  Future<bool> hasValue(key) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userPref = prefs.getString(key);

      return userPref?.isNotEmpty ?? false;
    } catch (e) {
      Log.log(e.toString());
      return false;
    }
  }

  Future<bool> saveValue(String key, dynamic information) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      bool result = await prefs.setString(key, information.toString());
      if (result) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Log.log(e.toString());
      return false;
    }
  }

  // Save the Person object to shared preferences
  Future<bool> saveToSharedPreferences(String key, dynamic jsonCodedData) async {
    final prefs = await SharedPreferences.getInstance();


    try {
      await prefs.setString(key, jsonCodedData);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Load the Person object from shared preferences
  static Future<dynamic> loadFromSharedPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);
    if (json != null) {
      final map = jsonDecode(json);
      return map; //call FromJson
    }
    return null;
  }

  Future<bool> eraseData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      bool result = await prefs.clear();
      Log.log(result.toString());
      return result;
    } else {
      return false;
    }
  }

  // Function to store a list of InterestChipModel objects in shared preferences
  Future<void> saveInterestChips(List<InterestChipModel> chips) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedChips = chips.map((chip) => jsonEncode(chip.toMap())).toList();
    await prefs.setStringList(PREFS_NAME_INTEREST_CHIPS, encodedChips);
  }

// Function to retrieve a list of InterestChipModel objects from shared preferences
  Future<List<InterestChipModel>> loadInterestChips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedChips = prefs.getStringList(PREFS_NAME_INTEREST_CHIPS) ?? [];
    List<InterestChipModel> chips = [];
    for (String encodedChip in encodedChips) {
      try {
        Map<String, dynamic> chipMap = jsonDecode(encodedChip);
        InterestChipModel chip = InterestChipModel.fromMap(chipMap);
        chips.add(chip);
      } catch (e) {
        Log.log(e.toString());
      }
    }
    return chips;
  }
}
