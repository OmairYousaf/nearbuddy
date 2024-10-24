import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/connect/connect_screen.dart';
import 'package:nearby_buddy_app/screens/main_screen/web/channel_web_main_screen.dart';

import 'package:nearby_buddy_app/screens/main_screen/web/home_screen_web.dart';
import 'package:side_navigation/side_navigation.dart';
import '../../../components/custom_dialogs.dart';
import '../../../components/custom_snack_bars.dart';
import '../../../constants/apis_urls.dart';
import '../../../constants/image_paths.dart';
import '../../../helper/shared_preferences.dart';
import '../../../helper/utils.dart';
import '../../../models/interest_chip_model.dart';
import '../../../models/user_model.dart';
import '../../../routes/api_service.dart';
import '../sub_screens/myProfile/components/about_us_screen.dart';
import '../sub_screens/myProfile/components/edit_profile_screen.dart';
import '../sub_screens/myProfile/components/report_issue_screen.dart';
import '../sub_screens/myProfile/components/settings_screen.dart';
import 'chat_web_main_screen.dart';

class MainScreenWeb extends StatefulWidget {
  const MainScreenWeb({super.key});

  @override
  State<MainScreenWeb> createState() => _MainScreenWebState();
}

class _MainScreenWebState extends State<MainScreenWeb> {
  UserModel loggedInUser = UserModel.empty();
  bool isLoaded = false;
  double newLat = 43.2994;
  double distance = 10;
  double newLong = 74.2179;
  List<InterestChipModel> interestList = [];
  List<InterestChipModel> fullInterestList = [];
  List<Widget> views = [];
  bool _permissionGranted = false;

  /// The currently selected index of the bar
  int selectedIndexDashboard = 0;
  late BitmapDescriptor customIcon;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    views.clear();
  if (isLoaded) {
    setState(() {
      views.add(HomeScreenWeb(
        interestList: interestList,
        fullInterestList: fullInterestList,
        longitude: newLong,
        latitude: newLat,
        loggedInUser: loggedInUser,
        distance: distance,
        customIcon: customIcon,
        updateDistance: (double distance) {
          this.distance = distance;
          setState(() {
            Log.log("Change in  distance $distance");
          });
        },
      ));
      views.add(ConnectScreen(userModel: loggedInUser, fullInterestList: fullInterestList, updateDistance: updateDistance, distance: distance, latitude: newLat, longitude: newLong));
      views.add(ChatWebMainScreen(loggedInUser: loggedInUser, myInterestList: interestList));
      views.add(ChannelWebMainScreen(loggedInUser: loggedInUser,radius: distance.toString(),location: '${newLat},${newLong}',));
      views.add(EditProfileScreen(
        userModel: loggedInUser,
        myInterestList: interestList,
        onUpdate: _updateData,
      ));
      views.add(const SettingsScreen());
      views.add(const AboutUsScreen());
      views.add(ReportIssueScreen(loggedInUser: loggedInUser,));


    });
  }

