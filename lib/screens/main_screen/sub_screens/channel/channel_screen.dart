import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nearby_buddy_app/constants/colors.dart';
import 'package:nearby_buddy_app/models/user_model.dart';

import '../../../../responsive.dart';
import '../../../../models/group_model.dart';
import 'findChannel/find_channels.dart';
import 'myChannel/my_channels.dart';
import 'myChannel/create_group_screen.dart';

class ChannelScreen extends StatefulWidget {
  UserModel loggedInUser; //we get the logged user
  Function(GroupModel)? onChannelItemClick;
  Function()? onCreateItemClick;
  bool isWeb = false;
  String radius;
  String location;

  ChannelScreen(
      {Key? key,
      required this.loggedInUser,
      required this.radius,
      required this.location,
      this.isWeb = false,
      this.onChannelItemClick,
      this.onCreateItemClick})
      : super(key: key);

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; //controller
  bool _showAppBar = false;
  bool isLandMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isLandMode =
        (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipOval(
              child: Material(
                color: kWhiteColor,
                child: InkWell(
                  splashColor: kPrimaryTransparent, // Splash color
                  onTap: () {
                    if (false) {
                      widget.onCreateItemClick!(); // for browser
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateGroupScreen(
                            loggedInUser: widget.loggedInUser,
                          ),
                        ),
                      );
                    }
                  },
                  child: const SizedBox(
                      width: 30,
                      height: 30,
                      child: Icon(
                        FontAwesomeIcons.plus,
                        size: 24,
                        color: Color(0xFF949AB9),
                      )),
                ),
              ),
            ),
          )
        ],
        title: Text(
          "Events",
          style: TextStyle(
              fontSize: 18, color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(
              text: 'My Events',
            ),
          ],
          labelColor: kBlack,
          unselectedLabelColor: kGreyDark,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: kPrimaryColor),
            insets: const EdgeInsets.symmetric(horizontal: 100.0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FindChannelsScreen(
                    loggedInUser: widget.loggedInUser,
                    radius: widget.radius,
                    location: widget.location,
                    onChannelItemClick: (GroupModel groupModel) {
                      widget.onChannelItemClick!(groupModel);
                    },
                  ),
                  MyChannelsScreen(
                    loggedInUser: widget.loggedInUser,
                    onChannelItemClick: (GroupModel groupModel) {
                      widget.onChannelItemClick!(groupModel);
                    },
                    /*onChangeToolbar: () {
                      setState(() {
                        _showAppBar = true;
                      });
                    },*/
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
