import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/constants/apis_urls.dart';
import 'package:nearby_buddy_app/constants/image_paths.dart';
import 'package:nearby_buddy_app/helper/shared_preferences.dart';
import 'package:nearby_buddy_app/helper/utils.dart';
import 'package:nearby_buddy_app/routes/api_service.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/home/notification_screen.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/myProfile/components/about_us_screen.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/myProfile/components/report_issue_screen.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/myProfile/components/settings_screen.dart';

import '../../../../components/custom_dialogs.dart';
import '../../../../components/custom_snack_bars.dart';
import '../../../../constants/colors.dart';
import '../../../../models/interest_chip_model.dart';
import '../../../../models/user_model.dart';

import '../../../registration/login_screen.dart';
import 'components/edit_profile_screen.dart';
import 'components/my_friends_screen.dart';

class MyProfileScreen extends StatefulWidget {
  UserModel userModel;
  List<InterestChipModel> myInterestList;
  Function onDataChanged;
  MyProfileScreen(
      {Key? key,
      required this.userModel,
      required this.myInterestList,
      required this.onDataChanged})
      : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  int myFriends = 0;
  @override
  void initState() {
    getFriendNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
              fontSize: 18, color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: ListView(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl:
                        "${ApiUrls.usersImageUrl}/${widget.userModel.image}",
                    width: 150,
                    height: 150,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) =>
                        Image.asset(ImagesPaths.placeholderImage),
                    fadeInDuration: const Duration(milliseconds: 500),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                "${widget.userModel.name}, ${Utils().calculateAge(widget.userModel.birthday)}",
                style: TextStyle(
                    color: kBlack, fontWeight: FontWeight.w600, fontSize: 24),
              ),
            ),
            Center(
              child: SelectableText(
                "@${widget.userModel.username}",
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 15),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            _buildListTile(
                title: 'My Profile',
                iconData: FontAwesomeIcons.user,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                              userModel: widget.userModel,
                              myInterestList: widget.myInterestList,
                              onUpdate: _updateData,
                            )),
                  );
                  widget.onDataChanged();
                }),
            Divider(
              color: kGreyDark,
            ),
            _buildListTile(
                title: 'My Friends',
                showSubText:myFriends>0,
                iconData: FontAwesomeIcons.handshake,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => MyFriendsScreen(
                              userModel: widget.userModel,
                              myInterestList: widget.myInterestList,
                            )),
                  );
                  await getFriendNumber();
                  widget.onDataChanged();
                }),
            Divider(
              color: kGreyDark,
            ),
            _buildListTile(
              title: 'Notifications',
              iconData: FontAwesomeIcons.bell,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (c) =>
                        NotificationScreen(loggedInUser: widget.userModel)));
              },
            ),
            Divider(
              color: kGreyDark,
            ),
            _buildListTile(
                title: 'Settings',
                iconData: FontAwesomeIcons.gears,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                }),
            Divider(
              color: kGreyDark,
            ),
            _buildListTile(
                title: 'About us',
                iconData: FontAwesomeIcons.info,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AboutUsScreen()));
                }),
            Divider(
              color: kGreyDark,
            ),
            _buildListTile(
                title: 'Report an Issue',
                iconData: FontAwesomeIcons.triangleExclamation,
                onTap: () {
                  Log.log("text");
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ReportIssueScreen(
                            loggedInUser: widget.userModel,
                          )));
                }),
            Divider(
              color: kGreyDark,
            ),
            _buildListTile(
                title: 'Log out',
                iconData: FontAwesomeIcons.arrowRightFromBracket,
                onTap: () {
                  CustomDialogs.showAppDialog(
                      context: context,
                      message:
                          "Are you sure you want to Logout of this account?",
                      buttonLabel1: "Logout",
                      callbackMethod1: () async {
                        CustomDialogs.showLoadingAnimation(context);
                        bool loggedOut = await SharedPrefs()
                            .eraseData(SharedPrefs().PREFS_LOGIN_USER_DATA);
                        if (loggedOut) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                            return const LoginScreen();
                          }));
                        } else {
                          CustomSnackBar.showErrorSnackBar(context,
                              "Something went wrong. Please try again");
                        }
                      },
                      buttonLabel2: "Cancel",
                      callbackMethod2: () {
                        Navigator.of(context).pop();
                      });
                }),
          ],
        ),
      ),
    );
  }

  _updateData(UserModel userModel) {
    setState(() {
      widget.userModel = userModel;
    });
  }

  _buildListTile({
    required String title,
    required IconData iconData,
    required VoidCallback onTap,
    bool showSubText = false,
    String? iconSvg,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          /*    Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 20, 5),
            child: Icon(
              iconData,
              color: kPrimaryColor,
            ),
          ),*/
          iconSvg == null
              ? IconButton(
                  icon: Icon(
                    iconData,
                    size: 20,
                    color: kPrimaryColor,
                  ),
                  onPressed: onTap,
                )
              : InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: SvgPicture.asset(
                      iconSvg, // Replace with your SVG file path
                      width: 24,
                      height: 24,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: kBlack, fontWeight: FontWeight.w500, fontSize: 15),
                ),
                showSubText
                    ? Container(
                        padding: const EdgeInsets.all(5.0), // Add some padding
                        margin: const EdgeInsets.all(5.0), // Add some margin
                        child: Text(
                          myFriends.toString(),
                          style: const TextStyle(
                            color: Colors.white, // Text color white
                          ),
                          textAlign: TextAlign.center, // Center the text
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor, // Background color red
                          borderRadius:
                              BorderRadius.circular(10.0), // Rounded corners
                          border:
                              Border.all(color: kPrimaryColor), // Red outline
                        ),
                      )
                    : Container(), // Empty container if showSubText is false
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right_outlined,
              size: 20,
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Future<void> getFriendNumber() async {
    myFriends =
        (await ApiService().showFriendList(username: widget.userModel.username))
            .length;
    if (mounted) {
      setState(() {});
    }
  }
}