    return Scaffold(
      body: isLoaded
          ? _buildMainScreen()
          : const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
    );
  }
  _updateData(UserModel userModel) {
    setState(() {
      loggedInUser = userModel;
    });
  }

  Widget _buildMainScreen() {
    return Row(
      children: [
        SideNavigationBar(
          expandable: false,
          initiallyExpanded: false,
          header: SideNavigationBarHeader(
              image: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: "${ApiUrls.usersImageUrl}/${loggedInUser.image}",
                    width: 50,
                    height: 50,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Image.asset(ImagesPaths.placeholderImage),
                    fadeInDuration: const Duration(milliseconds: 500),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                loggedInUser.name,
                style: TextStyle(color: kBlack, fontWeight: FontWeight.w600, fontSize: 18),
              ),
              subtitle: Text(loggedInUser.username)),
          footer: SideNavigationBarFooter(
              label: Text(
            'Nearby Buddy',
            style: TextStyle(color: kGrey, fontWeight: FontWeight.w600, fontSize: 18),
          )),
          selectedIndex: selectedIndexDashboard,
          items: const [
            SideNavigationBarItem(
              icon: FontAwesomeIcons.house,
              label: 'Home',
            ),
            SideNavigationBarItem(
              icon: FontAwesomeIcons.heart,
              label: 'Connect',
            ),
            SideNavigationBarItem(icon: FontAwesomeIcons.comments, label: "Chat"),
            SideNavigationBarItem(icon: FontAwesomeIcons.hashtag, label: "Events"),
            SideNavigationBarItem(icon: FontAwesomeIcons.user, label: "Edit Profile"),
            SideNavigationBarItem(icon: FontAwesomeIcons.gears, label: "Settings"),
            SideNavigationBarItem(icon:  FontAwesomeIcons.info,label: "About us"),
            SideNavigationBarItem(icon:  FontAwesomeIcons.triangleExclamation,label: "Report an Issue"),
            SideNavigationBarItem(icon:  FontAwesomeIcons.arrowRightFromBracket,label: "Log out"),
          ],
          onTap: (index) {
            setState(() {
              if(index!=8) {
                selectedIndexDashboard = index;
              }else{
                CustomDialogs.showAppDialog(
                    context: context,
                    message:
                    "Are you sure you want to Logout of this account?",
                    buttonLabel1: "Logout",
                    callbackMethod1: () async {
                      CustomDialogs.showLoadingAnimation(context);
                      bool loggedOut = await SharedPrefs().eraseData(
                          SharedPrefs().PREFS_LOGIN_USER_DATA);
                      if (loggedOut) {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/login',);
                      } else {
                        CustomSnackBar.showErrorSnackBar(context,
                            "Something went wrong. Please try again");
                      }
                    },
                    buttonLabel2: "Cancel",
                    callbackMethod2: () {
                      Navigator.of(context).pop();
                    });
              }
            });
          },
          theme: SideNavigationBarTheme(
            backgroundColor: const Color(0xFFF8F8F8),
            itemTheme: SideNavigationBarItemTheme(
              unselectedItemColor: const Color(0xFF6C6C6C),
              selectedItemColor: kPrimaryColor,
              iconSize: 16,
            ),
            togglerTheme: SideNavigationBarTogglerTheme.standard(),
            dividerTheme: SideNavigationBarDividerTheme.standard(),
          ),
        ),
        Expanded(
          child: views.elementAt(selectedIndexDashboard),
        )
      ],
    );
  }

  getUserFromHive() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(20, 20)), ImagesPaths.locationPin);

    loggedInUser = UserModel.fromJson(
        await SharedPrefs.loadFromSharedPreferences(SharedPrefs().PREFS_LOGIN_USER_DATA));
    Log.log(loggedInUser);
  }

  Future<void> _getInterest() async {
    List<String> idList = loggedInUser.selectedInterests.split(",").map((id) => id).toList();

    fullInterestList = await ApiService().getInterests();

    for (String id in idList) {
      for (InterestChipModel interest in fullInterestList) {
        if (interest.catID == id) {
          interestList.add(interest);
          break; // Exit the inner loop once a match is found
        }
      }
    }
  }

  void _loadData() async {

    await getUserFromHive();
    await _getLocation();
    await _getInterest();
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> _getLocation() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied || status == LocationPermission.deniedForever) {
      // Ask for permission
      status = await Geolocator.requestPermission();
      if (status == LocationPermission.denied || status == LocationPermission.deniedForever) {
        setState(() {
          _permissionGranted = false;
        });
      } else {
        _permissionGranted = true;

        var position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation);
        setState(() {
          newLat = position.latitude;
          newLong = position.longitude;

          Log.log(newLat);
        });
      }
    } else if (status == LocationPermission.whileInUse || status == LocationPermission.always) {
      _permissionGranted = true;

      var position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      setState(() {
        newLat = position.latitude;
        newLong = position.longitude;

        Log.log(newLat);
      });
    }
  }

  void updateDistance(double radius) {
    distance = radius;
    setState(() {
      Log.log("Change in  distance $distance");
    });
  }
}
