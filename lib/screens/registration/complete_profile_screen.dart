import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nearby_buddy_app/components/custom_dialogs.dart';
import 'package:nearby_buddy_app/components/custom_snack_bars.dart';
import 'package:nearby_buddy_app/constants/image_paths.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import 'package:nearby_buddy_app/screens/registration/verify_otp_screen.dart';

import '../../constants/colors.dart';
import '../../helper/shared_preferences.dart';
import '../../helper/utils.dart';
import '../../models/interest_chip_model.dart';
import '../../models/user_model.dart';
import '../main_screen/main_screen.dart';
import 'components/interest_information_component.dart';
import 'components/location_information_componenet.dart';
import 'components/personal_information_component.dart';
import 'components/portfolio_information_component.dart';

class CompleteProfileScreen extends StatefulWidget {
  String? email;
  String? name;
  String? password;
  LoginType? loginType;

  CompleteProfileScreen({Key? key, this.email, this.name, this.password, this.loginType})
      : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  double _progressValue = 0;
  int counter = 0;
  PersonalData personalData = PersonalData(
      fullname: "",
      bioData: '',
      selectedInterests: [],
      birthdate: DateTime.now(),
      gender: '',
      imageName: '',
      listofPhotos: [],
      webListPhotos: [],
      latitude: '',
      longitude: '');

