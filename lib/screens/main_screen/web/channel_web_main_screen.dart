import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_buddy_app/models/group_model.dart';
import 'package:nearby_buddy_app/screens/main_screen/sub_screens/channel/channel_screen.dart';

import '../../../models/user_model.dart';
import '../../../responsive.dart';

class ChannelWebMainScreen extends StatefulWidget {
  UserModel loggedInUser; //we get the logged user
  String radius;
  String location;
  ChannelWebMainScreen(
      {Key? key, required this.loggedInUser, required this.location, required this.radius})
      : super(key: key);

  @override
  State<ChannelWebMainScreen> createState() => _ChannelWebMainScreenState();
}

class _ChannelWebMainScreenState extends State<ChannelWebMainScreen> {
  bool isLandMode = false;
  bool showSidePanel = false;
  bool showChatScreen = false;
  bool isWeb = false;
  GroupModel groupModel = GroupModel();
  @override
  void initState() {
    isLandMode = (kIsWeb && !Responsive.isMobile() && !Responsive.isMobileWeb());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        build(context);
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: MediaQuery.of(context).size.width > 600 //set your width threshold here
            ? ChannelScreen(
                loggedInUser: widget.loggedInUser,
                radius: widget.radius,
                location: widget.location,
                isWeb: MediaQuery.of(context).size.width > 600,
                onChannelItemClick: (GroupModel groupModel) {
                  this.groupModel = groupModel;
                  setState(() {
                    showChatScreen = true;
                    showSidePanel = false;
                  });
                },
                onCreateItemClick: () {
                  setState(() {
                    showSidePanel = !showSidePanel;
                    showChatScreen = false;
                  });
                })
            : ChannelScreen(
                loggedInUser: widget.loggedInUser,
                radius: widget.radius,
                location: widget.location,
              ),
      ),
    );
  }
}