  bool isMale = false;
  bool isFemale = false;
  TextEditingController fullnameController = TextEditingController();
  TextEditingController bioTxtController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<Widget> screenList = [];
  final DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 18));
  _intit() async {
    if (kIsWeb) {
      await Hive.openBox(Utils().databaseName);
      Box box = Hive.box(Utils().databaseName);
      widget.name = box.get("name");
      widget.password = box.get("password");
      widget.email = box.get("email")!;
      widget.loginType = box.get("loginType") == LoginType.google.name
          ? LoginType.google
          : box.get("loginType") == LoginType.facebook.name
              ? LoginType.facebook
              : box.get("loginType") == LoginType.manual.name
                  ? LoginType.manual
                  : box.get("loginType") == LoginType.apple.name
                      ? LoginType.apple
                      : LoginType
                          .manual; // Set a default value or handle the case where none of the conditions match
      fullnameController.text = widget.name ?? "";
    }
  }

  @override
  void initState() {
    super.initState();
    screenList.add(
      PersonalInformation(
        personalData: personalData,
        fullnameController: fullnameController,
        bioTxtCntrl: bioTxtController,
      ),
    );
    screenList.add(
      LocationInformation(
        personalData: personalData,
        addressController: addressController,
      ),
    );
    screenList.add(
      PortfolioInformation(
        personalData: personalData,
      ),
    );
    screenList.add(
      InterestInformation(
        personalData: personalData,
      ),
    );
    _intit();
  }

  @override
  void dispose() {
    bioTxtController.dispose();
    fullnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Disable resizing to avoid the bottom insets

      floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 10, 20),
          child: Row(
            children: [
              (counter == 0) ? const SizedBox() : _buildBackFABButton(),
              const Expanded(child: SizedBox()),
              _buildNextFABButton()
            ],
          )),
      body: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          build(context);
          return false;
        },
        child: SizeChangedLayoutNotifier(
          child: Container(
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
                _buildBackground(),
                _buildLogo(),
                MediaQuery.of(context).size.width < 600 //set your width threshold here
                    ? Center(child: SingleChildScrollView(child: screenList[counter]))
                    : Center(
                        child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 100,horizontal: 250.0),
                        child: SingleChildScrollView(child: screenList[counter]),
                      )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _buildProgressIndicator(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildBackground() {
    return Align(
      alignment: Alignment.topLeft,
      child: Image.asset(ImagesPaths.bubble1),
    );
  }

  _buildLogo() {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            ImagesPaths.lightLogo,
            width: 100,
            height: 100,
          ),
        ));
  }

  _buildNextFABButton() {
    return FloatingActionButton(
      heroTag: 'fab_$counter',
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (counter != (screenList.length - 1) && (checkInformation())) {
          counter++;
          _progressValue += (100 / screenList.length) / 100;
          setState(() {});
        } else {
          if (checkInformation()) {
            if (counter == screenList.length - 1) {
              _progressValue += (100 / screenList.length) / 100;
              setState(() {});
              _register();
            }
          }
          // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MainScreen()));
        }
      },
      child: const Icon(FontAwesomeIcons.arrowRight),
    );
  }

  _buildBackFABButton() {
    return FloatingActionButton(
      heroTag: 'backfab_$counter',
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (counter != 0) {
          counter--;
          _progressValue -= (100 / screenList.length) / 100;
          setState(() {});
        }
      },
      child: const Icon(FontAwesomeIcons.arrowLeft),
    );
  }

  _buildProgressIndicator() {
    return SizedBox(
      height: 10,
      child: LinearProgressIndicator(
        value: _progressValue, // The value should be between 0.0 and 1.0
        backgroundColor: const Color(0xFFE1E1E1), // Set the background color
        valueColor:
            const AlwaysStoppedAnimation<Color>(Color(0xFF9453BC)), // Set the foreground color
      ),
    );
  }

  bool checkInformation() {
    personalData.fullname = fullnameController.text;
    personalData.bioData = bioTxtController.text;
    if (fullnameController.text.isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, "Please enter your name");
      return false;
    } else if (bioTxtController.text.isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, "Please enter your bio");
      return false;
    } else if (personalData.gender.isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, "Please select a gender");
      return false;
    } else if (personalData.birthdate.year == DateTime.now().year) {
      CustomSnackBar.showErrorSnackBar(context, "Please enter a valid date");
      return false;
    }
    if (counter == 1 && (personalData.longitude.isEmpty || personalData.latitude.isEmpty)) {
      CustomSnackBar.showErrorSnackBar(context, "We need to get your location");
      return false;
    }
    if (personalData.profilePhoto == null && counter == 2) {
      CustomSnackBar.showErrorSnackBar(context, "Profile Image is Mandatory");
      return false;
    }

    if (counter == 3 && personalData.selectedInterests.length < 3) {
      CustomSnackBar.showErrorSnackBar(context, "Select at least 3 interests");

      return false;
    }
    return true;
  }

  Future<void> _register() async {
    CustomDialogs.showLoadingAnimation(context);
    bool result = await ApiService().registerUser(
      email: widget.email!,
      password: widget.password!,
      passwordType: widget.loginType!,
      osType: OS.android,
      name: fullnameController.text,
    );

    if (result) {
      UserModel tempUserData = UserModel.fromJson(await SharedPrefs.loadFromSharedPreferences(
          SharedPrefs().PREFS_LOGIN_USER_DATA)); //SAVING USER FOR TEMP CASE
      bool result = await ApiService().updateProfile(
          name: fullnameController.text,
          selectedInterests: getSelectedInterests(),
          bio: personalData.bioData,
          profilePath: kIsWeb
              ? personalData.webProfilePhoto!.path.split('/').last
              : personalData.profilePhoto!.path.split('/').last,
          birthday: DateFormat('dd-MM-yyyy').format(personalData.birthdate),
          location: '${personalData.latitude},${personalData.longitude}',
          gender: personalData.gender,
          username: tempUserData.username,
          profileImageFile: kIsWeb ? personalData.webProfilePhoto! : personalData.profilePhoto!,
          photos: kIsWeb ? personalData.webListPhotos : personalData.listofPhotos);

      UserModel returnedUser = UserModel.fromJson(
          await SharedPrefs.loadFromSharedPreferences(SharedPrefs().PREFS_LOGIN_USER_DATA));

      if (result) {
        Navigator.pop(context);
        if (widget.loginType == LoginType.manual) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => VerifyOTPScreen(
                      email: widget.email!,
                      user: returnedUser,
                    )),
          );
        } else {
          bool result = await SharedPrefs()
              .saveToSharedPreferences(SharedPrefs().PREFS_NAME_ISLOGGED, true.toString());
          Log.log("${result}Logged");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen(userModel: returnedUser)),
          );
        }
      } else {
        Navigator.pop(context);
        CustomSnackBar.showErrorSnackBar(context, "Error while signing up");
      }
    } else {
      Navigator.pop(context);
      CustomSnackBar.showErrorSnackBar(context, "Error while signing up");
    }
  }

  getSelectedInterests() {
    String selectedInterests = "";
    for (InterestChipModel interests in personalData.selectedInterests) {
      selectedInterests += "${interests.catID},";
    }

// Remove the last comma
    selectedInterests = selectedInterests.substring(0, selectedInterests.length - 1);
    return selectedInterests;
  }
}

class PersonalData {
  String fullname;
  String bioData;
  DateTime birthdate;
  String gender;
  String imageName;
  String latitude;
  String longitude;
  List<File> listofPhotos;
  List<XFile> webListPhotos;
  File? profilePhoto;
  XFile? webProfilePhoto;
  List<InterestChipModel> selectedInterests;

  PersonalData(
      {required this.fullname,
      required this.bioData,
      required this.birthdate,
      required this.gender,
      required this.imageName,
      required this.selectedInterests,
      required this.latitude,
      this.profilePhoto,
      required this.listofPhotos,
      required this.webListPhotos,
      this.webProfilePhoto,
      required this.longitude});

  @override
  String toString() {
    return 'PersonalData{fullname: $fullname, bioData: $bioData, birthdate: $birthdate, gender: $gender, imageName: $imageName, latitude: $latitude, longitude: $longitude, listofPhotos: $listofPhotos, webListPhotos: $webListPhotos, profilePhoto: $profilePhoto, webProfilePhoto: $webProfilePhoto, selectedInterests: $selectedInterests}';
  }
}
